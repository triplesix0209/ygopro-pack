-- Ultimaya Black-Winged Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.counter_list = {COUNTER_FEATHER}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:EnableCounterPermit(COUNTER_FEATHER)

    -- synhcro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- add code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(CARD_BLACK_WINGED_DRAGON)
    c:RegisterEffect(code)

    -- place counter (effect damage)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1, 0)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e1b)

    -- place counter (battle damage)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(function(e, c) return c:GetCounter(COUNTER_FEATHER) * 100 end)
    c:RegisterEffect(e3)

    -- atk down
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e4:SetCondition(s.e4con1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetType(EFFECT_TYPE_QUICK_O)
    e4b:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e4b:SetCode(EVENT_FREE_CHAIN)
    e4b:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
    e4b:SetCondition(s.e4con2)
    c:RegisterEffect(e4b)
end

function s.e1val(e, re, val, r, rp, rc)
    if (r & REASON_EFFECT) ~= 0 then
        e:GetHandler():AddCounter(COUNTER_FEATHER, 1)
        return 0
    end
    return val
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    if ep ~= tp then return false end

    return (r & REASON_BATTLE) ~= 0 and not e:GetHandler():IsRelateToBattle()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp) e:GetHandler():AddCounter(COUNTER_FEATHER, 1) end

function s.e4con1(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetCounter(COUNTER_FEATHER) < 4 end

function s.e4con2(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetCounter(COUNTER_FEATHER) >= 4 end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return e:GetHandler():IsCanRemoveCounter(tp, COUNTER_FEATHER, 1, REASON_EFFECT) and
                   Duel.IsExistingTarget(aux.nzatk, tp, 0, LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, aux.nzatk, tp, 0, LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    local ct = c:GetCounter(COUNTER_FEATHER)
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() or ct == 0 then return end

    local preatk = tc:GetAttack()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(ct * -700)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)

    c:RemoveCounter(tp, COUNTER_FEATHER, ct, REASON_EFFECT)
    Duel.Damage(1 - tp, preatk - tc:GetAttack(), REASON_EFFECT)
end
