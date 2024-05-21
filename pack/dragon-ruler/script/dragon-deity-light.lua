-- Diamondoh, Dragon Deity of Miracle Symphonies
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_LIGHT)

    -- untargetable & cannot be negated    
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsLinkAbove(5) and c:IsRace(RACE_DRAGON)) end)
    e1:SetValue(aux.tgoval)
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
    local e1c = Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_FIELD)
    e1c:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1c:SetCode(EFFECT_CANNOT_DISABLE)
    e1c:SetRange(LOCATION_MZONE)
    e1c:SetTargetRange(LOCATION_MZONE, 0)
    e1c:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsLinkAbove(5) and c:IsRace(RACE_DRAGON)) end)
    c:RegisterEffect(e1c)
end
