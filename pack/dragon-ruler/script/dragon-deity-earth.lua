-- Amberoh, Dragon Deity of World Continents
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_EARTH)

    -- cannot be returned & spell immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_TO_DECK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsLinkAbove(5) and c:IsRace(RACE_DRAGON)) end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_IMMUNE_EFFECT)
    e1b:SetValue(function(e, te) return te:GetOwnerPlayer() ~= e:GetHandlerPlayer() and te:IsActivated() and te:IsTrapEffect() end)
    c:RegisterEffect(e1b)

    -- send top deck & multiple attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DECKDES)
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
    return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true))
end

function s.e2filter2(c) return c:IsLocation(LOCATION_GRAVE) and c:IsMonster() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.e2filter1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsPlayerCanDiscardDeck(tp, 1) or Duel.IsPlayerCanDiscardDeck(1 - tp, 1) end
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, PLAYER_ALL, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local b1 = Duel.IsPlayerCanDiscardDeck(tp, 1)
    local b2 = Duel.IsPlayerCanDiscardDeck(1 - tp, 1)
    if not b1 and not b2 then return end

    local op = Duel.SelectEffect(tp, {b1, aux.Stringid(id, 1)}, {b2, aux.Stringid(id, 2)})
    local p = op == 1 and tp or 1 - tp
    local max = Duel.GetFieldGroupCount(p, LOCATION_DECK, 0)
    if max > 5 then max = 5 end
    local t = {}
    for i = 1, max do t[i] = i end
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 3))
    local ac = Duel.AnnounceNumber(tp, table.unpack(t))
    Duel.DiscardDeck(p, ac, REASON_EFFECT)
    
    local g = Duel.GetOperatedGroup()
    local ct = g:FilterCount(s.e2filter2, nil)
    if ct > 1 and c:IsFaceup() and c:IsRelateToEffect(e) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetDescription(aux.Stringid(id, ct + 2))
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_EXTRA_ATTACK)
        ec1:SetValue(ct - 1)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end
