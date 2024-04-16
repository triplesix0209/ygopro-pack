-- Number C38: Hope Keeper Dragon Tyrant Galaxy
Duel.LoadScript("util.lua")
Duel.LoadScript("util_xyz.lua")
local s, id = GetID()

s.xyz_number = 38
s.listed_names = {63767246}
s.listed_series = {0x95, 0x7b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se)
        local loc = e:GetHandler():GetLocation()
        if loc ~= LOCATION_EXTRA then return true end
        return se:GetHandler():IsSetCard(0x95) and
                   se:GetHandler():IsType(TYPE_SPELL)
    end)
    c:RegisterEffect(splimit)

    -- transfer material
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- attach the destroyed
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- negate effect & attach
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- indes
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.effcon)
    e4:SetValue(1)
    c:RegisterEffect(e4)

    -- special summon attached monsters
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, id)
    e5:SetCondition(s.effcon)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

s.rum_limit = function(c, e) return c:IsCode(63767246) end
s.rum_xyzsummon = function(c)
    local xyz = Effect.CreateEffect(c)
    xyz:SetDescription(1073)
    xyz:SetType(EFFECT_TYPE_FIELD)
    xyz:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    xyz:SetCode(EFFECT_SPSUMMON_PROC)
    xyz:SetRange(c:GetLocation())
    xyz:SetCondition(Xyz.Condition(nil, 9, 3, 3, false))
    xyz:SetTarget(Xyz.Target(nil, 9, 3, 3, false))
    xyz:SetOperation(Xyz.Operation(nil, 9, 3, 3, false))
    xyz:SetValue(SUMMON_TYPE_XYZ)
    xyz:SetReset(RESET_CHAIN)
    c:RegisterEffect(xyz)
    return xyz
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayCount() > 0
end

function s.e1filter(c)
    return c:IsFaceup() and not c:IsCode(id) and c:IsType(TYPE_XYZ)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g =
        Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or c:GetOverlayCount() == 0 or
        not tc:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
    local mg = c:GetOverlayGroup():Select(tp, 1, 1, nil)
    UtilXyz.Overlay(tc, mg)

    local oc = mg:GetFirst():GetOverlayTarget()
    Duel.RaiseSingleEvent(oc, EVENT_DETACH_MATERIAL, e, 0, 0, 0, 0)
end

function s.e2filter(c, tp)
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and
               c:IsPreviousControler(tp) and
               c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_XYZ)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e2filter, 1, nil, tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsType(TYPE_XYZ) and eg:IsExists(s.e2filter, 1, nil, tp)
    end

    local g = eg:Filter(s.e2filter, nil, tp)
    Duel.SetTargetCard(g)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = eg:Filter(function(c, e, tp)
        return s.e2filter(c, tp) and c:IsRelateToEffect(e)
    end, nil, e, tp)
    if #g == 0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    UtilXyz.Overlay(c, eg)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    local loc = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_LOCATION)
    return (loc & LOCATION_SZONE) ~= 0 and
               re:IsActiveType(TYPE_TRAP + TYPE_SPELL) and
               Duel.IsChainDisablable(ev)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsType(TYPE_XYZ) end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if Duel.NegateEffect(ev) and c:IsRelateToEffect(e) and
        rc:IsRelateToEffect(re) and c:IsType(TYPE_XYZ) then
        rc:CancelToGrave()
        UtilXyz.Overlay(c, rc)
    end
end

function s.effcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(function(c)
        return c:IsSetCard(0x7b) and c:IsType(TYPE_XYZ)
    end, 1, nil)
end

function s.e5filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return e:GetHandler():GetOverlayGroup():FilterCount(s.e5filter, nil, e,
                                                            tp) > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_OVERLAY)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if ft > 1 and Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
        ft = 1
    end
    if ft < 1 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sg = c:GetOverlayGroup():FilterSelect(tp, s.e5filter, 1, ft, nil, e,
                                                tp)
    for tc in aux.Next(sg) do
        Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 4))
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetLabel(Duel.GetTurnCount() + 1)
        ec1:SetLabelObject(c)
        ec1:SetCountLimit(1)
        ec1:SetCondition(function(e)
            return Duel.GetTurnCount() == e:GetLabel()
        end)
        ec1:SetOperation(s.e5retop)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE +
                         PHASE_END, 2)
        tc:RegisterEffect(ec1)
    end
    Duel.SpecialSummonComplete()
end

function s.e5retop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local sc = e:GetLabelObject()

    local og = c:GetOverlayGroup()
    if #og > 0 then Duel.SendtoGrave(og, REASON_RULE) end

    if not sc:IsLocation(LOCATION_MZONE) or sc:IsFacedown() or
        not sc:IsType(TYPE_XYZ) or UtilXyz.Overlay(sc, c) == 0 then
        Duel.SendtoGrave(c, REASON_COST)
    end
end
