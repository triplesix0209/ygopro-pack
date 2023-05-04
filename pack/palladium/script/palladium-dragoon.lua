-- The Palladium Dragoon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785, CARD_BLUEEYES_W_DRAGON}
s.material_setcode = {0x13a, 0xdd}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, 71703785, {CARD_BLUEEYES_W_DRAGON, s.fusfilter})

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st) end)
    c:RegisterEffect(splimit)

    -- indes & untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1b:SetValue(aux.tgoval)
    c:RegisterEffect(e1b)

    -- negate
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_CHAINING)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- register effect
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.e4con)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    local e4mat = Effect.CreateEffect(c)
    e4mat:SetType(EFFECT_TYPE_SINGLE)
    e4mat:SetCode(EFFECT_MATERIAL_CHECK)
    e4mat:SetValue(s.e4check)
    e4mat:SetLabelObject(e4)
    c:RegisterEffect(e4mat)
end

function s.fusfilter(c, fc, sumtype, tp) return c:IsRace(RACE_DRAGON, fc, sumtype, tp) and c:IsType(TYPE_EFFECT, fc, sumtype, tp) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return rc ~= c and Duel.IsChainNegatable(ev)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end

    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Destroy(eg, REASON_EFFECT) end
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ct1 = Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    local ct2 = Duel.GetMatchingGroupCount(Card.IsSpellTrap, tp, 0, LOCATION_ONFIELD, nil)
    if chk == 0 then return ct1 > 0 or ct2 > 0 end

    if (ct1 > ct2 and ct2 ~= 0) or ct1 == 0 then ct1 = ct2 end
    if ct1 ~= 0 then
        local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, ct1, 0, 0)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g1 = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    local g2 = Duel.GetMatchingGroup(Card.IsSpellTrap, tp, 0, LOCATION_ONFIELD, nil)
    if #g1 == 0 and #g2 == 0 then return end

    if #g1 == 0 then
        Duel.Destroy(g2, REASON_EFFECT)
    elseif #g2 == 0 then
        Duel.Destroy(g1, REASON_EFFECT)
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
        local opt = Duel.SelectOption(tp, aux.Stringid(id, 2), aux.Stringid(id, 3))
        if opt == 0 then
            Duel.Destroy(g1, REASON_EFFECT)
        else
            Duel.Destroy(g2, REASON_EFFECT)
        end
    end
end

function s.e4check(e, c)
    local g = c:GetMaterial()
    local ct = g:FilterCount(Card.IsType, nil, TYPE_NORMAL)
    e:GetLabelObject():SetLabel(ct)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel() > 0
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:RegisterFlagEffect(id, RESET_EVENT + (RESETS_STANDARD & ~RESET_TURN_SET), EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 4))

    -- atk up
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetCode(EVENT_DESTROYED)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCondition(s.e4effcon)
    ec1:SetOperation(s.e4effop)
    ec1:SetReset(RESET_EVENT + (RESETS_STANDARD & ~RESET_TURN_SET))
    c:RegisterEffect(ec1)
end

function s.e4effcon(e, tp, eg, ep, ev, re, r, rp) return (r & REASON_EFFECT) ~= 0 and re and re:GetOwner() == e:GetHandler() end

function s.e4effop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if #eg > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(#eg * 500)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(ec1)
    end
end
