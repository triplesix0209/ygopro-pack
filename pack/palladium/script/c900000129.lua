-- Palladium Sacrophagus
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- act in hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e1:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(), LOCATION_MZONE, 0) == 0 end)
    c:RegisterEffect(e1)

    -- activate
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE, LOCATION_GRAVE,
            1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, Card.IsAbleToRemove, tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil):GetFirst()
    if not tc or Duel.Remove(tc, POS_FACEDOWN, REASON_EFFECT) == 0 then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetCode(EVENT_CHAIN_SOLVING)
    ec1:SetRange(LOCATION_REMOVED)
    ec1:SetOperation(s.e2disop)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
end

function s.e2disop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()

    if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() and rc:IsCode(c:GetCode()) and Duel.IsChainDisablable(ev) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        Utility.HintCard(e:GetOwner())
        Duel.ConfirmCards(tp, c)
        if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
            if rc:IsPreviousLocation(LOCATION_HAND) then
                Duel.SendtoHand(c, nil, REASON_EFFECT)
            elseif rc:IsPreviousLocation(LOCATION_DECK + LOCATION_EXTRA) then
                Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
            elseif rc:IsPreviousLocation(LOCATION_GRAVE) then
                Duel.SendtoGrave(c, REASON_EFFECT)
            end
        end
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() == tp and aux.exccon(e, tp, eg, ep, ev, re, r, rp) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsAbleToHand, tp, LOCATION_REMOVED, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_REMOVED)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToHand, tp, LOCATION_REMOVED, 0, nil)

    if #g > 0 and Duel.SendtoDeck(c, nil, SEQ_DECKBOTTOM, REASON_EFFECT) > 0 then
        Duel.BreakEffect()
        g = Utility.GroupSelect(HINTMSG_RTOHAND, g, tp)
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
