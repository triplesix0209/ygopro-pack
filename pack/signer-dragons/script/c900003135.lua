-- Red Dragon Archfiend Calamity Emperor
Duel.LoadScript("util.lua")
local s, id = GetID()

s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 3, 3, Synchro.NonTunerEx(
        function(c, val, sc, sumtype, tp) return c:IsType(TYPE_SYNCHRO, sc, sumtype, tp) end), 1, 1)

    -- double tuner
    local doubletuner = Effect.CreateEffect(c)
    doubletuner:SetType(EFFECT_TYPE_SINGLE)
    doubletuner:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    doubletuner:SetCode(21142671)
    c:RegisterEffect(doubletuner)

    -- negate & act limit
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, c)
        return Duel.GetMatchingGroupCount(Card.IsType, c:GetControler(), LOCATION_GRAVE, 0, nil, TYPE_TUNER) * 500
    end)
    c:RegisterEffect(e2)

    -- indes
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- destroy
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_DESTROY + CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- banish
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 5))
    e5:SetCategory(CATEGORY_REMOVE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e5:SetCondition(s.e5con1)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
    local e5b = e5:Clone()
    e5b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e5b:SetCode(EVENT_ATTACK_ANNOUNCE)
    e5b:SetCondition(s.e5con2)
    c:RegisterEffect(e5b)
    local e5ret = Effect.CreateEffect(c)
    e5ret:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5ret:SetCode(EVENT_PHASE + PHASE_END)
    e5ret:SetRange(LOCATION_REMOVED)
    e5ret:SetCountLimit(1)
    e5ret:SetCondition(s.e5retcon)
    e5ret:SetOperation(s.e5retop)
    c:RegisterEffect(e5ret)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():IsExists(function(mc)
        return mc:IsAttribute(ATTRIBUTE_DARK) and mc:IsRace(RACE_DRAGON) and mc:IsType(TYPE_SYNCHRO)
    end, 1, nil)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec1:SetTargetRange(0, 1)
    ec1:SetValue(function(e, re, tp) return re:GetHandler():IsOnField() or re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_DISABLE)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
        local ec2b = ec2:Clone()
        ec2b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec2b)
    end
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() == PHASE_MAIN1 end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) end

    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT, LOCATION_REMOVED) end

    aux.RegisterClientHint(c, nil, tp, 1, 0, aux.Stringid(id, 3), nil)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetTargetRange(LOCATION_MZONE, 0)
    ec1:SetTarget(function(e, tc) return e:GetLabel() ~= tc:GetFieldID() end)
    ec1:SetLabel(c:GetFieldID())
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e5con1(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() ~= tp and rp == 1 - tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end

function s.e5con2(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() ~= tp and Duel.GetAttacker():GetControler() ~= tp end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToRemove() end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, c, 1, 0, 0)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.Remove(c, POS_FACEUP, REASON_EFFECT) == 0 then return end

    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
    if Duel.GetAttacker() and Duel.GetAttacker():GetControler() ~= tp and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 6)) then
        Duel.NegateAttack()
    else
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_ATTACK_ANNOUNCE)
        ec1:SetRange(LOCATION_REMOVED)
        ec1:SetLabel(0)
        ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            if e:GetLabel() ~= 0 or not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 6)) then return end

            Utility.HintCard(e:GetHandler())
            Duel.NegateAttack()
            e:SetLabel(1)
        end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end

function s.e5retcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:GetFlagEffect(id) > 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e5retop(e, tp, eg, ep, ev, re, r, rp) Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP) end
