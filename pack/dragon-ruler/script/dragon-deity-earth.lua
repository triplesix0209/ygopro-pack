-- Amberoh, Dragon Deity of World Continents
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_EARTH)

    -- trap immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:IsRace(RACE_DRAGON) and c:GetMutualLinkedGroupCount() > 0) end)
    e1:SetValue(function(e, te) return te:IsActiveType(TYPE_TRAP) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1)
end
