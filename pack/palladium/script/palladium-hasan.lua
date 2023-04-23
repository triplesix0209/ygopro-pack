-- Palladium Protector Hasan
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(2)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(3, id, EFFECT_COUNT_CODE_DUEL)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- avoid damage
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- return to the Deck
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e3:SetValue(LOCATION_DECKBOT)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    return Duel.GetAttackTarget() == nil and ac:IsControler(1 - tp) and ac:IsAttackAbove(Duel.GetLP(tp))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ac = Duel.GetAttacker()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 and ac:CanAttack() and not ac:IsImmuneToEffect(e) then
        Duel.CalculateDamage(ac, c)
    end
end
