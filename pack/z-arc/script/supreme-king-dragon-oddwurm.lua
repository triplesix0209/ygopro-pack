-- Supreme King Dragon Oddwurm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_ODD_EYES, SET_SUPREME_KING_DRAGON}

function s.initial_effect(c)
    c:SetSPSummonOnce(id)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2c)

    -- damage
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon a dragon
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    if not Duel.GetFieldCard(tp, LOCATION_PZONE, 0) or not Duel.GetFieldCard(tp, LOCATION_PZONE, 1) then return false end

    local lsc = Duel.GetFieldCard(tp, LOCATION_PZONE, 0):GetLeftScale()
    local rsc = Duel.GetFieldCard(tp, LOCATION_PZONE, 1):GetRightScale()
    if lsc > rsc then lsc, rsc = rsc, lsc end
    local lv = c:GetLevel()
    return lsc < lv and lv < rsc
end

function s.e2filter(c) return c:IsSpellTrap() and c:ListsArchetype(SET_ODD_EYES) and c:IsAbleToHand() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e2filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local bc = e:GetHandler():GetBattleTarget()
    local atk = bc:GetBaseAttack()
    if atk < 0 then atk = 0 end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(atk)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, atk)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end

function s.e4filter(c, e, tp)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0 then return false end
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and not c:IsCode(id) and
               ((c:IsSetCard(SET_ODD_EYES) and c:IsRace(RACE_DRAGON)) or c:IsSetCard(SET_SUPREME_KING_DRAGON))
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return (r & REASON_EFFECT + REASON_BATTLE) ~= 0 end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_EXTRA
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then loc = loc + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE end
    if chk == 0 then return loc ~= 0 and Duel.IsExistingMatchingCard(s.e4filter, tp, loc, 0, 1, nil, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_EXTRA
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then loc = loc + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE end
    if loc == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.e4filter, tp, loc, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
