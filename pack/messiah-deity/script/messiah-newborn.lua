-- Newborn Messiah of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_messiah.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterMessiahBabyEffect(s, c, id, LOCATION_EXTRA + LOCATION_DECK, true)

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp) return not c:IsType(TYPE_LINK, sc, sumtype, tp) end, 2, 3)
end
