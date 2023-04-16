-- Black Luster Soldier - Palladium Soldier
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    c:EnableReviveLimit()

    -- special summon procedure
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_HAND)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- battle destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdocon)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.spfilter(c, attr) return c:IsAttribute(attr) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c, true) end

function s.sprescon(sg, e, tp, mg) return aux.ChkfMMZ(1)(sg, e, tp, mg) and sg:IsExists(s.spattrcheck, 1, nil, sg) end

function s.spattrcheck(c, sg) return c:IsAttribute(ATTRIBUTE_LIGHT) and sg:FilterCount(Card.IsAttribute, c, ATTRIBUTE_DARK) == 1 end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g1 = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil, ATTRIBUTE_LIGHT)
    local g2 = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil, ATTRIBUTE_DARK)

    local g = g1:Clone():Merge(g2)
    return #g1 > 0 and #g2 > 0 and aux.SelectUnselectGroup(g, e, tp, 2, 2, s.sprescon, 0) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > -2
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    local mg = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil, ATTRIBUTE_LIGHT + ATTRIBUTE_DARK)
    local g = aux.SelectUnselectGroup(mg, e, tp, 2, 2, s.sprescon, 1, tp, HINTMSG_REMOVE, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.Remove(g, POS_FACEUP, REASON_COST)
    g:DeleteGroup()
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3060)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(aux.tgoval)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetDescription(3030)
    ec1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    ec1b:SetValue(function(e, re, rp) return rp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(ec1b)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local b3 = Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
    local b4 = Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0, LOCATION_HAND, 1, nil)
    local op = Duel.SelectEffect(tp, {true, aux.Stringid(id, 0)}, {true, aux.Stringid(id, 1)}, {b3, aux.Stringid(id, 2)},
        {b4, aux.Stringid(id, 3)})
    e:SetLabel(op)

    e:SetCategory(0)
    if op == 3 then
        e:SetCategory(CATEGORY_REMOVE)
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, tp, 0)
    elseif op == 4 then
        e:SetCategory(CATEGORY_REMOVE)
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0, LOCATION_HAND, nil)
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, tp, 0)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = e:GetLabel()
    if op == 1 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1500)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
    elseif op == 2 then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec2:SetCode(EFFECT_EXTRA_ATTACK)
        ec2:SetValue(1)
        ec2:SetLabel(Duel.GetTurnCount())
        ec2:SetCondition(function(e, tp) return Duel.GetTurnCount() > e:GetLabel() end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_SELF_TURN, 2)
        c:RegisterEffect(ec2)
    elseif op == 3 then
        local g = Utility.SelectMatchingCard(HINT_SELECTMSG, tp, Card.IsAbleToRemove, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1,
            1, nil)
        if #g > 0 then
            Duel.HintSelection(g)
            Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
        end
    elseif op == 4 then
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0, LOCATION_HAND, nil, tp)
        if #g > 0 then
            g = g:RandomSelect(tp, 1)
            Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
        end
    end
end
