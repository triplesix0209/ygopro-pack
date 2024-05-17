-- Kidisuto, Dragon Ruler of Gorges
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterBabyShuffleEffect(s, c, id)
end
