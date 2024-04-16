-- Surtr, Bringer of the Nordic Ragnarok
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x42}
s.material_setcode = {0x42}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.NordicGodEffect(c, SUMMON_TYPE_XYZ)

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, nil, 3, nil, nil, nil, nil, false,
                     s.xyzcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                            EFFECT_FLAG_SINGLE_RANGE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetRange(LOCATION_EXTRA)
    splimit:SetValue(aux.xyzlimit)
    c:RegisterEffect(splimit)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)

    -- can attack all monsters
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ATTACK_ALL)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- negate (destroyed)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetRange(LOCATION_ALL)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- negate & reset atk/def
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_DISABLE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE + PHASE_BATTLE_START)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4, false, REGISTER_FLAG_DETACH_XMAT)

    -- destroy
    local e5 = Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e5:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetCondition(s.e5con)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.xyzfilter(c, sc, sumtype, tp)
    return c:GetOriginalLevel() >= 8 and
               c:IsAttribute(ATTRIBUTE_DARK, sc, sumtype, tp) and
               c:IsSetCard(0x42, sc, sumtype, tp)
end

function s.xyzcheck(g, tp, sc)
    return g:CheckDifferentProperty(Card.GetCode, sc, SUMMON_TYPE_XYZ, tp)
end

function s.e1con(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end

function s.e1val(e, te)
    return te:GetOwner() ~= e:GetOwner() and te:IsActiveType(TYPE_MONSTER)
end

function s.e3filter(c, tc)
    local rc
    if c:IsReason(REASON_BATTLE) then
        rc = c:GetReasonCard()
    elseif c:IsReason(REASON_EFFECT) then
        rc = c:GetReasonEffect():GetHandler()
    end

    if not rc then return false end
    return c:IsType(TYPE_EFFECT) and rc == tc
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e3filter, 1, nil, e:GetHandler())
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = eg:Filter(s.e3filter, nil, c)
    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec1b)
        local ec2 = ec1:Clone()
        ec2:SetCode(EFFECT_CANNOT_TRIGGER)
        tc:RegisterEffect(ec2)
    end
end

function s.e4filter1(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end

function s.e4filter2(c)
    return c:IsFaceup() and
               not (c:IsAttack(c:GetBaseAttack()) and
                   c:IsDefense(c:GetBaseDefense()))
end

function s.e4filter3(c) return c:IsFaceup() and c:IsType(TYPE_EFFECT) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() == tp end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    c:RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter1, tp, 0, LOCATION_MZONE,
                                           1, nil) or (s.e4filter2(c) and
                   Duel.IsExistingMatchingCard(s.e4filter2, tp, 0,
                                               LOCATION_MZONE, 1, nil))
    end

    Duel.SetChainLimit(function(e, lp, tp)
        return lp == tp or not e:IsActiveType(TYPE_MONSTER)
    end)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local g = Duel.GetMatchingGroup(s.e4filter3, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec1b)
    end

    g = Duel.GetMatchingGroup(s.e4filter2, tp, 0, LOCATION_MZONE, nil)
    if c:IsRelateToEffect(e) and c:IsFaceup() then g:AddCard(c) end
    for tc in aux.Next(g) do
        if not tc:IsAttack(tc:GetBaseAttack()) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
            ec1:SetValue(tc:GetBaseAttack())
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
        end
        if not tc:IsDefense(tc:GetBaseDefense()) then
            local ec2 = Effect.CreateEffect(c)
            ec2:SetType(EFFECT_TYPE_SINGLE)
            ec2:SetCode(EFFECT_SET_DEFENSE_FINAL)
            ec2:SetValue(tc:GetBaseDefense())
            ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec2)
        end
    end
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and
               c:IsSummonType(SUMMON_TYPE_XYZ)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    Duel.SetOperationInfo(0, LOCATION_MZONE, g, #g, 0, 0)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    if #g == 0 then return end
    Duel.Destroy(g, REASON_EFFECT)
end
