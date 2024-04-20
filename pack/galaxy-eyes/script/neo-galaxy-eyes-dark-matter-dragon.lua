-- Number C95: Neo Galaxy-Eyes Dark Matter Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 95
s.listed_series = {SET_GALAXY_EYES, SET_NUMBER}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_DARK), 10, 4, s.xyzovfilter, aux.Stringid(id, 0))

    -- cannot be xyz material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- attach & banish
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- untargetable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayGroup():IsExists(s.efffilter, 1, nil) end)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    -- multi attack
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE + PHASE_BATTLE_START)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.xyzovfilter(c, tp, xyzc)
    return c:IsFaceup() and c:IsSetCard(SET_GALAXY_EYES, xyzc, SUMMON_TYPE_XYZ, tp) and c:IsType(TYPE_XYZ, xyzc, SUMMON_TYPE_XYZ, tp)
end

function s.e2filter1(c) return c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost() end

function s.e2filter2(c) return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_DECK, 0, 1, nil) end
    local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e2filter1, tp, LOCATION_DECK, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, nil) end
    Duel.SetPossibleOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, LOCATION_ONFIELD + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local g1 = Utility.SelectMatchingCard(HINTMSG_XMATERIAL, tp, s.e2filter2, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, 1, nil)
    if #g1 == 0 then return end
    Duel.Overlay(c, g1)

    if Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD + LOCATION_GRAVE, 1, nil) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then
        local g2 = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD + LOCATION_GRAVE, 1, 1, nil)
        Duel.Remove(g2, POS_FACEDOWN, REASON_EFFECT)
    end
end

function s.efffilter(c) return c:IsSetCard(SET_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayGroup():IsExists(s.efffilter, 1, nil) and Duel.GetTurnPlayer() == tp end

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
