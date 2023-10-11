-- Osiris's Apostle
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_names = {10000020}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, nil, 3, 3)

    -- apostle effect
    Divine.Apostle(id, c, aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE), nil, 10000020)
end
