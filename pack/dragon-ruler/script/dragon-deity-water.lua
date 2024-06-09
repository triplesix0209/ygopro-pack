-- Sapphireoh, Dragon Deity of Ice Ages
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_WATER)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsType(TYPE_PENDULUM)) end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- chain limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, 1)
    e2:SetCondition(function(e) return Duel.GetAttacker() == e:GetHandler() end)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- block
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCost(DragonRuler.DeityCost(aux.Stringid(id, 0), ATTRIBUTE_WATER))
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3b:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL + 1) end)
    e3b:SetCost(aux.TRUE)
    c:RegisterEffect(e3b)
end

function s.e3filter(c) return c:GetFlagEffect(id) == 0 end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, c)
    if chk == 0 then return #g > 0 end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e3filter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, c):GetFirst()
    if not tc then return end
    Duel.HintSelection(Group.FromCards(tc))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
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
            local ec3 = Effect.CreateEffect(c)
            ec3:SetType(EFFECT_TYPE_SINGLE)
            ec3:SetCode(EFFECT_SET_ATTACK_FINAL)
            ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
            ec3:SetValue(0)
            tc:RegisterEffect(ec3)
            local ec3b = ec3:Clone()
            ec3b:SetCode(EFFECT_SET_DEFENSE_FINAL)
            tc:RegisterEffect(ec3b)
        end
    end
end
