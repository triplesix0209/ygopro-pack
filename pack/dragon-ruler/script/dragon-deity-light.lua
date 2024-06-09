-- Diamondoh, Dragon Deity of Miracle Symphonies
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_LIGHT)

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

    -- negate the effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    aux.GlobalCheck(s, function()
        s.type_list = {}
        s.type_list[0] = 0
        s.type_list[1] = 0
        aux.AddValuesReset(function()
            s.type_list[0] = 0
            s.type_list[1] = 0
        end)
    end)

    -- shuffle
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 4))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    DragonRuler.RegisterDeityIgnitionEffect(c, id, e3, ATTRIBUTE_LIGHT)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return rp == 1 - tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and s.type_list[tp] & re:GetActiveType() == 0 and
               Duel.IsChainDisablable(ev)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if chk == 0 then return true end

    local op = 0
    if re:IsMonsterEffect() then
        op = 1
    elseif re:IsSpellEffect() then
        op = 2
    elseif re:IsTrapEffect() then
        op = 3
    end
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, op))
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(id)
    ec1:SetTargetRange(1, 0)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    s.type_list[tp] = s.type_list[tp] + (re:GetActiveType() & (TYPE_MONSTER + TYPE_SPELL + TYPE_TRAP))

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
    if rc:IsRelateToEffect(re) and rc:IsDestructable() then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Destroy(eg, REASON_EFFECT) end
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED,
        LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED, c)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, PLAYER_ALL, LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED,
        LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED, c)
    local max = math.min(Duel.TossDice(tp, 1), #g)
    local tg = Utility.GroupSelect(HINTMSG_TODECK, g, tp, 1, max)
    if #tg == 0 then return end
    Duel.HintSelection(tg)

    local ct = Duel.SendtoDeck(tg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    if ct > 0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(ct * 1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end
