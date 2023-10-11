-- The Wicked Apostle
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_names = {62180201, 57793869, 21208154}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, nil, 3, 3)

    -- apostle effect
    Divine.Apostle(id, c, {62180201, 57793869, 21208154}, s.tribute_filter)
end

function s.tribute_filter(e, c) return c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND) end
