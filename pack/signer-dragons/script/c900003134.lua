-- Let's Rev It Up!
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1017}
s.counter_list = {0x1148}

function s.initial_effect(c)
    c:EnableCounterPermit(0x1148)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- chain limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- add counter
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- 4 counters
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.effcost(4))
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- 7 counters
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_DRAW + CATEGORY_HANDES)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCost(s.effcost(7))
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- 10 counters
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 2))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e6:SetRange(LOCATION_SZONE)
    e6:SetCost(s.effcost(10))
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e1filter1(c) return c:IsSetCard(0x1017) and c:IsType(TYPE_TUNER) and c:IsAbleToHand() end

function s.e1filter2(c, tc) return c:HasLevel() and c:GetLevel() < tc:GetLevel() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_DECK, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter1, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
    if not tc then return end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
    Duel.ShuffleDeck(tp)

    if not tc:IsLocation(LOCATION_HAND) or not tc:HasLevel() or
        Duel.GetMatchingGroupCount(s.e1filter2, tp, LOCATION_DECK, 0, nil, tc) == 0 or not Duel.SelectEffectYesNo(tp, c, 504) then
        return
    end

    Duel.BreakEffect()
    local sg = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e1filter2, tp, LOCATION_DECK, 0, 1, 1, nil, tc)
    Duel.SendtoGrave(sg, REASON_EFFECT)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local rc = re:GetHandler()
    if re:IsActiveType(TYPE_MONSTER) and rc:IsOriginalSetCard(0x1017) then Duel.SetChainLimit(s.e2chainlimit) end
end

function s.e2chainlimit(e, rp, tp) return tp == rp end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local ct = eg:FilterCount(aux.FaceupFilter(Card.IsType, TYPE_SYNCHRO), nil)
    if ct > 0 then e:GetHandler():AddCounter(0x1148, ct) end
end

function s.effcost(ct)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then return c:IsCanRemoveCounter(tp, 0x1148, ct, REASON_COST) end

        Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
        Duel.RemoveCounter(tp, 1, 1, 0x1148, ct, REASON_COST)
    end
end

function s.e4filter(c, mg) return c:IsSynchroSummonable(nil, mg) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return (Duel.GetCurrentPhase() == PHASE_MAIN1 or Duel.GetCurrentPhase() == PHASE_MAIN2)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local mg = Duel.GetMatchingGroup(Card.IsOnField, tp, LOCATION_MZONE, 0, nil)
        return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_EXTRA, 0, 1, nil, mg)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id + 2 * 1000, RESET_PHASE + PHASE_END, 0, 1)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local mg = Duel.GetMatchingGroup(Card.IsOnField, tp, LOCATION_MZONE, 0, nil)
    local eg = Duel.GetMatchingGroup(s.e4filter, tp, LOCATION_EXTRA, 0, nil, mg)
    if #eg > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sc = eg:Select(tp, 1, 1, nil):GetFirst()
        Duel.SynchroSummon(tp, sc, nil, mg)
    end
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetFlagEffect(tp, id + 1 * 1000) == 0 and Duel.IsPlayerCanDraw(tp, 2) end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
    Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 0, tp, 1)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id + 2 * 1000, RESET_PHASE + PHASE_END, 0, 1)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    if Duel.Draw(p, d, REASON_EFFECT) == 2 then
        Duel.BreakEffect()
        Duel.DiscardHand(tp, aux.TRUE, 1, 1, REASON_EFFECT)
    end
end

function s.e6filter(c, e, tp) return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetFlagEffect(tp, id + 3 * 1000) == 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e6filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e6filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id + 3 * 1000, RESET_PHASE + PHASE_END, 0, 1)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) end
end
