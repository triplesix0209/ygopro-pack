-- Mesaia, Supreme Deity of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)
end
