-- Spellbinding Palladium Circle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- can be activated from the hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 71703785), e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
    end)
    c:RegisterEffect(e1)

    -- activate
    aux.AddPersistentProcedure(c, 1, aux.FilterBoolFunction(Card.IsFaceup), CATEGORY_POSITION, EFFECT_FLAG_DAMAGE_STEP, TIMING_DAMAGE_STEP,
        TIMING_DAMAGE_STEP, s.e2con)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e2:SetTarget(aux.PersistentTargetFilter)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EFFECT_DISABLE)
    c:RegisterEffect(e2c)
    local e2d = e2:Clone()
    e2d:SetCode(EFFECT_UPDATE_ATTACK)
    e2d:SetValue(-700)
    c:RegisterEffect(e2d)
    local e2e = e2d:Clone()
    e2e:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2e)
    local e2leave = Effect.CreateEffect(c)
    e2leave:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e2leave:SetRange(LOCATION_SZONE)
    e2leave:SetCode(EVENT_LEAVE_FIELD)
    e2leave:SetCondition(s.e2descon)
    e2leave:SetOperation(s.e2desop)
    c:RegisterEffect(e2leave)

    -- change attribute & race
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or not Duel.IsDamageCalculated() end

function s.e2descon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end

    local tc = c:GetFirstCardTarget()
    return tc and eg:IsContains(tc)
end

function s.e2desop(e, tp, eg, ep, ev, re, r, rp) Duel.Destroy(e:GetHandler(), REASON_EFFECT) end

function s.e3filter(c) return c:IsFaceup() and c:IsLevelAbove(6) and c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x13a) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return aux.exccon(e) and Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_ONFIELD, 0, 1, nil) end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKBOTTOM, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1, nil)

    local attr = Duel.AnnounceAttribute(tp, 1, ATTRIBUTE_ALL)
    local race = Duel.AnnounceRace(tp, 1, RACE_ALL)
    e:SetLabelObject({attr, race})
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc and not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local attr = e:GetLabelObject()[1]
    local race = e:GetLabelObject()[2]
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    ec1:SetValue(attr)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_CHANGE_RACE)
    ec2:SetValue(race)
    tc:RegisterEffect(ec2)
end
