-- Galaxy-Eyes Full Armor Luminous Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x107b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_LIGHT), 8, 2, s.xyzovfilter, aux.Stringid(id, 0))
end

function s.xyzovfilter(c, tp, xyzc)
    return c:IsFaceup() and c:IsSetCard(0x107b, xyzc, SUMMON_TYPE_XYZ, tp) and c:IsRace(RACE_DRAGON, xyzc, SUMMON_TYPE_XYZ)
end
