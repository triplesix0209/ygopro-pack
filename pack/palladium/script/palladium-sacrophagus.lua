-- Palladium Sacrophagus
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE, LOCATION_GRAVE,
            1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, Card.IsAbleToRemove, tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil):GetFirst()

    if tc and Duel.Remove(tc, POS_FACEDOWN, REASON_EFFECT) > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_CHAIN_SOLVING)
        ec1:SetRange(LOCATION_REMOVED)
        ec1:SetLabelObject(tc)
        ec1:SetOperation(s.e1disop)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e1disop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    local rc = re:GetHandler()
    if tc:IsLocation(LOCATION_REMOVED) and tc:IsFacedown() and rc:IsCode(tc:GetCode()) and Duel.IsChainDisablable(ev) and
        Duel.SelectEffectYesNo(tp, tc, aux.Stringid(id, 0)) then
        Utility.HintCard(e)
        Duel.ConfirmCards(tp, tc)
        Duel.ConfirmCards(1 - tp, tc)
        Duel.NegateEffect(ev)
        e:Reset()
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() == tp and aux.exccon(e, tp, eg, ep, ev, re, r, rp) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsAbleToHand, tp, LOCATION_REMOVED, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_REMOVED)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToHand, tp, LOCATION_REMOVED, 0, nil)

    if #g > 0 and Duel.SendtoDeck(c, nil, SEQ_DECKBOTTOM, REASON_EFFECT) > 0 then
        Duel.BreakEffect()
        g = Utility.GroupSelect(HINTMSG_RTOHAND, g, tp)
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
