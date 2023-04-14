-- Evil HERO Igneous Insurgent
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x6008}

function s.initial_effect(c)
    -- add name
    local addname = Effect.CreateEffect(c)
    addname:SetType(EFFECT_TYPE_SINGLE)
    addname:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    addname:SetCode(EFFECT_ADD_CODE)
    addname:SetValue(84327329)
    c:RegisterEffect(addname)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- negate attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- damage
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c) return c:IsSetCard(0x6008) and c:IsMonster() and c:IsDiscardable() end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND, 0, c)
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and #rg > 0 and aux.SelectUnselectGroup(rg, e, tp, 1, 1, nil, 0)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local g = nil
    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND, 0, c)
    local g = aux.SelectUnselectGroup(rg, e, tp, 1, 1, nil, 1, tp, HINTMSG_TOGRAVE, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.SendtoGrave(g, REASON_COST)
    g:DeleteGroup()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local d = Duel.GetAttackTarget()
    return d and d:IsControler(tp) and d:IsFaceup()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp) Duel.NegateAttack() end

function s.e3filter(c) return c:IsRace(RACE_FIEND) and c:HasLevel() and c:IsFaceup() end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return (r & REASON_FUSION) == REASON_FUSION and c:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED) and c:IsFaceup()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_MZONE, 0, 1, nil) end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp, chk)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    local tc = Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e3filter, tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if tc then
        Duel.HintSelection(tc)
        Duel.Damage(p, tc:GetOriginalLevel() * 200, REASON_EFFECT)
    end
end
