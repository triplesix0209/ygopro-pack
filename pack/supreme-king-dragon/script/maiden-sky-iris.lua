-- Maiden of Sky Iris
Duel.LoadScript("util.lua")
local s, id = GetID()

s.pendulum_level = 4

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- xyz summon
    Xyz.AddProcedure(c, nil, 8, 2, s.ovfilter, aux.Stringid(id, 0))

    -- atk & def up
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetCode(EFFECT_UPDATE_ATTACK)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(LOCATION_MZONE, 0)
    pe1:SetValue(s.pe1val)
    c:RegisterEffect(pe1)
    local pe1b = pe1:Clone()
    pe1b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(pe1b)

    -- special summon (pendulum zone)
    local pe2 = Effect.CreateEffect(c)
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    pe2:SetCode(EVENT_DESTROYED)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1, id)
    pe2:SetCondition(s.pe2con)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

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

    -- place in pendulum zone
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 1))
    me2:SetType(EFFECT_TYPE_QUICK_O)
    me2:SetCode(EVENT_FREE_CHAIN)
    me2:SetRange(LOCATION_MZONE)
    me2:SetHintTiming(0, TIMING_END_PHASE)
    me2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    me2:SetCost(s.mecost)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2, false, REGISTER_FLAG_DETACH_XMAT)

    -- special summon from pendulum zone
    local me3 = me2:Clone()
    me3:SetDescription(aux.Stringid(id, 2))
    me3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.ovfilter(c, tp, sc) return c:IsFaceup() and c:IsType(TYPE_XYZ, sc, SUMMON_TYPE_XYZ) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end

function s.pe1val(e, c)
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType, TYPE_PENDULUM), tp, LOCATION_EXTRA, 0, nil)
    return g:GetClassCount(Card.GetCode) * 100
end

function s.pe2filter(c, tp)
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and
               c:IsType(TYPE_PENDULUM)
end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.pe2filter, 1, nil, tp) end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 and Duel.CheckPendulumZones(tp) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
        local tc = eg:Filter(s.pe2filter, nil, tp):Select(tp, 1, 1, nil):GetFirst()
        Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end
end

function s.me1filter1(c, sc) return c:IsType(TYPE_PENDULUM, sc, SUMMON_TYPE_XYZ) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end

function s.ne1filter2(c) return c:IsQuickPlaySpell() and c:IsSSetable() end

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
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.me1filter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, 0, 0)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
    local g = Utility.SelectMatchingCard(HINTMSG_SET, tp, s.ne1filter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then Duel.SSet(tp, g) end
end

function s.mecost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:CheckRemoveOverlayCard(tp, 1, REASON_COST) end

    c:RemoveOverlayCard(tp, 1, 1, REASON_COST)
    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
end

function s.me2filter(c) return c:IsFaceup() and c:IsType(TYPE_PENDULUM) end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)) and
                   Duel.IsExistingMatchingCard(s.me2filter, tp, LOCATION_MZONE, 0, 1, nil)
    end
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    if not Duel.CheckLocation(tp, LOCATION_PZONE, 0) or not Duel.CheckLocation(tp, LOCATION_PZONE, 1) then return end

    local g = Utility.SelectMatchingCard(aux.Stringid(id, 0), tp, s.me2filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.HintSelection(g)

    if #g > 0 then Duel.MoveToField(g:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
end

function s.me3filter(c, e, tp) return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_PENDULUM, tp, false, false) end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.me3filter, tp, LOCATION_PZONE, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_PZONE)
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.me3filter, tp, LOCATION_PZONE, 0, 1, 1, nil, e, tp)
    Duel.HintSelection(g)

    if #g > 0 then Duel.SpecialSummon(g, SUMMON_TYPE_PENDULUM, tp, tp, false, false, POS_FACEUP) end
end
