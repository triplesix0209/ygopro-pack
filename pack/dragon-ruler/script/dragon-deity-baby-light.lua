-- Pearlon, Dragon of Wishes
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityBabyEffect(s, c, id, ATTRIBUTE_LIGHT)
end
