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

    -- overscale
    local pensp = Effect.CreateEffect(c)
    pensp:SetType(EFFECT_TYPE_SINGLE)
    pensp:SetCode(511004423)
    c:RegisterEffect(pensp)

    -- change other scale
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_CANNOT_DISABLE)
    pe1:SetCode(EFFECT_CHANGE_LSCALE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(LOCATION_PZONE, 0)
    pe1:SetTarget(function(e, c) return e:GetHandler() ~= c end)
    pe1:SetValue(0)
    c:RegisterEffect(pe1)
    local pe1b = pe1:Clone()
    pe1b:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(pe1b)

    -- act limit
    local pe2 = Effect.CreateEffect(c)
    pe2:SetType(EFFECT_TYPE_FIELD)
    pe2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    pe2:SetCode(EFFECT_CANNOT_ACTIVATE)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetTargetRange(0, 1)
    pe2:SetValue(s.pe2val)
    c:RegisterEffect(pe2)

    -- special summon from pendulum zone
    local pe3 = Effect.CreateEffect(c)
    pe3:SetDescription(2)
    pe3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe3:SetType(EFFECT_TYPE_IGNITION)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetCountLimit(1, id)
    pe3:SetCost(s.pe3cost)
    pe3:SetTarget(s.pe3tg)
    pe3:SetOperation(s.pe3op)
    c:RegisterEffect(pe3)

    -- destroy all
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 0))
    me1:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetCost(s.me1cost)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- control cannot switch
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_CANNOT_DISABLE)
    me2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    me2:SetRange(LOCATION_MZONE)
    c:RegisterEffect(me2)

    -- cannot be Tributed, or be used as a material
    local me3 = Effect.CreateEffect(c)
    me3:SetType(EFFECT_TYPE_SINGLE)
    me3:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me3:SetCode(EFFECT_UNRELEASABLE_SUM)
    me3:SetRange(LOCATION_MZONE)
    me3:SetValue(1)
    c:RegisterEffect(me3)
    local me3b = me3:Clone()
    me3b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(me3b)
    local me3b = me3:Clone()
    me3b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    c:RegisterEffect(me3b)

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

    -- unaffected by activated effects
    local me5 = Effect.CreateEffect(c)
    me5:SetType(EFFECT_TYPE_FIELD)
    me5:SetCode(EFFECT_IMMUNE_EFFECT)
    me5:SetRange(LOCATION_MZONE)
    me5:SetTargetRange(LOCATION_MZONE, 0)
    me5:SetTarget(s.me5tg)
    me5:SetValue(s.me5val)
    c:RegisterEffect(me5)

    -- destroy drawn
    local me6 = Effect.CreateEffect(c)
    me6:SetDescription(aux.Stringid(id, 1))
    me6:SetCategory(CATEGORY_DESTROY)
    me6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me6:SetProperty(EFFECT_FLAG_DELAY)
    me6:SetCode(EVENT_TO_HAND)
    me6:SetRange(LOCATION_MZONE)
    me6:SetCondition(s.me6con)
    me6:SetTarget(s.me6tg)
    me6:SetOperation(s.me6op)
    c:RegisterEffect(me6)

    -- summon dragon (monster)
    local me7 = Effect.CreateEffect(c)
    me7:SetDescription(aux.Stringid(id, 2))
    me7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me7:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me7:SetCode(EVENT_BATTLE_DESTROYING)
    me7:SetCondition(aux.bdocon)
    me7:SetTarget(s.me7tg)
    me7:SetOperation(s.me7op)
    c:RegisterEffect(me7)

    -- place into pendulum zone
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

function s.pe2val(e, re, rp)
    local rc = re:GetHandler()
    return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and rc:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
end

function s.pe3filter(c, ft, tp)
    return c:IsSetCard(0x20f8) and (ft > 0 or (c:IsControler(tp) and c:GetSequence() < 5)) and (c:IsControler(tp) or c:IsFaceup())
end

function s.pe3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, s.pe3filter, 1, false, nil, nil, ft, tp) end
    local g = Duel.SelectReleaseGroupCost(tp, s.pe3filter, 1, 1, false, nil, nil, ft, tp)
    Duel.Release(g, REASON_COST)
end

function s.pe3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.pe3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsRelateToEffect(e) then Duel.SpecialSummon(c, 0, tp, tp, true, false, POS_FACEUP) end
end

function s.me1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetAttackAnnouncedCount() == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 0)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    if Duel.Destroy(g, REASON_EFFECT) > 0 then
        local dmg = 0
        local dg = Duel.GetOperatedGroup()
        for tc in dg:Iter() do
            local atk = tc:GetPreviousAttackOnField()
            if atk < 0 then atk = 0 end
            dmg = dmg + atk
        end

        Duel.Damage(1 - tp, dmg, REASON_EFFECT)
    end
end

function s.me5tg(e, tc) return tc:IsFaceup() end

function s.me5val(e, te)
    local tp = e:GetHandlerPlayer()
    local tc = te:GetOwner()
    return te:GetOwnerPlayer() ~= tp and te:IsMonsterEffect() and te:IsActivated() and te:IsActiveType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
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
