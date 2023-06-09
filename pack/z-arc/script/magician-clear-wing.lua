-- Clear Wing Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_CLEAR_WING}

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM)), 1, 99)

    -- synchro summon
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(1172)
    pe1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- synchro level
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    me1:SetCode(EFFECT_SYNCHRO_LEVEL)
    me1:SetValue(function(e, sync) return 3 * 65536 + e:GetHandler():GetLevel() end)
    c:RegisterEffect(me1)

    -- damage
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 0))
    me2:SetCategory(CATEGORY_DAMAGE)
    me2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_PLAYER_TARGET)
    me2:SetCode(EVENT_CHAINING)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, id)
    me2:SetCondition(s.me2con)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)

    -- place into pendulum zone
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(2203)
    me3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me3:SetCode(EVENT_DESTROYED)
    me3:SetProperty(EFFECT_FLAG_DELAY)
    me3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
    me3:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not e:GetHandler():IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end
        Duel.MoveToField(e:GetHandler(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end)
    c:RegisterEffect(me3)
end

function s.pe1filter1(c, tp, mc)
    local mg = Group.FromCards(c, mc)
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSynchroMaterial() and
               Duel.IsExistingMatchingCard(s.pe1filter2, tp, LOCATION_EXTRA, 0, 1, nil, tp, mg)
end

function s.pe1filter2(c, tp, mg) return Duel.GetLocationCountFromEx(tp, tp, mg, c) > 0 and c:IsSynchroSummonable(nil, mg) end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsPlayerCanSpecialSummonCount(tp, 2) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   Duel.IsExistingMatchingCard(s.pe1filter1, tp, LOCATION_MZONE, 0, 1, nil, tp, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SMATERIAL)
    Duel.SelectTarget(tp, s.pe1filter1, tp, LOCATION_MZONE, 0, 1, 1, c, tp, c)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 or Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) == 0 then return end
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local mg = Group.FromCards(c, tc)
    local g = Duel.GetMatchingGroup(s.pe1filter2, tp, LOCATION_EXTRA, 0, nil, tp, mg)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        Duel.SynchroSummon(tp, g:Select(tp, 1, 1, nil):GetFirst(), nil, mg)
    end
end

function s.me2con(e, tp, eg, ep, ev, re, r, rp)
    local rc = re:GetHandler()
    return re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(SET_CLEAR_WING) and rc:IsRace(RACE_DRAGON)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then return rc:IsOnField() and rc:IsFaceup() end

    local dmg = rc:GetAttack()
    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
