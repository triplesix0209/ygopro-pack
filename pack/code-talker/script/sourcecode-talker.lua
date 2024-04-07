-- Sourcecode Talker
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_CODE_TALKER}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 99,
        function(g, sc, st, tp) return g:IsExists(Card.IsType, 1, nil, TYPE_LINK, sc, st, tp) end)

    -- banish & gain effects
    local e1reg = Effect.CreateEffect(c)
    e1reg:SetType(EFFECT_TYPE_SINGLE)
    e1reg:SetCode(EFFECT_MATERIAL_CHECK)
    e1reg:SetValue(s.e1matcheck)
    c:RegisterEffect(e1reg)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    e1:SetLabelObject(e1reg)
    c:RegisterEffect(e1)

    -- no LP cost
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_LPCOST_CHANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1, 0)
    e2:SetCondition(function(e) return Duel.GetLP(e:GetHandlerPlayer()) <= 2000 end)
    e2:SetValue(function(e, re, rp, val)
        if not re then return val end
        local rc = re:GetHandler()
        if re:IsActiveType(TYPE_MONSTER) and rc:IsType(TYPE_LINK) and rc:IsRace(RACE_CYBERSE) then return 0 end
        return val
    end)
    c:RegisterEffect(e2)
end

function s.e1matcheck(e, c)
    local g = c:GetMaterial()

    e:SetLabel(0)
    if g:IsExists(Card.IsLinkMonster, 1, nil) then e:SetLabel(1) end
end

function s.e1filter1(c, e)
    return c:IsType(TYPE_LINK) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())) and c:IsCanBeEffectTarget(e)
end

function s.e1filter2(c) return not c:IsCode(id) and c:IsSetCard(SET_CODE_TALKER) and c:GetLink() == 3 and c:IsAbleToRemove() end

function s.e1rescon(sg, e, tp) return sg:GetClassCount(Card.GetAttribute) == #sg, sg:GetClassCount(Card.GetAttribute) ~= #sg end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_LINK) and e:GetLabelObject():GetLabel() == 1
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local mg = c:GetMaterial():Filter(s.e1filter1, nil, e)
    local dg = Duel.GetMatchingGroup(s.e1filter2, tp, LOCATION_EXTRA + LOCATION_GRAVE, 0, nil)
    if chk == 0 then return #mg > 0 and #dg > 0 end

    local tg = Utility.GroupSelect(HINTMSG_TARGET, mg, tp, 1, 1)
    Duel.SetTargetCard(tg)

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, LOCATION_EXTRA + LOCATION_GRAVE)
    Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local ct = tc:GetLink()
        local g = Duel.GetMatchingGroup(s.e1filter2, tp, LOCATION_EXTRA + LOCATION_GRAVE, 0, nil)
        local sg = aux.SelectUnselectGroup(g, e, tp, 1, ct, s.e1rescon, 1, tp, HINTMSG_REMOVE)
        for tc in sg:Iter() do
            if Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) > 0 then c:CopyEffect(tc:GetOriginalCode(), RESET_EVENT + RESETS_STANDARD) end
        end
    end

    aux.addTempLizardCheck(c, tp)
end
