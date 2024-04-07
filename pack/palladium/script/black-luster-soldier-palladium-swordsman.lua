-- Black Luster Soldier - Palladium Swordsman
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_CHAOS, SET_BLACK_LUSTER_SOLDIER}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(Card.IsAttribute, ATTRIBUTE_LIGHT + ATTRIBUTE_DARK), 1, 99,
        function(c, sc, st, tp) return c:IsAttribute(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK, sc, st, tp) end)

    -- register if a card is removed
    aux.GlobalCheck(s, function()
        local ge1 = Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_REMOVE)
        ge1:SetOperation(function() Duel.RegisterFlagEffect(0, id, RESET_PHASE | PHASE_END, 0, 1) end)
        Duel.RegisterEffect(ge1, 0)
    end)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function() return Duel.HasFlagEffect(0, id) end)
    e1:SetValue(function(e, re) return e:GetOwnerPlayer() == 1 - re:GetOwnerPlayer() end)
    c:RegisterEffect(e1)

    -- temp banish
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetCost(aux.bfgcost)
    e3:SetCondition(aux.exccon)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsMainPhase() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToRemove, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, Card.IsAbleToRemove, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Remove(tc, 0, REASON_EFFECT + REASON_TEMPORARY) > 0 then
        local ct = Duel.GetCurrentPhase() <= PHASE_STANDBY and 2 or 1
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD - RESET_TEMP_REMOVE + RESET_PHASE + PHASE_STANDBY, 0, ct)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_PHASE + PHASE_STANDBY)
        ec1:SetCountLimit(1)
        ec1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            return Duel.GetTurnCount() > e:GetLabel() and e:GetLabelObject():GetFlagEffect(id) > 0
        end)
        ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            Duel.Hint(HINT_SELECTMSG, 1 - tp, HINTMSG_ZONE)
            Duel.ReturnToField(e:GetLabelObject())
        end)
        ec1:SetReset(RESET_PHASE + PHASE_STANDBY, ct)
        ec1:SetLabel(Duel.GetTurnCount())
        ec1:SetLabelObject(tc)
        Duel.RegisterEffect(ec1, tp)
        tc:SetReasonEffect(ec1)
    end
end

function s.e3filter(c, e, tp)
    return not c:IsCode(id) and c:IsCanBeSpecialSummoned(e, 0, tp, true, false, POS_FACEUP) and
               (c:IsSetCard(SET_BLACK_LUSTER_SOLDIER) or (c:IsSetCard(SET_CHAOS) and c:IsType(TYPE_SYNCHRO)))
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e3filter, tp, LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, 1, nil, e, tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
        tc:CompleteProcedure()
    end
end
