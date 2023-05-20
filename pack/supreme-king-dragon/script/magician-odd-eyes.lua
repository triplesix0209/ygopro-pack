-- Odd-Eyes Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_ODD_EYES}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- reduce damage
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCondition(s.pe1con)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- special summon odd-eyes
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 1))
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    pe2:SetCode(EVENT_DESTROYED)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1, {id, 1})
    pe2:SetCondition(s.pe2con)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- destroy & pendulum summon
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 2))
    me1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me1:SetType(EFFECT_TYPE_QUICK_O)
    me1:SetCode(EVENT_FREE_CHAIN)
    me1:SetRange(LOCATION_MZONE)
    me1:SetHintTiming(0, TIMING_MAIN_END)
    me1:SetCountLimit(1, {id, 2})
    me1:SetCondition(s.me1con)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)
    aux.GlobalCheck(s, function()
        s.should_check = false
        local me1exclude = Effect.CreateEffect(c)
        me1exclude:SetType(EFFECT_TYPE_FIELD)
        me1exclude:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        me1exclude:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        me1exclude:SetTargetRange(1, 1)
        me1exclude:SetTarget(function(e, c)
            if s.should_check then return not c:IsRace(RACE_DRAGON) or not c:IsType(TYPE_PENDULUM) end
            return false
        end)
        Duel.RegisterEffect(me1exclude, 0)
    end)

    -- damage
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 3))
    me2:SetCategory(CATEGORY_DAMAGE)
    me2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me2:SetCode(EVENT_BATTLE_DAMAGE)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, {id, 3})
    me2:SetCondition(s.me2con)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
end

function s.pe1con(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetAttacker()
    if tc:IsControler(1 - tp) then tc = Duel.GetAttackTarget() end
    return ep == tp and tc and tc:IsType(TYPE_PENDULUM) and Duel.GetFlagEffect(tp, id) == 0
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) and Duel.GetFlagEffect(tp, id) ~= 0 then return end

    if Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
        Duel.ChangeBattleDamage(tp, 0)
    end
end

function s.pe2filter1(c, tp)
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and
               c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(SET_ODD_EYES)
end

function s.pe2filter2(c, e, tp)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsSetCard(SET_ODD_EYES) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.pe2filter1, 1, nil, tp) end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then return Duel.IsExistingMatchingCard(s.pe2filter2, tp, loc, 0, 1, nil, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local loc = 0
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then loc = loc + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE end
    if Duel.GetLocationCountFromEx(tp, rp, nil) > 0 then loc = loc + LOCATION_EXTRA end
    if loc == 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.pe2filter2), tp, loc, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.me1con() return Duel.IsMainPhase() end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        s.should_check = true
        local res = Duel.IsPlayerCanPendulumSummon(tp)
        s.should_check = false
        return res
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_EXTRA)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.Destroy(c, REASON_EFFECT) == 0 then return end

    s.should_check = true
    Duel.PendulumSummon(tp)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetCode(EVENT_CHAIN_END)
    ec1:SetOperation(function(e) s.should_check = false end)
    Duel.RegisterEffect(ec1, 0)
end

function s.me2con(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    return ep ~= tp and ac:IsControler(tp) and ac:IsSetCard(SET_ODD_EYES) and ac:IsRace(RACE_DRAGON)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_PZONE, 0, nil)
    if chk == 0 then return #g > 0 end

    local dmg = 0
    for tc in g:Iter() do if tc:GetAttack() > 0 then dmg = dmg + tc:GetAttack() end end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
