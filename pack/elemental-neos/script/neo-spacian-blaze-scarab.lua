-- Neo-Spacian Blaze Scarab
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- cannot special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e1)

    -- add code
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_ADD_CODE)
    e2:SetValue(89621922)
    c:RegisterEffect(e2)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(function(e, c)
        return Duel.GetMatchingGroupCount(Card.IsType, c:GetControler(), LOCATION_ONFIELD, 0, nil, TYPE_SPELL + TYPE_TRAP) * 400
    end)
    c:RegisterEffect(e3)
end
