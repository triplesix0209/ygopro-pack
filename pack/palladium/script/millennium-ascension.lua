-- Millennium Ascension
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {39913299}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- activation and effect cannot be negated
    local nonegate = Effect.CreateEffect(c)
    nonegate:SetType(EFFECT_TYPE_FIELD)
    nonegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nonegate:SetCode(EFFECT_CANNOT_INACTIVATE)
    nonegate:SetRange(LOCATION_ONFIELD)
    nonegate:SetTargetRange(1, 0)
    nonegate:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(nonegate)
    local nodiseff = nonegate:Clone()
    nodiseff:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(nodiseff)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(nodis)

    -- add "the true name"
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- inactivatable
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_INACTIVATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e2b)
end

function s.e1filter(c) return c:IsCode(39913299) and c:IsAbleToHand() end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and Duel.GetDrawCount(tp) > 0
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local dt = Duel.GetDrawCount(tp)
    if dt == 0 then return end
    _replace_count = 1
    _replace_max = dt

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_DRAW_COUNT)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_DRAW)
    Duel.RegisterEffect(ec1, tp)
    if _replace_count > _replace_max or not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, g)
        Duel.ShuffleHand(tp)
        Duel.ShuffleDeck(tp)

        if Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 then
            Duel.BreakEffect()
            Duel.ConfirmCards(tp, Duel.GetDecktopGroup(tp, 1))
        end
    end
end

function s.e2val(e, ct)
    local p = e:GetHandler():GetControler()
    local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
    local tc = te:GetHandler()
    return p == tp and tc:IsCode(39913299) and (loc & LOCATION_ONFIELD) ~= 0
end
