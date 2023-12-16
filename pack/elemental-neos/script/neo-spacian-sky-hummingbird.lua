-- Neo-Spacian Sky Hummingbird
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
    e2:SetValue(54959865)
    c:RegisterEffect(e2)

    -- recover
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) > 0 end

    Duel.SetTargetPlayer(tp)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local rt = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) * 500
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    Duel.Recover(p, rt, REASON_EFFECT)
end
