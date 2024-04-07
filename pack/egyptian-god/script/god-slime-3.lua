-- Egyptian God Slime III
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, aux.FilterBoolFunctionEx(Card.IsRace, RACE_AQUA),
        function(c, fc, st, tp) return c:IsAttribute(ATTRIBUTE_WATER, fc, st, tp) and c:GetLevel() == 10 end)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_EXTRA)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- triple tribute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- cannot be destroyed by battle
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- indes
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE, 0)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end

function s.spfilter(c, tp, sc)
    return c:IsRace(RACE_AQUA) and c:GetLevel() == 10 and c:GetAttack() == 0 and Duel.GetLocationCountFromEx(tp, tp, c, sc) > 0
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    return Duel.CheckReleaseGroup(tp, s.spfilter, 1, false, 1, true, c, tp, nil, nil, nil, tp, c)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    local g = Duel.SelectReleaseGroup(tp, s.spfilter, 1, 1, false, true, true, c, tp, nil, false, nil, tp, c)
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

    Duel.Release(g, REASON_COST + REASON_MATERIAL)
    g:DeleteGroup()
end
