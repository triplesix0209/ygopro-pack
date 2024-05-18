-- Messiah, Genesis of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterMessiahBabyEffect(s, c, id, ATTRIBUTE_WATER + ATTRIBUTE_EARTH + ATTRIBUTE_DARK, LOCATION_DECK + LOCATION_GRAVE)
end
