-- Diamondoh, Dragon Deity of Miracle Symphonies
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_LIGHT)

    -- cannot be returned & cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_TO_DECK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:IsLinkMonster() and c:IsType(TYPE_PENDULUM)) end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1b:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(e1b)
    local e1c = Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_FIELD)
    e1c:SetCode(EFFECT_CANNOT_DISEFFECT)
    e1c:SetRange(LOCATION_MZONE)
    e1c:SetValue(function(e, ct)
        local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
        local tc = te:GetHandler()
        local p = e:GetHandler():GetControler()
        if p ~= tp or (loc & LOCATION_MZONE) == 0 then return false end
        return tc == e:GetHandler() or (tc:IsLinkMonster() and tc:IsType(TYPE_PENDULUM) and tc:IsRace(RACE_DRAGON))
    end)
    c:RegisterEffect(e1c)

    -- shuffle
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TODECK)
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

function s.e2filter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true))
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED,
        LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED, c)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, PLAYER_ALL, LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED,
        LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED, c)
    local max = math.min(Duel.TossDice(tp, 1), #g)
    local sg = Utility.GroupSelect(g, tp, 1, max, HINTMSG_TODECK)
    if #sg == 0 then return end
    Duel.HintSelection(sg)

    local ct = Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    if ct > 0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(ct * 1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end
