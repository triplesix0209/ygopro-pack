-- Elemental HERO Nimbus Neos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS}
s.material_setcode = {SET_HERO, SET_ELEMENTAL_HERO, SET_NEOS, SET_NEO_SPACIAN}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, CARD_NEOS, 17732278, 54959865)
    Fusion.AddContactProc(c, function(tp) return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil) end,
        function(g, tp)
            Duel.ConfirmCards(1 - tp, g)
            Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
        end, function(e) return not e:GetHandler():IsLocation(LOCATION_EXTRA) end)

    -- return
    aux.EnableNeosReturn(c, nil, nil, nil)
end
