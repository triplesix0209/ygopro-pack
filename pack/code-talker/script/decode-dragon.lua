-- Decode Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2)

    -- negate activation
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return not c:IsStatus(STATUS_BATTLE_DESTROYED) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return rp ~= tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    local lg = c:GetLinkedGroup():Filter(s.e1filter, nil)
    if chk == 0 then return #lg > 0 end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, lg, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    local lg = c:GetLinkedGroup():Filter(s.e1filter, nil)

    local tc = Utility.GroupSelect(HINTMSG_DESTROY, lg, tp):GetFirst()
    if not tc or Duel.Destroy(tc, REASON_EFFECT) == 0 then return end
    Duel.NegateActivation(ev)
end

function s.e2filter(c, e, tp, zone)
    return c:IsRace(RACE_CYBERSE) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, tp, zone)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local zone = c:GetLinkedZone(tp) & 0x1f
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp, zone)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp, zone)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    local zone = c:GetLinkedZone(tp) & 0x1f
    if tc and tc:IsRelateToEffect(e) and zone ~= 0 then Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP, zone) end
end
