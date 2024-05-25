-- Obsidianoh, Dragon Deity of Event Horizons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_DARK)

    -- untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_ONFIELD, 0)
    e1:SetTarget(function(e, c)
        if c:IsFacedown() then return false end
        return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsRace(RACE_DRAGON) and c:IsMonster()) or c:IsSpellTrap()
    end)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- negate effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DISABLE + CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter(c) return
    c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true)) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return rp == 1 - tp and Duel.IsChainDisablable(ev) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then return not rc:IsDisabled() end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
    if rc:CheckUniqueOnField(tp) and not rc:IsForbidden() then Duel.SetPossibleOperationInfo(0, CATEGORY_EQUIP, eg, 1, 0, 0) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if not Duel.NegateEffect(ev) then return end

    local c = e:GetHandler()
    local rc = re:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and rc:CheckUniqueOnField(tp) and not rc:IsForbidden() and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) and Duel.Equip(tp, rc, c, true) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_EQUIP_LIMIT)
        ec1:SetLabelObject(c)
        ec1:SetValue(function(e, c) return c == e:GetLabelObject() end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        rc:RegisterEffect(ec1)
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_EQUIP)
        ec2:SetCode(EFFECT_UPDATE_ATTACK)
        ec2:SetValue(1000)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        rc:RegisterEffect(ec2)
    end
end
