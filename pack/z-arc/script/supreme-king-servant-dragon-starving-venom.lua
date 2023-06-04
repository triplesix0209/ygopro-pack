-- Supreme King Servant Dragon Starving Venom
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_DRAGON, SET_SUPREME_KING_GATE}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixN(c, true, true, s.fusfilter, 2)
    Fusion.AddContactProc(c, s.contactgroup, s.contactop)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    sp:SetCode(EVENT_SPSUMMON_SUCCESS)
    sp:SetRange(LOCATION_EXTRA + LOCATION_GRAVE)
    sp:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    sp:SetCondition(s.spcon)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- cannot be battle target
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, LOCATION_MZONE)
    e1:SetValue(function(e, tc) return tc:IsFaceup() and tc:IsType(TYPE_FUSION) and tc ~= e:GetHandler() end)
    c:RegisterEffect(e1)

    -- drain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon other monster
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_BATTLE_START + TIMING_BATTLE_END)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.fusfilter(c, fc, sumtype, tp) return c:IsAttribute(ATTRIBUTE_DARK, fc, sumtype, tp) and c:IsType(TYPE_PENDULUM, fc, sumtype, tp) end

function s.contactgroup(tp) return Duel.GetReleaseGroup(tp) end

function s.contactop(g) Duel.Release(g, REASON_COST + REASON_MATERIAL) end

function s.spfilter1(c, tp) return c:IsControler(1 - tp) and c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION) end

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
    return eg:IsExists(s.spfilter1, 1, nil, tp) and
               Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), tp, LOCATION_ONFIELD, 0, 1, nil) and
               Duel.CheckReleaseGroup(tp, s.spfilter2, 1, nil, tp, Group.CreateGroup(), c) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        local sg = Group.CreateGroup()
        while #sg < 2 do sg:Merge(Duel.SelectReleaseGroup(tp, s.spfilter2, 1, 1, sg, tp, sg, c)) end
        Duel.Release(sg, REASON_COST)

        Duel.SpecialSummon(c, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
        c:CompleteProcedure()
    end
end

function s.e2filter(c) return c:IsMonster() and c:IsNegatable() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return (Duel.GetTurnPlayer() == tp and Duel.IsMainPhase()) or Duel.IsBattlePhase() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_MZONE + LOCATION_GRAVE, LOCATION_MZONE + LOCATION_GRAVE, 1, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_MZONE + LOCATION_GRAVE, LOCATION_MZONE + LOCATION_GRAVE, 1, 1, c)

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()

    if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (tc:IsFaceup() or tc:IsLocation(LOCATION_GRAVE)) then
        local code = tc:GetOriginalCodeRule()
        if not tc:IsType(TYPE_TOKEN) and not tc:IsType(TYPE_TRAPMONSTER) then
            c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 1)
        end

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

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetCode(EFFECT_PIERCE)
    ec2:SetTargetRange(LOCATION_MZONE, 0)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
end

function s.e3filter(c, e, tp)
    return c:IsFaceup() and c:IsSetCard({SET_SUPREME_KING_DRAGON, SET_SUPREME_KING_GATE}) and c:IsType(TYPE_PENDULUM) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() >= PHASE_BATTLE_START and Duel.GetCurrentPhase() <= PHASE_BATTLE end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToExtraAsCost() end
    Duel.SendtoDeck(c, nil, 0, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCountFromEx(tp, tp, c) > 0 and Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local max = math.min(Duel.GetLocationCountFromEx(tp), 2)
    if max == 0 then return end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then max = 1 end
    max = math.min(max, aux.CheckSummonGate(tp) or max)

    local sg = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e3filter, tp, LOCATION_EXTRA, 0, 1, max, nil, e, tp)
    if #sg > 0 and Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 then
        local tg = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType, TYPE_FUSION), tp, 0, LOCATION_MZONE, nil)
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
