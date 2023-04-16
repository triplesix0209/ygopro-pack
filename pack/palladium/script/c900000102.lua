-- Illusory Palladium Oracle Mana
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(function(e, c) return (c:IsSetCard(0x13a) or c:IsLevelAbove(7)) and c:IsRace(RACE_SPELLCASTER) end)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_HAND + LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c, tp) return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    return tg and tg:IsExists(s.e1filter, 1, nil, tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetAttackTarget()
    if not tc then return false end
    if tc:IsControler(1 - tp) then tc = Duel.GetAttacker() end
    e:SetLabelObject(tc)
    return tc and tc ~= e:GetHandler() and tc:IsSetCard(0x13a) and tc:IsRace(RACE_SPELLCASTER) and tc:IsRelateToBattle()
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToGraveAsCost() end

    Duel.SendtoGrave(c, REASON_COST)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    if tc:IsFaceup() and tc:IsRelateToBattle() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(c:GetBaseAttack())
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE_CAL)
        tc:RegisterEffect(ec1)
    end
end
