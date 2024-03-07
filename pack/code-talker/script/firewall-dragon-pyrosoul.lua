-- Firewall Dragon Pyrosoul
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_FIREWALL}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 99,
        function(g, sc, sumtype, tp) return g:CheckDifferentPropertyBinary(Card.GetAttribute, sc, sumtype, tp) end)

    -- co-linked
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetCondition(function(e) return e:GetHandler():GetMutualLinkedGroupCount() > 0 end)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or e:GetHandler():GetMutualLinkedGroup():IsContains(c) end)
    e1:SetValue(function(e, c) return c:GetMutualLinkedGroupCount() * 500 end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1b:SetTargetRange(LOCATION_ONFIELD, 0)
    e1b:SetValue(aux.tgoval)
    c:RegisterEffect(e1b)
    local e1c = e1b:Clone()
    e1c:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1c:SetValue(aux.indoval)
    c:RegisterEffect(e1c)
    local e1d = e1b:Clone()
    e1d:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1d:SetCode(EFFECT_CANNOT_REMOVE)
    e1d:SetTargetRange(1, 1)
    e1d:SetTarget(function(e, c, rp, r, re)
        local tp = e:GetHandlerPlayer()
        return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and rp == 1 - tp and r & REASON_EFFECT ~= 0 and
                   (c == e:GetHandler() or e:GetHandler():GetLinkedGroup():IsContains(c))
    end)
    c:RegisterEffect(e1d)

    -- place link
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2checkzone(p, zone) return Duel.GetLocationCount(p, LOCATION_SZONE, p, REASON_EFFECT, zone) > 0 end

function s.e2filter(c, zone)
    local p = c:GetOwner()
    return c:IsSetCard(SET_FIREWALL) and c:IsLinkMonster() and c:CheckUniqueOnField(p, LOCATION_SZONE) and
               (c:IsLocation(LOCATION_MZONE) or not c:IsForbidden()) and s.e2checkzone(p, zone)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 2000) end
    Duel.PayLPCost(tp, 2000)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local zone = c:GetLinkedZone() >> 8
    if chk == 0 then return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_MZONE, 0, 1, c, zone) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_MZONE, 0, 1, 1, c, zone)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end

    local zone = c:GetLinkedZone() >> 8
    if tc:IsLocation(LOCATION_MZONE) and not s.e2checkzone(tc:GetOwner(), zone) then
        Duel.SendtoGrave(tc, REASON_RULE, nil, PLAYER_NONE)
    elseif Duel.MoveToField(tc, tp, tc:GetOwner(), LOCATION_SZONE, POS_FACEUP, true, zone) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CHANGE_TYPE)
        ec1:SetValue(TYPE_SPELL + TYPE_LINK)
        ec1:SetReset(RESET_EVENT + (RESETS_STANDARD & ~RESET_TURN_SET))
        tc:RegisterEffect(ec1)

        if c:GetMutualLinkedGroup():IsContains(tc) then
            local code = tc:GetOriginalCode()
            c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD, 1)
        end
    end
end

function s.e3filter1(c, e, tp)
    return c:IsLinkMonster() and e:GetHandler():GetLinkedGroup():IsContains(c) and
               Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, c)
end

function s.e3filter2(c, e, tp, tc)
    return c:IsRace(RACE_CYBERSE) and c:IsLinkMonster() and c:IsLinkBelow(tc:GetLink()) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_LINK, tp, false, false)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(s.e3filter1, tp, LOCATION_MZONE, 0, 1, c, e, tp) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.e3filter1, tp, LOCATION_MZONE, 0, 1, 1, c, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if Duel.Destroy(tc, REASON_EFFECT) ~= 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e3filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, tc):GetFirst()
        if tc then
            Duel.SpecialSummon(tc, SUMMON_TYPE_LINK, tp, tp, false, false, POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
end
