-- Numeron Code
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_NUMBER, SET_NUMERON}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- activation and effect cannot be negated
    local nonegate = Effect.CreateEffect(c)
    nonegate:SetType(EFFECT_TYPE_FIELD)
    nonegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nonegate:SetCode(EFFECT_CANNOT_INACTIVATE)
    nonegate:SetRange(LOCATION_ONFIELD)
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

    -- cannot disable summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTarget(function(e, c) return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) and c:IsControler(e:GetHandlerPlayer()) end)
    c:RegisterEffect(e1)

    -- detaching cost is optional
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(0)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return (r & REASON_COST) ~= 0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and re:GetHandler():IsSetCard(SET_NUMERON)
    end)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) return ev end)
    c:RegisterEffect(e2)
end

