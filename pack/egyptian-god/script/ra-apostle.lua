-- Ra's Apostle
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, nil, 3, 3)

    -- apostle effect
    Divine.Apostle(id, c, CARD_RA, aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE), s.gain_op)
end

function s.gain_op(e, tp, eg, ep, ev, re, r, rp, rc)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local atk = 0
    local def = 0
    local mg = rc:GetMaterial()
    for tc in mg:Iter() do
        atk = atk + tc:GetPreviousAttackOnField()
        def = def + tc:GetPreviousDefenseOnField()
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
    rc:RegisterEffect(ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(def)
    rc:RegisterEffect(ec1b, true)
end
