-- Odd-Eyes Wing Dragon Overlord
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x99, 0xff}
s.listed_series = {0x99, 0xff}
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, sumtype, tp)
        return c:IsSetCard(0x99, sc, sumtype, tp) and c:IsRace(RACE_DRAGON, sc, sumtype, tp) and c:IsType(TYPE_PENDULUM, sc, sumtype, tp)
    end, 1, 1, Synchro.NonTunerEx(
        function(c, sc, sumtype, tp) return c:IsSetCard(0xff, sc, sumtype, tp) and c:IsType(TYPE_SYNCHRO, sc, sumtype, tp) end), 1, 1)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_SYNCHRO) == SUMMON_TYPE_SYNCHRO or (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)
end
