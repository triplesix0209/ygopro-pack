-- Genesis Messiah of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_messiah.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterMessiahBabyEffect(s, c, id, LOCATION_GRAVE, false)

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp) return c:IsRace(RACE_DRAGON, sc, sumtype, tp) and not c:IsType(TYPE_LINK, sc, sumtype, tp) end,
        2, 2)
end