-- Red-Eyes Metalmorph
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_RED_EYES}

function s.initial_effect(c)
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

    -- send to grave and set
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return c:IsSetCard(SET_RED_EYES) and c:IsFaceup() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp, c, tc)
        local eqlimit = Effect.CreateEffect(c)
        eqlimit:SetType(EFFECT_TYPE_SINGLE)
        eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
        eqlimit:SetValue(function(e, c) return c:IsSetCard(SET_RED_EYES) end)
        eqlimit:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(eqlimit)

        -- Prevent effect target
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_EQUIP)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        ec1:SetValue(aux.tgoval)
        c:RegisterEffect(ec1)

        -- atk up
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_EQUIP)
        ec2:SetCode(EFFECT_UPDATE_ATTACK)
        ec2:SetCondition(function(e)
            return Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL and Duel.GetAttacker() == e:GetHandler():GetEquipTarget() and Duel.GetAttackTarget()
        end)
        ec2:SetValue(function(e, c) return Duel.GetAttackTarget():GetAttack() / 2 end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec2)
    else
        c:CancelToGrave(false)
    end
end

function s.e2filter(c) return not c:IsCode(id) and c:IsSetCard(SET_RED_EYES) and c:IsTrap() and c:IsSSetable() end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetEquipTarget() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_SET, tp, s.e2filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    if tc and Duel.SSet(tp, tc) > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        ec1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end
