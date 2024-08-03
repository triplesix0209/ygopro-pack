-- init
if not aux.MessiahProcedure then aux.MessiahProcedure = {} end
if not Messiah then Messiah = aux.MessiahProcedure end

-- constant
Messiah.CARD_MESSIAH_ELYSIUM = 900007000

-- function
function Messiah.RegisterMessiahBabyEffect(s, c, id, sp_location, sp_filter)
    s.listed_names = {Messiah.CARD_MESSIAH_ELYSIUM}
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- untargetable
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_CANNOT_DISABLE)
    pe1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetValue(1)
    c:RegisterEffect(pe1)

    -- add to extra deck
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetCategory(CATEGORY_TOEXTRA)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    pe2:SetCode(EVENT_SPSUMMON_SUCCESS)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return eg:IsExists(function(c, tp) return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsSummonPlayer(tp) end, 1, nil, tp)
    end)
    pe2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return true end
        Duel.SetOperationInfo(0, CATEGORY_TOEXTRA, e:GetHandler(), 1, 0, 0)
    end)
    pe2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not e:GetHandler():IsRelateToEffect(e) then return end
        Duel.SendtoExtraP(e:GetHandler(), tp, REASON_EFFECT)
    end)
    c:RegisterEffect(pe2)

    -- cannot disable pendulum summon
    local pe3 = Effect.CreateEffect(c)
    pe3:SetType(EFFECT_TYPE_FIELD)
    pe3:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    pe3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetTargetRange(1, 0)
    pe3:SetTarget(function(e, c) return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsRace(RACE_DRAGON) end)
    c:RegisterEffect(pe3)

    -- special summon or place in pendulum zone
    local me1 = Effect.CreateEffect(c)
    me1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me1:SetType(EFFECT_TYPE_IGNITION)
    me1:SetRange(LOCATION_EXTRA)
    me1:SetCountLimit(1, {id, 1})
    me1:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        local b1 = Duel.IsExistingMatchingCard(DeityCostBypassFilter, tp, LOCATION_ONFIELD, 0, 1, nil)
        local b2 = Duel.IsExistingMatchingCard(MessiahBabyPlaceCostFilter, tp, LOCATION_HAND, 0, 1, nil)
        if chk == 0 then return b1 or b2 end

        if not b2 then return end
        if not b1 or Duel.SelectEffectYesNo(tp, c, aux.Stringid(Messiah.CARD_MESSIAH_ELYSIUM, 0)) then
            local g = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, MessiahBabyPlaceCostFilter, tp, LOCATION_HAND, 0, 1, 1, nil)
            Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
        end
    end)
    me1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        local b1 = c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
        local b2 = c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
        if chk == 0 then return c:IsFaceup() and (b1 or b2) end
        Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    end)
    me1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsRelateToEffect(e) then return end

        local b1 = c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
        local b2 = c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and Duel.CheckPendulumZones(tp)
        local op = Duel.SelectEffect(tp, {b1, 2}, {b2, aux.Stringid(id, 1)})
        if op == 1 then
            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        else
            Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
        end
    end)
    c:RegisterEffect(me1)

    -- special summon a monster
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 2))
    me2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me2:SetType(EFFECT_TYPE_IGNITION)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, {id, 2})
    me2:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        local zone = aux.GetMMZonesPointedTo(tp)
        local b1 = Duel.IsExistingMatchingCard(DeityCostBypassFilter, tp, LOCATION_ONFIELD, 0, 1, nil)
        local b2 = c:IsReleasable()
        if chk == 0 then return b1 or b2 end

        if not b2 then return end
        if not b1 or Duel.SelectEffectYesNo(tp, c, aux.Stringid(Messiah.CARD_MESSIAH_ELYSIUM, 0)) then Duel.Release(c, REASON_COST) end
    end)
    me2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        local zone = aux.GetMMZonesPointedTo(tp)
        if chk == 0 then
            return zone > 0 and Duel.IsExistingMatchingCard(MessiahBabySummonTargetFilter, tp, sp_location, 0, 1, nil, e, tp, zone, sp_filter)
        end

        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, sp_location)
    end)
    me2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local zone = aux.GetMMZonesPointedTo(tp)
        if zone <= 0 then return end
        local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, MessiahBabySummonTargetFilter, tp, sp_location, 0, 1, 1, nil, e, tp, zone,
            sp_filter):GetFirst()
        if not tc then return end

        if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP, zone) > 0 then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(3207)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(ec1)
        end
    end)
    c:RegisterEffect(me2)
end

function DeityCostBypassFilter(c) return c:IsFaceup() and c:IsOriginalCode(Messiah.CARD_MESSIAH_ELYSIUM) end

function MessiahBabyPlaceCostFilter(c) return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost() end

function MessiahBabySummonTargetFilter(c, e, tp, zone, sp_filter)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, tp, zone) and (sp_filter == nil or sp_filter(c))
end
