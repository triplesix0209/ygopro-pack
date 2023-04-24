-- Palladium Archfiend Gilfer
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- summon with no tribute
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- equip
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    aux.AddEREquipLimit(c, nil, aux.FilterBoolFunction(Card.IsMonster), Card.EquipByEffectAndLimitRegister, e2)
end

function s.e1con(e, c, minc)
    if c == nil then return true end
    return minc == 0 and c:GetLevel() > 4 and Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(574)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetCountLimit(1)
    ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT) end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
    c:RegisterEffect(ec1)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 or not c:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    -- equip
    Duel.Equip(tp, c, tc, true)
    local eqlimit = Effect.CreateEffect(tc)
    eqlimit:SetType(EFFECT_TYPE_SINGLE)
    eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
    eqlimit:SetValue(function(e, c) return e:GetOwner() == c end)
    eqlimit:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(eqlimit)

    -- down atk
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_EQUIP)
    ec2:SetCode(EFFECT_UPDATE_ATTACK)
    ec2:SetValue(-500)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec2)
    local ec2b = ec2:Clone()
    ec2b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(ec2b)
end
