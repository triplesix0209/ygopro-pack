-- Sourcecode Talker
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_CODE_TALKER, SET_CYNET}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 99,
        function(g, sc, sumtype, tp) return g:IsExists(Card.IsType, 1, nil, TYPE_LINK, sc, sumtype, tp) end)

    -- Set 1 "Cynet" Spell/Trap
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter(c) return c:IsSetCard(SET_CYNET) and c:IsSpellTrap() and c:IsSSetable() end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsExtraLinked() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SET, tp, s.e2filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then Duel.SSet(tp, g) end
end
