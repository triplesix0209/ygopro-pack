-- Supreme King Servant Dragon Clear Wing
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_DRAGON, SET_SUPREME_KING_GATE}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(s.synfilter), 1, 99)
end

function s.synfilter(c, val, sc, sumtype, tp) return c:IsAttribute(ATTRIBUTE_DARK, sc, sumtype, tp) and c:IsType(TYPE_PENDULUM, sc, sumtype, tp) end
