-- Mark Of The Dragon Star
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0xc2}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetCost(s.actcost)
    act:SetTarget(s.acttg)
    act:SetOperation(s.actop)
    c:RegisterEffect(act)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.actcounterfilter)

    -- set from GY
    local set = Effect.CreateEffect(c)
    set:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    set:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    set:SetCode(EVENT_SPSUMMON_SUCCESS)
    set:SetRange(LOCATION_GRAVE)
    set:SetCountLimit(1, id)
    set:SetCondition(s.setcon)
    set:SetTarget(s.settg)
    set:SetOperation(s.setop)
    c:RegisterEffect(set)
end

function s.actcounterfilter(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO) end

function s.actcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, tc, sump, sumtype, sumpos, targetp, se)
        return tc:IsLocation(LOCATION_EXTRA) and not tc:IsType(TYPE_SYNCHRO)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    aux.addTempLizardCheck(e:GetHandler(), tp, function(e, c) return not c:IsOriginalType(TYPE_SYNCHRO) end)
end

function s.acttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return s.e1check(e, tp) or s.e2check(e, tp) end

    local op = Duel.SelectEffect(tp, {s.e1check(e, tp), aux.Stringid(id, 1)}, {s.e2check(e, tp), aux.Stringid(id, 2)})
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
    if Duel.GetFlagEffect(tp, id + op * 1000) > 0 then return end

    Duel.RegisterFlagEffect(tp, id + op * 1000, RESET_PHASE + PHASE_END, 0, 1)
    if op == 1 then
        s.e1op(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 2 then
        s.e2op(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.e1check(e, tp)
    return Duel.GetFlagEffect(tp, id + 1 * 1000) == 0 and
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil) and
               Duel.IsPlayerCanDraw(tp, 2)
end

function s.e1filter(c) return c:IsType(TYPE_TUNER) and c:IsAbleToDeck() end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc =
        Utility.SelectMatchingCard(HINTMSG_TODECK, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()

    if Duel.SendtoDeck(tc, nil, 0, REASON_EFFECT) > 0 then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Draw(tp, 2, REASON_EFFECT)
    end
end

function s.e2check(e, tp)
    return Duel.GetFlagEffect(tp, id + 2 * 1000) == 0 and
               Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
end

function s.e2filter(c, e, tp)
    local mt = c:GetMetatable()
    local ct = 0
    if mt.synchro_tuner_required then ct = ct + mt.synchro_tuner_required end
    if mt.synchro_nt_required then ct = ct + mt.synchro_nt_required end

    return
        (c:IsSetCard(0xc2) or ((c:GetLevel() == 7 or c:GetLevel() == 8) and c:IsRace(RACE_DRAGON))) and c:IsType(TYPE_SYNCHRO) and
            ct == 0 and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false) and
            Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
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
end

function s.setfilter(c, tp)
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.setcon(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.setfilter, 1, nil, tp) end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSSetable() end

    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsSSetable() then return end

    Duel.SSet(tp, c)
end
