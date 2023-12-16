-- Neo-Spacian Black Panther
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- cannot special summon
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    ec1:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(ec1)

    -- add code
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    ec2:SetCode(EFFECT_ADD_CODE)
    ec2:SetValue(43237273)
    c:RegisterEffect(ec2)
end
