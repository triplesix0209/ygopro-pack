-- Obsidianoh, Dragon Deity of Event Horizons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_DARK)

    -- unbanishable & cannot be negated
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
    e1b:SetCode(EFFECT_CANNOT_DISEFFECT)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetValue(function(e, ct)
        local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
        local tc = te:GetHandler()
        if tc == e:GetHandler() then return true end
        local p = e:GetHandler():GetControler()
        return tc:GetMutualLinkedGroupCount() > 0 and tc:IsLinkAbove(5) and tc:IsRace(RACE_DRAGON) and p == tp and (loc & LOCATION_MZONE) ~= 0
    end)
    c:RegisterEffect(e1b)
    local e1c=e1b:Clone()
    e1c:SetCode(EFFECT_CANNOT_INACTIVATE)
    c:RegisterEffect(e1c)
    local e1d = Effect.CreateEffect(c)
    e1d:SetType(EFFECT_TYPE_FIELD)
    e1d:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1d:SetCode(EFFECT_CANNOT_DISABLE)
    e1d:SetRange(LOCATION_MZONE)
    e1d:SetTargetRange(LOCATION_MZONE, 0)
    e1d:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsLinkAbove(5) and c:IsRace(RACE_DRAGON)) end)
    c:RegisterEffect(e1d)
end
