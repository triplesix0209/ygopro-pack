-- Arcana Palladium Joker
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_QUEEN_KNIGHT, CARD_KING_KNIGHT, CARD_JACK_KNIGHT}

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.DoubleSnareValidity(c, LOCATION_MZONE)

    -- fusion summon
    Fusion.AddProcMixN(c, false, false, s.fusfilter, 3)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetLabel(0)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1reg = Effect.CreateEffect(c)
    e1reg:SetType(EFFECT_TYPE_SINGLE)
    e1reg:SetCode(EFFECT_MATERIAL_CHECK)
    e1reg:SetValue(s.e1matcheck)
    e1reg:SetLabelObject(e1)
    c:RegisterEffect(e1reg)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    aux.DoubleSnareValidity(c, LOCATION_MZONE)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- add hand
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.fusfilter(c, fc, sumtype, tp, sub, mg, sg)
    return (not sg or
               not sg:IsExists(function(c, code, fc, sumtype, tp) return c:IsSummonCode(fc, sumtype, tp, code) and not c:IsHasEffect(511002961) end,
            1, c, c:GetCode(fc, sumtype, tp), fc, sumtype, tp)) and c:IsRace(RACE_WARRIOR, fc, sumtype, tp)
end

function s.e1matcheck(e, c)
    local mg = c:GetMaterial()
    if mg:IsExists(Card.IsCode, 1, nil, CARD_QUEEN_KNIGHT) and mg:IsExists(Card.IsCode, 1, nil, CARD_KING_KNIGHT) and mg:IsExists(Card.IsCode, 1, nil, CARD_JACK_KNIGHT) then
        e:GetLabelObject():SetLabel(1)
        local ec0 = Effect.CreateEffect(c)
        ec0:SetDescription(aux.Stringid(id, 0))
        ec0:SetType(EFFECT_TYPE_SINGLE)
        ec0:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec0:SetCode(id)
        ec0:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
        c:RegisterEffect(ec0)
    end
end

function s.e1val(e, te) return e:GetLabel() ~= 0 and te:GetOwnerPlayer() ~= e:GetHandlerPlayer() and te:IsActivated() end

function s.e2filter(c, type) return c:IsType(type) and c:IsDiscardable() end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if re:GetHandler() == c or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    
    return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainDisablable(ev)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local type = (re:GetActiveType() & 0x7)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND, 0, 1, nil, type) end

    Duel.DiscardHand(tp, s.e2filter, 1, 1, REASON_COST + REASON_DISCARD, nil, type)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, #eg, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp) Duel.NegateEffect(ev) end

function s.e3filter1(c, tp)
    local type = c:GetType()
    return type ~= 0 and c:IsDiscardable() and Duel.IsExistingMatchingCard(s.e3filter2, tp, 0, LOCATION_ONFIELD, 1, nil, type)
end

function s.e3filter2(c, type) return c:IsFaceup() and c:IsType(type) end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_HAND, 0, 1, nil, tp) end

    Duel.DiscardHand(tp, s.e3filter1, 1, 1, REASON_COST + REASON_DISCARD, nil, tp)
    local g = Duel.GetOperatedGroup()
    e:SetLabel(g:GetFirst():GetType() & 0x7)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local g = Duel.GetMatchingGroup(s.e3filter2, tp, 0, LOCATION_ONFIELD, nil, e:GetLabel())
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.e3filter2, tp, 0, LOCATION_ONFIELD, nil, e:GetLabel())
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e4filter(c) return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(RACE_WARRIOR) and not c:IsType(TYPE_FUSION) and c:IsAbleToHand() end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsReason(REASON_BATTLE + REASON_EFFECT)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(s.e4filter, tp, LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.e4filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end
