-- Mesaia, Genesis of Dragons
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- special summon limit
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    pe1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(1, 0)
    pe1:SetTarget(function(e, c, tp, sumtp, sumpos) return not c:IsRace(RACE_DRAGON) and (sumtp & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM end)
    c:RegisterEffect(pe1)
end
