-- Elemental Fusion
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_ELEMENTAL_HERO}

function s.initial_effect(c)
    -- fusion summon
    local e1 = Fusion.CreateSummonEff({
        handler = c,
        extrafil = s.e1extrafil
    })
    c:RegisterEffect(e1)
end

function s.e1check(tp, sg, fc, mg) return sg:FilterCount(Card.IsLocation, nil, LOCATION_DECK) <= 1 end

function s.e1extrafil(e, tp, mg)
    if mg:IsExists(Card.IsSetCard, 1, nil, SET_ELEMENTAL_HERO, nil, SUMMON_TYPE_FUSION, tp) then
        local g = Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave), tp, LOCATION_DECK, 0, nil)
        if g and #g > 0 then return g, s.e1check end
    end
    return nil
end
