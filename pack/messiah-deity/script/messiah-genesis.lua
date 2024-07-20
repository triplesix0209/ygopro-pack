-- Genesis Messiah of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_messiah.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterMessiahBabyEffect(s, c, id, LOCATION_HAND + LOCATION_DECK, function(c) return c:IsRace(RACE_DRAGON) end)

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp) return not c:IsType(TYPE_LINK, sc, sumtype, tp) end, 2, 2)
end
