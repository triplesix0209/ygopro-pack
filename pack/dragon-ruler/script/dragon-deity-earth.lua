-- Amberoh, Dragon Deity of Ancient Continents
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_EARTH)

    -- cannot be tributed, or be used as a material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsType(TYPE_PENDULUM)) end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetTargetRange(LOCATION_MZONE, 0)
    e1b:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)

    -- draw
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- send top deck
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DECKDES)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCost(s.e3cost)
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

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(Card.IsSummonPlayer, 1, nil, 1 - tp) end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local val = eg:FilterCount(Card.IsSummonPlayer, nil, tp)
    if not Duel.IsChainSolving() then
        if val > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
            Duel.Hint(HINT_CARD, 1 - tp, id)
            Duel.Draw(tp, 1, REASON_EFFECT)
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
    if val > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_CARD, 1 - tp, id)
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
    e:Reset()
    e:GetLabelObject():SetLabelObject(nil)
end

function s.e3filter1(c)
    return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true))
end

function s.e3filter2(c) return c:IsLocation(LOCATION_GRAVE) and c:IsMonster() end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.e3filter1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsPlayerCanDiscardDeck(tp, 1) or Duel.IsPlayerCanDiscardDeck(1 - tp, 1) end
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, PLAYER_ALL, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
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
end
