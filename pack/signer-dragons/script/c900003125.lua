-- Stardust Spark Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0xa3}

function s.initial_effect(c)
    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND + LOCATION_MZONE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsReleasable() end

    Duel.Release(c, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, c)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    ec1:SetCountLimit(1)
    ec1:SetValue(function(e, re, r, rp) return (r & REASON_BATTLE + REASON_EFFECT) ~= 0 end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
end

function s.e2filter1(c, e, tp, tuner)
    local rg = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, tuner)
    return c:IsSetCard(0xa3) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false) and
               aux.SelectUnselectGroup(rg, e, tp, nil, 2, s.e2rescon(tuner, c), 0)
end

function s.e2filter2(c) return
    c:HasLevel() and not c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c, true) end

function s.e2rescon(tuner, sc)
    return function(sg, e, tp, mg)
        sg:AddCard(tuner)
        local res = Duel.GetLocationCountFromEx(tp, tp, sg, sc) > 0 and
                        sg:CheckWithSumEqual(Card.GetLevel, sc:GetLevel(), #sg, #sg)
        sg:RemoveCard(tuner)
        return res
    end
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local pg = aux.GetMustBeMaterialGroup(tp, Group.CreateGroup(), tp, nil, nil, REASON_SYNCHRO)

    if chk == 0 then
        return #pg <= 0 and Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, c) and
                   c:IsAbleToRemoveAsCost()
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.e2filter1, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, c):GetFirst()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local rg = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, c)
    local sg = aux.SelectUnselectGroup(rg, e, tp, 1, 2, s.e2rescon(c, sc), 1, tp, HINTMSG_REMOVE, s.e2rescon(c, sc))
    sg:AddCard(c)

    Duel.Remove(sg, POS_FACEUP, REASON_COST)
    e:SetLabelObject(sc)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    if not tc or not tc:IsLocation(LOCATION_EXTRA) or not tc:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false) then
        return
    end

    if Duel.SpecialSummonStep(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP) then
        tc:CompleteProcedure()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3302)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_TRIGGER)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
    end
    Duel.SpecialSummonComplete()
end
