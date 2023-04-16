-- Dark Flare Knight of Palladium
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true,
        function(c, fc, sumtype, tp) return c:IsLevelAbove(6) and c:IsRace(RACE_SPELLCASTER, fc, sumtype, tp) end,
        aux.FilterBoolFunctionEx(Card.IsRace, RACE_WARRIOR))

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st)
    end)
    c:RegisterEffect(splimit)

    -- destroy
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetTarget(function(e, c) return c:IsAttackBelow(e:GetHandler():GetAttack()) end)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    Duel.Destroy(tc, REASON_EFFECT)
end

function s.e3filter(c, e, tp)
    return c:IsMonster() and c:IsSetCard(0x13a) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if chk == 0 then
        return
            Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e3filter, tp, loc, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e3filter), tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, true, false, POS_FACEUP) end
end
