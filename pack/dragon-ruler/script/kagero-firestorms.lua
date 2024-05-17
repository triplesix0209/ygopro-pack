-- Kagero, Dragon Emperor of Firestorms
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterEmperorEffect(s, c, id, ATTRIBUTE_FIRE)

    -- fusion summon
    Fusion.AddProcMix(c, true, true, function(c, sc, sumtype, tp) return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON, sc, sumtype, tp) end,
        aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_FIRE))
    Fusion.AddContactProc(c, function(tp) return Duel.GetReleaseGroup(tp) end, function(g) Duel.Release(g, REASON_COST + REASON_MATERIAL) end,
        s.splimit, nil, nil, nil, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(s.splimit)
    c:RegisterEffect(splimit)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or c:IsRace(RACE_DRAGON) end)
    e1:SetValue(aux.indoval)
    c:RegisterEffect(e1)

    -- destroy & damage
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2b:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL + 1) end)
    e2b:SetCost(aux.TRUE)
    c:RegisterEffect(e2b)
end

function s.splimit(e, se, sp, st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st) or aux.penlimit(e, se, sp, st) end

function s.e2filter(c) return
    c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true)) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local tc = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, c):GetFirst()
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, tc, 1, tp, 0)

    if tc:IsMonster() then
        if tc:IsFaceup() then
            Duel.SetPossibleOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, tc:GetAttack())
        else
            Duel.SetPossibleOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 0)
        end
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    local dmg = 0
    if tc:IsMonster() and tc:IsFaceup() then dmg = tc:GetAttack() end
    if Duel.Destroy(tc, REASON_EFFECT) > 0 and dmg > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then
        Duel.BreakEffect()
        Duel.Damage(1 - tp, dmg, REASON_EFFECT)
    end
end
