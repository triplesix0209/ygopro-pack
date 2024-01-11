-- The Seed of Fallen Paradise
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {13301895, 6007213, 32491822, 69890967}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- protect spell
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_ONFIELD, 0)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return s.sbcount(e:GetHandlerPlayer()) >= 1 end)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSpellTrap))
    e1:SetValue(aux.indoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetProperty(EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_IGNORE_IMMUNE)
    e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1b:SetValue(aux.tgoval)
    c:RegisterEffect(e1b)

    -- activate trap from hand
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_HAND, 0)
    e2:SetCountLimit(1)
    e2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return s.sbcount(e:GetHandlerPlayer()) >= 2 end)
    c:RegisterEffect(e2)

    -- attach spell/trap
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return s.sbcount(e:GetHandlerPlayer()) >= 3 end)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter1(c) return c:IsCode(13301895) end

function s.e1filter2(c) return c:ListsCode(6007213, 32491822, 69890967) and c:IsAbleToHand() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, c) end
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e1filter1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, c):GetFirst()
    Duel.Overlay(c, tc)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_CHANGE_CODE)
    ec1:SetValue(tc:GetOriginalCode())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
    c:CopyEffect(tc:GetCode(), RESET_EVENT + RESETS_STANDARD)

    local g = Duel.GetMatchingGroup(s.e1filter2, tp, LOCATION_DECK, 0, nil)
    if #g > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        local sg = Utility.GroupSelect(HINTMSG_SELECT, g, tp, 1, 1, nil)
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
    end
end

function s.e2tg1(e, c) return c:IsFaceup() and (c:IsCode(6007213, 32491822, 69890967) or (c:IsSetCard(0x145) and c:IsType(TYPE_FUSION))) end

function s.e2tg2(e, c, rp, r, re)
    local tp = e:GetHandlerPlayer()
    return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and rp == 1 - tp and r == REASON_EFFECT and
               (c:IsCode(6007213, 32491822, 69890967) or (c:IsSetCard(0x145) and c:IsType(TYPE_FUSION)))
end

function s.e2val(e, re, rp) return rp == 1 - e:GetHandlerPlayer() end

function s.sbfilter(c) return c:IsFaceup() and c:IsCode(6007213, 32491822, 69890967) end

function s.sbcount(tp) return Duel.GetMatchingGroup(s.sbfilter, tp, LOCATION_ONFIELD, 0, nil):GetClassCount(Card.GetCode) end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 2) end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end

function s.e3filter(c, og)
    return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and c:ListsCode(6007213, 32491822, 69890967) and
               not og:IsExists(Card.IsCode, 1, nil, c:GetCode())
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup()
    if chk == 0 then return Duel.IsExistingTarget(s.e3filter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, c, og) end

    local g = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, 1, c, og)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end

    Duel.Overlay(c, tc)
    c:CopyEffect(tc:GetCode(), RESET_EVENT + RESETS_STANDARD)
end
