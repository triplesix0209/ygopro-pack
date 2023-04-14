-- Evil HERO Darkness Inferno Wing
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {0x8, 0x6008}
s.material_setcode = {0x8, 0x6008}
s.dark_calling = true

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true,
        function(c, sc, st, tp) return c:IsSetCard(0x6008, sc, st, tp) and c:IsType(TYPE_FUSION, sc, st, tp) end,
        aux.FilterBoolFunctionEx(Card.IsRace, RACE_FIEND))

    -- lizard check
    local lizcheck = Effect.CreateEffect(c)
    lizcheck:SetType(EFFECT_TYPE_SINGLE)
    lizcheck:SetCode(CARD_CLOCK_LIZARD)
    lizcheck:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    lizcheck:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), EFFECT_SUPREME_CASTLE)
    end)
    lizcheck:SetValue(1)
    c:RegisterEffect(lizcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.EvilHeroLimit)
    c:RegisterEffect(splimit)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c)
        return Duel.GetMatchingGroupCount(Card.IsSetCard, c:GetControler(), LOCATION_GRAVE, 0, nil, 0x8) * 300
    end)
    c:RegisterEffect(e1)

    -- destroy & chain attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_START)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- piercing 
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e3)

    -- inflict damage
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCondition(aux.bdcon)
    e4:SetTarget(s.e4tg1)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e4b:SetCode(EVENT_DESTROYED)
    e4b:SetRange(LOCATION_MZONE)
    e4b:SetCondition(s.e4con2)
    e4b:SetTarget(s.e4tg2)
    c:RegisterEffect(e4b)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local tc = c:GetBattleTarget()
    if chk == 0 then return tc and tc:IsControler(1 - tp) end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, tc, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetAttacker()
    if c == tc then tc = Duel.GetAttackTarget() end

    if tc and tc:IsRelateToBattle() then Duel.Destroy(tc, REASON_EFFECT) end
    if c:IsRelateToEffect(e) and c:CanChainAttack() and c == Duel.GetAttacker() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_DAMAGE_STEP_END)
        ec1:SetCountLimit(1)
        ec1:SetOperation(function(e, tp)
            local c = e:GetHandler()
            if c:CanChainAttack() then Duel.ChainAttack() end
        end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_BATTLE)
        c:RegisterEffect(ec1)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end

function s.e4tg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    local dmg = bc:GetBaseAttack()
    if bc:GetBaseAttack() < bc:GetBaseDefense() then dmg = bc:GetBaseDefense() end
    if dmg < 0 then dmg = 0 end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e4con2(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT) ~= 0 and re and re:GetOwner() == e:GetHandler() and eg:IsExists(Card.IsMonster, 1, nil)
end

function s.e4tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local c = e:GetHandler()

    local dmg = 0
    local g = eg:Filter(Card.IsMonster, nil)
    for tc in aux.Next(g) do
        if tc:GetBaseAttack() > dmg then dmg = tc:GetBaseAttack() end
        if tc:GetBaseDefense() > dmg then dmg = tc:GetBaseDefense() end
    end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end
