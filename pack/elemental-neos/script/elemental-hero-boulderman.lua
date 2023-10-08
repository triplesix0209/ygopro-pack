-- Elemental HERO Boulderman
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

    -- indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
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

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()

    local ec0 = Effect.CreateEffect(c)
    ec0:SetDescription(aux.Stringid(id, 1))
    ec0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec0:SetCode(id)
    ec0:SetTargetRange(1, 0)
    ec0:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec0, tp)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    ec1:SetTargetRange(LOCATION_MZONE, 0)
    ec1:SetTarget(function(e, tc) return tc:IsSetCard(SET_HERO) end)
    ec1:SetValue(aux.TRUE)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
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

    -- atk/def down
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    ec1:SetType(EFFECT_TYPE_QUICK_O)
    ec1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    ec1:SetCode(EVENT_FREE_CHAIN)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
    ec1:SetCountLimit(1)
    ec1:SetCondition(s.e3effcon)
    ec1:SetTarget(s.e3efftg)
    ec1:SetOperation(s.e3effop)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1, true)
end

function s.e3effcon(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or not Duel.IsDamageCalculated() end

function s.e3efftg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1, nil)
end

function s.e3effop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(-800)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(ec1b)
    end
end
