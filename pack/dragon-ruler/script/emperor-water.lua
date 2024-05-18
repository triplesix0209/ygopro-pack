-- Sapphire, Dragon Emperor of Ice Ages
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterEmperorEffect(s, c, id, ATTRIBUTE_WATER)
end
