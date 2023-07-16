-- Rose Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- synchro level
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EFFECT_SYNCHRO_LEVEL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c) return 3 * 65536 + e:GetHandler():GetLevel() end)
    c:RegisterEffect(e1)
end
