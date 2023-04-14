-- Rush Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1017}

function s.initial_effect(c)
    -- extra summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- change lv
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetFlagEffect(tp, id) ~= 0 then return end

    Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    ec1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x1017))
    ec1:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2filter(c) return c:IsFaceup() and c:HasLevel() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_MZONE, 0, 1, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tc = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_MZONE, 0, 1, 1, c):GetFirst()

    local op = 0
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EFFECT)
    if tc:GetLevel() == 1 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 2))
    else
        op = Duel.SelectOption(tp, aux.Stringid(id, 2), aux.Stringid(id, 3))
    end
    e:SetLabel(op)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_LEVEL)
    if e:GetLabel() == 0 then
        ec1:SetValue(2)
    else
        ec1:SetValue(-2)
    end
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
end
