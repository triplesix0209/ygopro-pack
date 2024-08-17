-- Neo-Spacian Pure Heart
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS}
s.listed_series = {SET_NEO_SPACIAN}
s.material_setcode = {SET_HERO, SET_NEO_SPACIAN}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp)
        return not c:IsType(TYPE_LINK, sc, sumtype, tp) and (c:IsSetCard(SET_HERO, sc, sumtype, tp) or c:IsSetCard(SET_NEO_SPACIAN, sc, sumtype, tp))
    end, 1, 1)

    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- attribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetRange(LOCATION_MZONE + LOCATION_GRAVE + LOCATION_REMOVED)
    e2:SetCode(EFFECT_REMOVE_ATTRIBUTE)
    e2:SetValue(ATTRIBUTE_LIGHT)
    c:RegisterEffect(e2)

    -- copy effect
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c) return c:ListsArchetype(SET_NEO_SPACIAN) and c:IsSpellTrap() and c:IsAbleToHand() end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e3filter(c) return not c:IsCode(id) and c:IsSetCard(SET_NEO_SPACIAN) and c:IsMonster() and c:IsAbleToGrave() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc =
        Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e3filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil):GetFirst()
    if tc and Duel.SendtoGrave(tc, REASON_EFFECT) and c:IsRelateToEffect(e) and c:IsFaceup() then
        local code = tc:GetOriginalCode()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CHANGE_CODE)
        ec1:SetValue(code)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
        if not tc:IsType(TYPE_TRAPMONSTER) then c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 1) end
    end
end
