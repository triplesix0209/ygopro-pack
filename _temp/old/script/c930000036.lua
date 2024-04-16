-- Nordic Horror - Ouroboros Break
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {64203620}
s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- act in hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    c:RegisterEffect(e1)

    -- equip
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_EQUIP + CATEGORY_DISABLE + CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCondition(s.e2con)
    e2:SetCost(aux.RemainFieldCost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- search
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter(c, e, tp)
    return c:IsFaceup() and aux.CheckStealEquip(c, e, tp)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,
                                                                0x4b), tp,
                                       LOCATION_MZONE, 0, 1, nil)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return e:IsHasType(EFFECT_TYPE_ACTIVATE) and
                   Duel.IsExistingTarget(s.e2filter, tp, 0, LOCATION_MZONE, 1,
                                         nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, 0, LOCATION_MZONE, 1, 1,
                                nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_CONTROL, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsLocation(LOCATION_SZONE) or not c:IsRelateToEffect(e) or
        c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then
        c:CancelToGrave(false)
        return
    end

    Duel.Equip(tp, c, tc)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_EQUIP_LIMIT)
    ec1:SetValue(function(e, c)
        return c:GetControler() == e:GetHandlerPlayer() or
                   e:GetHandler():GetEquipTarget() == c
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_EQUIP)
    ec2:SetCode(EFFECT_CANNOT_TRIGGER)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec2)
    local ec2b = ec2:Clone()
    ec2b:SetCode(EFFECT_DISABLE)
    c:RegisterEffect(ec2b)
    local ec2c = ec2:Clone()
    ec2c:SetCode(EFFECT_DISABLE_TRAPMONSTER)
    c:RegisterEffect(ec2c)

    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_EQUIP)
    ec3:SetCode(EFFECT_SET_CONTROL)
    ec3:SetValue(function(e) return e:GetHandlerPlayer() end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec3)
end

function s.e3filter(c) return c:IsCode(64203620) and c:IsAbleToHand() end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e3filter), tp,
                                    LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g == 0 then return end

    g = Utility.GroupSelect(g, tp, 1, 1, HINTMSG_ATOHAND)
    Duel.SendtoHand(g, tp, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, g)
end
