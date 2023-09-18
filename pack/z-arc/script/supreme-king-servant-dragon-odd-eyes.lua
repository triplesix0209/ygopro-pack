-- Supreme King Servant Dragon Odd-Eyes
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_DRAGON, SET_SUPREME_KING_GATE}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    sp:SetCode(EVENT_SPSUMMON_SUCCESS)
    sp:SetRange(LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE)
    sp:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    sp:SetCondition(s.spcon)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- add to extra
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    pe1:SetCode(EVENT_STARTUP)
    pe1:SetRange(0xff)
    pe1:SetOperation(s.pe1op)
    Duel.RegisterEffect(pe1, 0)

    -- search
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 1))
    pe2:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_SEARCH)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCost(s.pe2cost)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- cannot be battle target
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_FIELD)
    me1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    me1:SetRange(LOCATION_MZONE)
    me1:SetTargetRange(0, LOCATION_MZONE)
    me1:SetValue(function(e, tc) return tc:IsFaceup() and tc:IsType(TYPE_PENDULUM) and tc ~= e:GetHandler() end)
    c:RegisterEffect(me1)

    -- indes
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_FIELD)
    me2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    me2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    me2:SetRange(LOCATION_MZONE)
    me2:SetTargetRange(LOCATION_MZONE, 0)
    me2:SetTarget(s.me2tg)
    me2:SetValue(s.me2val)
    c:RegisterEffect(me2)

    -- double damage
    local me3 = Effect.CreateEffect(c)
    me3:SetType(EFFECT_TYPE_FIELD)
    me3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
    me3:SetRange(LOCATION_MZONE)
    me3:SetTargetRange(LOCATION_MZONE, 0)
    me3:SetTarget(function(e, tc) return tc:IsType(TYPE_PENDULUM) and tc:GetBattleTarget() ~= nil end)
    me3:SetValue(aux.ChangeBattleDamage(1, DOUBLE_DAMAGE))
    c:RegisterEffect(me3)

    -- special summon other monster
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(aux.Stringid(id, 2))
    me4:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_ATKCHANGE)
    me4:SetType(EFFECT_TYPE_QUICK_O)
    me4:SetCode(EVENT_FREE_CHAIN)
    me4:SetRange(LOCATION_MZONE)
    me4:SetHintTiming(0, TIMING_BATTLE_START + TIMING_BATTLE_END)
    me4:SetCondition(s.me4con)
    me4:SetCost(s.me4cost)
    me4:SetTarget(s.me4tg)
    me4:SetOperation(s.me4op)
    c:RegisterEffect(me4)
end

function s.spfilter1(c, tp) return c:IsControler(1 - tp) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end

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
               Duel.CheckReleaseGroup(tp, s.spfilter2, 1, nil, tp, Group.CreateGroup(), c) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        local sg = Group.CreateGroup()
        while #sg < 2 do sg:Merge(Duel.SelectReleaseGroup(tp, s.spfilter2, 1, 1, sg, tp, sg, c)) end
        Duel.Release(sg, REASON_COST)

        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.pe1op(e)
    local c = e:GetHandler()
    local tp = c:GetOwner()
    Duel.SendtoExtraP(c, tp, REASON_EFFECT)
end

function s.pe2filter(c) return c:IsType(TYPE_PENDULUM) and c:IsAttackBelow(1500) and c:IsAbleToHand() end

function s.pe2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, Card.IsSetCard, 1, false, nil, nil, SET_SUPREME_KING_DRAGON) end
    local g = Duel.SelectReleaseGroupCost(tp, Card.IsSetCard, 1, 1, false, nil, nil, SET_SUPREME_KING_DRAGON)
    Duel.Release(g, REASON_COST)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.pe2filter, tp, LOCATION_DECK, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.Destroy(c, REASON_EFFECT) == 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.pe2filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.me2tg(e, c) return c:IsType(TYPE_PENDULUM) end

function s.me2val(e, re, r, rp)
    if (r & REASON_BATTLE) ~= 0 or ((r & REASON_EFFECT) ~= 0 and re:GetHandlerPlayer() ~= e:GetHandlerPlayer()) then
        return 1
    else
        return 0
    end
end

function s.me4filter(c, e, tp)
    return not c:IsCode(96733134) and c:IsFaceup() and c:IsSetCard({SET_SUPREME_KING_DRAGON, SET_SUPREME_KING_GATE}) and c:IsType(TYPE_PENDULUM) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.me4con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() >= PHASE_BATTLE_START and Duel.GetCurrentPhase() <= PHASE_BATTLE end

function s.me4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsReleasable() end
    Duel.Release(c, REASON_COST)
end

function s.me4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCountFromEx(tp, tp, c) > 0 and Duel.IsExistingMatchingCard(s.me4filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.me4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local max = math.min(Duel.GetLocationCountFromEx(tp), 2)
    if max == 0 then return end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then max = 1 end
    max = math.min(max, aux.CheckSummonGate(tp) or max)

    local sg = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.me4filter, tp, LOCATION_EXTRA, 0, 1, max, nil, e, tp)
    if #sg > 0 and Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 and
        Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), tp, LOCATION_ONFIELD, 0, 1, nil) then
        local tg = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType, TYPE_PENDULUM), tp, 0, LOCATION_MZONE, nil)
        for tc in tg:Iter() do
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
            ec1:SetValue(0)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
        end
    end
end
