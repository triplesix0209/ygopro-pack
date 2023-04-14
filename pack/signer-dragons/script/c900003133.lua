-- Majestic Salvation
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c)
    local mt = c:GetMetatable()
    local ct = 0
    if mt.synchro_tuner_required then ct = ct + mt.synchro_tuner_required end
    if mt.synchro_nt_required then ct = ct + mt.synchro_nt_required end

    return c:IsFaceup() and c:IsLevelAbove(10) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and ct > 0 and
               c:GetFlagEffect(id) == 0
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil) end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if not tc then return end

    Duel.HintSelection(tc)
    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))

    -- prevent negation
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CANNOT_INACTIVATE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_CANNOT_DISEFFECT)
    tc:RegisterEffect(ec1b)
    local ec1c = Effect.CreateEffect(c)
    ec1c:SetType(EFFECT_TYPE_SINGLE)
    ec1c:SetCode(EFFECT_CANNOT_DISABLE)
    tc:RegisterEffect(ec1c)

    -- indes
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetCountLimit(1)
    ec2:SetValue(function(e, re, r, rp) return (r & REASON_EFFECT + REASON_BATTLE) ~= 0 end)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec2)

    -- atk/def up
    local ec3 = Effect.CreateEffect(c)
    ec3:SetDescription(aux.Stringid(id, 1))
    ec3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec3:SetCode(EVENT_ATTACK_ANNOUNCE)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return Duel.GetAttacker() == e:GetHandler() end)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local tc = e:GetHandler()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(ec1b)
    end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec3)
end
