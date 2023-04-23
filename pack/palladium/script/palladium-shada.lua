-- Palladium Guardian Shada
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- down atk
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    local bc = Duel.GetAttackTarget()
    return ac and bc and ac:IsRelateToBattle() and bc:IsRelateToBattle()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard, 0x13a), tp, LOCATION_MZONE, 0, nil)
        for tc in aux.Next(g) do
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(3000)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            ec1:SetValue(1)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(ec1)
        end
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local bc = e:GetHandler():GetBattleTarget()
    return bc and bc:IsRelateToBattle()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = e:GetHandler():GetBattleTarget()
    if bc:IsRelateToBattle() and bc:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(-800)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        bc:RegisterEffect(ec1)
    end
end
