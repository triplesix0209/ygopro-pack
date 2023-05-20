-- Supreme King Dragon Goldwurm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_SUPREME_KING_DRAGON}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- cannot target
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    pe1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(LOCATION_MZONE, 0)
    pe1:SetTarget(aux.TargetBoolFunction(Card.IsRace, RACE_DRAGON))
    pe1:SetValue(function(e, re, rp) return re:IsActiveType(TYPE_TRAP) and rp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(pe1)

    -- destroy
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetCategory(CATEGORY_DESTROY)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetCondition(s.pe2con)
    pe2:SetCost(s.pe2cost)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- add to your hand
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 1))
    me1:SetCategory(CATEGORY_TOHAND)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    me1:SetCode(EVENT_SUMMON_SUCCESS)
    me1:SetCountLimit(1, id)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)
    local me1b = me1:Clone()
    me1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(me1b)
    local me1c = me1:Clone()
    me1c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(me1c)

    -- negate attack
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 2))
    me2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me2:SetCode(EVENT_BE_BATTLE_TARGET)
    me2:SetCountLimit(1)
    me2:SetCondition(s.me2con)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_PZONE, 0, 1, e:GetHandler()) end

function s.pe2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    Duel.Destroy(tc, REASON_EFFECT)
end

function s.me1filter(c) return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.me1filter, tp, LOCATION_DECK, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_DECK)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.me1filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.me2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, SET_SUPREME_KING_DRAGON), tp, LOCATION_MZONE, 0, 1, c)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, SET_SUPREME_KING_DRAGON), tp, LOCATION_MZONE, 0, 1, c) then return end
    Duel.NegateAttack()
end
