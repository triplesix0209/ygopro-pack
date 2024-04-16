-- Divine Nordic Relic Brisingamen
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {930000002}
s.listed_series = {0x4b}

function s.initial_effect(c)
    -- atk
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id + 2000000)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return c:IsFaceup() and Utility.IsSetCard(c, 0x4b, 0x42) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or
               not Duel.IsDamageCalculated()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return
            Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil) and
                Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1,
                                      nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELF)
    local tc = Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1,
                                 nil):GetFirst()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_OPPO)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1, nil)
    e:SetLabelObject(tc)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    local tc1 = tg:GetFirst()
    local tc2 = tg:GetNext()
    if tc1:IsFacedown() or not tc1:IsRelateToEffect(e) or tc2:IsFacedown() or
        not tc2:IsRelateToEffect(e) then return end
    local ac = e:GetLabelObject()
    if tc2 == ac then
        tc2 = tc1
        tc1 = ac
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(tc2:GetAttack())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc1:RegisterEffect(ec1)

    if tc1:IsSetCard(0x4b) then
        tc1:RegisterFlagEffect(id,
                               RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                   PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0,
                               aux.Stringid(id, 0))

        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        ec2:SetCode(EVENT_BATTLE_DESTROYING)
        ec2:SetCondition(aux.bdcon)
        ec2:SetOperation(function(e, tp)
            Utility.HintCard(id)
            Duel.Damage(1 - tp,
                        e:GetHandler():GetBattleTarget():GetBaseAttack(),
                        REASON_EFFECT)
        end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc1:RegisterEffect(ec2)
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return aux.exccon(e) and
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsCode, 930000002), tp,
                   LOCATION_MZONE, 0, 1, nil)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SendtoHand(c, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, c)
end
