-- Emeraldoh, Dragon Deity of Eternal Lifes
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_WIND)

    -- cannot be banished
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_REMOVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1, 1)
    e1:SetTarget(function(e, c, tp, r)
        if r & REASON_EFFECT == 0 then return false end
        return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsType(TYPE_PENDULUM))
    end)
    c:RegisterEffect(e1)

    -- gain LP
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCost(DragonRuler.DeityCost(aux.Stringid(id, 0), ATTRIBUTE_WIND, s.e3costextra))
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

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(aux.FaceupFilter(Card.IsSummonPlayer, tp), 1, nil) end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local val = eg:Filter(aux.FaceupFilter(Card.IsSummonPlayer, tp), nil):GetSum(Card.GetAttack)
    if not Duel.IsChainSolving() then
        if val > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then
            Duel.Hint(HINT_CARD, 1 - tp, id)
            Duel.Recover(tp, val, REASON_EFFECT)
        end
    else
        local eff = e:GetLabelObject()
        if eff and not eff:IsDeleted() then
            eff:SetLabel(eff:GetLabel() + val)
        else
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            ec1:SetCode(EVENT_CHAIN_SOLVED)
            ec1:SetRange(LOCATION_MZONE)
            ec1:SetLabel(val)
            ec1:SetLabelObject(e)
            ec1:SetOperation(s.e2chainop)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_CHAIN)
            c:RegisterEffect(ec1)
            e:SetLabelObject(ec1)
            local ec2 = Effect.CreateEffect(c)
            ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            ec2:SetCode(EVENT_CHAIN_SOLVED)
            ec2:SetOperation(function() e:SetLabelObject(nil) end)
            ec2:SetReset(RESET_CHAIN)
            Duel.RegisterEffect(ec2, tp)
        end
    end
end

function s.e2chainop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local val = e:GetLabel()
    if val > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then
        Duel.Hint(HINT_CARD, 1 - tp, id)
        Duel.Recover(tp, val, REASON_EFFECT)
    end
    e:Reset()
    e:GetLabelObject():SetLabelObject(nil)
end

function s.e3filter(c, e, tp)
    return not c:IsCode(id) and
               (c:IsCanBeSpecialSummoned(e, 0, tp, false, false) or c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, 1 - tp))
end

function s.e3costextra(sc, e, tp) return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND + LOCATION_GRAVE, LOCATION_GRAVE, 1, sc, e, tp) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 or Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0) and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND + LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e, tp)
    end

    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_HAND + LOCATION_GRAVE, LOCATION_GRAVE, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e3filter, tp, LOCATION_HAND + LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, e, tp):GetFirst()
    if not tc then return end

    local b1 = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and tc:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    local b2 = Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0 and tc:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, 1 - tp)
    local op = Duel.SelectEffect(tp, {b1, aux.Stringid(id, 3)}, {b2, aux.Stringid(id, 4)})
    local p = op == 1 and tp or 1 - tp

    Duel.SpecialSummon(tc, 0, tp, p, false, false, POS_FACEUP)
end
