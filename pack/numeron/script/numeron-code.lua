-- Numeron Code
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_NUMBER, SET_NUMERON}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- activation and effect cannot be negated
    local nonegate = Effect.CreateEffect(c)
    nonegate:SetType(EFFECT_TYPE_FIELD)
    nonegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nonegate:SetCode(EFFECT_CANNOT_INACTIVATE)
    nonegate:SetRange(LOCATION_ONFIELD)
    nonegate:SetTargetRange(1, 0)
    nonegate:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(nonegate)
    local nodiseff = nonegate:Clone()
    nodiseff:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(nodiseff)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(nodis)

    -- untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_FZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- cannot disable summon
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTarget(function(e, c) return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) and c:IsControler(e:GetHandlerPlayer()) end)
    c:RegisterEffect(e2)

    -- detaching cost is optional
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local rc = re:GetHandler()
        return (r & REASON_COST) ~= 0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and rc:IsSetCard(SET_NUMERON) and
                   rc:IsControler(e:GetOwnerPlayer())
    end)
    e3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) return ev end)
    c:RegisterEffect(e3)

    -- copy effect
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_FZONE)
    e4:SetHintTiming(TIMINGS_CHECK_MONSTER + TIMING_BATTLE_START + TIMING_MAIN_END)
    e4:SetCountLimit(1, id)
    e4:SetCost(function(e)
        e:SetLabel(1)
        return true
    end)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e4filter(c)
    return c:IsSetCard(SET_NUMERON) and c:IsSpellTrap() and c:IsAbleToGraveAsCost()
        and c:CheckActivateEffect(true, true, true) ~= nil
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        if e:GetLabel() == 0 then return false end
        e:SetLabel(0)

        return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil)
    end

    e:SetLabel(0)
    local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e4filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil)
    local te, ceg, cep, cev, cre, cr, crp = g:GetFirst():CheckActivateEffect(true, true, true)
    Duel.SendtoGrave(g, REASON_COST)

    te:SetProperty(te:GetProperty())
    local tg = te:GetTarget()
    if tg then tg(e, tp, ceg, cep, cev, cre, cr, crp, 1) end
    e:SetLabelObject(te)
    Duel.ClearOperationInfo(0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local te = e:GetLabelObject()
    if not te then return end
    local op = te:GetOperation()
    if op then op(te, tp, eg, ep, ev, re, r, rp) end
end
