-- Elemental HERO Stratumine Neos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS}
s.material_setcode = {SET_HERO, SET_ELEMENTAL_HERO, SET_NEOS, SET_NEO_SPACIAN}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, CARD_NEOS, 17955766, 80344569)
    Fusion.AddContactProc(c, function(tp) return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil) end,
        function(g, tp)
            Duel.ConfirmCards(1 - tp, g)
            Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
        end, function(e) return not e:GetHandler():IsLocation(LOCATION_EXTRA) end)

    -- shuffle cards into deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- return all Spell and Trap Cards to the hand
    aux.EnableNeosReturn(c, CATEGORY_TODECK, s.e2info, s.e2op)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, loc, loc, 1, c) end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, 0, loc)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = Duel.SelectEffect(tp,
        {Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE, LOCATION_ONFIELD + LOCATION_GRAVE, 1, c),
         aux.Stringid(id, 1)}, {Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, 0, LOCATION_HAND, 1, c), aux.Stringid(id, 2)})

    local g = Group.CreateGroup()
    if op == 1 then
        g = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, Card.IsAbleToDeck, tp, LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE,
            LOCATION_ONFIELD + LOCATION_GRAVE, 1, 1, c)
    else
        g = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, 0, LOCATION_HAND, c):RandomSelect(tp, 1)
    end

    if #g > 0 then Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) end
end

function s.e2filter(c) return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand() end

function s.e2info(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, LOCATION_REMOVED, LOCATION_REMOVED, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(nil, tp, LOCATION_REMOVED, LOCATION_REMOVED, nil)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
end
