-- Amberoh, Dragon Deity of Ancient Continents
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_EARTH)

    -- immune trap
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsType(TYPE_PENDULUM)) end)
    e1:SetValue(function(e, te) return te:IsActivated() and te:IsTrapEffect() and te:GetOwnerPlayer() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1)

    -- draw
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- send card to GY
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOGRAVE + CATEGORY_DECKDES)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCost(DragonRuler.DeityCost(aux.Stringid(id, 0), ATTRIBUTE_EARTH, s.e3costextra))
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
        if val > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then
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
    if val > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then
        Duel.Hint(HINT_CARD, 1 - tp, id)
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
    e:Reset()
    e:GetLabelObject():SetLabelObject(nil)
end

function s.e3filter(c) return c:IsAbleToGrave() and not (c:IsLinkMonster() and c:IsType(TYPE_PENDULUM)) end

function s.e3condition1(tp) return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil) end

function s.e3condition2(tp) return Duel.IsPlayerCanDiscardDeck(tp, 1) end

function s.e3costextra(sc, e, tp) return s.e3condition1(tp) or s.e3condition2(1 - tp) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local b1 = s.e3condition1(tp)
    local b2 = s.e3condition2(1 - tp)
    if chk == 0 then return b1 or b2 end

    local op = Duel.SelectEffect(tp, {b1, aux.Stringid(id, 3)}, {b2, aux.Stringid(id, 4)})
    e:SetLabel(op)
    if op == 1 then
        Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 0, tp, 1)
    else
        Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, 1)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = e:GetLabel()
    if op == 1 then
        local tc =
            Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e3filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil):GetFirst()
        if tc then Duel.SendtoGrave(tc, REASON_EFFECT) end
    else
        local max = Duel.GetFieldGroupCount(1 - tp, LOCATION_DECK, 0)
        if max == 0 then return end
        if max > 10 then max = 10 end

        local t = {}
        for i = 1, max do t[i] = i end
        Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 5))
        local ac = Duel.AnnounceNumber(tp, table.unpack(t))
        Duel.DiscardDeck(1 - tp, ac, REASON_EFFECT)
    end
end
