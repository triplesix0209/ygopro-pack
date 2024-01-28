-- Galaxy-Eyes Full Armor Luminous Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x107b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_LIGHT), 8, 2, s.xyzovfilter, aux.Stringid(id, 0))

    -- cannot be xyz material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    e1:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) and e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
    e1:SetValue(1)
    c:RegisterEffect(e1)
end

function s.xyzovfilter(c, tp, xyzc)
    return c:IsFaceup() and c:IsSetCard(0x107b, xyzc, SUMMON_TYPE_XYZ, tp) and c:IsRace(RACE_DRAGON, xyzc, SUMMON_TYPE_XYZ)
end
