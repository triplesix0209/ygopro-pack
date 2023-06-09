-- Overlord Z-ARC
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_DRAGON}
s.miracle_synchro_fusion = true

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- fusion summon
    Fusion.AddProcMix(c, true, true, s.fusfilter(TYPE_FUSION), s.fusfilter(TYPE_SYNCHRO), s.fusfilter(TYPE_XYZ), s.fusfilter(TYPE_PENDULUM))

    -- rank/level
    local ranklevel = Effect.CreateEffect(c)
    ranklevel:SetType(EFFECT_TYPE_SINGLE)
    ranklevel:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    ranklevel:SetCode(EFFECT_RANK_LEVEL_S)
    c:RegisterEffect(ranklevel)

    -- start of duel
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    startup:SetCode(EVENT_STARTUP)
    startup:SetRange(0xff)
    startup:SetOperation(s.startupop)
    Duel.RegisterEffect(startup, 0)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.fuslimit)
    c:RegisterEffect(splimit)

    -- act limit
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    pe1:SetCode(EFFECT_CANNOT_ACTIVATE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(0, 1)
    pe1:SetValue(s.pe1val)
    c:RegisterEffect(pe1)

    -- destroy added card (p-zone)
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetCategory(CATEGORY_DESTROY + CATEGORY_DISABLE)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    pe2:SetCode(EVENT_TO_HAND)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetCondition(s.pe2con)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- destroy & damage
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 1))
    me1:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetCost(s.me1cost)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- untargetable
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    me2:SetRange(LOCATION_MZONE)
    me2:SetValue(aux.tgoval)
    c:RegisterEffect(me2)

    -- unaffected by activated effects
    local me3 = Effect.CreateEffect(c)
    me3:SetType(EFFECT_TYPE_FIELD)
    me3:SetCode(EFFECT_IMMUNE_EFFECT)
    me3:SetRange(LOCATION_MZONE)
    me3:SetTargetRange(LOCATION_MZONE, 0)
    me3:SetValue(s.me3val)
    c:RegisterEffect(me3)

    -- destroy added card (m-zone)
    local me4 = pe2:Clone()
    me4:SetRange(LOCATION_MZONE)
    c:RegisterEffect(me4)

    -- summon dragon
    local me5 = Effect.CreateEffect(c)
    me5:SetDescription(aux.Stringid(id, 2))
    me5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me5:SetCode(EVENT_BATTLE_DESTROYING)
    me5:SetCondition(aux.bdocon)
    me5:SetTarget(s.me5tg)
    me5:SetOperation(s.me5op)
    c:RegisterEffect(me5)

    -- place into pendulum zone
    local me6 = Effect.CreateEffect(c)
    me6:SetDescription(2203)
    me6:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me6:SetCode(EVENT_DESTROYED)
    me6:SetProperty(EFFECT_FLAG_DELAY)
    me6:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
    me6:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me6:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not e:GetHandler():IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end
        Duel.MoveToField(e:GetHandler(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end)
    c:RegisterEffect(me6)
end

function s.fusfilter(type) return function(c, fc, sumtype, tp) return c:IsRace(RACE_DRAGON, fc, sumtype, tp) and c:IsType(type, fc, sumtype, tp) end end

function s.startupfilter(c) return not c:IsCode(CARD_ZARC) and c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ) end

function s.startupop(e)
    local c = e:GetHandler()
    local tp = c:GetOwner()

    local g = Duel.GetMatchingGroup(s.startupfilter, tp, 0xff, 0xff, nil)
    for tc in g:Iter() do
        -- no change control, battle position, material
        local noswitch = Effect.CreateEffect(c)
        noswitch:SetType(EFFECT_TYPE_FIELD)
        noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
        noswitch:SetRange(LOCATION_GRAVE + LOCATION_REMOVED)
        noswitch:SetTargetRange(LOCATION_MZONE, 0)
        noswitch:SetTarget(aux.TargetBoolFunction(aux.FaceupFilter(Card.IsOriginalCodeRule, CARD_ZARC)))
        noswitch:SetValue(1)
        tc:RegisterEffect(noswitch)
        local nochangebp = noswitch:Clone()
        nochangebp:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
        tc:RegisterEffect(nochangebp)
        local nomaterial = noswitch:Clone()
        nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
        tc:RegisterEffect(nomaterial)

        -- indes & no leave, tributed
        local indesbattle = Effect.CreateEffect(c)
        indesbattle:SetType(EFFECT_TYPE_FIELD)
        indesbattle:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        indesbattle:SetRange(LOCATION_GRAVE + LOCATION_REMOVED)
        indesbattle:SetTargetRange(LOCATION_MZONE, 0)
        indesbattle:SetTarget(aux.TargetBoolFunction(aux.FaceupFilter(Card.IsOriginalCodeRule, CARD_ZARC)))
        indesbattle:SetValue(1)
        tc:RegisterEffect(indesbattle)
        local indeseffect = indesbattle:Clone()
        indeseffect:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        indeseffect:SetValue(function(e, re, rp, c) return rp ~= c:GetControler() end)
        tc:RegisterEffect(indeseffect)
        local unreleasable = indeseffect:Clone()
        unreleasable:SetCode(EFFECT_UNRELEASABLE_EFFECT)
        tc:RegisterEffect(unreleasable)
        local noleave = indeseffect:Clone()
        noleave:SetCode(EFFECT_IMMUNE_EFFECT)
        noleave:SetValue(function(e, te, c)
            return te and te:GetHandlerPlayer() ~= c:GetControler() and
                       te:IsHasCategory(CATEGORY_TOHAND + CATEGORY_TODECK + CATEGORY_TOGRAVE + CATEGORY_REMOVE)
        end)
        tc:RegisterEffect(noleave)
        local norelease = indeseffect:Clone()
        norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        norelease:SetCode(EFFECT_CANNOT_RELEASE)
        norelease:SetTargetRange(1, 1)
        norelease:SetTarget(function(e, c, tp) return c:IsFaceup() and c:IsOriginalCodeRule(CARD_ZARC) and not c:IsControler(tp) end)
        tc:RegisterEffect(norelease)
    end
end

function s.pe1val(e, re, rp)
    local rc = re:GetHandler()
    return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and rc:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
end

function s.pe2filter(c, tp) return c:IsControler(1 - tp) and c:IsPreviousLocation(LOCATION_DECK) end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() ~= PHASE_DRAW end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = eg:Filter(s.pe2filter, nil, tp)
    if chk == 0 then return #g > 0 end
    e:SetLabelObject(g)
    g:KeepAlive()

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetChainLimit(s.pe2chainlimit)
end

function s.pe2chainlimit(e, lp, tp)
    local g = e:GetLabelObject()
    return g and not g:IsContains(e:GetHandler())
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = e:GetLabelObject()
    if not c:IsRelateToEffect(e) then
        g:DeleteGroup()
        return
    end

    Duel.Destroy(g, REASON_EFFECT)
    g:DeleteGroup()
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

function s.me3val(e, te)
    local tp = e:GetHandlerPlayer()
    local tc = te:GetOwner()
    return te:GetOwnerPlayer() ~= tp and te:IsMonsterEffect() and te:IsActivated() and te:IsActiveType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
end

function s.me5filter(c, e, tp)
    if not c:IsSetCard(SET_SUPREME_KING_DRAGON) or not c:IsCanBeSpecialSummoned(e, 0, tp, true, false) then return false end
    if c:IsLocation(LOCATION_EXTRA) then
        local g = Duel.GetMatchingGroup(nil, tp, LOCATION_MZONE, 0, nil)
        return Duel.GetLocationCountFromEx(tp, tp, g, c) > 0
    else
        return Duel.GetMZoneCount(tp) > 0
    end
end

function s.me5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA
    if chk == 0 then return Duel.IsExistingMatchingCard(s.me5filter, tp, loc, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.me5op(e, tp, eg, ep, ev, re, r, rp)
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

    local sg = Duel.GetMatchingGroup(s.me5filter, tp, loc, 0, nil, e, tp)
    if #sg == 0 then return end
    local sg = aux.SelectUnselectGroup(sg, e, tp, 1, ft, s.me5rescon(ft1, ft2, ft3, ft4, ft), 1, tp, HINTMSG_SPSUMMON)
    Duel.SpecialSummon(sg, 0, tp, tp, true, false, POS_FACEUP)

    local og = Duel.GetOperatedGroup()
    for sc in og:Iter() do sc:CompleteProcedure() end
end

function s.me5exfilter1(c) return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ) end
function s.me5exfilter2(c) return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM))) end
function s.me5rescon(ft1, ft2, ft3, ft4, ft)
    return function(sg, e, tp, mg)
        local exnpct = sg:FilterCount(s.me5exfilter1, nil, LOCATION_EXTRA)
        local expct = sg:FilterCount(s.me5exfilter2, nil, LOCATION_EXTRA)
        local mct = sg:FilterCount(aux.NOT(Card.IsLocation), nil, LOCATION_EXTRA)
        local exct = sg:FilterCount(Card.IsLocation, nil, LOCATION_EXTRA)
        local groupcount = #sg
        local res = ft3 >= exnpct and ft4 >= expct and ft1 >= mct and ft >= groupcount
        return res, not res
    end
end
