-- Red-Eyes Extreme Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_REDEYES_B_DRAGON}
s.listed_series = {SET_RED_EYES}
s.material_setcode = {SET_RED_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixN(c, false, false,
        function(c, fc, sumtype, tp) return c:IsSetCard(SET_RED_EYES, fc, sumtype, tp) and c:IsRace(RACE_DRAGON, fc, sumtype, tp) end, 3)

    -- add to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1reg = Effect.CreateEffect(c)
    e1reg:SetType(EFFECT_TYPE_SINGLE)
    e1reg:SetCode(EFFECT_MATERIAL_CHECK)
    e1reg:SetValue(s.e1matcheck)
    c:RegisterEffect(e1reg)

    -- protect spell/trap
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD, 0)
    e2:SetTarget(function(e, c) return c:IsFaceup() and c:IsSpellTrap() end)
    e2:SetValue(aux.indoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2b:SetProperty(EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_IGNORE_IMMUNE)
    e2b:SetValue(aux.tgoval)
    c:RegisterEffect(e2b)

    -- shuffle into the deck
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1matcheck(e, c)
    if c:GetMaterial():IsExists(Card.IsCode, 1, nil, CARD_REDEYES_B_DRAGON) then
        c:RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD & ~(RESET_TOFIELD | RESET_TEMP_REMOVE | RESET_LEAVE), 0, 1)
    end
end

function s.e1filter(c, e)
    if not c:IsAbleToHand() then return false end
    return (c:IsSetCard(SET_RED_EYES) and c:IsTrap()) or (e:GetHandler():GetFlagEffect(id) ~= 0 and c:IsType(TYPE_EQUIP))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e1filter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, nil, e)
    if #g == 0 then return end

    local sg = aux.SelectUnselectGroup(g, e, tp, 1, 3, aux.dncheck, 1, tp, HINTMSG_ATOHAND)
    if #sg > 0 then
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
    end
end

function s.e3filter(c) return c:IsFaceup() and c:IsLevelBelow(7) and c:IsSetCard(SET_RED_EYES) and c:IsAbleToDeck() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(s.e3filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tc = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil):GetFirst()

    Duel.SetOperationInfo(0, CATEGORY_TODECK, tc, 1, 0, 0)
    if c:IsSummonType(SUMMON_TYPE_FUSION) then Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, tc:GetBaseAttack()) end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    if Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) ~= 0 and c:IsFaceup() and c:IsRelateToEffect(e) and c:IsSummonType(SUMMON_TYPE_FUSION) then
        Duel.BreakEffect()
        Duel.Damage(1 - tp, tc:GetBaseAttack(), REASON_EFFECT)
    end
end
