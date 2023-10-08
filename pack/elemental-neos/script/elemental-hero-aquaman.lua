-- Elemental HERO Aquaman
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_HERO, SET_ELEMENTAL_HERO}

function s.initial_effect(c)
    -- normal monster
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE + LOCATION_ONFIELD)
    e1:SetValue(TYPE_NORMAL)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_REMOVE_TYPE)
    e1b:SetValue(TYPE_EFFECT)
    c:RegisterEffect(e1b)

    -- draw
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER + EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(SET_HERO) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end

function s.e3filter(c) return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_ELEMENTAL_HERO) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e3filter, 1, nil) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = eg:Filter(s.e3filter, nil, SET_HERO):GetFirst()
    if not tc then return end

    tc:RegisterFlagEffect(0, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
    if not tc:IsType(TYPE_EFFECT) then
        local ec0 = Effect.CreateEffect(c)
        ec0:SetType(EFFECT_TYPE_SINGLE)
        ec0:SetCode(EFFECT_ADD_TYPE)
        ec0:SetValue(TYPE_EFFECT)
        ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec0, true)
    end

    -- untargetable
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(function(e, re, rp) return aux.tgoval(e, re, rp) and re:IsActiveType(TYPE_MONSTER) end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1, true)
end
