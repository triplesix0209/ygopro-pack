-- Supreme King Gate Hope
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {13331639, 900005006}
s.listed_series = {0x10f8}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- self destroy
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    pe1:SetCode(EFFECT_SELF_DESTROY)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCondition(s.pe1con)
    c:RegisterEffect(pe1)

    -- recover
    local pe2 = Effect.CreateEffect(c)
    pe2:SetCategory(CATEGORY_RECOVER)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe2:SetCode(900005006)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)
end

function s.pe1filter(c) return c:IsFaceup() and c:IsSetCard(0x10f8) end

function s.pe1con(e) return not Duel.IsExistingMatchingCard(s.pe1filter, e:GetHandlerPlayer(), LOCATION_PZONE, 0, 1, e:GetHandler()) end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    Utility.HintCard(e)
    Duel.Recover(tp, ev, REASON_EFFECT)
end
