-- Supreme King Servant Dragon Starving Venom
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_DRAGON, SET_SUPREME_KING_GATE}

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- fusion summon
    Fusion.AddProcMixN(c, true, true, s.fusfilter, 2)
    Fusion.AddContactProc(c, s.contactgroup, s.contactop)
end

function s.fusfilter(c, fc, sumtype, tp) return c:IsAttribute(ATTRIBUTE_DARK, fc, sumtype, tp) and c:IsType(TYPE_PENDULUM, fc, sumtype, tp) end

function s.contactgroup(tp) return Duel.GetReleaseGroup(tp) end

function s.contactop(g) Duel.Release(g, REASON_COST + REASON_MATERIAL) end
