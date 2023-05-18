-- Supreme Overlord Dragon Dark Rebellion
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_DRAGON, SET_SUPREME_KING_GATE}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, 4, 2)
end

function s.xyzfilter(c, xyz, sumtype, tp) return c:IsType(TYPE_PENDULUM, xyz, sumtype, tp) and c:IsAttribute(ATTRIBUTE_DARK, xyz, sumtype, tp) end
