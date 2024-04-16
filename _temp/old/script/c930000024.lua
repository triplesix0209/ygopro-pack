-- Idun the Nordic Young
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {93483212}
s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetRange(LOCATION_HAND + LOCATION_DECK)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    aux.GlobalCheck(s, function()
        s[0] = 0
        s[1] = 0
        local e1dmgreg = Effect.CreateEffect(c)
        e1dmgreg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1dmgreg:SetCode(EVENT_DAMAGE)
        e1dmgreg:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            s[ep] = s[ep] + ev
        end)
        Duel.RegisterEffect(e1dmgreg, 0)
        local e1dmgclear = Effect.CreateEffect(c)
        e1dmgclear:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1dmgclear:SetCode(EVENT_ADJUST)
        e1dmgclear:SetCountLimit(1)
        e1dmgclear:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            s[0] = 0
            s[1] = 0
        end)
        Duel.RegisterEffect(e1dmgclear, 0)
    end)

    -- shuffle
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE + LOCATION_REMOVED)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter1(c) return not c:IsStatus(STATUS_LEAVE_CONFIRMED) end

function s.e1filter2(c)
    return c:IsFaceup() and c:IsSetCard(0x48) and c:IsType(TYPE_MONSTER)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsLocation(LOCATION_DECK) and
        not Duel.IsExistingMatchingCard(
            aux.FilterFaceupFunction(Card.IsCode, 93483212), tp,
            LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) then return false end
    return ep == tp and tp ~= rp and
               not Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_MZONE,
                                               0, 1, nil) and
               Duel.IsExistingMatchingCard(s.e1filter2, tp,
                                           LOCATION_GRAVE + LOCATION_REMOVED, 0,
                                           1, nil)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, s[tp])
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rec = Duel.Recover(tp, s[tp], REASON_EFFECT)

    if c:IsRelateToEffect(e) then
        if Duel.SpecialSummonStep(c, 0, tp, tp, true, false, POS_FACEUP_DEFENSE) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_SET_BASE_DEFENSE)
            ec1:SetValue(rec)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(ec1, true)
        end
        Duel.SpecialSummonComplete()
    end
end

function s.e2filter(c)
    return c:IsFaceup() and Utility.IsSetCard(c, 0x4b, 0x42) and
               c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsAbleToDeck() and
                   Duel.IsExistingTarget(s.e2filter, tp,
                                         LOCATION_REMOVED + LOCATION_GRAVE, 0,
                                         5, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, aux.NecroValleyFilter(s.e2filter), tp,
                                LOCATION_REMOVED + LOCATION_GRAVE, 0, 5, 5, c)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Group.FromCards(c)
    tg:Merge(Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS))
    if tg:FilterCount(Card.IsRelateToEffect, nil, e) ~= #tg then return end
    Duel.SendtoDeck(tg, nil, 0, REASON_EFFECT)

    local g = Duel.GetOperatedGroup()
    if g:IsExists(Card.IsLocation, 1, nil, LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
    end
    local ct = g:FilterCount(Card.IsLocation, nil,
                             LOCATION_DECK + LOCATION_EXTRA)
    if ct == #tg then Duel.Draw(tp, 1, REASON_EFFECT) end
end
