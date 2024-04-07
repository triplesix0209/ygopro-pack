-- Rose Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- synchro level
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EFFECT_SYNCHRO_LEVEL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c) return 4 * 65536 + e:GetHandler():GetLevel() end)
    c:RegisterEffect(e1)

    -- grave synchro summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.e2counterfilter)
end

function s.e2counterfilter(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO) end

function s.e2filter1(c, e, tp)
    local lv = e:GetHandler():GetLevel()
    return c:HasLevel() and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove() and
               Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_EXTRA, 0, 1, nil, c:GetLevel() + lv, e, tp)
end

function s.e2filter2(c, lv, e, tp)
    return (c:IsRace(RACE_PLANT) or c:IsSetCard(SET_ROSE_DRAGON)) and c:IsType(TYPE_SYNCHRO) and c:GetLevel() == lv and
               Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0 and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, tc, sump, st, sumpos, targetp, se) return tc:IsLocation(LOCATION_EXTRA) and not tc:IsType(TYPE_SYNCHRO) end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    aux.addTempLizardCheck(c, tp, function(e, c) return not c:IsOriginalType(TYPE_SYNCHRO) end)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, 69832741) and c:IsAbleToRemove() and
                   Duel.IsExistingTarget(s.e2filter1, tp, LOCATION_GRAVE, 0, 1, c, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, s.e2filter1, tp, LOCATION_GRAVE, 0, 1, 1, c, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end

    local rg = Group.FromCards(c, tc)
    if Duel.Remove(rg, POS_FACEUP, REASON_EFFECT) == #rg then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sc = Duel.SelectMatchingCard(tp, s.e2filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, tc:GetLevel() + c:GetLevel(), e, tp):GetFirst()
        if sc and Duel.SpecialSummon(sc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP) > 0 then sc:CompleteProcedure() end
    end
end
