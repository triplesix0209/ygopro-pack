-- Red-Eyes Dark Steel Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_RED_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, nil, 10, 2, s.xyzovfilter, aux.Stringid(id, 0), nil, nil, false, s.xyzcheck)

    -- destroy replace
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then return not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp, 1, REASON_EFFECT) end
        if Duel.SelectEffectYesNo(tp, c, 96) then
            c:RemoveOverlayCard(tp, 1, 1, REASON_EFFECT)
            return true
        else
            return false
        end
    end)
    c:RegisterEffect(e1)

    -- Special summon a monster
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.effcon)
    e3:SetValue(function(e, c) return Duel.GetMatchingGroupCount(Card.IsRace, c:GetControler(), LOCATION_GRAVE, 0, nil, RACE_DRAGON) * 400 end)
    c:RegisterEffect(e3)

    -- negate spell
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.xyzovfilter(c, tp, sc) return c:IsFaceup() and c:IsSetCard(SET_RED_EYES, sc, SUMMON_TYPE_XYZ, tp) and c:IsLevelAbove(9) end

function s.xyzcheck(g, tp, sc)
    local mg = g:Filter(function(c) return not c:IsHasEffect(511001175) end, nil)
    return mg:CheckSameProperty(Card.GetRace, sc, SUMMON_TYPE_XYZ, tp) and g:CheckSameProperty(Card.GetAttribute, sc, SUMMON_TYPE_XYZ, tp)
end

function s.e2filter(c, e, tp)
    return not c:IsCode(id) and (c:IsSetCard(SET_RED_EYES) or c:IsRace(RACE_DRAGON)) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND + LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e2filter), tp,
        LOCATION_HAND + LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.effcon(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard, 1, nil, SET_RED_EYES) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return ep ~= tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and s.effcon(e) and Duel.IsChainNegatable(ev)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD, nil)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0) end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Destroy(eg, REASON_EFFECT) end
end
