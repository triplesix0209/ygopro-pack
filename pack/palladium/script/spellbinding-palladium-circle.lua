-- Spellbinding Palladium Circle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.listed_series = {SET_PALLADIUM}

function s.initial_effect(c)
    -- can be activated from the hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(function(e)
        local tp = e:GetHandlerPlayer()
        return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 71703785), tp, LOCATION_ONFIELD, 0, 1, nil)
    end)
    c:RegisterEffect(e1)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCondition(s.e1con)
    e1:SetCost(aux.RemainFieldCost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or not Duel.IsDamageCalculated() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsLocation(LOCATION_SZONE) or not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end

    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then
        c:CancelToGrave(false)
        return
    end

    -- equip
    Duel.Equip(tp, c, tc)
    local eqlimit = Effect.CreateEffect(c)
    eqlimit:SetType(EFFECT_TYPE_SINGLE)
    eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
    eqlimit:SetValue(function(e, c) return c:IsFaceup() end)
    eqlimit:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(eqlimit)

    -- equip effect
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_EQUIP)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(-700)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1, true)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(ec2, true)
    local ec3 = ec1:Clone()
    ec3:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(ec3, true)
    local ec4 = ec1:Clone()
    ec4:SetCode(EFFECT_CANNOT_TRIGGER)
    c:RegisterEffect(ec4, true)
    local ec5 = ec1:Clone()
    ec5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    c:RegisterEffect(ec5, true)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or not Duel.IsDamageCalculated() end

function s.e2descon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end

    local tc = c:GetFirstCardTarget()
    return tc and eg:IsContains(tc)
end

function s.e2desop(e, tp, eg, ep, ev, re, r, rp) Duel.Destroy(e:GetHandler(), REASON_EFFECT) end

function s.e2filter(c) return c:IsFaceup() and c:IsLevelAbove(6) and c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(SET_PALLADIUM) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return aux.exccon(e) and Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_ONFIELD, 0, 1, nil) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKBOTTOM, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(Card.IsNegatable, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local g = Duel.SelectTarget(tp, Card.IsNegatable, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc and not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsDisabled() then return end

    Duel.NegateRelatedChain(tc, RESET_TURN_SET)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    ec1b:SetValue(RESET_TURN_SET)
    tc:RegisterEffect(ec1b)
    if tc:IsType(TYPE_TRAPMONSTER) then
        local ec1c = ec1:Clone()
        ec1c:SetCode(EFFECT_DISABLE_TRAPMONSTER)
        tc:RegisterEffect(ec1c)
    end
end
