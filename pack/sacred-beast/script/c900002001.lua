-- Uria, Ruler of Searing Flames
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_HAND)
    spr:SetCondition(s.sprcon)
    spr:SetTarget(s.sprtg)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)

    -- special summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(spsafe)

    -- no change control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(nomaterial)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c) return Duel.GetMatchingGroupCount(Card.IsTrap, c:GetControler(), LOCATION_GRAVE, 0, nil) * 1000 end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e1b)

    -- destroy spell/trap
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- reborn from grave
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(aux.exccon)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.sprfilter1(c) return c:IsFaceup() and c:IsTrap() and c:IsAbleToGraveAsCost() end

function s.sprfilter2(c) return c:IsTrap() and c:IsAbleToGraveAsCost() end

function s.sprcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local g = nil
    if Duel.IsPlayerAffectedByEffect(tp, 16317140) then
        g = Duel.GetMatchingGroup(s.sprfilter2, tp, LOCATION_ONFIELD, 0, nil)
    else
        g = Duel.GetMatchingGroup(s.sprfilter1, tp, LOCATION_ONFIELD, 0, nil)
    end

    return Duel.GetLocationCount(tp, LOCATION_MZONE) > -3 and #g > 2 and
               aux.SelectUnselectGroup(g, e, tp, 3, 3, aux.ChkfMMZ(1), 0)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, c)
    local g = nil
    if Duel.IsPlayerAffectedByEffect(tp, 16317140) then
        g = Duel.GetMatchingGroup(s.sprfilter2, tp, LOCATION_ONFIELD, 0, nil)
    else
        g = Duel.GetMatchingGroup(s.sprfilter1, tp, LOCATION_ONFIELD, 0, nil)
    end

    local sg = aux.SelectUnselectGroup(g, e, tp, 3, 3, aux.ChkfMMZ(1), 1, tp, HINTMSG_TOGRAVE, nil, nil, true)
    local dg = sg:Filter(Card.IsFacedown, nil)
    if #dg > 0 then Duel.ConfirmCards(1 - tp, dg) end

    if #sg == 3 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.SendtoGrave(g, REASON_COST)
    g:DeleteGroup()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(Card.IsFacedown, tp, 0, LOCATION_SZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, Card.IsFacedown, tp, 0, LOCATION_SZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)

    Duel.SetChainLimit(s.e2chainlimit)
end

function s.e2chainlimit(e, rp, tp) return not e:IsHasType(EFFECT_TYPE_ACTIVATE) end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsFacedown() and tc:IsRelateToEffect(e) then Duel.Destroy(tc, REASON_EFFECT) end
end

function s.e3costfilter(c) return c:IsTrap() and c:IsDiscardable() end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3costfilter, tp, LOCATION_HAND, 0, 1, nil) end

    Duel.DiscardHand(tp, s.e3costfilter, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetReasonPlayer() ~= tp and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(c, 0, tp, tp, true, false, POS_FACEUP)
end
