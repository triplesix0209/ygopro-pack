-- Elemental HERO Astrum Neos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_NEOS, SET_NEO_SPACIAN}
s.material_setcode = {SET_HERO}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, aux.FilterBoolFunctionEx(Card.IsSetCard, SET_HERO), aux.FilterBoolFunctionEx(Card.IsLevelBelow, 5))

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st) return aux.fuslimit(e, se, sp, st) or not e:GetHandler():IsLocation(LOCATION_EXTRA) end)
    c:RegisterEffect(splimit)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_EXTRA)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- special summon neo-spacian
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.spfilter(c, tp, sc)
    return c:IsControler(tp) and Duel.GetLocationCountFromEx(tp, tp, c, sc) > 0 and c:IsAbleToDeckOrExtraAsCost() and
               c:IsSetCard(SET_NEOS, sc, MATERIAL_FUSION, tp) and c:IsLevel(7)
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_MZONE, 0, 1, nil, tp, c)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp, c)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
    g:DeleteGroup()
end

function s.e1filter(c, e, tp) return c:IsSetCard(SET_NEO_SPACIAN) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3206)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)

        if c:IsFaceup() and c:IsRelateToEffect(e) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_UPDATE_ATTACK)
            ec1:SetValue(tc:GetAttack())
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_OPPO_TURN)
            c:RegisterEffect(ec1)
        end
    end
end
