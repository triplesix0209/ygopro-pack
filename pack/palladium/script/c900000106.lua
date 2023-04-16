-- Chaos End Ruler - Ruler of the Beginning and the End
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xcf}
s.listed_series = {0xcf}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, 8, 2)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or ((st & SUMMON_TYPE_XYZ) == SUMMON_TYPE_XYZ and not se)
    end)
    c:RegisterEffect(splimit)

    -- special summon, activation and effects cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1b:SetTargetRange(1, 0)
    e1b:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(e1b)
    local e1c = e1b:Clone()
    e1c:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e1c)
    local e1d = Effect.CreateEffect(c)
    e1d:SetType(EFFECT_TYPE_SINGLE)
    e1d:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(e1d)

    -- act limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) Duel.SetChainLimitTillChainEnd(function(e, ep, tp) return tp == ep end) end)
    c:RegisterEffect(e2)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(function(e, c)
        return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_GRAVE + LOCATION_REMOVED, LOCATION_GRAVE + LOCATION_REMOVED) * 100
    end)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3b)

    -- disable
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_DISABLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0, LOCATION_MZONE)
    e4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return Duel.GetAttacker() == c and c:GetBattleTarget() and
                   (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL)
    end)
    e4:SetTarget(function(e, c) return c == e:GetHandler():GetBattleTarget() end)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e4b)

    -- immune
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_CANNOT_RELEASE)
    e5:SetTargetRange(0, 1)
    e5:SetCondition(s.e5con)
    e5:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(e5)
    local e5b = Effect.CreateEffect(c)
    e5b:SetType(EFFECT_TYPE_SINGLE)
    e5b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e5b:SetCondition(s.e5con)
    e5b:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e5b)
    local e5c = Effect.CreateEffect(c)
    e5c:SetType(EFFECT_TYPE_SINGLE)
    e5c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5c:SetRange(LOCATION_MZONE)
    e5c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e5c:SetCondition(s.e5con)
    e5c:SetValue(aux.tgoval)
    c:RegisterEffect(e5c)
    local e5d = e5c:Clone()
    e5d:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e5d:SetValue(1)
    c:RegisterEffect(e5d)

    -- banish & damage
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 0))
    e6:SetCategory(CATEGORY_REMOVE + CATEGORY_DAMAGE)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1, id)
    e6:SetCondition(s.e6con)
    e6:SetCost(s.e6cost)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
    c:RegisterEffect(e6, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.xyzfilter(c, sc, sumtype, tp) return c:IsSetCard(0xcf, sc, sumtype, tp) end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(function(c)
        return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_RITUAL)
    end, 1, nil)
end

function s.e6con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(function(c)
        return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_RITUAL)
    end, 1, nil) and Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()
end

function s.e6cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    c:RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_ONFIELD
    local g = Duel.GetFieldGroup(tp, 0, loc)
    if chk == 0 then return #g > 0 end

    local dc = g:FilterCount(Card.IsAbleToRemove, nil, 1 - tp)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, 0, 0, 1 - tp, dc * 500)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_HAND + LOCATION_ONFIELD)
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT)

    local ct = Duel.GetOperatedGroup():FilterCount(Card.IsLocation, nil, LOCATION_REMOVED)
    if ct > 0 then
        Duel.BreakEffect()
        Duel.Damage(1 - tp, ct * 500, REASON_EFFECT)
    end

    local ec0 = Effect.CreateEffect(c)
    ec0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT + EFFECT_FLAG_OATH)
    ec0:SetDescription(aux.Stringid(id, 1))
    ec0:SetTargetRange(1, 0)
    ec0:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec0, tp)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetTargetRange(LOCATION_MZONE, 0)
    ec1:SetTarget(function(e, c) return e:GetLabel() ~= c:GetFieldID() end)
    ec1:SetLabel(c:GetFieldID())
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end
