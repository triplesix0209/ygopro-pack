-- Utopic Astral Genesis
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x54, 0x59, 0x82, 0x8f, 0x48}

function s.initial_effect(c)
    c:AddSetcodesRule(0x54, 0x59, 0x82, 0x8f)

    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- effect gains
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter1(c) return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) end

function s.e1filter2(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and
               Utility.IsSetCard(c, 0x54, 0x59, 0x82, 0x8f)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_EXTRA, 0,
                                           1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local tc = Duel.SelectMatchingCard(tp, s.e1filter1, tp, LOCATION_EXTRA, 0,
                                       1, 1, nil):GetFirst()
    Duel.ConfirmCards(1 - tp, tc)
    e:SetLabelObject(tc)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()

    local rk = tc:GetRank()
    local attr = tc:GetAttribute()
    local g = Duel.GetMatchingGroup(s.e1filter2, tp, LOCATION_MZONE, 0, nil)
    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CHANGE_LEVEL)
        ec1:SetValue(rk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        ec1b:SetValue(attr)
        tc:RegisterEffect(ec1b)
    end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, 1))
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec2:SetTargetRange(1, 0)
    ec2:SetTarget(function(e, c)
        return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
    end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
    aux.addTempLizardCheck(c, tp, function(e, c)
        return not c:IsOriginalType(TYPE_XYZ)
    end)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return r == REASON_XYZ end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local ec1 = Effect.CreateEffect(rc)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetCategory(CATEGORY_DRAW)
    ec1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EVENT_SPSUMMON_SUCCESS)
    ec1:SetCondition(s.e2drcon)
    ec1:SetTarget(s.e2drtg)
    ec1:SetOperation(s.e2drop)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec1, true)

    if not rc:IsType(TYPE_EFFECT) then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_ADD_TYPE)
        ec2:SetValue(TYPE_EFFECT)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        rc:RegisterEffect(ec2, true)
    end
end

function s.e2drcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.e2drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2drop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end
