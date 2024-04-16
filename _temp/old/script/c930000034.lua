-- Way the Nordic Realm
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- recover
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- return to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetTarget(s.e2tg)
    e2:SetValue(s.e2val)
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
    local tc = Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1,
                                 nil):GetFirst()

    local rec
    local op = Duel.SelectOption(tp, aux.Stringid(id, 0), aux.Stringid(id, 1))
    e:SetLabel(op)
    if op == 0 then
        rec = tc:GetAttack()
    else
        rec = tc:GetDefense()
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, tc, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, rec)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or
        Duel.Destroy(tc, REASON_EFFECT) == 0 then return end

    local rec
    if e:GetLabel() == 0 then
        rec = tc:GetAttack()
    else
        rec = tc:GetDefense()
    end
    Duel.Recover(tp, rec, REASON_EFFECT)

    if tc:IsSetCard(0x4b) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 2))
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CHANGE_DAMAGE)
        ec1:SetTargetRange(1, 0)
        ec1:SetValue(0)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
        Duel.RegisterEffect(ec1b, tp)
    end
end

function s.e2filter(c, tp)
    return c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and
               c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and
               c:IsReason(REASON_EFFECT + REASON_BATTLE) and c:IsSetCard(0x4b)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsAbleToRemove() and eg:IsExists(s.e2filter, 1, nil, tp)
    end

    return Duel.SelectEffectYesNo(tp, c, 96)
end

function s.e2val(e, c) return s.e2filter(c, e:GetHandlerPlayer()) end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_EFFECT)
end
