-- Mark Of The Dragon Star
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_CRIMSON_DRAGON}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetTarget(s.acttg)
    act:SetOperation(s.actop)
    c:RegisterEffect(act)

    -- shuffle
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(aux.exccon)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.actcounterfilter(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO) end

function s.acttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return s.e1check(e, tp) or s.e2check(e, tp) end

    local op = Duel.SelectEffect(tp, {s.e1check(e, tp), aux.Stringid(id, 0)}, {s.e2check(e, tp), aux.Stringid(id, 1)})
    e:SetLabel(op)

    if op == 1 then
        e:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
        Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND + LOCATION_GRAVE)
        Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
    elseif op == 2 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
    end
end

function s.actop(e, tp, eg, ep, ev, re, r, rp)
    local op = e:GetLabel()
    if Duel.GetFlagEffect(tp, id + op * 10000) > 0 then return end
    Duel.RegisterFlagEffect(tp, id + op * 10000, RESET_PHASE + PHASE_END, 0, 1)

    if op == 1 then
        s.e1op(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 2 then
        s.e2op(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.e1filter(c) return c:IsType(TYPE_TUNER) and c:IsAbleToDeck() end

function s.e1check(e, tp)
    return Duel.GetFlagEffect(tp, id + 1 * 10000) == 0 and Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil) and
               Duel.IsPlayerCanDraw(tp, 2)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    if Duel.SendtoDeck(tc, nil, 0, REASON_EFFECT) > 0 then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Draw(tp, 2, REASON_EFFECT)
    end
end

function s.e2filter(c, e, tp)
    return c:IsCode(CARD_CRIMSON_DRAGON) and Duel.GetLocationCountFromEx(tp, tp, nil, c) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2check(e, tp)
    return Duel.GetFlagEffect(tp, id + 2 * 10000) == 0 and Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e2filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e3filter(c) return c:IsFaceup() and c:ListsCode(CARD_CRIMSON_DRAGON) and c:IsAbleToDeck() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(s.e3filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
end
