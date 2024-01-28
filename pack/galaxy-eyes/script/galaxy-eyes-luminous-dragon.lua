-- Galaxy-Eyes Luminous Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- remove
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(TIMING_BATTLE_PHASE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAttackAbove(2000) end

function s.e1con(e, c)
    if c == nil then return true end
    return Duel.CheckReleaseGroup(c:GetControler(), s.e1filter, 2, false, 2, true, c, c:GetControler(), nil, false, nil)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
    local g = Duel.SelectReleaseGroup(tp, s.e1filter, 2, 2, false, true, true, c, nil, nil, false, nil)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.Release(g, REASON_COST)
    g:DeleteGroup()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsBattlePhase() and not e:GetHandler():IsStatus(STATUS_CHAINING) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if chk == 0 then return bc and bc:IsOnField() and bc:IsCanBeEffectTarget(e) and c:IsAbleToRemove() and bc:IsAbleToRemove() end

    Duel.SetTargetCard(bc)
    local g = Group.FromCards(c, bc)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end

    local g = Group.FromCards(c, tc)
    if Duel.Remove(g, 0, REASON_EFFECT + REASON_TEMPORARY) ~= 0 then
        local og = Duel.GetOperatedGroup()
        local oc = og:GetFirst()
        for tc in aux.Next(og) do tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1) end
        og:KeepAlive()

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_PHASE + PHASE_BATTLE)
        ec1:SetCountLimit(1)
        ec1:SetLabelObject(og)
        ec1:SetOperation(s.e2retop)
        ec1:SetReset(RESET_PHASE + PHASE_BATTLE)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e2retop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    local g = e:GetLabelObject()
    local sg = g:Filter(function(c) return c:GetFlagEffect(id) ~= 0 end, nil)
    g:DeleteGroup()

    for tc in sg:Iter() do
        if Duel.ReturnToField(tc) and tc:IsFaceup() and tc ~= c then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_DISABLE)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
            local ec2 = ec1:Clone()
            ec2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(ec2)
            if tc:IsType(TYPE_TRAPMONSTER) then
                local ec3 = ec1:Clone()
                ec3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                tc:RegisterEffect(ec3)
            end
        end
    end
end
