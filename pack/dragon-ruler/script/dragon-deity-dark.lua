-- Obsidianoh, Dragon Deity of Event Horizons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_DARK)

    -- control cannot switch & untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:IsLinkMonster() and c:IsType(TYPE_PENDULUM)) end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1b:SetValue(aux.tgoval)
    c:RegisterEffect(e1b)

    -- equip
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2b:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL + 1) end)
    e2b:SetCost(aux.TRUE)
    c:RegisterEffect(e2b)
end

function s.e2filter1(c, e, tp)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true)) and
               Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, LOCATION_ONFIELD + LOCATION_GRAVE, 1, e:GetHandler())
end

function s.e2filter2(c, tp) return c:IsControler(tp) or c:IsAbleToChangeControler() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil, e, tp) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.e2filter1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)

    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, LOCATION_ONFIELD + LOCATION_GRAVE, c, tp)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, g, 1, PLAYER_ALL, LOCATION_ONFIELD + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_EQUIP, tp, s.e2filter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, LOCATION_ONFIELD + LOCATION_GRAVE, 1,
        1, c, tp):GetFirst()
    if not tc or not tc:IsForbidden() or (not tc:IsControler(tp) and not tc:CheckUniqueOnField(tp)) or Duel.GetLocationCount(tp, LOCATION_SZONE) == 0 then
        return
    end
    Duel.HintSelection(Group.FromCards(tc))

    if Duel.Equip(tp, tc, c, true) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_EQUIP_LIMIT)
        ec1:SetLabelObject(c)
        ec1:SetValue(function(e, c) return c == e:GetLabelObject() end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_EQUIP)
        ec2:SetCode(EFFECT_UPDATE_ATTACK)
        ec2:SetValue(1000)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
        local ec3 = ec2:Clone()
        ec3:SetCode(EFFECT_EXTRA_ATTACK)
        ec3:SetValue(1)
        tc:RegisterEffect(ec3)
    end
end
