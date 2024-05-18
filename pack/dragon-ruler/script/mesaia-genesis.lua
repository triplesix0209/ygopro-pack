-- Mesaia, Genesis of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp)
        return c:IsRace(RACE_DRAGON, sc, sumtype, tp) and not c:IsAttribute(ATTRIBUTE_DIVINE, sc, sumtype, tp)
    end, 1, 1)

    -- pendulum summon limit
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    pe1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(1, 0)
    pe1:SetTarget(function(e, c, tp, sumtp, sumpos) return not c:IsRace(RACE_DRAGON) and (sumtp & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM end)
    c:RegisterEffect(pe1)

    -- add to extra deck
    local pe3 = Effect.CreateEffect(c)
    pe3:SetDescription(aux.Stringid(id, 0))
    pe3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    pe3:SetCode(EVENT_SPSUMMON_SUCCESS)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetCondition(s.pe3con)
    pe3:SetOperation(s.pe3op)
    c:RegisterEffect(pe3)

    -- attribute
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    me1:SetCode(EFFECT_ADD_ATTRIBUTE)
    me1:SetRange(LOCATION_MZONE + LOCATION_GRAVE)
    me1:SetValue(ATTRIBUTE_FIRE + ATTRIBUTE_WATER + ATTRIBUTE_WIND + ATTRIBUTE_EARTH + ATTRIBUTE_LIGHT + ATTRIBUTE_DARK)
    c:RegisterEffect(me1)

    -- special summon a Dragon
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 1))
    me2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me2:SetType(EFFECT_TYPE_IGNITION)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, id)
    me2:SetCost(s.me2cost)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)

    -- place in pendulum zone
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(aux.Stringid(id, 2))
    me3:SetType(EFFECT_TYPE_IGNITION)
    me3:SetRange(LOCATION_EXTRA)
    me3:SetCountLimit(1, id)
    me3:SetCondition(aux.exccon)
    me3:SetCost(s.me3cost)
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)
end

function s.pe3filter(c, tp) return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsSummonPlayer(tp) end

function s.pe3con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.pe3filter, 1, nil, tp) end

function s.pe3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SendtoExtraP(c, tp, REASON_EFFECT)
end

function s.me2filter1(c, e, tp)
    return c:IsDiscardable() and c:IsRace(RACE_DRAGON) and
               Duel.IsExistingMatchingCard(s.me2filter2, tp, LOCATION_DECK, 0, 1, nil, c:GetAttribute(), e, tp)
end

function s.me2filter2(c, attr, e, tp)
    return c:IsRace(RACE_DRAGON) and c:IsAttribute(attr) and c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.me2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(), REASON_COST)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetMZoneCount(tp, c) > 0 and Duel.IsExistingMatchingCard(s.me2filter1, tp, LOCATION_HAND, 0, 1, nil, e, tp) end

    local sc = Utility.SelectMatchingCard(HINTMSG_DISCARD, tp, s.me2filter1, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp):GetFirst()
    e:SetLabel(sc:GetAttribute())
    Duel.SendtoGrave(sc, REASON_COST | REASON_DISCARD)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    local attr = e:GetLabel()
    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.me2filter2, tp, LOCATION_DECK, 0, 1, 1, nil, attr, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.me3filter(c) return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true)) end

function s.me3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.me3filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.me3filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not Duel.CheckPendulumZones(tp) or not c:IsRelateToEffect(e) then return end
    Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end
