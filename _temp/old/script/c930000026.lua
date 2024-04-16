-- Divine Nordic Relic Gungnir
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {93483212}
s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    aux.AddEquipProcedure(c, nil, s.equipfilter)

    -- unstoppable Attack
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    c:RegisterEffect(e1)

    -- cannot be target
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, id + 1000000)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- equip
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_EQUIP)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1, id + 2000000)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.equipfilter(c) return Utility.IsSetCard(c, 0x4b, 0x42) end

function s.e3filter(c)
    return c:IsFaceup() and (c:IsSetCard(0x42) or c:IsSetCard(0x4b)) and
               c:IsAbleToRemoveAsCost()
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local eqc = c:GetEquipTarget()
    if chk == 0 then
        return eqc:IsAbleToRemoveAsCost() or (eqc:IsSetCard(0x4b) and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_MZONE,
                                               0, 1, nil))
    end

    local sc = eqc
    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_MZONE, 0, nil)
    if eqc:IsSetCard(0x4b) and #g > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        sc = g:Select(tp, 1, 1, nil):GetFirst()
    end

    if Duel.Remove(sc, POS_FACEUP, REASON_COST + REASON_TEMPORARY) ~= 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetLabelObject(sc)
        ec1:SetCountLimit(1)
        ec1:SetOperation(function(e)
            Duel.ReturnToField(e:GetLabelObject())
        end)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        local eqc = c:GetEquipTarget()
        local exg = Group.FromCards(c)
        if eqc:IsSetCard(0x4b) and
            not Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_MZONE, 0,
                                            1, eqc) then exg:AddCard(eqc) end

        return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_ONFIELD,
                                     LOCATION_ONFIELD, 1, exg)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD,
                                LOCATION_ONFIELD, 1, 1, c)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    Duel.Destroy(tc, REASON_EFFECT)
end

function s.e4filter(c, ec)
    return c:IsFaceup() and c:IsCode(93483212) and ec:CheckEquipTarget(c)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:CheckUniqueOnField(tp) and not c:IsForbidden() and
                   Duel.IsExistingTarget(s.e4filter, tp, LOCATION_MZONE, 0, 1,
                                         nil, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    Duel.SelectTarget(tp, s.e4filter, tp, LOCATION_MZONE, 0, 1, 1, nil, c)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc or tc:IsFacedown() or
        not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then return end

    Duel.Equip(tp, c, tc)
end
