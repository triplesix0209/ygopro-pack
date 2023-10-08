-- Elemental HERO Wingman
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_HERO, SET_ELEMENTAL_HERO}

function s.initial_effect(c)
    -- normal monster
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE + LOCATION_ONFIELD)
    e1:SetValue(TYPE_NORMAL)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_REMOVE_TYPE)
    e1b:SetValue(TYPE_EFFECT)
    c:RegisterEffect(e1b)

    -- special summon itself
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER + EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter(c) return c:IsSetCard(SET_HERO) and c:IsDiscardable() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND, 0, 1, c) end
    Duel.DiscardHand(tp, s.e2filter, 1, 1, REASON_COST + REASON_DISCARD, c)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3300)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        ec1:SetValue(LOCATION_REMOVED)
        ec1:SetReset(RESET_EVENT + RESETS_REDIRECT)
        c:RegisterEffect(ec1, true)
    end
end

function s.e3filter(c) return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_ELEMENTAL_HERO) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e3filter, 1, nil) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = eg:Filter(s.e3filter, nil, SET_HERO):GetFirst()
    if not tc then return end

    tc:RegisterFlagEffect(0, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
    if not tc:IsType(TYPE_EFFECT) then
        local ec0 = Effect.CreateEffect(c)
        ec0:SetType(EFFECT_TYPE_SINGLE)
        ec0:SetCode(EFFECT_ADD_TYPE)
        ec0:SetValue(TYPE_EFFECT)
        ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec0, true)
    end

    -- atk up
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(400)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1, true)
end
