-- init
if not aux.DragonRulerProcedure then aux.DragonRulerProcedure = {} end
if not DragonRuler then DragonRuler = aux.DragonRulerProcedure end

-- constant
DragonRuler.CARD_MESSIAH_DEITY = 900007001

-- function
function DragonRuler.RegisterDeityEffect(s, c, id, attribute)
    s.listed_names = {DragonRuler.CARD_MESSIAH_DEITY}
    s.pendulum_level = 10
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)
    Pendulum.AddProcedure(c, false)

    -- link summon
    Link.AddProcedure(c, nil, 3, nil, function(g, sc, sumtype, tp)
        return g:IsExists(function(c, sc, sumtype, tp) return c:IsAttribute(attribute, sc, sumtype, tp) end, 1, nil, sc, sumtype, tp)
    end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        local c = e:GetHandler()
        if sp ~= e:GetOwnerPlayer() then return false end
        return not (c:IsLocation(LOCATION_EXTRA) and c:IsFacedown()) or (st & SUMMON_TYPE_LINK) == SUMMON_TYPE_LINK
    end)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(sumsafe)

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- cannot be target while in pendulum zone
    local pen_untarget = Effect.CreateEffect(c)
    pen_untarget:SetType(EFFECT_TYPE_SINGLE)
    pen_untarget:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    pen_untarget:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    pen_untarget:SetRange(LOCATION_PZONE)
    pen_untarget:SetValue(aux.tgoval)
    c:RegisterEffect(pen_untarget)

    -- special summon from the pendulum zone
    local pen_sum = Effect.CreateEffect(c)
    pen_sum:SetDescription(2)
    pen_sum:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pen_sum:SetType(EFFECT_TYPE_QUICK_O)
    pen_sum:SetCode(EVENT_FREE_CHAIN)
    pen_sum:SetRange(LOCATION_PZONE)
    pen_sum:SetCountLimit(1, {id, 0})
    pen_sum:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() < PHASE_END end)
    pen_sum:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local rg = Duel.GetMatchingGroup(function(c)
            return (c:IsRace(RACE_DRAGON) or c:IsAttribute(attribute)) and c:IsAbleToRemoveAsCost() and
                       (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true))
        end, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, e:GetHandler())
        if chk == 0 then
            return Duel.GetLocationCount(tp, LOCATION_MZONE) > -2 and #rg > 1 and aux.SelectUnselectGroup(rg, e, tp, 2, 2, aux.ChkfMMZ(1), 0)
        end

        local g = aux.SelectUnselectGroup(rg, e, tp, 2, 2, aux.ChkfMMZ(1), 1, tp, HINTMSG_REMOVE)
        Duel.Remove(g, POS_FACEUP, REASON_COST)
    end)
    pen_sum:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
    end)
    pen_sum:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if e:GetHandler():IsRelateToEffect(e) then Duel.SpecialSummon(e:GetHandler(), 1, tp, tp, false, false, POS_FACEUP) end
    end)
    c:RegisterEffect(pen_sum)

    -- place itself into pendulum zone
    local pen_place = Effect.CreateEffect(c)
    pen_place:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    pen_place:SetProperty(EFFECT_FLAG_DELAY)
    pen_place:SetCode(EVENT_DESTROYED)
    pen_place:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return e:GetHandler():IsFaceup() and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
    end)
    pen_place:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    pen_place:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not Duel.CheckPendulumZones(tp) or not e:GetHandler():IsRelateToEffect(e) then return false end
        Duel.MoveToField(e:GetHandler(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end)
    c:RegisterEffect(pen_place)
end

function DragonRuler.DeityCost(question_string, attribute, extra_cost)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.IsExistingMatchingCard(DeityCostFilter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil, attribute, e, tp,
                extra_cost) or Duel.IsExistingMatchingCard(DeityCostBypassFilter, tp, LOCATION_ONFIELD, 0, 1, nil)
        end

        if Duel.IsExistingMatchingCard(DeityCostBypassFilter, tp, LOCATION_ONFIELD, 0, 1, nil) and
            not Duel.SelectEffectYesNo(tp, e:GetHandler(), question_string) then return end

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local g = Duel.SelectMatchingCard(tp, DeityCostFilter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil, attribute, e, tp,
            extra_cost)

        Duel.Remove(g, POS_FACEUP, REASON_COST)
    end
end

function DragonRuler.RegisterDeityBabyEffect(s, c, id, attribute)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 2, nil,
        function(g, sc, sumtype, tp) return g:IsExists(Card.IsAttribute, 1, nil, attribute, sc, sumtype, tp) end)

    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH + CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
    e1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return Duel.IsExistingMatchingCard(DeityBabySearchFilter, tp, LOCATION_DECK, 0, 1, nil, attribute) end

        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
        Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local sc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, DeityBabySearchFilter, tp, LOCATION_DECK, 0, 1, 1, nil, attribute):GetFirst()
        if not sc or Duel.SendtoHand(sc, nil, REASON_EFFECT) == 0 then return end

        Duel.ConfirmCards(1 - tp, sc)
        if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and DeityBabySpecialSummonFilter(sc, e, tp) and
            Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then Duel.SpecialSummon(sc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) end
    end)
    c:RegisterEffect(e1)

    -- to deck
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e2:SetRange(LOCATION_REMOVED)
    e2:SetCode(EVENT_PHASE + PHASE_STANDBY)
    e2:SetCountLimit(1)
    e2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return true end
        Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
        Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_REMOVED)
    end)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if e:GetHandler():IsRelateToEffect(e) and Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKSHUFFLE, REASON_EFFECT) and
            Duel.IsExistingMatchingCard(DeityBabyReturnFilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, attribute) and
            Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then
            Duel.BreakEffect()
            local g = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, DeityBabyReturnFilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil,
                attribute)
            Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        end
    end)
    e2:SetLabelObject(e2reg)
    c:RegisterEffect(e2)
end

function DragonRuler.RegisterMessiahBabyEffect(s, c, id, attributes, search_locations)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp) return c:IsRace(RACE_DRAGON, sc, sumtype, tp) and not c:IsType(TYPE_LINK, sc, sumtype, tp) end,
        1, 1)

    -- pendulum summon limit
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    pe1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(1, 0)
    pe1:SetTarget(function(e, c, tp, sumtp, sumpos) return not c:IsRace(RACE_DRAGON) and (sumtp & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM end)
    c:RegisterEffect(pe1)

    -- add to extra deck
    local pe3 = Effect.CreateEffect(c)
    pe3:SetDescription(aux.Stringid(id, 0))
    pe3:SetCategory(CATEGORY_TOEXTRA)
    pe3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    pe3:SetCode(EVENT_SPSUMMON_SUCCESS)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return eg:IsExists(function(c, tp) return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsSummonPlayer(tp) end, 1, nil, tp)
    end)
    pe3:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return true end
        Duel.SetOperationInfo(0, CATEGORY_TOEXTRA, e:GetHandler(), 1, 0, 0)
    end)
    pe3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not e:GetHandler():IsRelateToEffect(e) then return end
        Duel.SendtoExtraP(e:GetHandler(), tp, REASON_EFFECT)
    end)
    c:RegisterEffect(pe3)

    -- attribute
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    me1:SetCode(EFFECT_ADD_ATTRIBUTE)
    me1:SetRange(LOCATION_MZONE + LOCATION_GRAVE)
    me1:SetValue(attributes)
    c:RegisterEffect(me1)

    -- special summon a dragon
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 1))
    me2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me2:SetType(EFFECT_TYPE_IGNITION)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, id)
    me2:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return e:GetHandler():IsReleasable() end
        Duel.Release(e:GetHandler(), REASON_COST)
    end)
    me2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then
            return Duel.GetMZoneCount(tp, c) > 0 and
                       Duel.IsExistingMatchingCard(MessiahBabySearchCostFilter, tp, LOCATION_HAND, 0, 1, nil, search_locations, e, tp)
        end

        local tc = Utility.SelectMatchingCard(HINTMSG_DISCARD, tp, MessiahBabySearchCostFilter, tp, LOCATION_HAND, 0, 1, 1, nil, search_locations, e,
            tp):GetFirst()
        e:SetLabel(tc:GetAttribute())
        Duel.SendtoGrave(tc, REASON_COST + REASON_DISCARD)

        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, search_locations)
    end)
    me2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

        local attr = e:GetLabel()
        local tc =
            Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, MessiahBabySearchTargetFilter, tp, search_locations, 0, 1, 1, nil, attr, e, tp):GetFirst()
        if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(3207)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE | PHASE_END)
            tc:RegisterEffect(ec1)
        end
    end)
    c:RegisterEffect(me2)

    -- place in pendulum zone
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(aux.Stringid(id, 2))
    me3:SetType(EFFECT_TYPE_IGNITION)
    me3:SetRange(LOCATION_EXTRA)
    me3:SetCountLimit(1, id)
    me3:SetCondition(aux.exccon)
    me3:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.IsExistingMatchingCard(MessiahBabyPlaceCostFilter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil)
        end

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local g = Duel.SelectMatchingCard(tp, MessiahBabyPlaceCostFilter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)

        Duel.Remove(g, POS_FACEUP, REASON_COST)
    end)
    me3:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end
    end)
    me3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not Duel.CheckPendulumZones(tp) or not c:IsRelateToEffect(e) then return end
        Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end)
    c:RegisterEffect(me3)
end

function DeityCostFilter(c, attribute, e, tp, extra_cost)
    return c:IsAttribute(attribute) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true)) and
               (extra_cost == nil or extra_cost(c, e, tp))
end

function DeityCostBypassFilter(c) return c:IsFaceup() and c:IsCode(DragonRuler.CARD_MESSIAH_DEITY) end

function DeityBabySearchFilter(c, attribute) return c:IsLevelBelow(7) and c:IsAttribute(attribute) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand() end

function DeityBabySpecialSummonFilter(c, e, tp) return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE) end

function DeityBabyReturnFilter(c, attribute)
    return c:IsFaceup() and not c:IsType(TYPE_LINK) and c:IsAbleToDeck() and (c:IsAttribute(attribute) or c:IsRace(RACE_DRAGON))
end

function MessiahBabySearchCostFilter(c, locations, e, tp)
    return c:IsDiscardable() and c:IsRace(RACE_DRAGON) and
               Duel.IsExistingMatchingCard(MessiahBabySearchTargetFilter, tp, locations, 0, 1, c, c:GetAttribute(), e, tp)
end

function MessiahBabySearchTargetFilter(c, attr, e, tp)
    return c:IsRace(RACE_DRAGON) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function MessiahBabyPlaceCostFilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true))
end
