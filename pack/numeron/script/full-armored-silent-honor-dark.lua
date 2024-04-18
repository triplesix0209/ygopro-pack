-- Number C101: Full Armored Silent Honor DARK
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 101

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Xyz Summon Procedure
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_WATER), 6, 4, s.xyzfilter, aux.Stringid(id, 0), 3, s.xyzop)

    -- untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function(e) return e:GetHandler():GetOverlayCount() > 0 end)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- attach
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.xyzfilter(c, tp, sc)
    return c:IsFaceup() and c:IsRank(5, 6) and c:IsAttribute(ATTRIBUTE_WATER, sc, SUMMON_TYPE_XYZ, tp) and c:IsType(TYPE_XYZ, sc, SUMMON_TYPE_XYZ, tp)
end

function s.xyzop(e, tp, chk)
    if chk == 0 then return not Duel.HasFlagEffect(tp, id) end
    Duel.RegisterFlagEffect(tp, id, RESET_PHASE | PHASE_END, 0, 1)
    return true
end

function s.e2filter(c)
    return not c:IsLocation(LOCATION_MZONE) or (not c:IsType(TYPE_TOKEN) and c:IsAbleToChangeControler() and c:IsSummonType(SUMMON_TYPE_SPECIAL))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return e:GetHandler():IsType(TYPE_XYZ) and
                   Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, LOCATION_MZONE + LOCATION_GRAVE + LOCATION_REMOVED, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tg = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, LOCATION_MZONE + LOCATION_GRAVE + LOCATION_REMOVED, 1, 1, nil)

    local g = tg:Filter(Card.IsLocation, nil, LOCATION_GRAVE)
    if #g > 0 then Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, #g, 0, 0) end
    Duel.SetPossibleOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, LOCATION_ONFIELD)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end

    Duel.Overlay(c, tc, true)
    if Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, c) and c:GetOverlayCount() > 0 and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) and c:RemoveOverlayCard(tp, 1, 1, REASON_EFFECT) > 0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, c)
        Duel.HintSelection(g)
        Duel.Destroy(g, REASON_EFFECT)
    end
end
