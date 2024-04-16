-- Narfi of the Nordic Alfar
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x42}

function s.initial_effect(c)
    -- to deck & search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_HAND)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return not c:IsCode(id) and c:IsSetCard(0x42) and c:IsAbleToHand()
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and
               not c:IsLocation(LOCATION_DECK)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1,
                                           nil) and c:IsAbleToDeck()
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_DECK, 0, nil)
    if not c:IsRelateToEffect(e) or #g == 0 then return end

    if Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local sg = g:Select(tp, 1, 1, nil)
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return r & REASON_EFFECT > 0 and re:GetHandler():IsSetCard(0x42) and
               e:GetHandler():GetPreviousControler() == tp
end

function s.e2filter(c)
    return not c:IsCode(id) and c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and
               c:IsAbleToHand()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local tc = Duel.SelectMatchingCard(tp, s.e2filter, tp,
                                       LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                       nil):GetFirst()
    if not tc then return end

    if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 and
        tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, tc)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_CANNOT_SUMMON)
        ec1:SetTargetRange(1, 0)
        ec1:SetLabel(tc:GetCode())
        ec1:SetTarget(s.e2sumlimit)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
        local e2b = ec1:Clone()
        e2b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        Duel.RegisterEffect(e2b, tp)
        local e2c = ec1:Clone()
        e2c:SetCode(EFFECT_CANNOT_MSET)
        Duel.RegisterEffect(e2c, tp)
    end
end

function s.e2sumlimit(e, c) return c:IsCode(e:GetLabel()) end
