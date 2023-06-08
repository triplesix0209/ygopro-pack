-- Maiden of Sky Iris
Duel.LoadScript("util.lua")
local s, id = GetID()

s.pendulum_level = 8

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- xyz summon
    Xyz.AddProcedure(c, nil, 8, 2, s.ovfilter, aux.Stringid(id, 0))

    -- place in pendulum zone / special summon
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 1))
    pe1:SetType(EFFECT_TYPE_QUICK_O)
    pe1:SetCode(EVENT_FREE_CHAIN)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetHintTiming(0, TIMING_END_PHASE)
    pe1:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1, false, REGISTER_FLAG_DETACH_XMAT)
    local pe1b = pe1:Clone()
    pe1b:SetDescription(aux.Stringid(id, 2))
    pe1b:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe1b:SetTarget(s.pe1btg)
    pe1b:SetOperation(s.pe1bop)
    c:RegisterEffect(pe1b, false, REGISTER_FLAG_DETACH_XMAT)

    -- set spell
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetCondition(s.me1con)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)
    local me1check = Effect.CreateEffect(c)
    me1check:SetType(EFFECT_TYPE_SINGLE)
    me1check:SetCode(EFFECT_MATERIAL_CHECK)
    me1check:SetValue(s.me1check)
    me1check:SetLabelObject(me1)
    c:RegisterEffect(me1check)

    -- destroy replace
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    me2:SetCode(EFFECT_DESTROY_REPLACE)
    me2:SetRange(LOCATION_MZONE)
    me2:SetTarget(s.me2tg)
    me2:SetValue(s.me2val)
    c:RegisterEffect(me2)

    -- place into pendulum zone (destroyed)
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(2203)
    me3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me3:SetCode(EVENT_DESTROYED)
    me3:SetProperty(EFFECT_FLAG_DELAY)
    me3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
    me3:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not Duel.CheckPendulumZones(tp) then return end
        local c = e:GetHandler()
        if c:IsRelateToEffect(e) then Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
    end)
    c:RegisterEffect(me3)
end

function s.ovfilter(c, tp, sc)
    return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsType(TYPE_PENDULUM, sc, SUMMON_TYPE_XYZ) and
               c:IsType(TYPE_XYZ, sc, SUMMON_TYPE_XYZ)
end

function s.pe1filter(c) return c:IsFaceup() and c:IsType(TYPE_PENDULUM) end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)) and
                   Duel.IsExistingMatchingCard(s.pe1filter, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    if not (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)) then return end

    local g = Utility.SelectMatchingCard(aux.Stringid(id, 0), tp, s.pe1filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.HintSelection(g)
    if #g > 0 then Duel.MoveToField(g:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
end

function s.pe1bfilter(c, e, tp) return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_PENDULUM, tp, false, false) end

function s.pe1btg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.pe1bfilter, tp, LOCATION_PZONE, 0, 1, nil, e, tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_PZONE)
end

function s.pe1bop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.pe1bfilter, tp, LOCATION_PZONE, 0, 1, 1, nil, e, tp)
    Duel.HintSelection(g)
    if #g > 0 then Duel.SpecialSummon(g, SUMMON_TYPE_PENDULUM, tp, tp, false, false, POS_FACEUP) end
end

function s.me1filter1(c, sc) return c:IsType(TYPE_PENDULUM, sc, SUMMON_TYPE_XYZ) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end

function s.me1filter2(c) return c:IsQuickPlaySpell() and c:IsSSetable() end

function s.me1check(e, c)
    local g = c:GetMaterial()
    if g:IsExists(s.me1filter1, 1, nil, c) then
        e:GetLabelObject():SetLabel(1)
    else
        e:GetLabelObject():SetLabel(0)
    end
end

function s.me1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel() == 1 end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and Duel.IsExistingMatchingCard(s.me1filter2, tp, LOCATION_DECK, 0, 1, nil)
    end
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SET, tp, s.me1filter2, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then Duel.SSet(tp, g) end
end

function s.me2filter(c, tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE + REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = c:GetLinkedGroup()
    if chk == 0 then return eg:IsExists(s.me2filter, 1, nil, tp) and c:CheckRemoveOverlayCard(tp, 1, REASON_EFFECT) end

    if Duel.SelectEffectYesNo(tp, c, 96) then
        c:RemoveOverlayCard(tp, 1, 1, REASON_EFFECT)
        return true
    else
        return false
    end
end

function s.me2val(e, c)
    local tp = e:GetHandlerPlayer()
    return s.me2filter(c, tp)
end
