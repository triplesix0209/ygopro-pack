-- Evil HERO Executor
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_EVIL_HERO}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- send grave
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE + CATEGORY_ATKCHANGE + CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, tp)
    return not c:IsCode(id) and c:IsSetCard(SET_EVIL_HERO) and c:IsMonster() and c:IsAbleToRemove() and
               (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 or (c:IsLocation(LOCATION_MZONE) and c:GetSequence() < 5))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, c, tp) and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, tp, LOCATION_MZONE + LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    local g = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, s.e1filter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, c, tp)
    if Duel.Remove(g, POS_FACEUP, REASON_COST) > 0 and c:IsRelateToEffect(e) then Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e2filter(c) return c:IsSetCard(SET_EVIL_HERO) and c:IsMonster() and c:HasLevel() and not c:IsCode(id) and c:IsAbleToGrave() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e2filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil):GetFirst()
    if not tc or Duel.SendtoGrave(tc, REASON_EFFECT) == 0 then return end

    local lv = tc:GetLevel()
    if c:IsRelateToEffect(e) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_CHANGE_CODE)
        ec1:SetValue(tc:GetCode())
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
        local ec2 = ec1:Clone()
        ec2:SetCode(EFFECT_UPDATE_ATTACK)
        ec2:SetValue(lv * 100)
        c:RegisterEffect(ec2)
    end

    Duel.DiscardDeck(1 - tp, lv, REASON_EFFECT)
end
