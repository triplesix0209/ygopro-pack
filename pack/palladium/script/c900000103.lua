-- Chaos Palladium Oracle Aknamkanon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_HAND)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- summon success
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- atk/def up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(function(e, c) return c:IsRace(RACE_SPELLCASTER) end)
    e2:SetValue(function(e, c) return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_REMOVED, LOCATION_REMOVED) * 100 end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2b)

    -- battle banish
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e3)

    -- return spell/trap
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCountLimit(1, id)
    e4:SetCondition(aux.bdocon)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.spfilter(c) return c:IsLevelAbove(7) and c:IsSetCard(0x13a) and c:IsRace(RACE_SPELLCASTER) end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.CheckReleaseGroup(tp, s.spfilter, 1, false, 1, true, c, tp, nil, false, nil)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    local g = Duel.SelectReleaseGroup(tp, s.spfilter, 1, 1, false, true, true, c, nil, nil, false, nil)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.Release(g, REASON_COST)
    g:DeleteGroup()
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Utility.HintCard(c)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec1:SetTargetRange(0, 1)
    ec1:SetValue(function(e, re) return re:IsActiveType(TYPE_MONSTER) end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e4filter(c) return c:IsSpellTrap() and c:IsAbleToHand() end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(s.e4filter, tp, LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.e4filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end
