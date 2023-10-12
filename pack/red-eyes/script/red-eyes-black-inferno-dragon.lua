-- Red-Eyes Black Inferno Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- normal monster
    local addtype = Effect.CreateEffect(c)
    addtype:SetType(EFFECT_TYPE_SINGLE)
    addtype:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    addtype:SetCode(EFFECT_ADD_TYPE)
    addtype:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    addtype:SetValue(TYPE_NORMAL)
    c:RegisterEffect(addtype)
    local addtype2 = addtype:Clone()
    addtype2:SetCode(EFFECT_REMOVE_TYPE)
    addtype2:SetValue(TYPE_EFFECT)
    c:RegisterEffect(addtype2)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- inflict damage
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_PHASE + PHASE_BATTLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_HAND + LOCATION_DECK) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetBattledGroupCount() > 0 end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local c = e:GetHandler()
    local dmg = c:GetBaseAttack()
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local dmg = c:GetBaseAttack()
        Duel.Damage(1 - tp, dmg, REASON_EFFECT)
    end
end
