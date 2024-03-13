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

    -- cannot be tributed, be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(nomaterial)

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- place counter (synchro summoned)
    local counter1 = Effect.CreateEffect(c)
    counter1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    counter1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    counter1:SetCode(EVENT_SPSUMMON_SUCCESS)
    counter1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
    counter1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local ct = s.max_counter(e)
        if ct > 0 then c:AddCounter(DuelDragon.COUNTER_COSMIC, ct) end
    end)
    c:RegisterEffect(counter1)

    -- place counter (end phase)
    local counter2 = Effect.CreateEffect(c)
    counter2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    counter2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    counter2:SetCode(EVENT_PHASE + PHASE_END)
    counter2:SetRange(LOCATION_MZONE)
    counter2:SetCountLimit(1)
    counter2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return c:IsFaceup() and c:GetCounter(DuelDragon.COUNTER_COSMIC) < s.max_counter(e)
    end)
    counter2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local ct = s.max_counter(e) - c:GetCounter(DuelDragon.COUNTER_COSMIC)
        c:AddCounter(DuelDragon.COUNTER_COSMIC, ct)
    end)
    c:RegisterEffect(counter2)

    -- negate effect (battle)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e1b)

    -- chain attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- negate effect (activate)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCondition(s.e4con)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.max_counter(e)
    return e:GetHandler():GetMaterial():FilterCount(function(c) return c:IsOriginalRace(RACE_DRAGON) and c:IsOriginalType(TYPE_SYNCHRO) end, nil)
end

function s.e1con(e) return (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL) and e:GetHandler():GetBattleTarget() end

function s.e1tg(e, c) return c == e:GetHandler():GetBattleTarget() end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetAttacker() == e:GetHandler() end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsCanRemoveCounter(tp, DuelDragon.COUNTER_COSMIC, 1, REASON_EFFECT) or not c:CanChainAttack(0) or
        not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then return end

    c:RemoveCounter(tp, DuelDragon.COUNTER_COSMIC, 1, REASON_EFFECT)
    Duel.ChainAttack()
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return e ~= re and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsCanRemoveCounter(tp, DuelDragon.COUNTER_COSMIC, 1, REASON_COST) end
    c:RemoveCounter(tp, DuelDragon.COUNTER_COSMIC, 1, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local rc = re:GetHandler()

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, #eg, 0, 0)
    if rc:IsDestructable() and rc:IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0) end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Destroy(eg, REASON_EFFECT) end
end

function s.e4filter(c, e, tp)
    return c:IsLevelBelow(10) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0 and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e4filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP) then tc:CompleteProcedure() end
end
