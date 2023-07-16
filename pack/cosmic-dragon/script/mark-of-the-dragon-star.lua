-- Mark Of The Dragon Star
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_CRIMSON_DRAGON}
s.listed_series = {0xc2}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetTarget(s.acttg)
    act:SetOperation(s.actop)
    c:RegisterEffect(act)

    -- special summon the crimson dragon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
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
    return Duel.GetFlagEffect(tp, id + 1 * 1000) == 0 and Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil) and
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
    local mt = c:GetMetatable()
    local ct = 0
    if mt.synchro_tuner_required then ct = ct + mt.synchro_tuner_required end
    if mt.synchro_nt_required then ct = ct + mt.synchro_nt_required end

    return (c:IsSetCard(0xc2) or ((c:GetLevel() == 7 or c:GetLevel() == 8) and c:IsRace(RACE_DRAGON))) and c:IsType(TYPE_SYNCHRO) and ct == 0 and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
end

function s.e2check(e, tp)
    return Duel.GetFlagEffect(tp, id + 2 * 1000) == 0 and Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e2filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()

    if tc and Duel.SpecialSummonStep(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3206)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
        local ec2 = ec1:Clone()
        ec2:SetDescription(3302)
        ec2:SetCode(EFFECT_CANNOT_TRIGGER)
        tc:RegisterEffect(ec2)
        tc:CompleteProcedure()
    end
    Duel.SpecialSummonComplete()

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec2:SetTargetRange(1, 0)
    ec2:SetTarget(function(e, c) return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA) end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
    aux.RegisterClientHint(c, nil, tp, 1, 0, aux.Stringid(id, 2), nil)
    aux.addTempLizardCheck(c, tp, function(e, c) return not c:IsOriginalType(TYPE_SYNCHRO) end)
end

function s.e3filter1(c, tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY) and
               ((c:IsReason(REASON_EFFECT) and c:GetReasonPlayer() ~= tp) or (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1 - tp)))
end

function s.e3filter2(c) return c:IsFaceup() and c:ListsCode(CARD_CRIMSON_DRAGON) and c:IsAbleToDeck() end

function s.e3filter3(c, e, tp)
    return c:IsCode(CARD_CRIMSON_DRAGON) and Duel.GetLocationCountFromEx(tp, tp, nil, c) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e3filter1, 1, nil, tp) end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) end

    local g = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, s.e3filter2, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter3, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e3filter3, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
