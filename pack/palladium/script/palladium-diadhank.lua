-- Palladium Diadhank
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_PALLADIUM}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1des = Effect.CreateEffect(c)
    e1des:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e1des:SetCode(EVENT_LEAVE_FIELD)
    e1des:SetOperation(s.e1desop)
    c:RegisterEffect(e1des)

    -- recycle
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp) return (c:IsSetCard(SET_PALLADIUM) or c:IsType(TYPE_NORMAL)) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.GetActivityCount(tp, ACTIVITY_NORMALSUMMON) == 0 end end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e1filter, tp, loc, 0, 1, nil, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, loc)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, c, 1, 0, loc)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and c:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
        Duel.Equip(tp, c, tc, true)
        local eqlimit = Effect.CreateEffect(tc)
        eqlimit:SetType(EFFECT_TYPE_SINGLE)
        eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
        eqlimit:SetValue(function(e, c) return e:GetOwner() == c end)
        eqlimit:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(eqlimit)

        aux.RegisterClientHint(c, nil, tp, 1, 0, aux.Stringid(id, 0), nil)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_CANNOT_SUMMON)
        ec1:SetTargetRange(1, 0)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_CANNOT_MSET)
        Duel.RegisterEffect(ec1b, tp)
    end
    Duel.SpecialSummonComplete()
end

function s.e1desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetHandler():GetFirstCardTarget()
    if not tc or not tc:IsLocation(LOCATION_MZONE) then return end

    Utility.HintCard(e)
    if tc:IsPreviousLocation(LOCATION_HAND) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
    elseif tc:IsPreviousLocation(LOCATION_DECK) then
        Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    elseif tc:IsPreviousLocation(LOCATION_GRAVE) then
        Duel.SendtoGrave(tc, REASON_EFFECT)
    end
end

function s.e2filter(c) return (c:IsSetCard(SET_PALLADIUM) or c:IsType(TYPE_NORMAL)) and c:IsMonster() and c:IsAbleToDeck() end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() == tp end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetActivityCount(tp, ACTIVITY_NORMALSUMMON) == 0 end

    aux.RegisterClientHint(c, nil, tp, 1, 0, aux.Stringid(id, 0), nil)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_CANNOT_MSET)
    Duel.RegisterEffect(ec1b, tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE, 0, 1, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, 0, 1, 1, c)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    if Duel.SendtoDeck(tc, nil, SEQ_DECKBOTTOM, REASON_EFFECT) > 0 then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end
end
