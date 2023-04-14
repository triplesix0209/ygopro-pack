-- init
if not aux.DimensionProcedure then
    aux.DimensionProcedure = {}
    aux.DimensionProcedure._zones = {}
end
if not Dimension then Dimension = aux.DimensionProcedure end

-- constant
Dimension.TYPE = 0x20000000

-- function
function Dimension.Zones(tp)
    local g = Dimension._zones[tp]
    if not g then
        g = Group.CreateGroup()
        g:KeepAlive()
        Dimension._zones[tp] = g
    end

    return g
end

function Dimension.ZonesAddCard(c) return Dimension.Zones(c:GetOwner()):AddCard(c) end

function Dimension.ZonesRemoveCard(c) return Dimension.Zones(c:GetOwner()):RemoveCard(c) end

function Dimension.AddProcedure(c)
    -- startup
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    startup:SetRange(LOCATION_ALL - LOCATION_ONFIELD)
    startup:SetCode(EVENT_STARTUP)
    startup:SetOperation(function(e)
        local c = e:GetHandler()
        Duel.DisableShuffleCheck()
        Duel.SendtoDeck(c, nil, -2, REASON_RULE)
        Dimension.ZonesAddCard(c)
    end)
    c:RegisterEffect(startup)

    -- leave field
    local leave = Effect.CreateEffect(c)
    leave:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    leave:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    leave:SetCode(EVENT_LEAVE_FIELD)
    leave:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local loc = c:GetLocation()
        local rc = c:GetReasonCard()
        local mc = c:GetMaterial():GetFirst()

        if mc then
            Dimension.ZonesRemoveCard(mc)
            if loc == LOCATION_EXTRA and c:IsFaceup() then
                Duel.SendtoExtraP(mc, tp, r)
            elseif loc == LOCATION_DECK or loc == LOCATION_EXTRA then
                Duel.SendtoDeck(mc, tp, SEQ_DECKSHUFFLE, r)
            elseif loc == LOCATION_HAND then
                Duel.SendtoHand(mc, tp, r)
            elseif loc == LOCATION_GRAVE then
                Duel.SendtoGrave(mc, r)
            elseif loc == LOCATION_REMOVED then
                Duel.Remove(mc, c:GetPosition(), r, rp)
            end
            if re then mc:SetReasonEffect(re) end
            if rc then mc:SetReasonCard(rc) end
            if rp then mc:SetReasonPlayer(rp) end
        end

        Dimension.SendToDimension(c, c:GetReason())
    end)
    c:RegisterEffect(leave)
    local detach = leave:Clone()
    detach:SetCode(EVENT_TO_GRAVE)
    c:RegisterEffect(detach)
    local detach2 = detach:Clone()
    detach2:SetCode(EVENT_REMOVE)
    c:RegisterEffect(detach2)
end

function Dimension.SendToDimension(tc, reason)
    Duel.SendtoDeck(tc, nil, -2, reason)
    return Dimension.ZonesAddCard(tc)
end

function Dimension.IsInDimensionZone(c) return c:GetLocation() == 0 end

function Dimension.IsAbleToDimension(c) return c:GetLocation() ~= 0 and c:IsFaceup() end

function Dimension.CanBeDimensionMaterial(c) return c:GetLocation() ~= 0 and c:IsFaceup() end

function Dimension.CanBeDimensionChanged(c) return c:GetLocation() == 0 end

function Dimension.Change(mc, sc, mg, change_player, target_player, pos)
    if change_player == nil then change_player = mc:GetControler() end
    if target_player == nil then target_player = mc:GetControler() end
    local sumtype = mc:GetSummonType()
    local sumloc = mc:GetSummonLocation()
    local seq = target_player == mc:GetControler() and mc:GetSequence() or nil
    if pos == nil then pos = mc:IsAttackPos() and POS_FACEUP_ATTACK or POS_FACEUP_DEFENSE end

    if mg then
        sc:SetMaterial(mg)
    else
        sc:SetMaterial(Group.FromCards(mc))
    end

    Dimension.SendToDimension(mc, REASON_RULE)
    Dimension.ZonesRemoveCard(sc)
    Duel.MoveToField(sc, change_player, target_player, LOCATION_MZONE, pos, true, seq and 1 << seq or nil)
    Debug.PreSummon(sc, sumtype, sumloc)
    local ec1 = Effect.CreateEffect(sc)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_CONTROL)
    ec1:SetValue(target_player)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD - (RESET_TOFIELD + RESET_TEMP_REMOVE + RESET_TURN_SET))
    sc:RegisterEffect(ec1)
    sc:SetStatus(STATUS_FORM_CHANGED, true)

    Duel.BreakEffect()
    return true
end

Dimension.RegisterChange = aux.FunctionWithNamedArgs(function(c, event_code, filter, custom_reg, custom_op, flag_id)
    if flag_id == nil then flag_id = c:GetOriginalCode() end

    -- register
    if custom_reg then
        custom_reg(c, flag_id)
    else
        local reg = Effect.CreateEffect(c)
        reg:SetType(EFFECT_TYPE_CONTINUOUS)
        reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
        reg:SetCode(event_code)
        reg:SetCondition(function(e) return Dimension.CanBeDimensionChanged(e:GetHandler()) end)
        reg:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            local g = eg:Filter(aux.FaceupFilter(filter, c, e), nil)
            for tc in aux.Next(g) do tc:RegisterFlagEffect(flag_id + 1000000000 * (c:GetOwner() + 1), 0, 0, 1) end
        end)
        Duel.RegisterEffect(reg, 0)
    end

    -- change
    local change = Effect.CreateEffect(c)
    change:SetType(EFFECT_TYPE_CONTINUOUS)
    change:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    change:SetCode(EVENT_ADJUST)
    change:SetCondition(function(e)
        local tp = e:GetHandler():GetOwner()
        return Dimension.CanBeDimensionChanged(e:GetHandler()) and
                   Duel.IsExistingMatchingCard(function(c) return c:GetFlagEffect(flag_id + 1000000000 * (tp + 1)) > 0 end, 0,
                LOCATION_MZONE, LOCATION_MZONE, 1, nil)
    end)
    change:SetOperation(function(e)
        local tp = e:GetHandler():GetOwner()
        tp_flag_id = flag_id + 1000000000 * (tp + 1)
        local mc = Duel.GetFirstMatchingCard(function(c) return c:GetFlagEffect(tp_flag_id) > 0 end, 0, LOCATION_MZONE,
            LOCATION_MZONE, nil)
        if not mc then return end
        mc:ResetFlagEffect(tp_flag_id)
        if custom_op then
            custom_op(e, tp, mc)
        else
            Dimension.Change(mc, c)
        end
    end)
    Duel.RegisterEffect(change, 0)
end, "handler", "event_code", "filter", "custom_reg", "custom_op", "flag_id")
