-- Majestic Quasar Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_duel_dragon.lua")
local s, id = GetID()

s.counter_list = {DuelDragon.COUNTER_COSMIC}
s.synchro_tuner_required = 1
s.synchro_nt_required = 2

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:EnableCounterPermit(DuelDragon.COUNTER_COSMIC)

    -- synchro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO), 1, 1, Synchro.NonTunerEx(Card.IsType, TYPE_SYNCHRO), 2, 99)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.synlimit)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    spsafe:SetCondition(function(e) return e:GetHandler():GetSummonType() == SUMMON_TYPE_SYNCHRO end)
    c:RegisterEffect(spsafe)

    -- place counter (synchro summoned)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- negate effect (battle)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e2b)

    -- chain attack
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- place counter (end phase)
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_PHASE + PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- negate effect (activate)
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.e5con)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- special summon
    local e6 = Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e6:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e6:SetCode(EVENT_LEAVE_FIELD)
    e6:SetCondition(s.e6con)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.max_counter(e)
    return e:GetHandler():GetMaterial():FilterCount(function(c) return c:IsOriginalRace(RACE_DRAGON) and c:IsOriginalType(TYPE_SYNCHRO) end, nil)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = s.max_counter(e)
    if ct > 0 then c:AddCounter(DuelDragon.COUNTER_COSMIC, ct) end
end

function s.e2con(e) return (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL) and e:GetHandler():GetBattleTarget() end

function s.e2tg(e, c) return c == e:GetHandler():GetBattleTarget() end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetAttacker() == e:GetHandler() end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsCanRemoveCounter(tp, DuelDragon.COUNTER_COSMIC, 1, REASON_EFFECT) or not c:CanChainAttack(0) or
        not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then return end

    c:RemoveCounter(tp, DuelDragon.COUNTER_COSMIC, 1, REASON_EFFECT)
    Duel.ChainAttack()
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsFaceup() and c:GetCounter(DuelDragon.COUNTER_COSMIC) < s.max_counter(e)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = s.max_counter(e) - c:GetCounter(DuelDragon.COUNTER_COSMIC)
    c:AddCounter(DuelDragon.COUNTER_COSMIC, ct)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp) return e ~= re and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsCanRemoveCounter(tp, DuelDragon.COUNTER_COSMIC, 1, REASON_COST) end
    c:RemoveCounter(tp, DuelDragon.COUNTER_COSMIC, 1, REASON_COST)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local rc = re:GetHandler()

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, #eg, 0, 0)
    if rc:IsDestructable() and rc:IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0) end
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Destroy(eg, REASON_EFFECT) end
end

function s.e6filter(c, e, tp)
    return c:IsLevelBelow(10) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0 and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.e6con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e6filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP) then tc:CompleteProcedure() end
end
