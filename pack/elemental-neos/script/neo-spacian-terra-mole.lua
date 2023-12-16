-- Neo-Spacian Terra Mole
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- cannot special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e1)

    -- add code
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_ADD_CODE)
    e2:SetValue(80344569)
    c:RegisterEffect(e2)

    -- return to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_START)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetAttackTarget() == c or (Duel.GetAttacker() == c and Duel.GetAttackTarget() ~= nil) end

    local tc = Duel.GetAttacker()
    if tc == c then tc = Duel.GetAttackTarget() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, tc, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetAttacker()
    if tc == c then tc = Duel.GetAttackTarget() end
    if tc:IsRelateToBattle() then Duel.SendtoHand(tc, nil, REASON_EFFECT) end
end
