-- Huginn and Muninn the Nordic Eyes
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {93483212}
s.listed_series = {0x4b}

function s.initial_effect(c)
    -- check card
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_DECK + LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return c:IsFaceup() and c:IsSetCard(0x4b) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsTurnPlayer(tp) and
               (Duel.IsMainPhase() or Duel.GetCurrentPhase() == PHASE_STANDBY)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end

    if not tc:IsCode(93483212) then
        if tc:IsDisabled() then return end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)

        if tc:IsImmuneToEffect(ec1) then return end
    end

    local g = Duel.GetFieldGroup(tp, 0, LOCATION_HAND)
    g:Merge(Duel.GetMatchingGroup(Card.IsFacedown, tp, 0, LOCATION_ONFIELD, nil))
    Duel.ConfirmCards(tp, g)
    Duel.ShuffleHand(1 - tp)
end

function s.e2filter(c, tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x4b)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsLocation(LOCATION_DECK) and
        not eg:IsExists(Card.IsCode, 1, nil, 93483212) then return false end
    return eg:IsExists(s.e2filter, 1, nil, tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SendtoHand(c, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, c)
end
