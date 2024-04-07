-- The Supreme King HERO
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_SUPER_POLYMERIZATION}
s.listed_series = {SET_HERO}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixRep(c, true, true, function(c, sc, sumtype, tp) return c:IsType(TYPE_EFFECT, sc, sumtype, tp) end, 1, 99,
        aux.FilterBoolFunctionEx(Card.IsSetCard, SET_HERO))

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st) return se:GetHandler():IsCode(CARD_SUPER_POLYMERIZATION) end)
    c:RegisterEffect(splimit)
end
