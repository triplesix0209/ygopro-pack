-- Messiah, Origin of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterMessiahBabyEffect(s, c, id, ATTRIBUTE_FIRE + ATTRIBUTE_WIND + ATTRIBUTE_LIGHT, LOCATION_HAND + LOCATION_DECK)
end
