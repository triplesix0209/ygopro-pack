-- Sun Divine Dragon of Ra
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_names = {95286165}

function s.initial_effect(c)
    Divine.EgyptianGod(s, c, 2)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_SINGLE_RANGE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetRange(LOCATION_HAND + LOCATION_DECK)
    splimit:SetValue(aux.FALSE)
    c:RegisterEffect(splimit)

    -- atk/def value
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_MATERIAL_CHECK)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1sum = Effect.CreateEffect(c)
    e1sum:SetType(EFFECT_TYPE_SINGLE)
    e1sum:SetCode(EFFECT_SUMMON_COST)
    e1sum:SetLabelObject(e1)
    e1sum:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) e:GetLabelObject():SetLabel(1) end)
    c:RegisterEffect(e1sum)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- life point transfer
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET + EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e3:SetLabel(0)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3b:SetCode(EVENT_SUMMON_SUCCESS)
    e3b:SetCondition(aux.TRUE)
    c:RegisterEffect(e3b)
    local e3c = e3b:Clone()
    e3c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3c)
    local e3d = e3b:Clone()
    e3d:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3d)
    aux.GlobalCheck(s, function()
        local defuse = Effect.CreateEffect(c)
        defuse:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        defuse:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        defuse:SetCode(EVENT_ADJUST)
        defuse:SetCondition(s.e3defusregcon)
        defuse:SetOperation(s.e3defusregop)
        Duel.RegisterEffect(defuse, 0)
    end)
end

function s.e1val(e, c)
    local atk = 0
    local def = 0
    local g = c:GetMaterial()
    for tc in g:Iter() do
        atk = atk + tc:GetAttack()
        def = def + tc:GetDefense()
    end

    if e:GetLabel() == 1 then
        e:SetLabel(0)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_SET_BASE_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
        c:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
        ec1b:SetValue(def)
        c:RegisterEffect(ec1b)
    end
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, nil, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
    Duel.SetTargetCard(g)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then Duel.Destroy(tc, REASON_EFFECT) end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.GetLP(tp) > 1 and c:IsSummonType(SUMMON_TYPE_NORMAL)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetChainLimit(aux.FALSE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) or Duel.GetLP(tp) <= 1 then return end
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 0)

    -- set lp
    local lp = Duel.GetLP(tp) - 1
    e:SetLabel(lp)
    Duel.SetLP(tp, 1)

    -- hint
    local ec0 = Effect.CreateEffect(c)
    ec0:SetDescription(aux.Stringid(id, 2))
    ec0:SetType(EFFECT_TYPE_SINGLE)
    ec0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    ec0:SetCode(id)
    ec0:SetLabel(e:GetLabel())
    ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec0)

    -- fusion type
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_ADD_TYPE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    ec1:SetValue(TYPE_FUSION)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)

    -- atk/def up
    local lp = e:GetLabel()
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec2:SetCode(EFFECT_UPDATE_ATTACK)
    ec2:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    ec2:SetValue(function(e) return e:GetHandler():GetCardEffect(id):GetLabel() end)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec2)
    local ec2b = ec2:Clone()
    ec2b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(ec2b)

    -- life point convert
    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec3:SetCode(EVENT_RECOVER)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCondition(function(e, tp, eg, ep) return ep == tp end)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or not c:IsHasEffect(id) then return end

        local eff = c:GetCardEffect(id)
        local label = eff:GetLabel()
        label = label + ev
        eff:SetLabel(label)

        Duel.SetLP(tp, Duel.GetLP(tp) - ev, REASON_EFFECT)
    end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec3)

    -- unstoppable attack
    local ec4 = Effect.CreateEffect(c)
    ec4:SetType(EFFECT_TYPE_SINGLE)
    ec4:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    ec4:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    ec4:SetRange(LOCATION_MZONE)
    ec4:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    ec4:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec4)
    Utility.ResetListEffect(c, nil, EFFECT_CANNOT_ATTACK)

    -- tribute to atk up
    local ec5 = Effect.CreateEffect(c)
    ec5:SetDescription(aux.Stringid(id, 3))
    ec5:SetCategory(CATEGORY_ATKCHANGE)
    ec5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    ec5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec5:SetRange(LOCATION_MZONE)
    ec5:SetCode(EVENT_ATTACK_ANNOUNCE)
    ec5:SetCondition(s.e3atkcon)
    ec5:SetCost(s.e3atkcost)
    ec5:SetOperation(s.e3atkop)
    ec5:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec5)
end

function s.e3atkcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsHasEffect(id) and Duel.GetAttacker() == c
end

function s.e3atkcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsReleasable), tp, LOCATION_MZONE, 0, c)
    if chk == 0 then return #g > 0 end

    e:SetLabel(g:GetSum(Card.GetAttack))
    Duel.Release(g, REASON_COST)
end

function s.e3atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) or not c:IsHasEffect(id) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(e:GetLabel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e3defusregfilter(c) return c:IsCode(95286165) and not c:IsHasEffect(id) end

function s.e3defusregcon(e, tp, eg, ep, ev, re, r, rp) return Duel.IsExistingMatchingCard(s.e3defusregfilter, tp, 0xff, 0xff, 1, nil) end

function s.e3defusregop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.e3defusregfilter, tp, 0xff, 0xff, nil)
    for tc in g:Iter() do
        local ec0 = Effect.CreateEffect(tc)
        ec0:SetType(EFFECT_TYPE_SINGLE)
        ec0:SetCode(id)
        tc:RegisterEffect(ec0)

        local ec1 = Effect.CreateEffect(tc)
        ec1:SetDescription(aux.Stringid(id, 0))
        ec1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE + CATEGORY_RECOVER)
        ec1:SetType(EFFECT_TYPE_ACTIVATE)
        ec1:SetCode(tc:GetActivateEffect():GetCode())
        ec1:SetProperty(tc:GetActivateEffect():GetProperty() + EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
        ec1:SetTarget(s.e3defustg)
        ec1:SetOperation(s.e3defusop)
        tc:RegisterEffect(ec1)
    end
end

function s.e3defusfilter(c, id) return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsCode(CARD_RA) and c:IsHasEffect(id) end

function s.e3defustg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(s.e3defusfilter, tp, LOCATION_MZONE, 0, 1, nil, id) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tc = Duel.SelectTarget(tp, s.e3defusfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, id):GetFirst()

    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tc:GetControler(), tc:GetAttack())
end

function s.e3defusop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsHasEffect(id) then return end
    tc:RegisterFlagEffect(95286165, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)

    -- clear life point transfer
    local atk = tc:GetAttack()
    tc:GetCardEffect(id):Reset()
    if tc:GetCardEffect(EFFECT_SET_BASE_ATTACK) then tc:GetCardEffect(EFFECT_SET_BASE_ATTACK):Reset() end
    if tc:GetCardEffect(EFFECT_SET_BASE_DEFENSE) then tc:GetCardEffect(EFFECT_SET_BASE_DEFENSE):Reset() end

    -- cannot attack or activate effect
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetDescription(3302)
    ec1b:SetCode(EFFECT_CANNOT_TRIGGER)
    tc:RegisterEffect(ec1b)
    if Duel.GetAttacker() == c then Duel.NegateAttack() end

    -- atk/def become 0 and recover lp
    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_SINGLE)
    ec3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec3:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec3:SetValue(0)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec3)
    local ec3b = ec1:Clone()
    ec3b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    tc:RegisterEffect(ec3b)
    Duel.AdjustInstantly(tc)
    Duel.Recover(tc:GetControler(), atk, REASON_EFFECT)
end
