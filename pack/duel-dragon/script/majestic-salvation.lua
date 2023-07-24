-- Majestic Salvation
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_MAJESTIC}

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
    return c:IsFaceup() and c:IsSetCard(SET_MAJESTIC) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:GetFlagEffect(id) == 0
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil) end end

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

    -- cannot be tributed, nor be used as a material
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CANNOT_RELEASE)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetTargetRange(0, 1)
    ec2:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    tc:RegisterEffect(ec2)
    local ec2b = Effect.CreateEffect(c)
    ec2b:SetType(EFFECT_TYPE_SINGLE)
    ec2b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    ec2b:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    tc:RegisterEffect(ec2b)

    -- no return
    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_SINGLE)
    ec3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCode(EFFECT_CANNOT_TO_DECK)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec3)

    -- untargetable
    local ec4 = Effect.CreateEffect(c)
    ec4:SetDescription(3031)
    ec4:SetType(EFFECT_TYPE_SINGLE)
    ec4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    ec4:SetRange(LOCATION_MZONE)
    ec4:SetValue(aux.tgoval)
    ec4:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec4)
end
