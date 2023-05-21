-- Supreme King Dragon Zarc
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_SUPREME_KING_DRAGON}
s.miracle_synchro_fusion = true

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- fusion summon
    Fusion.AddProcMix(c, true, true, s.fusfilter1, s.fusfilter2, s.fusfilter3, s.fusfilter4)

    -- rank/level
    local ranklevel = Effect.CreateEffect(c)
    ranklevel:SetType(EFFECT_TYPE_SINGLE)
    ranklevel:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    ranklevel:SetCode(EFFECT_RANK_LEVEL_S)
    c:RegisterEffect(ranklevel)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_FUSION) == SUMMON_TYPE_FUSION or (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
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

    -- act limit
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    pe1:SetCode(EFFECT_CANNOT_ACTIVATE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(0, 1)
    pe1:SetValue(s.pe1val)
    c:RegisterEffect(pe1)

    -- special summon from pendulum zone
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(2)
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1, id)
    pe2:SetCost(s.pe2cost)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

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

    -- control cannot be changed 
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    me2:SetRange(LOCATION_MZONE)
    c:RegisterEffect(me2)

    -- battle position cannot be changed
    local me3 = Effect.CreateEffect(c)
    me3:SetType(EFFECT_TYPE_SINGLE)
    me3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me3:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    me3:SetRange(LOCATION_MZONE)
    c:RegisterEffect(me3)

    -- cannot be tributed, nor be used as a material
    local me4 = Effect.CreateEffect(c)
    me4:SetType(EFFECT_TYPE_FIELD)
    me4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    me4:SetCode(EFFECT_CANNOT_RELEASE)
    me4:SetRange(LOCATION_MZONE)
    me4:SetTargetRange(0, 1)
    me4:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(me4)
    local me4b = Effect.CreateEffect(c)
    me4b:SetType(EFFECT_TYPE_SINGLE)
    me4b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    me4b:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(me4b)

    -- indes, untargetable, unbanishable
    local me5 = Effect.CreateEffect(c)
    me5:SetType(EFFECT_TYPE_SINGLE)
    me5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    me5:SetRange(LOCATION_MZONE)
    me5:SetValue(1)
    c:RegisterEffect(me5)
    local me5b = me5:Clone()
    me5b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    me5b:SetValue(function(e, re, rp) return rp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(me5b)
    local me5c = me5:Clone()
    me5c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    me5c:SetValue(aux.tgoval)
    c:RegisterEffect(me5c)
    local me5d = Effect.CreateEffect(c)
    me5d:SetType(EFFECT_TYPE_FIELD)
    me5d:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    me5d:SetCode(EFFECT_CANNOT_REMOVE)
    me5d:SetRange(LOCATION_MZONE)
    me5d:SetTargetRange(1, 1)
    me5d:SetTarget(function(e, tc, rp, r, re)
        local tp = e:GetHandlerPlayer()
        return tc == e:GetHandler() and rp == 1 - tp and r == REASON_EFFECT
    end)
    c:RegisterEffect(me5d)

    local me5d = me5c:Clone()
    me5d:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(me5d)

    -- unaffected by activated effects
    local me6 = Effect.CreateEffect(c)
    me6:SetType(EFFECT_TYPE_FIELD)
    me6:SetCode(EFFECT_IMMUNE_EFFECT)
    me6:SetRange(LOCATION_MZONE)
    me6:SetTargetRange(LOCATION_MZONE, 0)
    me6:SetValue(s.me6val)
    c:RegisterEffect(me6)

    -- destroy added card
    local me7 = Effect.CreateEffect(c)
    me7:SetDescription(aux.Stringid(id, 1))
    me7:SetCategory(CATEGORY_DESTROY + CATEGORY_DISABLE)
    me7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me7:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    me7:SetCode(EVENT_TO_HAND)
    me7:SetRange(LOCATION_MZONE)
    me7:SetCountLimit(1)
    me7:SetCondition(s.me7con)
    me7:SetTarget(s.me7tg)
    me7:SetOperation(s.me7op)
    c:RegisterEffect(me7)

    -- summon dragon
    local me8 = Effect.CreateEffect(c)
    me8:SetDescription(aux.Stringid(id, 2))
    me8:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me8:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me8:SetCode(EVENT_BATTLE_DESTROYING)
    me8:SetCondition(aux.bdocon)
    me8:SetTarget(s.me8tg)
    me8:SetOperation(s.me8op)
    c:RegisterEffect(me8)

    -- place into pendulum zone
    local me9 = Effect.CreateEffect(c)
    me9:SetDescription(2203)
    me9:SetCategory(CATEGORY_DESTROY)
    me9:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me9:SetProperty(EFFECT_FLAG_DELAY)
    me9:SetCode(EVENT_DESTROYED)
    me9:SetCondition(s.me9con)
    me9:SetTarget(s.me9tg)
    me9:SetOperation(s.me9op)
    c:RegisterEffect(me9)
end

function s.fusfilter1(c, fc, sumtype, tp) return c:IsRace(RACE_DRAGON, fc, sumtype, tp) and c:IsType(TYPE_FUSION, fc, sumtype, tp) end

function s.fusfilter2(c, fc, sumtype, tp) return c:IsRace(RACE_DRAGON, fc, sumtype, tp) and c:IsType(TYPE_SYNCHRO, fc, sumtype, tp) end

function s.fusfilter3(c, fc, sumtype, tp) return c:IsRace(RACE_DRAGON, fc, sumtype, tp) and c:IsType(TYPE_XYZ, fc, sumtype, tp) end

function s.fusfilter4(c, fc, sumtype, tp) return c:IsRace(RACE_DRAGON, fc, sumtype, tp) and c:IsType(TYPE_PENDULUM, fc, sumtype, tp) end

function s.pe1val(e, re, rp)
    local rc = re:GetHandler()
    return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and rc:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
end

function s.pe2filter(c, ft, tp)
    return c:IsSetCard(SET_SUPREME_KING_DRAGON) and (ft > 0 or (c:IsControler(tp) and c:GetSequence() < 5)) and (c:IsControler(tp) or c:IsFaceup())
end

function s.pe2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, s.pe2filter, 1, false, nil, nil, ft, tp) end
    local g = Duel.SelectReleaseGroupCost(tp, s.pe2filter, 1, 1, false, nil, nil, ft, tp)
    Duel.Release(g, REASON_COST)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
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

function s.me6val(e, te)
    local tp = e:GetHandlerPlayer()
    local tc = te:GetOwner()
    return te:GetOwnerPlayer() ~= tp and te:IsMonsterEffect() and te:IsActivated() and te:IsActiveType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
end

function s.me7filter(c, tp) return c:IsControler(1 - tp) and c:IsPreviousLocation(LOCATION_DECK) end

function s.me7con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() ~= PHASE_DRAW end

function s.me7tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = eg:Filter(s.me7filter, nil, tp)
    if chk == 0 then return #g > 0 end
    e:SetLabelObject(g)
    g:KeepAlive()

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetChainLimit(s.me7chainlimit)
end

function s.me7chainlimit(e, lp, tp)
    local g = e:GetLabelObject()
    return g and not g:IsContains(e:GetHandler())
end

function s.me7op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = e:GetLabelObject()
    if not c:IsRelateToEffect(e) then
        g:DeleteGroup()
        return
    end

    if Duel.Destroy(g, REASON_EFFECT) > 0 then
        local dg = Duel.GetOperatedGroup()
        for tc in dg:Iter() do
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_DISABLE)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
            tc:RegisterEffect(ec1)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(ec1b)
        end
    end
    g:DeleteGroup()
end

function s.me8filter(c, e, tp)
    if not c:IsSetCard(SET_SUPREME_KING_DRAGON) or not c:IsCanBeSpecialSummoned(e, 0, tp, true, false) then return false end
    if c:IsLocation(LOCATION_EXTRA) then
        local g = Duel.GetMatchingGroup(nil, tp, LOCATION_MZONE, 0, nil)
        return Duel.GetLocationCountFromEx(tp, tp, g, c) > 0
    else
        return Duel.GetMZoneCount(tp) > 0
    end
end

function s.me8tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA
    if chk == 0 then return Duel.IsExistingMatchingCard(s.me8filter, tp, loc, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.me8op(e, tp, eg, ep, ev, re, r, rp)
    local ft1 = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local ft2 = Duel.GetLocationCountFromEx(tp)
    local ft3 = Duel.GetLocationCountFromEx(tp, tp, nil, TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
    local ft4 = Duel.GetLocationCountFromEx(tp, tp, nil, TYPE_PENDULUM + TYPE_LINK)
    local ft = math.min(Duel.GetUsableMZoneCount(tp), 2)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
        if ft1 > 0 then ft1 = 1 end
        if ft2 > 0 then ft2 = 1 end
        if ft3 > 0 then ft3 = 1 end
        if ft4 > 0 then ft4 = 1 end
        ft = 1
    end

    local ect = aux.CheckSummonGate(tp)
    if ect then
        ft1 = math.min(ect, ft1)
        ft2 = math.min(ect, ft2)
        ft3 = math.min(ect, ft3)
        ft4 = math.min(ect, ft4)
    end

    local loc = 0
    if ft1 > 0 then loc = loc + LOCATION_HAND + LOCATION_DECK end
    if ft2 > 0 or ft3 > 0 or ft4 > 0 then loc = loc + LOCATION_EXTRA end
    if loc == 0 then return end

    local sg = Duel.GetMatchingGroup(s.me8filter, tp, loc, 0, nil, e, tp)
    if #sg == 0 then return end
    local sg = aux.SelectUnselectGroup(sg, e, tp, 1, ft, s.me8rescon(ft1, ft2, ft3, ft4, ft), 1, tp, HINTMSG_SPSUMMON)
    Duel.SpecialSummon(sg, 0, tp, tp, true, false, POS_FACEUP)

    local og = Duel.GetOperatedGroup()
    for sc in og:Iter() do sc:CompleteProcedure() end
end

function s.me8exfilter1(c) return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ) end
function s.me8exfilter2(c) return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM))) end
function s.me8rescon(ft1, ft2, ft3, ft4, ft)
    return function(sg, e, tp, mg)
        local exnpct = sg:FilterCount(s.me8exfilter1, nil, LOCATION_EXTRA)
        local expct = sg:FilterCount(s.me8exfilter2, nil, LOCATION_EXTRA)
        local mct = sg:FilterCount(aux.NOT(Card.IsLocation), nil, LOCATION_EXTRA)
        local exct = sg:FilterCount(Card.IsLocation, nil, LOCATION_EXTRA)
        local groupcount = #sg
        local res = ft3 >= exnpct and ft4 >= expct and ft1 >= mct and ft >= groupcount
        return res, not res
    end
end

function s.me9con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.me9tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if #g > 0 then Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0) end
end

function s.me9op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
        Duel.BreakEffect()
    end
    Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end
