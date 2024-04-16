-- Number C37: Hope Invented Dragon Abyss Shark
Duel.LoadScript("util.lua")
Duel.LoadScript("util_xyz.lua")
local s, id = GetID()

s.xyz_number = 37
s.listed_names = {37279508}
s.listed_series = {0x95}

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

    -- attach special summoned
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- attach battle
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BATTLED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id) ~= 0 end)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3reg1 = Effect.CreateEffect(c)
    e3reg1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3reg1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3reg1:SetCode(EVENT_TO_GRAVE)
    e3reg1:SetOperation(s.e3reg1op)
    c:RegisterEffect(e3reg1)
    aux.GlobalCheck(s, function()
        local e3reg2 = Effect.CreateEffect(c)
        e3reg2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e3reg2:SetCode(EVENT_TO_GRAVE)
        e3reg2:SetOperation(s.e3reg2op)
        Duel.RegisterEffect(e3reg2, 0)
    end)

    -- extra attack
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_EXTRA_ATTACK)
    e4:SetCondition(s.effcon)
    e4:SetValue(1)
    c:RegisterEffect(e4)

    -- atk down
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_ATKCHANGE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetHintTiming(TIMING_DAMAGE_STEP,
                     TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
    e5:SetCountLimit(1)
    e5:SetCondition(s.effcon)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5, false, REGISTER_FLAG_DETACH_XMAT)
end

s.rum_limit = function(c, e) return c:IsCode(37279508) end
s.rum_xyzsummon = function(c)
    local filter = aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_WATER)
    local xyz = Effect.CreateEffect(c)
    xyz:SetDescription(1073)
    xyz:SetType(EFFECT_TYPE_FIELD)
    xyz:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    xyz:SetCode(EFFECT_SPSUMMON_PROC)
    xyz:SetRange(c:GetLocation())
    xyz:SetCondition(Xyz.Condition(filter, 5, 3, 3, false))
    xyz:SetTarget(Xyz.Target(filter, 5, 3, 3, false))
    xyz:SetOperation(Xyz.Operation(filter, 5, 3, 3, false))
    xyz:SetValue(SUMMON_TYPE_XYZ)
    xyz:SetReset(RESET_CHAIN)
    c:RegisterEffect(xyz)
    return xyz
end

function s.e1filter(c)
    return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and
               not c:IsType(TYPE_TOKEN) and c:IsAttribute(ATTRIBUTE_WATER)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE +
                                               LOCATION_HAND + LOCATION_GRAVE,
                                           0, 1, e:GetHandler())
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local tc = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_MZONE +
                                           LOCATION_HAND + LOCATION_GRAVE, 0, 1,
                                       1, c):GetFirst()
    if not tc then return end

    UtilXyz.Overlay(c, tc)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    return not c:IsStatus(STATUS_BATTLE_DESTROYED) and bc and
               bc:IsStatus(STATUS_BATTLE_DESTROYED)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if chk == 0 then return c:IsType(TYPE_XYZ) and not bc:IsType(TYPE_TOKEN) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if not bc:IsRelateToBattle() or c:IsFacedown() then return end

    UtilXyz.Overlay(c, bc)
end

function s.e3filter1(c, e, tp)
    return not c:IsCode(id) and c:GetFlagEffect(id) ~= 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3filter2(c)
    return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_WATER)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_GRAVE,
                                               0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local tg = Duel.GetMatchingGroup(s.e3filter1, tp, LOCATION_GRAVE, 0, nil, e,
                                     tp)
    if ft <= 0 or #tg == 0 then return end

    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    tg = tg:Select(tp, ft, ft, nil)
    Duel.SpecialSummon(tg, 0, tp, tp, false, false, POS_FACEUP)

    local sg = Duel.GetOperatedGroup():Filter(s.e3filter2, nil)
    if #sg == 0 then return end
    if #sg > 1 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
        sg = sg:Select(tp, 1, 1, nil)
    end

    UtilXyz.Overlay(sg:GetFirst(), c)
end

function s.e3reg1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsReason(REASON_BATTLE + REASON_EFFECT) then return end
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_END, 0, 1)
end

function s.e3reg2op(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(function(c) return not c:IsCode(id) end, nil)
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, 0, 0)
    end
end

function s.effcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(function(c)
        return c:IsRace(RACE_SEASERPENT) and c:IsType(TYPE_XYZ)
    end, 1, nil)
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST)
    end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE,
                                           1, nil)
    end
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        ec1:SetValue(math.ceil(tc:GetAttack() / 2))
        tc:RegisterEffect(ec1)
    end
end
