-- Sapphireoh, Dragon Deity of Ice Ages
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_WATER)

    -- indes & avoid damage
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsLinkAbove(5) and c:IsRace(RACE_DRAGON)) end)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(e1b)

    -- block & steal atk
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
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

function s.e2filter1(c)
    return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true))
end

function s.e2filter2(c) return c:GetFlagEffect(id) == 0 end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.e2filter1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, c)
    if chk == 0 then return #g > 0 end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e2filter2, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, c):GetFirst()
    if not tc then return end
    Duel.HintSelection(Group.FromCards(tc))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_TRIGGER)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)

    if tc:IsMonster() then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_CANNOT_ATTACK)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
        local ec2b = ec2:Clone()
        ec2b:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
        tc:RegisterEffect(ec2b)

        if tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
            local atk = tc:GetAttack()
            if tc:GetAttack() < tc:GetDefense() then atk = tc:GetDefense() end

            local ec3 = Effect.CreateEffect(c)
            ec3:SetType(EFFECT_TYPE_SINGLE)
            ec3:SetCode(EFFECT_SET_ATTACK_FINAL)
            ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
            ec3:SetValue(0)
            tc:RegisterEffect(ec3)
            local ec3b = ec3:Clone()
            ec3b:SetCode(EFFECT_SET_DEFENSE_FINAL)
            tc:RegisterEffect(ec3b)
            if c:IsRelateToEffect(e) and c:IsFaceup() then
                local ec3c = Effect.CreateEffect(c)
                ec3c:SetType(EFFECT_TYPE_SINGLE)
                ec3c:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                ec3c:SetCode(EFFECT_UPDATE_ATTACK)
                ec3c:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
                ec3c:SetValue(atk)
                c:RegisterEffect(ec3c)
            end
        end
    end
end
