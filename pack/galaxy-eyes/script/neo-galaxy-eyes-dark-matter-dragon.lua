-- Number C95: Neo Galaxy-Eyes Dark Matter Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 95
s.listed_series = {0x107b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_DARK), 10, 4, s.xyzovfilter, aux.Stringid(id, 0))

    -- xyzlimit
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- cannot be target
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- attach & banish
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- multi attack
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.xyzovfilter(c, tp, xyzc)
    return c:IsFaceup() and c:IsSetCard(0x107b, xyzc, SUMMON_TYPE_XYZ, tp) and c:IsType(TYPE_XYZ, xyzc, SUMMON_TYPE_XYZ, tp)
end

function s.e3filter1(c) return c:IsMonster() and c:IsAbleToGraveAsCost() end

function s.e3filter2(c) return c:IsRace(RACE_DRAGON) end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_DECK, 0, 1, nil) end
    local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e3filter1, tp, LOCATION_DECK, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, nil) end
    Duel.SetPossibleOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, LOCATION_ONFIELD + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local g1 = Utility.SelectMatchingCard(HINTMSG_XMATERIAL, tp, s.e3filter2, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, 1, nil)
    if #g1 == 0 then return end
    Duel.Overlay(c, g1)

    if Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, nil) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then
        local g2 = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD + LOCATION_GRAVE, 1, 1, nil)
        Duel.Remove(g2, POS_FACEDOWN, REASON_EFFECT)
    end
end

function s.e4filter(c) return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayGroup():IsExists(s.e4filter, 1, nil) and Duel.IsAbleToEnterBP() end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    c:RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetEffectCount(EFFECT_EXTRA_ATTACK) == 0 and c:GetEffectCount(EFFECT_EXTRA_ATTACK_MONSTER) == 0 end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetDescription(aux.Stringid(id, 4))
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    ec1:SetValue(2)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end
