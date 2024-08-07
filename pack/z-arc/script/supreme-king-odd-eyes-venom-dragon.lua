-- Supreme King Odd-Eyes Venom Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_ODD_EYES, SET_STARVING_VENOM, SET_VENOM}
s.material_setcode = {SET_ODD_EYES, SET_STARVING_VENOM, SET_VENOM}

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- fusion summon
    Fusion.AddProcMix(c, false, false, function(c, sc, st, tp)
        return c:IsSetCard(SET_ODD_EYES, sc, st, tp) and c:IsRace(RACE_DRAGON, sc, st, tp) and c:IsType(TYPE_PENDULUM, sc, st, tp)
    end, function(c, sc, st, tp) return c:IsSetCard(SET_STARVING_VENOM, sc, st, tp) and c:IsType(TYPE_FUSION, sc, st, tp) end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_FUSION) == SUMMON_TYPE_FUSION or (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)

    -- atk up
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetCategory(CATEGORY_ATKCHANGE)
    pe1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe1:SetCode(EVENT_BATTLE_CONFIRM)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetCondition(s.pe1con)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- fusion success
    local me1 = Effect.CreateEffect(c)
    me1:SetCategory(CATEGORY_ATKCHANGE)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel() == 1 end)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)
    local me1check = Effect.CreateEffect(c)
    me1check:SetType(EFFECT_TYPE_SINGLE)
    me1check:SetCode(EFFECT_MATERIAL_CHECK)
    me1check:SetValue(function(e, c)
        local g = e:GetHandler():GetMaterial()
        local lg = g:Filter(Card.IsLocation, nil, LOCATION_MZONE)
        if #g == #lg then e:GetLabelObject():SetLabel(1) end
    end)
    me1check:SetLabelObject(me1)
    c:RegisterEffect(me1check)

    -- pierce
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(me2)

    -- negate & copy effect and atk
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(aux.Stringid(id, 1))
    me3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DISABLE)
    me3:SetType(EFFECT_TYPE_QUICK_O)
    me3:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    me3:SetCode(EVENT_FREE_CHAIN)
    me3:SetRange(LOCATION_MZONE)
    me3:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
    me3:SetCountLimit(1)
    me3:SetCondition(s.me3con)
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)

    -- place into pendulum zone
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(2203)
    me4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me4:SetCode(EVENT_DESTROYED)
    me4:SetProperty(EFFECT_FLAG_DELAY)
    me4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
    me4:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me4:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not e:GetHandler():IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end
        Duel.MoveToField(e:GetHandler(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end)
    c:RegisterEffect(me4)
end

function s.pe1con(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    local bc = Duel.GetAttackTarget()

    if not bc then return false end
    if ac:IsControler(1 - tp) then bc, ac = ac, bc end
    e:SetLabelObject(ac)

    return ac:GetControler() ~= bc:GetControler() and ac:IsFaceup() and bc:IsFaceup()
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local ac = e:GetLabelObject()
    if not ac:IsRelateToBattle() or ac:IsFacedown() or not ac:IsControler(tp) then return end

    local ct = Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(1000 * ct)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    ac:RegisterEffect(ec1)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    local atk = 0
    for tc in g:Iter() do if tc:HasNonZeroAttack() then atk = atk + tc:GetAttack() end end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.me3filter(c)
    if c:IsFacedown() or not c:IsMonster() then return false end
    return c:IsNegatable() or (not c:IsType(TYPE_TOKEN) and not c:IsType(TYPE_TRAPMONSTER))
end

function s.me3con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or not Duel.IsDamageCalculated() end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(s.me3filter, tp, 0, LOCATION_MZONE + LOCATION_GRAVE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.me3filter, tp, 0, LOCATION_MZONE + LOCATION_GRAVE, 1, 1, nil)
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

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

    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local code = tc:GetOriginalCodeRule()
        local atk = tc:GetBaseAttack()
        if atk < 0 then atk = 0 end

        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_UPDATE_ATTACK)
        ec2:SetValue(atk)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec2)

        if not tc:IsType(TYPE_TOKEN) and not tc:IsType(TYPE_TRAPMONSTER) then
            c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 1)
        end
    end
end
