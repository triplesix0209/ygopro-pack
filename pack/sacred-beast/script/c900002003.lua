-- Raviel, Ruler of Phantasm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {69890968}

local PHANTASM_TOKEN = 69890968

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_HAND)
    spr:SetCondition(s.sprcon)
    spr:SetTarget(s.sprtg)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)

    -- special summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(spsafe)

    -- no change control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(nomaterial)

    -- disable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_BATTLED)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon tokens
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con1)
    e2:SetOperation(s.e2op1)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2c)
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2reg:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2reg:SetRange(LOCATION_MZONE)
    e2reg:SetCondition(s.e2regcon)
    e2reg:SetOperation(s.e2regop)
    c:RegisterEffect(e2reg)
    local e2sp = e2reg:Clone()
    e2sp:SetCode(EVENT_CHAIN_SOLVED)
    e2sp:SetCondition(s.e2con2)
    e2sp:SetOperation(s.e2op2)
    c:RegisterEffect(e2sp)

    -- tribute atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.e3cost)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.sprfilter(c, tp) return c:IsRace(RACE_FIEND) and (c:IsControler(tp) or c:IsFaceup()) end

function s.sprcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local rg = Duel.GetReleaseGroup(tp):Filter(s.sprfilter, nil, tp)
    return aux.SelectUnselectGroup(rg, e, tp, 3, 3, aux.ChkfMMZ(1), 0)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, c)
    local rg = Duel.GetReleaseGroup(tp):Filter(s.sprfilter, nil, tp)
    local mg = aux.SelectUnselectGroup(rg, e, tp, 3, 3, aux.ChkfMMZ(1), 1, tp, HINTMSG_RELEASE, nil, nil, true)
    if #mg == 3 then
        mg:KeepAlive()
        e:SetLabelObject(mg)
        return true
    end
    return false
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.Release(g, REASON_COST)
    g:DeleteGroup()
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = Duel.GetAttackTarget()
    if bc == c then bc = Duel.GetAttacker() end

    if bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsStatus(STATUS_BATTLE_DESTROYED) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
        bc:RegisterEffect(ec1)
    end
end

function s.e2filter(c, tp)
    if c:IsLocation(LOCATION_MZONE) then
        return c:IsFaceup() and c:GetSummonPlayer() ~= tp
    else
        return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetSummonPlayer() ~= tp
    end
end

function s.e2con1(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e2filter, 1, nil, tp) and
               (not re or (not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS)))
end

function s.e2op1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.IsPlayerCanSpecialSummonMonster(tp, PHANTASM_TOKEN, 0, TYPES_TOKEN, 1000, 1000, 1, RACE_FIEND, ATTRIBUTE_DARK) and
        Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        Utility.HintCard(c)

        local token = Duel.CreateToken(tp, PHANTASM_TOKEN)
        Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        token:RegisterEffect(ec1, true)
    end
end

function s.e2regcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e2filter, 1, nil, tp) and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end

function s.e2regop(e, tp, eg, ep, ev, re, r, rp) Duel.RegisterFlagEffect(tp, id, RESET_CHAIN, 0, 1) end

function s.e2con2(e, tp, eg, ep, ev, re, r, rp) return Duel.GetFlagEffect(tp, id) > 0 end

function s.e2op2(e, tp, eg, ep, ev, re, r, rp)
    Duel.ResetFlagEffect(tp, id)
    s.e2op1(e, tp, eg, ep, ev, re, r, rp)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 1, false, nil, c) end

    local g = Duel.SelectReleaseGroupCost(tp, Card.IsFaceup, 1, 2, false, nil, c)
    e:SetLabel(g:GetSum(Card.GetAttack))
    Duel.Release(g, REASON_COST)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(e:GetLabel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end
