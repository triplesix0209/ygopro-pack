-- Archfiend Darkness Skull Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {SET_RED_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, s.fusfilter1, s.fusfilter2)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
    e1:SetValue(function(e, te) return te:IsActiveType(TYPE_MONSTER) and te:GetOwner() ~= e:GetOwner() end)
    c:RegisterEffect(e1)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- damage
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3matcheck = Effect.CreateEffect(c)
    e3matcheck:SetType(EFFECT_TYPE_SINGLE)
    e3matcheck:SetCode(EFFECT_MATERIAL_CHECK)
    e3matcheck:SetValue(s.e3matcheck)
    e3matcheck:SetLabelObject(e3)
    c:RegisterEffect(e3matcheck)
end

function s.fusfilter1(c, fc, st, tp) return c:IsSetCard(SET_RED_EYES, fc, st, tp) and c:IsRace(RACE_DRAGON, fc, st, tp) end

function s.fusfilter2(c, fc, st, tp)
    return c:IsLevelAbove(8) and c:IsAttribute(ATTRIBUTE_DARK, fc, st, tp) and c:IsRace(RACE_DRAGON, fc, st, tp) and
               c:IsType(TYPE_FUSION, fc, st, tp)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.Destroy(g, REASON_EFFECT)

    g = Duel.GetOperatedGroup()
    if #g > 0 then
        local mg, atk = g:GetMaxGroup(Card.GetBaseAttack)
        if atk > 0 then Duel.Damage(1 - tp, atk, REASON_EFFECT) end
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel() > 0 end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local ct = Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, ct * 200)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    local ct = Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
    Duel.Damage(p, ct * 200, REASON_EFFECT)
end

function s.e3matcheck(e, c)
    if c:GetMaterial():FilterCount(Card.IsType, nil, TYPE_NORMAL) > 0 then
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
        e:GetLabelObject():SetLabel(1)
    end
end
