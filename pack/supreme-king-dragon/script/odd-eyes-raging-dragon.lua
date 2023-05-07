-- Odd-Eyes Raging Dragon Overlord
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x99, 0x13b}
s.listed_series = {0x99, 0x13b}
s.pendulum_level = 7

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, nil, 7, 2, nil, 0, nil, nil, false, function(g, tp, sc)
        return g:IsExists(function(tc)
            return tc:IsSetCard(0x99, sc, SUMMON_TYPE_XYZ, tp) and tc:IsRace(RACE_DRAGON, sc, SUMMON_TYPE_XYZ, tp) and
                       c:IsType(TYPE_PENDULUM, sc, SUMMON_TYPE_XYZ, tp)
        end, 1, nil) and
                   g:IsExists(function(tc)
                return tc:IsSetCard(0x13b, sc, SUMMON_TYPE_XYZ, tp) and c:IsType(TYPE_XYZ, sc, SUMMON_TYPE_XYZ, tp)
            end, 1, nil)
    end)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_XYZ) == SUMMON_TYPE_XYZ or (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)
end
