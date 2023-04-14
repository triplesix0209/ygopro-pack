-- Ruthless Inferno
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1045}

function s.initial_effect(c)
    -- activate from hand
    local acthand = Effect.CreateEffect(c)
    acthand:SetType(EFFECT_TYPE_SINGLE)
    acthand:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    acthand:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0x1045) end, e:GetHandlerPlayer(),
            LOCATION_MZONE, 0, 1, nil)
    end)
    c:RegisterEffect(acthand)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(aux.RemainFieldCost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- disable effect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- to hand
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c) return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, e:GetHandler(), 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsLocation(LOCATION_SZONE) or not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end

    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- equip
        Duel.Equip(tp, c, tc)
        local eqlimit = Effect.CreateEffect(c)
        eqlimit:SetType(EFFECT_TYPE_SINGLE)
        eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
        eqlimit:SetValue(function(e, tc)
            return e:GetHandlerPlayer() == tc:GetControler() or e:GetHandler():GetEquipTarget() == tc
        end)
        eqlimit:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(eqlimit)

        -- indes
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        ec1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        ec1:SetRange(LOCATION_SZONE)
        ec1:SetValue(function(e) return e:GetHandler():GetEquipTarget() end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
    else
        c:CancelToGrave(false)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end

    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if not g or #g == 0 then return end

    if g:IsContains(e:GetHandler():GetEquipTarget()) and re:GetOwnerPlayer() ~= e:GetOwnerPlayer() then Duel.NegateEffect(ev) end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT) ~= 0 and re and re:GetOwner() == e:GetHandler():GetEquipTarget()
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local eqc = c:GetEquipTarget()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(#eg * 500)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    eqc:RegisterEffect(ec1)
end

function s.e4filter(c, tp)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsControler(tp) and
               c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e4filter, 1, nil, tp) end
function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, tp, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end
end
