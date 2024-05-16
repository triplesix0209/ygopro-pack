-- Kagero, Dragon Emperor of Firestorms
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- fusion summon
    Fusion.AddProcMix(c, true, true, function(c, sc, sumtype, tp) return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON, sc, sumtype, tp) end,
        aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_FIRE))
    Fusion.AddContactProc(c, function(tp) return Duel.GetReleaseGroup(tp) end, function(g) Duel.Release(g, REASON_COST + REASON_MATERIAL) end,
        s.splimit, nil, nil, nil, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(s.splimit)
    c:RegisterEffect(splimit)

    DragonRuler.RegisterEmperorEffect(s, c, id, ATTRIBUTE_FIRE)
end

function s.splimit(e, se, sp, st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st) or aux.penlimit(e, se, sp, st) end
