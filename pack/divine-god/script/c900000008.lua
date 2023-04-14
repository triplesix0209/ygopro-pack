-- The Wicked Deity Avatar
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.WickedGod(s, c, 2)

    -- atk/def value
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_DELAY + EFFECT_FLAG_REPEAT + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    c:RegisterEffect(e1b)
    local e1check = Effect.CreateEffect(c)
    e1check:SetType(EFFECT_TYPE_SINGLE)
    e1check:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1check:SetCode(21208154)
    c:RegisterEffect(e1check)

    -- negate & prevent Spell/Trap
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1val(e)
    local c = e:GetHandler()

    local atk = 0
    local g = Duel.GetMatchingGroup(function(tc) return tc:IsFaceup() and not tc:IsHasEffect(21208154) end, 0, LOCATION_MZONE, LOCATION_MZONE, nil)
    if #g > 0 then
        local tg, val = g:GetMaxGroup(Card.GetAttack)
        if not tg:IsExists(aux.TRUE, 1, c) then
            g:RemoveCard(c)
            tg, val = g:GetMaxGroup(Card.GetAttack)
        end

        atk = val
    end

    if atk >= c:GetBaseAttack() then
        return atk + 100
    else
        return c:GetBaseAttack()
    end
end

function s.e2filter(c) return c:IsFaceup() and c:IsSpellTrap() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return true end
    Duel.SetChainLimit(function(e, rp, tp) return tp == rp or not e:IsHasType(EFFECT_TYPE_ACTIVATE) end)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local g = Duel.GetMatchingGroup(s.e2filter, tp, 0, LOCATION_ONFIELD, nil)
    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, Duel.IsTurnPlayer(tp) and 4 or 3)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec1b)
    end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, 0))
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec2:SetTargetRange(0, 1)
    ec2:SetValue(function(e, re, tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
    ec2:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
    Duel.RegisterEffect(ec2, tp)
    local ec2hint = Effect.CreateEffect(c)
    ec2hint:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2hint:SetCode(EVENT_PHASE + PHASE_END)
    ec2hint:SetCountLimit(1)
    ec2hint:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() ~= tp end)
    ec2hint:SetOperation(s.e2turnop)
    ec2hint:SetLabelObject(ec2)
    ec2hint:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
    Duel.RegisterEffect(ec2hint, tp)
    local ec2clockdestiny = Effect.CreateEffect(c)
    ec2clockdestiny:SetType(EFFECT_TYPE_SINGLE)
    ec2clockdestiny:SetDescription(aux.Stringid(id, tp == c:GetOwner() and 0 or 1))
    ec2clockdestiny:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_SET_AVAILABLE)
    ec2clockdestiny:SetCode(1082946)
    ec2clockdestiny:SetLabelObject(ec2hint)
    ec2clockdestiny:SetOwnerPlayer(tp)
    ec2clockdestiny:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) s.e2turnop(e:GetLabelObject(), tp, eg, ep, ev, e, r, rp) end)
    ec2clockdestiny:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
    c:RegisterEffect(ec2clockdestiny)
end

function s.e2turnop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = e:GetLabel() + 1
    c:SetTurnCounter(ct)

    if ct == 2 then
        c:SetTurnCounter(0)
        e:GetLabelObject():Reset()
        if re then re:Reset() end
    else
        e:SetLabel(ct)
    end
end
