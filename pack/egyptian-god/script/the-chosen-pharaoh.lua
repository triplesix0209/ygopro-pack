-- The Chosen Pharaoh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {39913299, 10000000, 10000020, CARD_RA, 10000040}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetHintTiming(0, TIMING_END_PHASE)
    c:RegisterEffect(act)

    -- activation and effect cannot be negated
    local nonegate = Effect.CreateEffect(c)
    nonegate:SetType(EFFECT_TYPE_FIELD)
    nonegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nonegate:SetCode(EFFECT_CANNOT_INACTIVATE)
    nonegate:SetRange(LOCATION_ONFIELD)
    nonegate:SetTargetRange(1, 0)
    nonegate:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(nonegate)
    local nodiseff = nonegate:Clone()
    nodiseff:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(nodiseff)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(nodis)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.e1con)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1b:SetCode(EFFECT_CANNOT_REMOVE)
    e1b:SetRange(LOCATION_SZONE)
    e1b:SetTargetRange(1, 1)
    e1b:SetCondition(s.e1con)
    e1b:SetTarget(function(e, c, tp, r) return c == e:GetHandler() and r == REASON_EFFECT end)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1c:SetValue(aux.tgoval)
    c:RegisterEffect(e1c)

    -- grave protect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_REMOVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_GRAVE, 0)
    e2:SetTarget(s.e2tg)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2b:SetCode(EVENT_CHAIN_SOLVING)
    e2b:SetRange(LOCATION_SZONE)
    e2b:SetOperation(s.e2op)
    c:RegisterEffect(e2b)

    -- leaving the field
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon a Divine-Beast
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetHintTiming(0, TIMING_END_PHASE)
    e4:SetCountLimit(1, {id, 1})
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- add or set spell/trap that mentions Divine-Beast
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_SZONE)
    e5:SetHintTiming(0, TIMING_END_PHASE)
    e5:SetCountLimit(1, {id, 1})
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- call holactie
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 3))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_SZONE)
    e6:SetHintTiming(0, TIMING_END_PHASE)
    e6:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
    e6:SetCost(s.e6cost)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e1filter(c) return c:IsFaceup() and c:IsOriginalAttribute(ATTRIBUTE_DIVINE) end

function s.e1con(e) return Duel.IsExistingMatchingCard(s.e1filter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil) end

function s.e2filter(c, tp, re)
    return c:IsRelateToEffect(re) and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsOriginalAttribute(ATTRIBUTE_DIVINE)
end

function s.e2tg(e, c, tp, r, re) return c:IsOriginalAttribute(ATTRIBUTE_DIVINE) end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if rp == tp or not Duel.IsChainDisablable(ev) then return end

    local res = false
    if not res and s.e2discheck(tp, ev, CATEGORY_SPECIAL_SUMMON, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_REMOVE, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_TOHAND, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_TODECK, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_TOEXTRA, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_EQUIP, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_LEAVE_GRAVE, re) then res = true end

    if res then
        Utility.HintCard(e)
        Duel.NegateEffect(ev)
    end
end

function s.e2discheck(tp, ev, category, re)
    local ex, tg, ct, p, v = Duel.GetOperationInfo(ev, category)
    if tg and #tg > 0 then return tg:IsExists(s.e2filter, 1, nil, tp, re) end
    return false
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousPosition(POS_FACEUP) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Utility.HintCard(e)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_RULE)
end

function s.e4filter(c, e, tp) return c:IsOriginalRace(RACE_DIVINE) and c:IsCanBeSpecialSummoned(e, 0, tp, true, false) end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil, e, tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e4filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP) > 0 and tc:IsPreviousLocation(LOCATION_GRAVE) then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 1))

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetCountLimit(1)
        ec1:SetLabelObject(tc)
        ec1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetLabelObject():GetFlagEffect(id) > 0 end)
        ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) Duel.SendtoGrave(e:GetLabelObject(), REASON_EFFECT) end)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e5filter1(c, tp)
    return c:IsFaceup() and c:IsOriginalRace(RACE_DIVINE) and Duel.IsExistingMatchingCard(s.e5filter2, tp, LOCATION_DECK, 0, 1, nil, tp, c)
end

function s.e5filter2(c, tp, sc)
    return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, c:GetCode()), tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, nil) and
               c:ListsCode(sc:GetCode()) and c:IsSpellTrap() and (c:IsSSetable() or c:IsAbleToHand())
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e5filter1, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil, tp) end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local sc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e5filter1, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil, tp):GetFirst()
    if not sc then return end
    Duel.HintSelection(Group.FromCards(sc))

    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e5filter2, tp, LOCATION_DECK, 0, 1, 1, nil, tp, sc):GetFirst()
    aux.ToHandOrElse(tc, tp, function(c) return tc:IsSSetable() end, function(c) Duel.SSet(tp, tc) end, 1159)
end

function s.e6filter1(c) return c:IsCode(39913299) and c:IsDiscardable() end

function s.e6filter2(c, code)
    local code2, code3 = c:GetOriginalCodeRule()
    return code2 == code or code3 == code
end

function s.e6rescon(sg, e, tp, mg)
    return aux.ChkfMMZ(1)(sg, e, tp, mg) and sg:IsExists(s.e6chk, 1, nil, sg, Group.CreateGroup(), 10000000, 10000020, CARD_RA)
end

function s.e6chk(c, sg, g, code, ...)
    local code2, code3 = c:GetOriginalCodeRule()
    if code ~= code2 and code ~= code3 then return false end
    local res
    if ... then
        g:AddCard(c)
        res = sg:IsExists(s.e6chk, 1, g, sg, g, ...)
        g:RemoveCard(c)
    else
        res = true
    end
    return res
end

function s.e6cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local rg = Duel.GetReleaseGroup(tp)
    local g1 = rg:Filter(s.e6filter2, nil, 10000000)
    local g2 = rg:Filter(s.e6filter2, nil, 10000020)
    local g3 = rg:Filter(s.e6filter2, nil, CARD_RA)
    local mg = Group.CreateGroup()
    mg:Merge(g1)
    mg:Merge(g2)
    mg:Merge(g3)

    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e6filter1, tp, LOCATION_HAND, 0, 1, nil) and Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c) and
                   #g1 > 0 and #g2 > 0 and #g3 > 0 and aux.SelectUnselectGroup(mg, e, tp, 3, 3, s.e6rescon, 0)
    end

    Duel.DiscardHand(tp, s.e6filter1, 1, 1, REASON_COST + REASON_DISCARD)
    local sg = aux.SelectUnselectGroup(mg, e, tp, 3, 3, s.e6rescon, 1, tp, HINTMSG_RELEASE, s.e6rescon, nil, false)
    Duel.Release(sg, REASON_COST)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsPlayerCanSpecialSummonMonster(tp, 10000040, 0, TYPE_MONSTER + TYPE_EFFECT, 0, 0, 12, RACE_CREATORGOD, ATTRIBUTE_DIVINE)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local tc = Duel.CreateToken(tp, 10000040)
    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
end
