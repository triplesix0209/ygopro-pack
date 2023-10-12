-- Red-Eyes Extreme Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {SET_RED_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixN(c, false, false,
        function(c, fc, sumtype, tp) return c:IsSetCard(SET_RED_EYES, fc, sumtype, tp) and c:IsRace(RACE_DRAGON, fc, sumtype, tp) end, 3)

    -- equip
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

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
end

function s.e1filter(c, tp, ec) return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, tp, c) and
                   Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, 0, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e1filter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, nil, tp, c)
    if #g == 0 then return end

    local ft = math.min(Duel.GetLocationCount(tp, LOCATION_SZONE), 3)
    local sg = aux.SelectUnselectGroup(g, e, tp, 1, ft, aux.dncheck, 1, tp, HINTMSG_EQUIP)
    if #sg > 0 then
        for tc in sg:Iter() do Duel.Equip(tp, tc, c, true, true) end
        Duel.EquipComplete()
    end
end
