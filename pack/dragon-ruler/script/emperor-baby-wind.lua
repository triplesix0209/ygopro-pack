-- Peridot, Dragon of Spirits
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterBabyEffect(s, c, id, ATTRIBUTE_WIND)
end
