-- Clash of Favorites
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS, CARD_YUBEL, 48130397}
s.listed_series = {SET_ULTIMATE_CRYSTAL, SET_ARMED_DRAGON}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMING_END_PHASE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- search "super polymerization"
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PREDRAW)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp, to_tp)
    if not c:IsCanBeSpecialSummoned(e, 0, tp, true, false, POS_FACEUP_ATTACK, to_tp) then return false end
    return c:IsCode(CARD_YUBEL) or c:IsSetCard(SET_ULTIMATE_CRYSTAL) or (c:IsLevel(10) and c:IsSetCard(SET_ARMED_DRAGON))
end

function s.e1check1(e, tp)
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp, tp) and
               Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_NEOS), tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.e1check2(e, tp)
    return Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp, 1 - tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return s.e1check1(e, tp) or s.e1check2(e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_HAND + LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = Duel.SelectEffect(tp, {s.e1check1(e, tp), aux.Stringid(id, 0)}, {s.e1check2(e, tp), aux.Stringid(id, 1)})

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp,
        op == 1 and tp or 1 - tp):GetFirst()
    if not tc then return end

    if Duel.SpecialSummon(tc, 0, tp, op == 1 and tp or 1 - tp, true, false, POS_FACEUP_ATTACK) ~= 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3207)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end

function s.e2filter(c) return c:IsCode(48130397) and c:IsAbleToHand() end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsTurnPlayer(tp) and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and Duel.GetDrawCount(tp) > 0 and
               (Duel.GetTurnCount() > 1 or Duel.IsDuelType(DUEL_1ST_TURN_DRAW)) and
               Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_NEOS), tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToDeckAsCost() end
    Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local dt = Duel.GetDrawCount(tp)
    if dt == 0 then return false end
    _replace_count = 1
    _replace_max = dt

    -- give up normal draw
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_DRAW_COUNT)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_DRAW)
    Duel.RegisterEffect(ec1, tp)
    if _replace_count > _replace_max then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e2filter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
