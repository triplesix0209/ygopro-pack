-- Dragon's Elysium
Duel.LoadScript("util.lua")
local s, id = GetID()

s.counter_place_list = {0x22}

function s.initial_effect(c)
    c:EnableCounterPermit(0x22)

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- add counter
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_REMOVE)
    e1:SetRange(LOCATION_FZONE)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e3reg = Effect.CreateEffect(c)
    e3reg:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3reg:SetCode(EVENT_LEAVE_FIELD_P)
    e3reg:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) e:SetLabel(e:GetHandler():GetCounter(0x22)) end)
    c:RegisterEffect(e3reg)
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetLabelObject(e3reg)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c) return c:IsFaceup() and c:IsMonster() and not c:IsPreviousLocation(0x80 + LOCATION_SZONE) and not c:IsType(TYPE_TOKEN) end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local ct = eg:FilterCount(s.e1filter, nil)
    if ct > 0 then e:GetHandler():AddCounter(0x22, ct) end
end

function s.e3filter(c, lk, e, tp)
    return c:IsRace(RACE_DRAGON) and c:IsLinkBelow(lk) and Duel.GetLocationCountFromEx(tp, tp, nil, c) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_LINK, tp, false, false)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local ct = e:GetLabelObject():GetLabel()
    e:SetLabel(ct)
    return ct > 0
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_EXTRA, 0, 1, nil, e:GetLabel(), e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e3filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e:GetLabel(), e, tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc, SUMMON_TYPE_LINK, tp, tp, false, false, POS_FACEUP)
        tc:CompleteProcedure()
    end
end
