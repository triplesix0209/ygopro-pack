-- Odd-Eyes Synchro Gate
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {16178681, 900005029}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, function(c) return not c:IsSummonType(SUMMON_TYPE_PENDULUM) end)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter1(c, e, tp)
    return c:IsFaceup() and c:IsCode(16178681) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               (not c:IsLocation(LOCATION_EXTRA) or Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0) and
               Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_GRAVE, 0, 1, nil, e, tp, c)
end

function s.e1filter2(c, e, tp, odd)
    return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               Duel.IsExistingMatchingCard(s.e1filter3, tp, LOCATION_EXTRA, 0, 1, odd, e, tp, odd, c)
end

function s.e1filter3(c, e, tp, odd, syn)
    if not c:IsType(TYPE_SYNCHRO) or not c:IsType(TYPE_PENDULUM) then return false end

    local ec1 = Effect.CreateEffect(e:GetHandler())
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_CHANGE_LEVEL)
    ec1:SetValue(1)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    odd:RegisterEffect(ec1)
    odd:AssumeProperty(ASSUME_TYPE, odd:GetType() | TYPE_TUNER)
    local result = c:IsSynchroSummonable(nil, Group.FromCards(odd, syn))
    ec1:Reset()
    Duel.AssumeReset()
    return result
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0 end

    aux.RegisterClientHint(c, 0, tp, 1, 0, aux.Stringid(id, 0))
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c, sump, sumtype, sumpos, targetp, se) return sumtype & SUMMON_TYPE_PENDULUM == SUMMON_TYPE_PENDULUM end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and Duel.IsPlayerCanSpecialSummonCount(tp, 2) and
                   aux.CheckSummonGate(tp, 2) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.GetUsableMZoneCount(tp) >= 2 and
                   Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, 0, LOCATION_GRAVE + LOCATION_EXTRA)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 or
        Duel.GetLocationCountFromEx(tp, tp, nil, TYPE_PENDULUM) <= 0 or Duel.GetUsableMZoneCount(tp) <= 1 then return end

    local tc1 = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter1, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    local tc2 = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter2, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp, tc1):GetFirst()
    local sg = Group.FromCards(tc1, tc2)
    if Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        for tc in sg:Iter() do if tc:IsLocation(LOCATION_MZONE) then s.e1disop(c, tc) end end
    else
        return
    end
    Duel.BreakEffect()

    local g = Duel.GetMatchingGroup(function(sc) return sc:IsType(TYPE_PENDULUM) and sc:IsSynchroSummonable(nil, sg) end, tp, LOCATION_EXTRA, 0, nil)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sc = g:Select(tp, 1, 1, nil):GetFirst()
        Duel.SynchroSummon(tp, sc, nil, sg)

        c:CancelToGrave()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_SPSUMMON_SUCCESS)
        ec1:SetLabelObject(c)
        ec1:SetCountLimit(1)
        ec1:SetOperation(function(e)
            local c = e:GetLabelObject()
            local sc = e:GetHandler()

            Duel.Equip(tp, c, sc, true)
            local eqlimit = Effect.CreateEffect(sc)
            eqlimit:SetType(EFFECT_TYPE_SINGLE)
            eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
            eqlimit:SetValue(function(e, c) return e:GetOwner() == c end)
            eqlimit:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(eqlimit)
        end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
        sc:RegisterEffect(ec1, true)
    end
end

function s.e1disop(c, tc)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1b)

    if tc:IsCode(16178681) then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_CHANGE_LEVEL)
        ec2:SetValue(1)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
        local ec2b = ec2:Clone()
        ec2b:SetCode(EFFECT_ADD_TYPE)
        ec2b:SetValue(TYPE_TUNER)
        tc:RegisterEffect(ec2b)
    end
end

function s.e2filter(c) return c:IsCode(900005029) and c:IsAbleToHand() end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local eqc = c:GetPreviousEquipTarget()
    return c:IsReason(REASON_LOST_TARGET) and not eqc:IsLocation(LOCATION_ONFIELD + LOCATION_OVERLAY)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e2filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
