-- Majestic Wills Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x3f}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- synchro symmon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- effect gain
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c, tp)
    return c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e1filter, 1, nil, tp) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e2filter(c, mg) return c:IsSetCard(0x3f) and c:IsSynchroSummonable(mg) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() ~= tp and (Duel.GetCurrentPhase() == PHASE_MAIN1 or Duel.GetCurrentPhase() == PHASE_MAIN2)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_EXTRA, 0, 1, nil, c) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsControler(1 - tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_EXTRA, 0, nil, c)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg = g:Select(tp, 1, 1, nil)
        Duel.SynchroSummon(tp, sg:GetFirst(), c)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetReasonCard()
    return r == REASON_SYNCHRO and tc:IsSetCard(0x3f)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetReasonCard()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_TO_DECK)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetDescription(3031)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetValue(aux.tgoval)
    tc:RegisterEffect(ec2)
end
