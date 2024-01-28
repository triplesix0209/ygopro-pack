-- Galaxy-Eyes Full Armor Luminous Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x107b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_LIGHT), 8, 2, s.xyzovfilter, aux.Stringid(id, 0))

    -- cannot be xyz material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    e1:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) and e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- atk/def down
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetValue(function(e, c) return c:GetOverlayCount() * -500 end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2b)

    -- remove
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.xyzovfilter(c, tp, xyzc)
    return c:IsFaceup() and c:IsSetCard(0x107b, xyzc, SUMMON_TYPE_XYZ, tp) and c:IsRace(RACE_DRAGON, xyzc, SUMMON_TYPE_XYZ) and c:IsLevel(8)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToRemove, tp, 0, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, Card.IsAbleToRemove, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    local mcount = 0
    if tc:IsFaceup() then mcount = tc:GetOverlayCount() end

    if Duel.Remove(tc, 0, REASON_EFFECT + REASON_TEMPORARY) ~= 0 then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetCountLimit(1)
        ec1:SetLabelObject(tc)
        ec1:SetOperation(s.e3retop)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)

        if mcount > 0 then
            local ec2 = Effect.CreateEffect(c)
            ec2:SetType(EFFECT_TYPE_SINGLE)
            ec2:SetCode(EFFECT_UPDATE_ATTACK)
            ec2:SetValue(mcount * 1000)
            ec2:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
            c:RegisterEffect(ec2)
        end
    end
end

function s.e3retop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    local tc = e:GetLabelObject()

    if Duel.ReturnToField(tc) and tc:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec2 = ec1:Clone()
        ec2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec2)
        if tc:IsType(TYPE_TRAPMONSTER) then
            local ec3 = ec1:Clone()
            ec3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            tc:RegisterEffect(ec3)
        end
    end
end
