-- Supreme Overlord Z-Arc
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x20f8}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 4, 4, s.lnkcheck)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_LINK) == SUMMON_TYPE_LINK or (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(sumsafe)

    -- activation and effect cannot be negated
    local nonegate = Effect.CreateEffect(c)
    nonegate:SetType(EFFECT_TYPE_FIELD)
    nonegate:SetCode(EFFECT_CANNOT_INACTIVATE)
    nonegate:SetRange(LOCATION_MZONE)
    nonegate:SetTargetRange(1, 0)
    nonegate:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(nonegate)
    local nodiseff = nonegate:Clone()
    nodiseff:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(nodiseff)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(nodis)

    -- overscale
    local pensp = Effect.CreateEffect(c)
    pensp:SetType(EFFECT_TYPE_SINGLE)
    pensp:SetCode(511004423)
    c:RegisterEffect(pensp)

    -- change other scale
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetCode(EFFECT_CHANGE_LSCALE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(LOCATION_PZONE, 0)
    pe1:SetTarget(function(e, c) return e:GetHandler() ~= c end)
    pe1:SetValue(0)
    c:RegisterEffect(pe1)
    local pe1b = pe1:Clone()
    pe1b:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(pe1b)

    -- summon dragon (pendulum)
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- destroy all
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 1))
    me1:SetCategory(CATEGORY_DESTROY)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- cannot be Tributed, or be used as a material
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me2:SetCode(EFFECT_UNRELEASABLE_SUM)
    me2:SetRange(LOCATION_MZONE)
    me2:SetValue(1)
    c:RegisterEffect(me2)
    local me2b = me2:Clone()
    me2b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(me2b)
    local me2b = me2:Clone()
    me2b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    c:RegisterEffect(me2b)

    -- control cannot switch
    local me3 = Effect.CreateEffect(c)
    me3:SetType(EFFECT_TYPE_SINGLE)
    me3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me3:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    me3:SetRange(LOCATION_MZONE)
    c:RegisterEffect(me3)

    -- untargetable & indes
    local me4 = Effect.CreateEffect(c)
    me4:SetType(EFFECT_TYPE_SINGLE)
    me4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    me4:SetRange(LOCATION_MZONE)
    me4:SetValue(aux.tgoval)
    c:RegisterEffect(me4)
    local me4b = me4:Clone()
    me4b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    me4b:SetValue(function(e, re, rp) return rp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(me4b)

    -- act limit
    local me5 = Effect.CreateEffect(c)
    me5:SetType(EFFECT_TYPE_FIELD)
    me5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    me5:SetCode(EFFECT_CANNOT_ACTIVATE)
    me5:SetRange(LOCATION_MZONE)
    me5:SetTargetRange(0, 1)
    me5:SetValue(s.me5val)
    c:RegisterEffect(me5)

    -- destroy drawn
    local me6 = Effect.CreateEffect(c)
    me6:SetDescription(aux.Stringid(id, 2))
    me6:SetCategory(CATEGORY_DESTROY)
    me6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me6:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    me6:SetCode(EVENT_TO_HAND)
    me6:SetRange(LOCATION_MZONE)
    me6:SetCountLimit(1)
    me6:SetCondition(s.me6con)
    me6:SetTarget(s.me6tg)
    me6:SetOperation(s.me6op)
    c:RegisterEffect(me6)

    -- summon dragon (monster)
    local me7 = Effect.CreateEffect(c)
    me7:SetDescription(aux.Stringid(id, 0))
    me7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me7:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me7:SetCode(EVENT_BATTLE_DESTROYING)
    me7:SetCondition(aux.bdocon)
    me7:SetTarget(s.me7tg)
    me7:SetOperation(s.me7op)
    c:RegisterEffect(me7)

    -- place to pendulum
    local me8 = Effect.CreateEffect(c)
    me8:SetDescription(2203)
    me8:SetCategory(CATEGORY_DESTROY)
    me8:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me8:SetProperty(EFFECT_FLAG_DELAY)
    me8:SetCode(EVENT_DESTROYED)
    me8:SetCondition(s.me8con)
    me8:SetTarget(s.me8tg)
    me8:SetOperation(s.me8op)
    c:RegisterEffect(me8)
end

function s.lnkcheck(g, sc, sumtype, tp)
    local mg = g:Clone()
    if not g:IsExists(Card.IsType, 1, nil, TYPE_FUSION, sc, sumtype, tp) then return false end
    mg:Remove(Card.IsType, nil, TYPE_FUSION, sc, sumtype, tp)
    if not g:IsExists(Card.IsType, 1, nil, TYPE_SYNCHRO, sc, sumtype, tp) then return false end
    mg:Remove(Card.IsType, nil, TYPE_SYNCHRO, sc, sumtype, tp)
    if not g:IsExists(Card.IsType, 1, nil, TYPE_XYZ, sc, sumtype, tp) then return false end
    mg:Remove(Card.IsType, nil, TYPE_XYZ, sc, sumtype, tp)
    return mg:IsExists(Card.IsType, 1, nil, TYPE_PENDULUM, sc, sumtype, tp)
end

function s.sumtype(c)
    if c:IsType(TYPE_FUSION) then return SUMMON_TYPE_FUSION end
    if c:IsType(TYPE_SYNCHRO) then return SUMMON_TYPE_SYNCHRO end
    if c:IsType(TYPE_XYZ) then return SUMMON_TYPE_XYZ end
    return 0
end

function s.pe2filter(c, e, tp)
    return c:IsFaceup() and c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ) and c:IsRace(RACE_DRAGON) and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local loc = LOCATION_REMOVED + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then return Duel.IsExistingMatchingCard(s.pe2filter, tp, loc, 0, 1, nil, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, loc)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.pe2filter), tp,
        LOCATION_REMOVED + LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if Duel.SpecialSummon(tc, s.sumtype(tc), tp, tp, true, false, POS_FACEUP) > 0 then
        Duel.BreakEffect()
        Duel.Destroy(c, REASON_EFFECT)
    end
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end

function s.me5val(e, re, rp)
    local rc = re:GetHandler()
    return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and rc:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
end

function s.me6filter(c, tp) return c:IsControler(1 - tp) and c:IsPreviousLocation(LOCATION_DECK) end

function s.me6con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() ~= PHASE_DRAW end

function s.me6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = eg:Filter(s.me6filter, nil, tp)
    if chk == 0 then return #g > 0 end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.me6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = eg:Filter(s.me6filter, nil, tp)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end

function s.me7filter(c, e, tp, rp)
    if not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, rp, nil, c) <= 0 then return false end
    return c:IsSetCard(0x20f8) and c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.me7tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then return Duel.IsExistingMatchingCard(s.me7filter, tp, loc, 0, 1, nil, e, tp, rp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.me7op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.me7filter), tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, 1, nil, e, tp, rp):GetFirst()
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP) > 0 then tc:CompleteProcedure() end
end

function s.me8con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.me8tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if #g > 0 then Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0) end
end

function s.me8op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
        Duel.BreakEffect()
    end
    Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end
