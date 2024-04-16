-- Odin, Allfather of the Aesir
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x3042, 0x4b}
s.material_setcode = {0x3042}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.AesirGodEffect(c)

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, sumtype, tp)
        return c:IsSetCard(0x3042, sc, sumtype, tp) or
                   c:IsHasEffect(EFFECT_SYNSUB_NORDIC)
    end, 1, 1, Synchro.NonTuner(nil), 2, 99)

    -- unaffected
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- draw card
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(UtilNordic.RebornCondition)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local tgp = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_PLAYER)
    return Duel.GetTurnPlayer() == tp and tgp ~= tp
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetChainLimit(function(e, lp, tp)
        return lp == tp or not e:IsHasType(EFFECT_TYPE_ACTIVATE)
    end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_IMMUNE_EFFECT)
    ec1:SetTargetRange(LOCATION_MZONE, 0)
    ec1:SetTarget(function(e, c)
        return c:IsFaceup() and c:IsOriginalSetCard(0x4b)
    end)
    ec1:SetValue(function(e, re)
        local c = e:GetHandler()
        if c:IsFacedown() or not c:IsLocation(LOCATION_ONFIELD) then
            return false
        end
        return re:IsActiveType(TYPE_SPELL + TYPE_TRAP)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    c:RegisterFlagEffect(id, RESET_PHASE + PHASE_END, EFFECT_FLAG_CLIENT_HINT,
                         1, 0, aux.Stringid(id, 0))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsPlayerCanDraw(tp, 1) and
                   Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0
    end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) == 0 then return end
    Duel.SortDecktop(tp, tp, 5)

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end
