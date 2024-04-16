-- Laufey the Nordic Giant
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x42}
s.material_setcode = {0x42}
s.curgroup = nil

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    UtilNordic.NordicGodEffect(c, SUMMON_TYPE_LINK)

    -- link summon
    Link.AddProcedure(c, s.lnkfilter, 4, 4, s.lnkcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                            EFFECT_FLAG_SINGLE_RANGE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetRange(LOCATION_EXTRA)
    splimit:SetValue(aux.lnklimit)
    c:RegisterEffect(splimit)

    -- extra material
    local extramat = Effect.CreateEffect(c)
    extramat:SetType(EFFECT_TYPE_FIELD)
    extramat:SetProperty(
        EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE +
            EFFECT_FLAG_SET_AVAILABLE)
    extramat:SetCode(EFFECT_EXTRA_MATERIAL)
    extramat:SetRange(LOCATION_EXTRA)
    extramat:SetTargetRange(1, 1)
    extramat:SetOperation(function(c, e, tp, sg, mg, lc, og, chk)
        return not s.curgroup or #(sg & s.curgroup) <= 4
    end)
    extramat:SetValue(function(chk, sumtype, e, ...)
        if chk == 0 then
            local tp, sc = ...
            if sumtype ~= SUMMON_TYPE_LINK or sc ~= e:GetHandler() then
                return Group.CreateGroup()
            else
                s.curgroup = Duel.GetMatchingGroup(Card.IsAttribute, tp,
                                                   LOCATION_HAND, 0, nil,
                                                   ATTRIBUTE_DARK, sc, sumtype,
                                                   tp)
                s.curgroup:KeepAlive()
                return s.curgroup
            end
        elseif chk == 2 then
            if s.curgroup then s.curgroup:DeleteGroup() end
            s.curgroup = nil
        end
    end)
    c:RegisterEffect(extramat)

    -- atk
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOEXTRA + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY +
                       EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.lnkfilter(c, sc, sumtype, tp)
    return c:IsSetCard(0x42, sc, sumtype, tp) and c:HasLevel() and
               not c:IsType(TYPE_TOKEN, sc, sumtype, tp)
end

function s.lnkcheck(g, sc, sumtype, tp)
    return g:CheckDifferentProperty(Card.GetCode, sc, sumtype, tp)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsSummonType(SUMMON_TYPE_LINK) then return end

    local ct = 0
    local g = c:GetMaterial()
    for tc in aux.Next(g) do
        local lv = tc:GetLevel()
        if lv < 0 then lv = 0 end
        ct = ct + lv
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(ct * 200)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
end

function s.e2filter(c, e, tp)
    return c:IsSetCard(0x42) and c:IsLevelBelow(5) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if chk == 0 then
        return
            Duel.IsExistingMatchingCard(s.e2filter, tp, loc, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOEXTRA, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, loc)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c, nil, 2, REASON_EFFECT) ==
        0 then return end

    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if ft > 4 then ft = 4 end
    if ft > 1 and Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
        ft = 1
    end
    if ft == 0 then return end

    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_HAND +
                                        LOCATION_DECK + LOCATION_GRAVE, 0, nil,
                                    e, tp)
    g = aux.SelectUnselectGroup(g, e, tp, 1, ft, aux.dncheck, 1, tp,
                                HINTMSG_SPSUMMON)
    if #g == 0 then return end
    for tc in aux.Next(g) do
        if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false,
                                  POS_FACEUP_DEFENSE) then
            local ec2 = Effect.CreateEffect(c)
            ec2:SetDescription(3302)
            ec2:SetType(EFFECT_TYPE_SINGLE)
            ec2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            ec2:SetCode(EFFECT_CANNOT_TRIGGER)
            ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(ec2)
        end
    end
    Duel.SpecialSummonComplete()
end
