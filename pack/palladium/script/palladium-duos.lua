-- Palladium Spirit Duos
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- up atk & indes
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(TIMING_DAMAGE_STEP)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, tp, rp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and
               (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer() == 1 - tp)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e1filter, 1, nil, tp, rp) and not eg:IsContains(e:GetHandler()) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local g, lv = eg:GetMaxGroup(Card.GetLevel)
        if #g > 1 then g = g:Select(tp, 1, 1, nil) end
        Duel.HintSelection(g)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(lv * 100)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end

function s.e2filter(c) return c:IsFaceup() and c:IsLevelAbove(1) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, s.e2filter, 1, false, nil, c) end

    local tc = Duel.SelectReleaseGroupCost(tp, s.e2filter, 1, 1, false, nil, c):GetFirst()
    e:SetLabel(tc:GetLevel())
    Duel.Release(tc, REASON_COST)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(e:GetLabel() * 100)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetDescription(3001)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetValue(1)
    c:RegisterEffect(ec2)
end
