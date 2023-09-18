-- Junk Striker
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_SYNCHRON}
s.listed_names = {62125439}

function s.initial_effect(c)
    -- search & summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter1(c) return c:IsSetCard(SET_SYNCHRON) and c:IsMonster() and c:IsAbleToHand() end

function s.e1filter2(c) return c:IsSummonable(true, nil) and c:IsType(TYPE_TUNER) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end

    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_DECK, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter1, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end

    if Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_HAND, 0, 1, nil) and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        Duel.BreakEffect()
        Duel.ShuffleHand(tp)

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
        local tc = Utility.SelectMatchingCard(HINTMSG_SUMMON, tp, s.e1filter2, tp, LOCATION_HAND + LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
        if tc then Duel.Summon(tp, tc, true, nil) end
    end
end
