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

    -- protect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or e:GetHandler():GetLinkedGroup():IsContains(c) end)
    e1:SetValue(aux.indoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1b:SetCode(EFFECT_CANNOT_REMOVE)
    e1b:SetTargetRange(1, 1)
    e1b:SetTarget(function(e, c, rp, r, re)
        local tp = e:GetHandlerPlayer()
        return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and rp == 1 - tp and r & REASON_EFFECT ~= 0 and
                   (c == e:GetHandler() or e:GetHandler():GetLinkedGroup():IsContains(c))
    end)
    c:RegisterEffect(e1b)

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
