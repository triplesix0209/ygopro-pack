-- Thousand Palladium Arrows
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.listed_series = {SET_PALLADIUM}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- banish
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
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

function s.e1filter1(c) return c:IsFaceup() and c:IsSetCard(SET_PALLADIUM) end

function s.e1filter2(c) return c:IsFaceup() and c:IsCode(71703785) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_MZONE, 0, 1, nil) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT) > 0 and
        Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_MZONE, 0, 1, nil) then
        local sc = Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e1filter2, tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(500)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        sc:RegisterEffect(ec1)
    end
end

function s.e2filter(c) return c:IsFaceup() and c:IsLevelAbove(6) and c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(SET_PALLADIUM) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return aux.exccon(e) and Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_ONFIELD, 0, 1, nil) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKBOTTOM, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToRemove), tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, aux.FaceupFilter(Card.IsAbleToRemove), tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Remove(tc, 0, REASON_EFFECT + REASON_TEMPORARY) ~= 0 then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetLabelObject(tc)
        ec1:SetCountLimit(1)
        ec1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetLabelObject():GetFlagEffect(id) ~= 0 end)
        ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) Duel.ReturnToField(e:GetLabelObject()) end)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end
