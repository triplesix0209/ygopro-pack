-- Numeron Code
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- cannot disable summon
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(function(e, c) return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) and c:IsControler(e:GetHandlerPlayer()) end)
    c:RegisterEffect(e2)
end
