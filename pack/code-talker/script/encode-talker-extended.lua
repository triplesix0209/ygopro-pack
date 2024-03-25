-- Encode Talker Extended
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names={6622715}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2)

    -- change name
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(6622715)
    c:RegisterEffect(e1)

    -- atk up & avoid battle damage
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(function(e, c) return c:IsRace(RACE_CYBERSE) and c:GetMutualLinkedGroupCount() > 0 end)
    e2:SetValue(500)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2b:SetValue(1)
    c:RegisterEffect(e2b)

    -- banish & recover
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_REMOVE + CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_CONFIRM)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    local bc = ac:GetBattleTarget()
    if not bc then return false end
    if ac:IsControler(1 - tp) then ac, bc = bc, ac end

    return ac:GetControler() ~= bc:GetControler() and e:GetHandler():GetLinkedGroup():IsContains(ac) and ac:IsFaceup() and bc:IsFaceup()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ac = Duel.GetAttacker()
    local bc = ac:GetBattleTarget()
    if ac:IsControler(1 - tp) then ac, bc = bc, ac end
    if chk == 0 then return bc and bc:IsOnField() and bc:IsCanBeEffectTarget(e) and ac:IsAbleToRemove() and bc:IsAbleToRemove() end

    local g = Group.FromCards(ac, bc)
    Duel.SetTargetCard(g)

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, ac:GetTextAttack() + bc:GetTextAttack())
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetTargetCards(e)
    if #tg > 0 and Duel.Remove(tg, 0, REASON_EFFECT + REASON_TEMPORARY) ~= 0 then
        local lp = 0
        local og = Duel.GetOperatedGroup()
        for tc in aux.Next(og) do
            tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
            local atk = tc:GetTextAttack()
            if atk < 0 then atk = 0 end
            lp = lp + atk
        end

        og:KeepAlive()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_PHASE + PHASE_BATTLE)
        ec1:SetCountLimit(1)
        ec1:SetLabelObject(og)
        ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local g = e:GetLabelObject()
            local sg = g:Filter(function(c) return c:GetFlagEffect(id) ~= 0 end, nil)
            g:DeleteGroup()
            for tc in aux.Next(sg) do Duel.ReturnToField(tc) end
        end)
        ec1:SetReset(RESET_PHASE + PHASE_BATTLE)
        Duel.RegisterEffect(ec1, tp)

        Duel.Recover(tp, lp, REASON_EFFECT)
    end
end
