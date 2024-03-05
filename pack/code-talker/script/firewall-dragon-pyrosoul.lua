-- Firewall Dragon Pyrosoul
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x118}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 99,
        function(g, sc, sumtype, tp) return g:CheckDifferentPropertyBinary(Card.GetAttribute, sc, sumtype, tp) end)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetTarget(function(e, c) return c:IsFaceup() and (c == e:GetHandler() or e:GetHandler():GetLinkedGroup():IsContains(c)) end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e2:SetCondition(function(e) return e:GetHandler():GetMutualLinkedGroupCount() > 0 end)
    e2:SetTarget(function(e, c)
        local g = e:GetHandler():GetMutualLinkedGroup()
        return c == e:GetHandler() or g:IsContains(c)
    end)
    e2:SetValue(function(e, c) return c:GetMutualLinkedGroupCount() * 500 end)
    c:RegisterEffect(e2)

    -- set
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_END_PHASE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3filter(c) return c:IsSetCard(0x118) and (c:IsQuickPlaySpell() or c:IsTrap()) and c:IsSSetable() end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_GRAVE, 0, 1, nil) end end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_SET, tp, s.e3filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if tc then Duel.SSet(tp, tc) end
end
