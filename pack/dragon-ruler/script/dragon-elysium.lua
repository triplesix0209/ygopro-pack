-- Dragon's Elysium
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

s.listed_names = {DragonRuler.CARD_MESSIAH_DEITY}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- cannot be targeted & immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, DragonRuler.CARD_MESSIAH_DEITY), e:GetHandlerPlayer(), LOCATION_ONFIELD, 0,
            1, nil)
    end)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_IMMUNE_EFFECT)
    e1b:SetValue(function(e, te) return e:GetOwnerPlayer() ~= te:GetOwnerPlayer() end)
    c:RegisterEffect(e1b)

    -- cannot be negated
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_DISABLE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_ONFIELD, 0)
    e2:SetTarget(function(e, c) return (c:GetType() & TYPE_LINK) ~= 0 and (c:GetType() & TYPE_PENDULUM) ~= 0 end)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD)
    e2b:SetCode(EFFECT_CANNOT_DISEFFECT)
    e2b:SetRange(LOCATION_FZONE)
    e2b:SetValue(function(e, ct)
        local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
        local tc = te:GetHandler()
        local p = e:GetHandler():GetControler()
        if p ~= tp or (loc & LOCATION_ONFIELD) == 0 then return false end
        return (tc:GetType() & TYPE_LINK) ~= 0 and (tc:GetType() & TYPE_PENDULUM) ~= 0
    end)
    c:RegisterEffect(e2b)

    -- gain effects
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_FZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- discard to activate effects
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e3filter(c) return c:IsContinuousSpellTrap() end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.e3filter, nil)
    local g = og:Filter(function(c) return c:GetFlagEffect(id) == 0 end, nil)
    if #g <= 0 then return end

    for tc in g:Iter() do
        local code = tc:GetOriginalCode()
        if not og:IsExists(function(c, code) return c:IsCode(code) and c:GetFlagEffect(id) > 0 end, 1, tc, code) then
            tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 0)
            local cid = c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD)
            local reset = Effect.CreateEffect(c)
            reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            reset:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            reset:SetCode(EVENT_ADJUST)
            reset:SetRange(LOCATION_MZONE)
            reset:SetLabel(cid)
            reset:SetLabelObject(tc)
            reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                local cid = e:GetLabel()
                local c = e:GetHandler()
                local tc = e:GetLabelObject()
                local g = c:GetOverlayGroup():Filter(function(c) return c:GetFlagEffect(id) > 0 end, nil)
                if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
                    c:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            reset:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(reset, true)
        end
    end
end

function s.e4filtercost(c, tp) return c:IsDiscardable() and (s.e4condition1(tp) or s.e4condition2(tp, c) or s.e4condition3(tp) or s.e4condition4(tp)) end

function s.e4filter1(c) return c:IsRace(RACE_DRAGON) and c:IsAbleToGrave() end

function s.e4filter2(c, attribute) return c:IsLevelBelow(4) and c:IsAttribute(attribute) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand() end

function s.e4filter3a(c, tp)
    return c:IsFaceup() and c:IsCode(DragonRuler.CARD_MESSIAH_DEITY) and
               Duel.IsExistingMatchingCard(s.e4filter3b, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, 1, c)
end

function s.e4filter3b(c) return c:IsRace(RACE_DRAGON) end

function s.e4condition1(tp) return Duel.IsExistingMatchingCard(s.e4filter1, tp, LOCATION_DECK, 0, 1, nil) end

function s.e4condition2(tp, dc) return dc:IsMonster() and Duel.IsExistingMatchingCard(s.e4filter2, tp, LOCATION_DECK, 0, 1, nil, dc:GetAttribute()) end

function s.e4condition3(tp) return Duel.IsExistingMatchingCard(s.e4filter3a, tp, LOCATION_MZONE, 0, 1, nil, tp) end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filtercost, tp, LOCATION_HAND, 0, 1, nil, tp) end

    local dc = Utility.SelectMatchingCard(HINTMSG_DISCARD, tp, Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, 1, nil):GetFirst()
    Duel.SendtoGrave(dc, REASON_COST + REASON_DISCARD)
    e:SetLabelObject(dc)

    local b1 = s.e4condition1(tp)
    local b2 = s.e4condition2(tp, dc)
    local b3 = s.e4condition3(tp)
    local op = Duel.SelectEffect(tp, {b1, aux.Stringid(id, 1)}, {b2, aux.Stringid(id, 2)}, {b3, aux.Stringid(id, 3)})
    e:SetLabel(op)
    if op == 1 then
        e:SetCategory(CATEGORY_TOGRAVE)
        Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
    elseif op == 2 then
        e:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    else
        e:SetCategory(0)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local dc = e:GetLabelObject()
    local op = e:GetLabel()
    if op == 1 then
        local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e4filter1, tp, LOCATION_DECK, 0, 1, 1, nil)
        if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
    elseif op == 2 then
        local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e4filter2, tp, LOCATION_DECK, 0, 1, 1, nil, dc:GetAttribute())
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    elseif op == 3 then
        local sc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e4filter3a, tp, LOCATION_MZONE, 0, 1, 1, nil, tp):GetFirst()
        if sc then
            local g = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e4filter3b, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, sc)
            Duel.Overlay(sc, g)
        end
    end
end
