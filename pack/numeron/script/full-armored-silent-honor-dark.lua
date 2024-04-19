-- Number C101: Full Armored Silent Honor DARK
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 101

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Xyz Summon Procedure
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_WATER), 6, 4, s.xyzfilter, aux.Stringid(id, 0), 3, s.xyzop)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1b:SetValue(1)
    c:RegisterEffect(e1b)
    local e1c = Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_FIELD)
    e1c:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1c:SetCode(EFFECT_CANNOT_REMOVE)
    e1c:SetRange(LOCATION_MZONE)
    e1c:SetTargetRange(1, 1)
    e1c:SetCondition(s.e1con)
    e1c:SetTarget(function(e, c, tp, r) return c == e:GetHandler() and r == REASON_EFFECT end)
    c:RegisterEffect(e1c)

    -- equip
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- attach
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.xyzfilter(c, tp, sc)
    return c:IsFaceup() and c:IsRank(5, 6) and c:IsAttribute(ATTRIBUTE_WATER, sc, SUMMON_TYPE_XYZ, tp) and c:IsType(TYPE_XYZ, sc, SUMMON_TYPE_XYZ, tp)
end

function s.xyzcostfilter(c) return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and c:IsAbleToGraveAsCost() end

function s.xyzop(e, tp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.xyzcostfilter, tp, LOCATION_EXTRA, 0, 1, c) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local tc = Duel.GetMatchingGroup(s.xyzcostfilter, tp, LOCATION_EXTRA, 0, c):SelectUnselect(Group.CreateGroup(), tp, false, Xyz.ProcCancellable)
    if tc then
        Duel.SendtoGrave(tc, REASON_COST)
        return true
    else
        return false
    end
end

function s.e1filter(c) return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsExistingMatchingCard(s.e1filter, 0, LOCATION_GRAVE, 0, 1, nil) end

function s.e2filter(c, tp)
    if c:IsFacedown() or not c:CheckUniqueOnField(tp) or c:IsForbidden() then return end
    return (c:IsLocation(LOCATION_MZONE) and c:IsMonster()) or c:IsSpellTrap()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_MZONE + LOCATION_REMOVED, LOCATION_MZONE, 1, c, tp) and
                   Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and Duel.CheckRemoveOverlayCard(tp, LOCATION_MZONE, 0, 1, REASON_EFFECT)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_MZONE + LOCATION_REMOVED, LOCATION_MZONE, 1, 1, c, tp)

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, g, #g, 0, 0)
    if g:IsExists(Card.IsLocation, 1, nil, LOCATION_GRAVE) then Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, #g, 0, 0) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if Duel.RemoveOverlayCard(tp, LOCATION_MZONE, 0, 1, 1, REASON_EFFECT) == 0 then return end
    if tc:IsRelateToEffect(e) and Duel.Equip(tp, tc, c, true) then
        local ec0 = Effect.CreateEffect(c)
        ec0:SetType(EFFECT_TYPE_SINGLE)
        ec0:SetCode(EFFECT_EQUIP_LIMIT)
        ec0:SetLabelObject(c)
        ec0:SetValue(function(e, c) return c == e:GetLabelObject() end)
        ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec0)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_EQUIP)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1200)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end

function s.e3filter(c, ec) return c:GetEquipTarget() == ec end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_SZONE, 0, 1, nil, c) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, LOCATION_ONFIELD)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local dt = 0
    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_SZONE, 0, nil, c)
    for tc in g:Iter() do
        if not tc:IsImmuneToEffect(e) then
            Duel.Overlay(c, tc, true)
            dt = dt + 1
        end
    end

    if dt > 0 and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) then
        Duel.BreakEffect()
        local dg = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, dt, nil)
        Duel.HintSelection(dg)
        Duel.Destroy(dg, REASON_EFFECT)
    end
end
