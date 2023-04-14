-- Yubel - The Ultimate Phantasmal Nightmare
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {31764700, 43378048, 900002008}
s.material_setcode = {0x145}

local PHANTASMAL_NIGHTMARE_TOKEN = 900002008

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, 31764700, function(c, fc, sumtype, tp)
        return c:IsType(TYPE_FUSION, fc, sumtype, tp) and c:IsSetCard(0x145, fc, sumtype, tp)
    end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.fuslimit)
    c:RegisterEffect(splimit)

    -- no change control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- add name
    local addname = Effect.CreateEffect(c)
    addname:SetType(EFFECT_TYPE_SINGLE)
    addname:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    addname:SetCode(EFFECT_ADD_CODE)
    addname:SetRange(LOCATION_MZONE)
    addname:SetValue(43378048)
    c:RegisterEffect(addname)

    -- no change battle position
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

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

    -- indes
    local indes = Effect.CreateEffect(c)
    indes:SetType(EFFECT_TYPE_SINGLE)
    indes:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    indes:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    indes:SetValue(1)
    c:RegisterEffect(indes)

    -- reflect battle damage
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- destroy
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2reg:SetCode(EVENT_BATTLED)
    e2reg:SetOperation(s.e2regop)
    c:RegisterEffect(e2reg)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    e2:SetLabelObject(e2reg)
    c:RegisterEffect(e2)

    -- banish & special summon token
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_REMOVE + CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if bc and c:IsAttackPos() then
        e:SetLabelObject(bc)
    else
        e:SetLabelObject(nil)
    end
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local bc = e:GetLabelObject():GetLabelObject()
    if chk == 0 then return bc end

    if bc:IsRelateToBattle() then Duel.SetOperationInfo(0, CATEGORY_DESTROY, bc, 1, 0, 0) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local bc = e:GetLabelObject():GetLabelObject()
    if bc:IsRelateToBattle() then Duel.Destroy(bc, REASON_EFFECT) end
end

function s.e3filter(c) return c:IsFaceup() and c:IsAbleToRemove() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(s.e3filter, tp, 0, LOCATION_MZONE, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 1, tp, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, s.e3filter, tp, 0, LOCATION_MZONE, 1, 1, nil):GetFirst()
    if not tc then return end

    Duel.HintSelection(tc)
    if Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) == 0 then return end

    local atk = tc:GetBaseAttack()
    if Duel.IsPlayerCanSpecialSummonMonster(tp, PHANTASMAL_NIGHTMARE_TOKEN, 0, TYPES_TOKEN, atk, 0, 12, RACE_FIEND, ATTRIBUTE_DARK) and
        Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        local token = Duel.CreateToken(tp, PHANTASMAL_NIGHTMARE_TOKEN)
        Duel.SpecialSummonStep(token, 0, tp, tp, false, false, POS_FACEUP)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        token:RegisterEffect(ec1)
        local ec2 = ec1:Clone()
        ec2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
        ec2:SetValue(1)
        token:RegisterEffect(ec2)
        Duel.SpecialSummonComplete()
    end
end
