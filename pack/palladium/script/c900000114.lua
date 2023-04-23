-- Palladium Paladin Gaia
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- position
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_CONFIRM)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- extra material
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(function(e) return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), 69832741) end)
    e3:SetValue(function(e, c) return c:IsSetCard(0x13a) end)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
    e3b:SetOperation(Fusion.BanishMaterial)
    c:RegisterEffect(e3b)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 or
               Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackAbove, 2000), tp, 0, LOCATION_MZONE, 1, nil)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local _, bc = Duel.GetBattleMonster(tp)
    return bc
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local _, bc = Duel.GetBattleMonster(tp)
    if chk == 0 then return bc:IsCanChangePosition() end

    Duel.SetOperationInfo(0, CATEGORY_POSITION, bc, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local _, bc = Duel.GetBattleMonster(tp)
    if bc and bc:IsRelateToBattle() then
        Duel.ChangePosition(bc, POS_FACEUP_DEFENSE, POS_FACEDOWN_DEFENSE, POS_FACEUP_ATTACK, POS_FACEUP_ATTACK)
    end
end
