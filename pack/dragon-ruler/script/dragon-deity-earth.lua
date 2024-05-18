-- Amberoh, Dragon Deity of World Continents
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_EARTH)

    -- cannot to GY & spell immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_TO_GRAVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsLinkAbove(5) and c:IsRace(RACE_DRAGON)) end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_IMMUNE_EFFECT)
    e1b:SetValue(function(e, te) return te:GetOwnerPlayer() ~= e:GetHandlerPlayer() and te:IsActivated() and te:IsTrapEffect() end)
    c:RegisterEffect(e1b)
end
