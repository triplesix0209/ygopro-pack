-- Messiah, Genesis Deity of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterMessiahBabyEffect(s, c, id, ATTRIBUTE_FIRE + ATTRIBUTE_EARTH + ATTRIBUTE_DARK, LOCATION_DECK + LOCATION_GRAVE)

    -- act limit
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe1:SetCode(EVENT_SPSUMMON_SUCCESS)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if eg:IsExists(s.pe1filter, 1, nil, tp) then Duel.SetChainLimitTillChainEnd(s.pe1chainlimit) end
    end)
    c:RegisterEffect(pe1)
end

function s.pe1filter(c, tp) return c:IsRace(RACE_DRAGON) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end

function s.pe1chainlimit(e, rp, tp) return tp == rp or (e:IsActiveType(TYPE_SPELL + TYPE_TRAP) and not e:IsHasType(EFFECT_TYPE_ACTIVATE)) end
