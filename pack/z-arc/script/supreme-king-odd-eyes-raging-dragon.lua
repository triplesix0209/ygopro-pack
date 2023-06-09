-- Supreme King Odd-Eyes Raging Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {SET_ODD_EYES}
s.listed_series = {SET_ODD_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- link summon
    Link.AddProcedure(c, s.lnkfilter, 2, 2, s.lnkcheck)

    -- overscale
    local pensum = Effect.CreateEffect(c)
    pensum:SetType(EFFECT_TYPE_SINGLE)
    pensum:SetCode(511004423)
    c:RegisterEffect(pensum)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_LINK) == SUMMON_TYPE_LINK or (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)

    -- pendulum set
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- place into pendulum zone
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(2203)
    me1:SetCategory(CATEGORY_DESTROY)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetCode(EVENT_DESTROYED)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCondition(s.me1con)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- gain effect
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    me2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    me2:SetCode(EVENT_SPSUMMON_SUCCESS)
    me2:SetCondition(s.me2con)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
    local me2check = Effect.CreateEffect(c)
    me2check:SetType(EFFECT_TYPE_SINGLE)
    me2check:SetCode(EFFECT_MATERIAL_CHECK)
    me2check:SetValue(s.me2check)
    me2check:SetLabelObject(me2)
    c:RegisterEffect(me2check)

    -- indes
    local me3 = Effect.CreateEffect(c)
    me3:SetType(EFFECT_TYPE_SINGLE)
    me3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    me3:SetRange(LOCATION_MZONE)
    me3:SetValue(s.effcon)
    c:RegisterEffect(me3)

    -- can make a second attack
    local me4 = Effect.CreateEffect(c)
    me4:SetType(EFFECT_TYPE_SINGLE)
    me4:SetCode(EFFECT_EXTRA_ATTACK)
    me4:SetCondition(s.effcon)
    me4:SetValue(1)
    c:RegisterEffect(me4)

    -- negate & destroy
    local me5 = Effect.CreateEffect(c)
    me5:SetDescription(aux.Stringid(id, 2))
    me5:SetCategory(CATEGORY_DESTROY)
    me5:SetType(EFFECT_TYPE_IGNITION)
    me5:SetRange(LOCATION_MZONE)
    me5:SetCountLimit(1)
    me5:SetCondition(s.effcon)
    me5:SetTarget(s.me5tg)
    me5:SetOperation(s.me5op)
    c:RegisterEffect(me5)
end

function s.lnkfilter(c, sc, sumtype, tp)
    return (c:HasLevel() or c:GetRank() > 0) and c:IsAttribute(ATTRIBUTE_DARK, sc, sumtype, tp) and c:IsRace(RACE_DRAGON, sc, sumtype, tp)
end

function s.lnkcheck(g, sc, sumtype, tp)
    return g:IsExists(Card.IsSetCard, 1, nil, SET_ODD_EYES, sc, sumtype, tp) and
               g:CheckSameProperty(function(c) return c:HasLevel() and c:GetLevel() or c:GetRank() end, sc, sumtype, tp)
end

function s.pe1filter(c)
    if c:Islocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.pe1filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil) end
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_TOFIELD, tp, s.pe1filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil)
    if #g > 0 then Duel.MoveToField(g:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
end

function s.me1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if chk == 0 then return #g > 0 end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if Duel.Destroy(g, REASON_EFFECT) > 0 and c:IsRelateToEffect(e) then Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
end

function s.me2checkfilter(c, sc) return c:IsType(TYPE_PENDULUM, sc, SUMMON_TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end

function s.me2check(e, c)
    local g = c:GetMaterial()
    if g:IsExists(s.me2checkfilter, 1, nil, c) then
        e:GetLabelObject():SetLabel(1)
    else
        e:GetLabelObject():SetLabel(0)
    end
end

function s.me2con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel() == 1 end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    e:GetHandler():RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 1))
end

function s.effcon(e) return e:GetHandler():GetFlagEffect(id) > 0 end

function s.me5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ng = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSpellTrap), tp, 0, LOCATION_ONFIELD, nil)
    local dg = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    if chk == 0 then return #dg > 0 end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, ng, #ng, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, dg, #dg, 0, 0)
end

function s.me5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ng = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSpellTrap), tp, 0, LOCATION_ONFIELD, nil)
    for tc in ng:Iter() do
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
    end
    Duel.AdjustInstantly()

    local dg = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    local ct = Duel.Destroy(dg, REASON_EFFECT)
    if ct > 0 and c:IsFaceup() and c:IsRelateToEffect(e) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(ct * 200)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end
