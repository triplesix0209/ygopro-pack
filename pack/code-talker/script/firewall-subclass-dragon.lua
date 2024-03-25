-- Firewall Subclass Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, nil, 2, 99, function(g, sc, sumtype, tp)
        return g:IsExists(function(c) return c:GetLink() == 4 and c:IsRace(RACE_CYBERSE, sc, sumtype, tp) end, 1, nil, sc, sumtype, tp)
    end)
end
