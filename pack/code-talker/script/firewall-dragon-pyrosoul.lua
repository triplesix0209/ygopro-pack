-- Firewall Dragon Pyrosoul
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 99,
        function(g, sc, sumtype, tp) return g:CheckDifferentPropertyBinary(Card.GetAttribute, sc, sumtype, tp) end)
end
