-- The Seed of Fallen Paradise
Duel.LoadScript("util.lua")
local s, id = GetID()
s.listed_names = {6007213, 32491822, 69890967, 43378048}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- protect sacred beast
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_ONFIELD, 0)
    e2:SetTarget(s.e2tg1)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2b:SetValue(s.e2val)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_PLAYER_TARGET)
    e2c:SetCode(EFFECT_CANNOT_REMOVE)
    e2c:SetTargetRange(1, 1)
    e2c:SetTarget(s.e2tg2)
    c:RegisterEffect(e2c)

    -- draw
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return s.sbcount(e:GetHandlerPlayer()) >= 1 end)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- untargetable & indes
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return s.sbcount(e:GetHandlerPlayer()) >= 2 end)
    e5:SetValue(aux.tgoval)
    c:RegisterEffect(e5)
    local e5b = e5:Clone()
    e5b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e5b:SetValue(function(e, re, tp) return tp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e5b)

    -- attach spell/trap
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 2))
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCountLimit(1)
    e6:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return s.sbcount(e:GetHandlerPlayer()) >= 3 end)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e1filter(c) return c:ListsCode(6007213, 32491822, 69890967) and c:IsAbleToHand() end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_DECK, 0, nil)
    if #g > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        local sg = Utility.GroupSelect(HINTMSG_SELECT, g, tp, 1, 1, nil)
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
    end
end

function s.e2tg1(e, c) return c:IsFaceup() and c:IsCode(6007213, 32491822, 69890967, 43378048) end

function s.e2tg2(e, c, rp, r, re)
    local tp = e:GetHandlerPlayer()
    return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and rp == 1 - tp and r == REASON_EFFECT and
               c:IsCode(6007213, 32491822, 69890967, 43378048)
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

function s.e6filter(c, og) return c:IsType(TYPE_CONTINUOUS) and not og:IsExists(Card.IsCode, 1, nil, c:GetCode()) end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup()
    if chk == 0 then return Duel.IsExistingTarget(s.e6filter, tp, LOCATION_GRAVE, 0, 1, c, og) end

    local g = Duel.SelectTarget(tp, s.e6filter, tp, LOCATION_GRAVE, 0, 1, 1, c, og)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, #g, 0, 0)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end

    Duel.Overlay(c, tc)
    c:CopyEffect(tc:GetCode(), RESET_EVENT + RESETS_STANDARD)
end
