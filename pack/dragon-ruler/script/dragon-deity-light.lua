-- Diamondoh, Dragon Deity of Miracle Symphonies
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_LIGHT)

    -- cannot be returned & cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_TO_DECK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c)
        if c:IsFacedown() then return false end
        return c == e:GetHandler() or (c:IsLinkMonster() and c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_DRAGON))
    end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1b:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(e1b)
    local e1c = Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_FIELD)
    e1c:SetCode(EFFECT_CANNOT_DISEFFECT)
    e1c:SetRange(LOCATION_MZONE)
    e1c:SetValue(function(e, ct)
        local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
        local tc = te:GetHandler()
        local p = e:GetHandler():GetControler()
        if p ~= tp or (loc & LOCATION_MZONE) == 0 or tc:IsFacedown() then return false end
        return tc == e:GetHandler() or (tc:IsLinkMonster() and tc:IsType(TYPE_PENDULUM) and tc:IsRace(RACE_DRAGON))
    end)
    c:RegisterEffect(e1c)
end
