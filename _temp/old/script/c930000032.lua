-- Match for the Nordic Artifacts
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {91148083, 930000002}
s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMING_END_PHASE)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_DECK)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    if not (c:IsAbleToHand() or c:IsSSetable(false)) then return false end
    return (c:IsSetCard(0x42) and c:IsType(TYPE_SPELL + TYPE_TRAP)) or
               c:IsCode(91148083)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    if Duel.IsExistingMatchingCard(
        aux.FilterFaceupFunction(Card.IsSetCard, 0x4b), tp, LOCATION_MZONE, 0,
        1, nil) then
        Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local tc = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_DECK, 0, 1,
                                       1, nil):GetFirst()
    if not tc then return end

    aux.ToHandOrElse(tc, tp, function(tc)
        return tc:IsSSetable(false) and
                   Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
    end, function(tc)
        Duel.SSet(tp, tc)

        local effect_code
        if tc:IsType(TYPE_TRAP) then
            effect_code = EFFECT_TRAP_ACT_IN_SET_TURN
        elseif tc:IsType(TYPE_QUICKPLAY) then
            effect_code = EFFECT_QP_ACT_IN_SET_TURN
        else
            return
        end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        ec1:SetCode(effect_code)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end, 1159)
end

function s.e2filter(c, tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsCode(930000002)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e2filter, 1, nil, tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
    if Duel.IsExistingMatchingCard(
        aux.FilterFaceupFunction(Card.IsSetCard, 0x4b), tp, LOCATION_MZONE, 0,
        1, nil) then
        Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SendtoHand(c, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, c)
end
