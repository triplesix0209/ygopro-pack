-- Celestial Overlord Odd-Eyes Arc-Ray Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {0xf8}
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

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st) or aux.penlimit(e, se, sp, st)
    end)
    c:RegisterEffect(splimit)

    -- alternate special summon
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_EXTRA)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(sumsafe)

    -- unaffected by opponent's card effects
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    pe1:SetCode(EFFECT_IMMUNE_EFFECT)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetValue(function(e, re) return e:GetOwnerPlayer() == 1 - re:GetOwnerPlayer() end)
    c:RegisterEffect(pe1)

    -- place into pendulum zone (p-zone)
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetType(EFFECT_TYPE_QUICK_O)
    pe2:SetCode(EVENT_FREE_CHAIN)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- special Summon (p-zone)
    local pe3 = Effect.CreateEffect(c)
    pe3:SetDescription(2)
    pe3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TODECK)
    pe3:SetType(EFFECT_TYPE_IGNITION)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetCountLimit(1, id)
    pe3:SetCondition(s.pe3con)
    pe3:SetTarget(s.pe3tg)
    pe3:SetOperation(s.pe3op)
    c:RegisterEffect(pe3)

    -- place into pendulum zone (summon)
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 0))
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetCondition(s.me1con)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- gain effect
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    me2:SetCode(EVENT_ADJUST)
    me2:SetRange(LOCATION_MZONE)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)

    -- place into pendulum zone (destroy)
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(2203)
    me3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me3:SetCode(EVENT_DESTROYED)
    me3:SetProperty(EFFECT_FLAG_DELAY)
    me3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
    me3:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not e:GetHandler():IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end
        Duel.MoveToField(e:GetHandler(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end)
    c:RegisterEffect(me3)
end

function s.fusfilter(type) return function(c, fc, sumtype, tp) return c:IsRace(RACE_DRAGON, fc, sumtype, tp) and c:IsType(type, fc, sumtype, tp) end end

function s.spfilter(c, tp, sc)
    return c:IsCode(CARD_ZARC) and c:IsLevel(12) and c:IsAttribute(ATTRIBUTE_DARK) and Duel.GetLocationCountFromEx(tp, tp, c, sc) > 0
end

function s.spcon(e, c)
    if not c then return true end
    if c:IsFaceup() then return false end
    local tp = c:GetControler()
    return Duel.CheckReleaseGroup(tp, s.spfilter, 1, false, 1, true, c, tp, nil, nil, nil, tp, c)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    local g = Duel.SelectReleaseGroup(tp, s.spfilter, 1, 1, false, true, true, c, tp, nil, false, nil, tp, c)
    if not g then return false end

    g:KeepAlive()
    e:SetLabelObject(g)
    return true
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.Release(g, REASON_COST | REASON_MATERIAL)
    g:DeleteGroup()
end

function s.pe2filter(c)
    if c:Islocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.pe2filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil) end
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_TOFIELD, tp, s.pe2filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil):GetFirst()
    if tc and Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CHANGE_LSCALE)
        ec1:SetRange(LOCATION_PZONE)
        ec1:SetValue(0)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_CHANGE_RSCALE)
        tc:RegisterEffect(ec1b)
    end
end

function s.pe3con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetFieldCard(tp, LOCATION_PZONE, 0) and Duel.GetFieldCard(tp, LOCATION_PZONE, 1) end

function s.pe3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_PZONE)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.pe3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) == 0 then return end

    local g = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, LOCATION_PZONE, 0, nil)
    if #g == 0 or not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then return end
    local sc = Utility.GroupSelect(HINTMSG_TODECK, g, tp, 1, 1, nil):GetFirst()
    if not sc then return end

    Duel.BreakEffect()
    if Duel.SendtoDeck(sc, nil, 1, REASON_EFFECT) > 0 and sc:IsLocation(LOCATION_EXTRA) and sc:IsCanBeSpecialSummoned(e, 0, tp, true, false) and
        Duel.GetLocationCountFromEx(tp, tp, nil, sc) > 0 and Duel.SelectYesNo(tp, 2) then
        Duel.BreakEffect()
        Duel.SpecialSummon(sc, 0, tp, tp, true, false, POS_FACEUP)
        sc:CompleteProcedure()
    end
end

function s.me1filter(c)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.me1con(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.me1filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil) end
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    if not Duel.CheckPendulumZones(tp) then return false end

    local tc = Utility.SelectMatchingCard(HINTMSG_TOFIELD, tp, s.me1filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil):GetFirst()
    if tc then Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
end

function s.me2filter(c)
    if c:GetFlagEffect(id) ~= 0 then return false end
    return (c:IsSetCard(0xf8) or c:IsSetCard(SET_ODD_EYES)) and c:IsRace(RACE_DRAGON)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup():Filter(s.me2filter, nil)
    if #g <= 0 then return end

    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe0000, 0, 0)
        local code = tc:GetOriginalCode()
        if not g:IsExists(function(c, code) return c:IsCode(code) and c:GetFlagEffect(id) > 0 end, 1, tc, code) then
            local cid = c:CopyEffect(code, RESET_EVENT + 0x1fe0000)
            local reset = Effect.CreateEffect(c)
            reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            reset:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            reset:SetCode(EVENT_ADJUST)
            reset:SetRange(LOCATION_MZONE)
            reset:SetLabel(cid)
            reset:SetLabelObject(tc)
            reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                local cid = e:GetLabel()
                local c = e:GetHandler()
                local tc = e:GetLabelObject()
                local g = c:GetOverlayGroup():Filter(function(c) return c:GetFlagEffect(id) > 0 end, nil)
                if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
                    c:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            reset:SetReset(RESET_EVENT + 0x1fe0000)
            c:RegisterEffect(reset, true)
        end
    end
end
