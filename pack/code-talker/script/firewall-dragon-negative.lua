-- Firewall Dragon Negative
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 3)

    -- shuffle card
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP | TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon from your Deck
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2reg:SetCode(EVENT_BATTLE_DESTROYED)
    e2reg:SetRange(LOCATION_MZONE)
    e2reg:SetCondition(s.e2regcon1)
    e2reg:SetOperation(s.e2regop)
    c:RegisterEffect(e2reg)
    local e2regb = e2reg:Clone()
    e2regb:SetCode(EVENT_TO_GRAVE)
    e2regb:SetCondition(s.e2regcon2)
    c:RegisterEffect(e2regb)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_CUSTOM + id)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return c:IsFaceup() and c:IsAbleToDeck() end

function s.e1con() return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or not Duel.IsDamageCalculated() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local ct = Duel.GetMatchingGroupCount(function(c) return c:GetMutualLinkedGroupCount() > 0 end, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    if chk == 0 then
        return ct > 0 and Duel.IsExistingTarget(s.e1filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, LOCATION_GRAVE + LOCATION_REMOVED, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, LOCATION_GRAVE + LOCATION_REMOVED, 1, ct, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetTargetCards(e)
    if #g == 0 or Duel.SendtoDeck(g, nil, SEQ_DECKBOTTOM, REASON_EFFECT) == 0 then return end

    local ct = Duel.GetOperatedGroup():FilterCount(Card.IsLocation, nil, LOCATION_DECK)
    if ct > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(ct * 500)
        ec1:SetReset(RESET_EVENT | RESETS_STANDARD_DISABLE)
        c:RegisterEffect(ec1)
    end
end

function s.e2regfilter1(c, tp, zone)
    local seq = c:GetPreviousSequence()
    if not c:IsPreviousControler(tp) then seq = seq + 16 end
    return c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone, seq) ~= 0
end

function s.e2regfilter2(c, tp, zone) return not c:IsReason(REASON_BATTLE) and s.e2regfilter1(c, tp, zone) end

function s.e2regcon1(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e2regfilter1, 1, nil, tp, e:GetHandler():GetLinkedZone()) end

function s.e2regcon2(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e2regfilter2, 1, nil, tp, e:GetHandler():GetLinkedZone()) end

function s.e2regop(e, tp, eg, ep, ev, re, r, rp) Duel.RaiseSingleEvent(e:GetHandler(), EVENT_CUSTOM + id, e, 0, tp, 0, 0) end

function s.e2filter(c, e, tp) return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e2filter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
