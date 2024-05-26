-- Emeraldoh, Dragon Deity of Eternal Lifes
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_WIND)

    -- cannot be banished & cannot be material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_REMOVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1, 1)
    e1:SetTarget(function(e, c, tp, r)
        if c:IsFacedown() or r ~= REASON_EFFECT then return false end
        return c == e:GetHandler() or (c:IsLinkMonster() and c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_DRAGON))
    end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetTargetRange(LOCATION_MZONE, 0)
    e1b:SetTarget(function(e, c)
        if c:IsFacedown() then return false end
        return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsRace(RACE_DRAGON))
    end)
    e1b:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
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
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true)) and
               Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_HAND + LOCATION_GRAVE, LOCATION_GRAVE, 1, c, e, tp)
end

function s.e2filter2(c, e, tp)
    return not c:IsCode(id) and
               (c:IsCanBeSpecialSummoned(e, 0, tp, false, false) or c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, 1 - tp))
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil, e, tp) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.e2filter1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)

    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 or Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0) and
                   Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_HAND + LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e, tp)
    end

    local g = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_HAND + LOCATION_GRAVE, LOCATION_GRAVE, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e2filter2, tp, LOCATION_HAND + LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, e, tp):GetFirst()
    if not tc then return end

    local b1 = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and tc:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    local b2 = Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0 and tc:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, 1 - tp)
    local op = Duel.SelectEffect(tp, {b1, aux.Stringid(id, 1)}, {b2, aux.Stringid(id, 2)})
    local p = op == 1 and tp or 1 - tp

    if Duel.SpecialSummon(tc, 0, tp, p, false, false, POS_FACEUP) > 0 then
        local atk = 0
        if tc:IsMonster() and tc:IsFaceup() then
            atk = tc:GetAttack()
            if tc:GetAttack() < tc:GetDefense() then atk = tc:GetDefense() end
        end
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end

