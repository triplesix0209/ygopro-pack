-- Hall of the Nordic Fallen
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- reborn
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- summon aesir
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               Utility.IsSetCard(c, 0x4b, 0x42)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local ph = Duel.GetCurrentPhase()
    return ph == PHASE_MAIN1 or ph == PHASE_MAIN2
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e1filter, tp, LOCATION_GRAVE, 0, 1,
                                         nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_GRAVE, 0, 1, 1,
                                nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    local sumtype = 0
    if tc:IsSetCard(0x4b) then sumtype = 1 end
    Duel.SpecialSummon(tc, sumtype, tp, tp, false, false, POS_FACEUP)
    
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCountLimit(1)
    ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.Destroy(e:GetHandler(), REASON_EFFECT)
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
end

function s.e2filter1(c, e, tp)
    return c:IsSetCard(0x4b) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false) and
               Duel.IsExistingMatchingCard(s.e2filter2, tp,
                                           LOCATION_GRAVE + LOCATION_REMOVED, 0,
                                           1, nil, e, tp, c)
end

function s.e2filter2(c, e, tp, sc)
    local rg = Duel.GetMatchingGroup(s.e2filter3, tp,
                                     LOCATION_GRAVE + LOCATION_REMOVED, 0, c)
    return c:IsFaceup() and c:IsSetCard(0x42) and c:IsType(TYPE_TUNER) and
               c:IsAbleToDeck() and
               aux.SelectUnselectGroup(rg, e, tp, nil, 2, s.e2rescon(c, sc), 0)
end

function s.e2filter3(c)
    return c:IsFaceup() and c:IsSetCard(0x42) and not c:IsType(TYPE_TUNER) and
               c:HasLevel() and c:IsAbleToDeck()
end

function s.e2rescon(tuner, sc)
    return function(sg, e, tp, mg)
        sg:AddCard(tuner)
        local res = Duel.GetLocationCountFromEx(tp, tp, sg, sc) > 0 and
                        sg:CheckWithSumEqual(Card.GetLevel, 10, 3, 3)
        sg:RemoveCard(tuner)
        return res
    end
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_EXTRA, 0,
                                           1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 3, tp,
                          LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.e2filter1, tp, LOCATION_EXTRA, 0,
                                       1, 1, nil, e, tp):GetFirst()
    if not sc then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local tuner = Duel.SelectMatchingCard(tp, s.e2filter2, tp,
                                          LOCATION_GRAVE + LOCATION_REMOVED, 0,
                                          1, 1, nil, e, tp, sc):GetFirst()
    local rg = Duel.GetMatchingGroup(s.e2filter3, tp,
                                     LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
    local sg = aux.SelectUnselectGroup(rg, e, tp, 1, 2, s.e2rescon(tuner, sc),
                                       1, tp, HINTMSG_TODECK,
                                       s.e2rescon(tuner, sc))
    sg:AddCard(tuner)
    if Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == 0 then
        return
    end

    Duel.SpecialSummon(sc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
    sc:CompleteProcedure()
end
