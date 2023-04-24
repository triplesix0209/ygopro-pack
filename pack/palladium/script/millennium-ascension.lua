-- Millennium Ascension
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {39913299}
s.listed_series = {0x13a}

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

    -- cannot disable summon "palladium"
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTarget(function(e, c) return c:GetOwner() == e:GetOwnerPlayer() and c:IsSetCard(0x13a) end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
    c:RegisterEffect(e1c)

    -- level 10 or higher monster become immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(function(e, c) return c:IsLevelAbove(10) end)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(e2c)
    local e2d = Effect.CreateEffect(c)
    e2d:SetType(EFFECT_TYPE_FIELD)
    e2d:SetCode(EFFECT_CANNOT_INACTIVATE)
    e2d:SetRange(LOCATION_FZONE)
    e2d:SetValue(function(e, ct)
        local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
        local tc = te:GetHandler()
        return tp == e:GetHandler():GetControler() and (loc & LOCATION_ONFIELD) ~= 0 and tc:IsLevelAbove(10)
    end)
    c:RegisterEffect(e2d)
    local e2e = e2d:Clone()
    e2e:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e2e)

    -- "the true name" inactivatable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_INACTIVATE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e3b)

    -- add "the true name"
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PREDRAW)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e3val(e, ct)
    local p = e:GetHandler():GetControler()
    local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
    local tc = te:GetHandler()
    return p == tp and tc:IsCode(39913299) and (loc & LOCATION_ONFIELD) ~= 0
end

function s.e4filter(c) return c:IsCode(39913299) and c:IsAbleToHand() end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and Duel.GetDrawCount(tp) > 0
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
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

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e4filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
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
