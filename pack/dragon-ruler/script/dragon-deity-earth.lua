-- Amberoh, Dragon Deity of World Continents
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterEmperorEffect(s, c, id, ATTRIBUTE_EARTH)
end
