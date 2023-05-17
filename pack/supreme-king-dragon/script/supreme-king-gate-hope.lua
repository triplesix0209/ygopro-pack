-- Supreme King Gate Hope
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {13331639, 900005006}
s.listed_series = {0x10f8}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- self destroy
    local pselfdes = Effect.CreateEffect(c)
    pselfdes:SetType(EFFECT_TYPE_SINGLE)
    pselfdes:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    pselfdes:SetCode(EFFECT_SELF_DESTROY)
    pselfdes:SetRange(LOCATION_PZONE)
    pselfdes:SetCondition(function(e)
        return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x10f8), e:GetHandlerPlayer(), LOCATION_PZONE, 0, 1, e:GetHandler())
    end)
    c:RegisterEffect(pselfdes)

    -- cannot disable pendulum summon
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    pe1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(1, 0)
    pe1:SetTarget(function(e, c) return c:IsSummonType(SUMMON_TYPE_PENDULUM) end)
    c:RegisterEffect(pe1)

    -- recover
    local pe2 = Effect.CreateEffect(c)
    pe2:SetCategory(CATEGORY_RECOVER)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe2:SetCode(900005006)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Utility.HintCard(e)
        Duel.Recover(tp, ev, REASON_EFFECT)
    end)
    c:RegisterEffect(pe2)
end
