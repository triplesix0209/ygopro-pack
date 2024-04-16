-- Strike of the Nordic Lord
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- unaffected
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMING_END_PHASE)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- return to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(aux.exccon)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsFaceup() and Utility.IsSetCardListed(c, 0x4b, 0x42)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3110)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_IMMUNE_EFFECT)
    ec1:SetValue(function(e, re)
        return e:GetOwnerPlayer() == 1 - re:GetOwnerPlayer()
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)

    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_ONFIELD,
                                    LOCATION_ONFIELD, c)
    if not tc:IsSetCard(0x4b) or #g == 0 or
        not Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    g = g:Select(tp, 1, 1, nil)
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e2filter(c) return c:IsFaceup() and c:IsSetCard(0x4b) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g =
        Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or tc:IsFacedown() or
        not tc:IsRelateToEffect(e) or Duel.Destroy(tc, REASON_EFFECT) == 0 then
        return
    end

    Duel.SendtoHand(c, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, c)
end
