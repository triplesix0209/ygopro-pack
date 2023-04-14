-- Evil HERO Faustian Slayer
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {0x8, 0x6008}
s.material_setcode = {0x8, 0x6008}
s.dark_calling = true

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixRep(c, true, true, aux.FilterBoolFunctionEx(Card.IsSummonLocation, LOCATION_EXTRA), 1, 99,
        aux.FilterBoolFunctionEx(Card.IsSetCard, 0x6008))

    -- lizard check
    local lizcheck = Effect.CreateEffect(c)
    lizcheck:SetType(EFFECT_TYPE_SINGLE)
    lizcheck:SetCode(CARD_CLOCK_LIZARD)
    lizcheck:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    lizcheck:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), EFFECT_SUPREME_CASTLE)
    end)
    lizcheck:SetValue(1)
    c:RegisterEffect(lizcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.EvilHeroLimit)
    c:RegisterEffect(splimit)

    -- atk up
    local e1reg = Effect.CreateEffect(c)
    e1reg:SetType(EFFECT_TYPE_SINGLE)
    e1reg:SetCode(EFFECT_MATERIAL_CHECK)
    e1reg:SetValue(s.e1regval)
    c:RegisterEffect(e1reg)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    e1:SetLabelObject(e1reg)
    c:RegisterEffect(e1)

    -- activate effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1regval(e, c)
    local g = c:GetMaterial()
    e:SetLabel(#g)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local atk = e:GetLabelObject():GetLabel() * 200
    if atk > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
    end
end

function s.e2countfilter(c) return c:IsSetCard(0x6008) and c:IsMonster() and c:IsFaceup() end

function s.e2filter1(c)
    return (c:IsCode(CARD_DARK_FUSION) or (c:IsSpellTrap() and c:ListsCode(CARD_DARK_FUSION))) and c:IsSSetable()
end

function s.e2filter2(c) return c:IsControlerCanBeChanged() or c:IsSummonType(SUMMON_TYPE_SPECIAL) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local opt = {}
    local sel = {}
    local ct = Duel.GetMatchingGroup(s.e2countfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil):GetClassCount(Card.GetCode)
    if ct >= 2 and Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_DECK, 0, 1, nil) then
        table.insert(opt, aux.Stringid(id, 1))
        table.insert(sel, 1)
    end
    if ct >= 4 and Duel.IsExistingMatchingCard(nil, tp, 0, LOCATION_ONFIELD, 1, nil) then
        table.insert(opt, aux.Stringid(id, 2))
        table.insert(sel, 2)
    end
    if ct >= 6 and Duel.IsExistingMatchingCard(s.e2filter2, tp, 0, LOCATION_MZONE, 1, nil) then
        table.insert(opt, aux.Stringid(id, 3))
        table.insert(sel, 3)
    end

    if chk == 0 then return #opt > 0 end
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    e:SetLabel(op)

    e:SetCategory(0)
    if op == 2 then
        e:SetCategory(CATEGORY_DESTROY)
        local g = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    elseif op == 3 then
        e:SetCategory(CATEGORY_CONTROL)
        local g = Duel.GetMatchingGroup(s.e2filter2, tp, 0, LOCATION_MZONE, nil)
        Duel.SetOperationInfo(0, CATEGORY_CONTROL, g, 1, 0, 0)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = e:GetLabel()

    if op == 1 and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 then
        local g = Utility.SelectMatchingCard(HINTMSG_SET, tp, s.e2filter1, tp, LOCATION_DECK, 0, 1, 1, nil)
        Duel.SSet(tp, g)
    elseif op == 2 then
        local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
        Duel.HintSelection(g)
        Duel.Destroy(g, REASON_EFFECT)
    elseif op == 3 then
        local g = Utility.SelectMatchingCard(HINTMSG_CONTROL, tp, s.e2filter2, tp, 0, LOCATION_MZONE, 1, 1, nil)
        Duel.HintSelection(g)
        Duel.GetControl(g, tp)
    end
end
