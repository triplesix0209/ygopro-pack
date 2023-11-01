-- The Palladium Oracles
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785, 42006475}
s.material_setcode = {SET_PALLADIUM}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, {71703785, 42006475}, s.fusfilter)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st) end)
    c:RegisterEffect(splimit)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c:IsRace(RACE_SPELLCASTER) end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- protect spell/trap
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD, 0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsType, TYPE_SPELL + TYPE_TRAP))
    e2:SetValue(aux.indoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2b:SetProperty(EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_IGNORE_IMMUNE)
    e2b:SetValue(aux.tgoval)
    c:RegisterEffect(e2b)

    -- draw
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(1108)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_CHAINING)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.fusfilter(c, fc, sumtype, tp) return (c:IsLevel(6) or c:IsLevel(7)) and c:IsRace(RACE_SPELLCASTER, fc, sumtype, tp) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    if Duel.Draw(p, d, REASON_EFFECT) == 0 then return end

    local tc = Duel.GetOperatedGroup():GetFirst()
    if tc:IsSpellTrap() and tc:IsSSetable() and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and Duel.SelectEffectYesNo(tp, c, 1601) then
        Duel.SSet(tp, tc, tp, false)
        if tc:IsQuickPlaySpell() or tc:IsTrap() then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            ec1:SetCode(tc:IsQuickPlaySpell() and EFFECT_QP_ACT_IN_SET_TURN or EFFECT_TRAP_ACT_IN_SET_TURN)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
        end
    end
end

function s.e4filter(c, e, tp, code) return c:IsCode(code) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToExtraAsCost() end
    Duel.SendtoDeck(c, nil, 0, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED
    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2 and
                   Duel.IsExistingMatchingCard(s.e4filter, tp, loc, 0, 1, nil, e, tp, 71703785) and
                   Duel.IsExistingMatchingCard(s.e4filter, tp, loc, 0, 1, nil, e, tp, 42006475)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, loc)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 then return end

    local g1 = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e4filter), tp, loc, 0, nil, e, tp, 71703785)
    local g2 = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e4filter), tp, loc, 0, nil, e, tp, 42006475)
    if #g1 == 0 or #g2 == 0 then return end

    g1 = Utility.GroupSelect(HINTMSG_SPSUMMON, g1, tp)
    g2 = Utility.GroupSelect(HINTMSG_SPSUMMON, g2, tp)
    Duel.SpecialSummon(g1:Merge(g2), 0, tp, tp, true, false, POS_FACEUP)
end
