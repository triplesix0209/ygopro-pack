-- Red-Eyes Extreme Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_REDEYES_B_DRAGON}
s.material_setcode = {SET_RED_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixN(c, false, false, CARD_REDEYES_B_DRAGON, 3)
end
