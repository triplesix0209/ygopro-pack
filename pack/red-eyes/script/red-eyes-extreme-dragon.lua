-- Red-Eyes Extreme Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {SET_RED_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixN(c, false, false,
        function(c, fc, sumtype, tp) return c:IsSetCard(SET_RED_EYES, fc, sumtype, tp) and c:IsRace(RACE_DRAGON, fc, sumtype, tp) end, 3)
end
