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
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(2203)
    me4:SetCategory(CATEGORY_DESTROY)
    me4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me4:SetCode(EVENT_DESTROYED)
    me4:SetProperty(EFFECT_FLAG_DELAY)
    me4:SetCondition(s.me4con)
    me4:SetTarget(s.me4tg)
    me4:SetOperation(s.me4op)
    c:RegisterEffect(me4)
end

function s.lnkfilter(c, sc, sumtype, tp)
    return (c:HasLevel() or c:GetRank() > 0) and c:IsAttribute(ATTRIBUTE_DARK, sc, sumtype, tp) and c:IsRace(RACE_DRAGON, sc, sumtype, tp)
end

function s.lnkcheck(g, sc, sumtype, tp)
    return g:IsExists(Card.IsSetCard, 1, nil, SET_ODD_EYES, sc, sumtype, tp) and
               g:CheckSameProperty(function(c) return c:HasLevel() and c:GetLevel() or c:GetRank() end, sc, sumtype, tp)
end

function s.pe1filter(c) return c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.pe1filter, tp, LOCATION_DECK, 0, 1, nil) end
end

function s.pe1filter(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_TOFIELD, tp, s.pe1filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then Duel.MoveToField(g:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
end

function s.me4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.me4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if chk == 0 then return #g > 0 end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.me4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if Duel.Destroy(g, REASON_EFFECT) > 0 and c:IsRelateToEffect(e) then Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
end
