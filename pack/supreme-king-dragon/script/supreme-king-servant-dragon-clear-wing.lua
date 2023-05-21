-- Supreme King Servant Dragon Clear Wing
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_DRAGON, SET_SUPREME_KING_GATE}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(s.synfilter), 1, 99)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    sp:SetCode(EVENT_SPSUMMON_SUCCESS)
    sp:SetRange(LOCATION_EXTRA + LOCATION_GRAVE)
    sp:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    sp:SetCondition(s.spcon)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- destroy all
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot be battle target
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetValue(function(e, tc) return tc:IsFaceup() and tc:IsType(TYPE_SYNCHRO) and tc ~= e:GetHandler() end)
    c:RegisterEffect(e2)

    -- destroy and damage
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EVENT_BATTLE_CONFIRM)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon other monster
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetHintTiming(0, TIMING_BATTLE_START + TIMING_BATTLE_END)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.synfilter(c, val, sc, sumtype, tp) return c:IsAttribute(ATTRIBUTE_DARK, sc, sumtype, tp) and c:IsType(TYPE_PENDULUM, sc, sumtype, tp) end

function s.spfilter1(c, tp) return c:IsControler(1 - tp) and c:IsType(TYPE_SYNCHRO) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) end

function s.spfilter2(c, tp, sg, tc)
    if c:IsFacedown() or not c:IsSetCard(SET_SUPREME_KING_DRAGON) then return false end
    sg:AddCard(c)

    local res
    if #sg < 2 then
        res = Duel.CheckReleaseGroup(tp, s.spfilter2, 1, sg, tp, sg, tc)
    else
        if tc:IsLocation(LOCATION_EXTRA) then
            res = Duel.GetLocationCountFromEx(tp, tp, sg, tc) > 0
        else
            res = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 or sg:IsExists(s.spcheck, 1, nil, tp)
        end
    end

    sg:RemoveCard(c)
    return res
end

function s.spcheck(c, tp) return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence() < 5 end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c then return false end
    return eg:IsExists(s.spfilter1, 1, nil, tp) and
               Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), tp, LOCATION_ONFIELD, 0, 1, nil) and
               Duel.CheckReleaseGroup(tp, s.spfilter2, 1, nil, tp, Group.CreateGroup(), c) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        local sg = Group.CreateGroup()
        while #sg < 2 do sg:Merge(Duel.SelectReleaseGroup(tp, s.spfilter2, 1, 1, sg, tp, sg, c)) end
        Duel.Release(sg, REASON_COST)

        Duel.SpecialSummon(c, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
    end
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    if chk == 0 then return #g > 0 end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ng = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsNegatable), tp, 0, LOCATION_MZONE, nil)
    for tc in ng:Iter() do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec1b)
        if tc:IsType(TYPE_TRAPMONSTER) then
            local ec1c = Effect.CreateEffect(c)
            ec1c:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            tc:RegisterEffect(ec1c)
        end
    end
    Duel.AdjustInstantly()

    local dg = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    Duel.Destroy(dg, REASON_EFFECT)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if chk == 0 then return true end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, bc, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, bc:GetBaseAttack())
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)

    Duel.NegateAttack()
    if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() and Duel.Destroy(bc, REASON_EFFECT) > 0 then
        local dmg = bc:GetBaseAttack()
        if dmg > 0 then Duel.Damage(p, dmg, REASON_EFFECT) end
    end
end

function s.e4filter(c, e, tp)
    return c:IsFaceup() and c:IsSetCard({SET_SUPREME_KING_DRAGON, SET_SUPREME_KING_GATE}) and c:IsType(TYPE_PENDULUM) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() >= PHASE_BATTLE_START and Duel.GetCurrentPhase() <= PHASE_BATTLE end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToExtraAsCost() end
    Duel.SendtoDeck(c, nil, 0, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCountFromEx(tp, tp, c) > 0 and Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local max = math.min(Duel.GetLocationCountFromEx(tp), 2)
    if max == 0 then return end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then max = 1 end
    max = math.min(max, aux.CheckSummonGate(tp) or max)

    local sg = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e4filter, tp, LOCATION_EXTRA, 0, 1, max, nil, e, tp)
    if #sg > 0 and Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 then
        local tg = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType, TYPE_SYNCHRO), tp, 0, LOCATION_MZONE, nil)
        for tc in tg:Iter() do
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
            ec1:SetValue(0)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(ec1)
        end
    end
end
