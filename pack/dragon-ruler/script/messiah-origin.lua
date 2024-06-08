-- Messiah, Origin Deity of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterMessiahBabyEffect(s, c, id, ATTRIBUTE_WATER + ATTRIBUTE_WIND + ATTRIBUTE_LIGHT, LOCATION_HAND + LOCATION_DECK)

    -- cannot disable pendulum summon
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    pe1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(1, 0)
    pe1:SetTarget(function(e, c) return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsRace(RACE_DRAGON) end)
    c:RegisterEffect(pe1)
end
