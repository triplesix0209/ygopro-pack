-- Forbidden Art of Palladium
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.listed_series = {SET_PALLADIUM}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
                   Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(71703785) end, tp, LOCATION_ONFIELD, 0, 1, nil)
    end)
    act:SetTarget(Utility.MultiEffectTarget(s))
    act:SetOperation(Utility.MultiEffectOperation(s))
    c:RegisterEffect(act)

    -- ritual
    local e1 = Ritual.CreateProc({
        desc = 1171,
        handler = c,
        lvtype = RITPROC_GREATER,
        location = LOCATION_HAND + LOCATION_DECK,
        matfilter = function(c) return c:IsSetCard(SET_PALLADIUM) end
    })
    Utility.RegisterMultiEffect(s, 1, e1)

    -- fusion
    local e2 = Fusion.CreateSummonEff({
        desc = 1170,
        handler = c,
        extrafil = function(e, tp)
            local g = Duel.GetMatchingGroup(function(c) return c:IsAbleToGrave() and c:IsSetCard(SET_PALLADIUM) end, tp, LOCATION_DECK, 0, nil)
            local check = function(tp, sg, fc)
                return sg:IsExists(Card.IsSetCard, 1, nil, SET_PALLADIUM) and sg:FilterCount(Card.IsLocation, nil, LOCATION_DECK) <= 1
            end
            return g, check
        end
    })
    Utility.RegisterMultiEffect(s, 2, e2)
end
