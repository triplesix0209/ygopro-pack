-- Obsidianoh, Dragon Deity of Event Horizons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_DARK)

    -- unbanishable & untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_REMOVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, c, tp, r)
        return (c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsLinkAbove(5) and c:IsRace(RACE_DRAGON))) and r == REASON_EFFECT
    end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetTargetRange(LOCATION_MZONE, 0)
    e1b:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsLinkAbove(5) and c:IsRace(RACE_DRAGON)) end)
    e1b:SetValue(aux.tgoval)
    c:RegisterEffect(e1b)
end
