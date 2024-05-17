-- init
if not aux.DragonRulerProcedure then aux.DragonRulerProcedure = {} end
if not DragonRuler then DragonRuler = aux.DragonRulerProcedure end

-- function
function DragonRuler.RegisterEmperorEffect(s, c, id, attribute)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)
    Pendulum.AddProcedure(c, false)

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(sumsafe)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(nomaterial)

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- battle position cannot be changed by effect
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

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

function DragonRuler.RegisterBabyShuffleEffect(s, c, id)
    local reg = Effect.CreateEffect(c)
    reg:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    reg:SetCode(EVENT_REMOVE)
    reg:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not re then return end
        local c = e:GetHandler()
        local rc = re:GetHandler()
        if c:IsReason(REASON_COST) and rc:IsRace(RACE_DRAGON) then
            c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
            e:SetLabel(Duel.GetTurnCount())
        end
    end)
    c:RegisterEffect(reg)

    local shuffle = Effect.CreateEffect(c)
    shuffle:SetCategory(CATEGORY_TODECK)
    shuffle:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    shuffle:SetRange(LOCATION_REMOVED)
    shuffle:SetCode(EVENT_PHASE + PHASE_END)
    shuffle:SetCountLimit(1)
    shuffle:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return e:GetLabelObject():GetLabel() == Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(id) > 0
    end)
    shuffle:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then return c:IsAbleToDeck() end
        Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
        c:ResetFlagEffect(id)
    end)
    shuffle:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if e:GetHandler():IsRelateToEffect(e) then Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKSHUFFLE, REASON_EFFECT) end
    end)
    shuffle:SetLabelObject(reg)
    c:RegisterEffect(shuffle)
end
