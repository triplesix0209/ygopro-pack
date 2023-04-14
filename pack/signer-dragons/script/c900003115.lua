-- Converging Wills Maiden
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_STARDUST_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- special summon (GY)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon (extra)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 3))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMING_MAIN_END)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.e2con)
    e2:SetCost(aux.CostWithReplace(s.e2cost, 84012625, function() return e2:GetLabel() == 1 end))
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp) return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, tc, sump, sumtype, sumpos, targetp, se)
        return tc:IsLocation(LOCATION_EXTRA) and not tc:IsType(TYPE_SYNCHRO)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e1filter), tp, LOCATION_GRAVE, 0, 1, 1,
        nil, e, tp):GetFirst()
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) ~= 0 and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_LVRANK)
        local lv = Duel.AnnounceLevel(tp, 1, 12, tc:GetLevel())

        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec2:SetCode(EFFECT_CHANGE_LEVEL)
        ec2:SetValue(lv)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end

function s.e2filter1(c, e, tp, rc)
    return (c:IsCode(CARD_STARDUST_DRAGON) or c:IsType(TYPE_TUNER)) and Duel.GetLocationCountFromEx(tp, tp, rc, c) > 0 and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.e2filter2(c, mg) return c:IsSynchroSummonable(nil, mg) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return (Duel.GetCurrentPhase() == PHASE_MAIN1 or Duel.GetCurrentPhase() == PHASE_MAIN2) and
               e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsReleasable() and Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, c)
    end

    Duel.Release(c, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        if c:IsReleasable() and Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) then
            e:SetLabel(1)
        else
            e:SetLabel(0)
        end
        return true
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e2filter1, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if not tc or Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP_DEFENSE) == 0 then return end

    tc:CompleteProcedure()
    local mg = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanBeSynchroMaterial), tp, LOCATION_MZONE, 0, nil)
    local eg = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_EXTRA, 0, nil, mg)
    if #eg > 0 and Duel.IsPlayerCanSpecialSummonCount(tp, 2) and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 4)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sc = eg:Select(tp, 1, 1, nil):GetFirst()
        if not sc then return end
        Duel.SynchroSummon(tp, sc, nil, mg)
    end
end
