-- Palladium Spirit Duos Dracocursed
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x13a}
s.listed_names = {900000112}
s.listed_series = {0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, s.fusfilter1, s.fusfilter2)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st) end)
    c:RegisterEffect(splimit)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_EXTRA)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)
end

function s.fusfilter1(c, fc, sumtype, tp) return c:IsSetCard(0x13a, fc, sumtype, tp) and c:IsRace(RACE_WARRIOR, fc, sumtype, tp) end

function s.fusfilter2(c, fc, sumtype, tp) return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON, fc, sumtype, tp) end

function s.spfilter1(c) return c:IsCode(900000112) end

function s.spfilter2(c, tp, sc) return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON, sc, MATERIAL_FUSION, tp) end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.CheckReleaseGroup(tp, s.spfilter1, 1, false, 1, true, c, tp, nil, false, nil, tp, c) and
               Duel.CheckReleaseGroup(tp, s.spfilter2, 1, true, 1, true, c, tp, nil, false, nil, tp, c)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    local g = Duel.SelectReleaseGroup(tp, s.spfilter1, 1, 1, false, true, true, c, tp, nil, false, nil, tp, c)
    g:Merge(Duel.SelectReleaseGroup(tp, s.spfilter2, 1, 1, true, true, true, c, tp, nil, false, nil, tp, c))

    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end

    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.Release(g, REASON_COST)
    g:DeleteGroup()
end
