-- Odd-Eyes Venom Dragon Overlord
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x99, 0x1050, 0x50}
s.listed_series = {0x99, 0x1050, 0x50}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, function(c, sc, sumtype, tp)
        return c:IsSetCard(0x99, sc, sumtype, tp) and c:IsRace(RACE_DRAGON, sc, sumtype, tp) and c:IsType(TYPE_PENDULUM, sc, sumtype, tp) and
                   c:IsOnField()
    end, function(c, sc, sumtype, tp) return c:IsSetCard(0x1050, sc, sumtype, tp) and c:IsType(TYPE_FUSION, sc, sumtype, tp) and c:IsOnField() end)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_FUSION) == SUMMON_TYPE_FUSION or (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)
end
