-- Evil HERO Cosmos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {0x8, 0x3008}

function s.initial_effect(c)
    -- special summon itself
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon "evil HERO" fusion monster
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_MAIN_END + TIMINGS_CHECK_MONSTER)
    e3:SetCountLimit(1, {id, 3})
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c, ft)
    return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION + TYPE_LINK) and c:IsAbleToExtraAsCost() and (ft > 0 or c:GetSequence() < 5)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local eff = {c:GetCardEffect(EFFECT_NECRO_VALLEY)}
    for _, te in ipairs(eff) do
        local op = te:GetOperation()
        if not op or op(e, c) then return false end
    end

    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_MZONE, 0, nil, ft)
    return ft > -1 and #rg > 0 and aux.SelectUnselectGroup(rg, e, tp, 1, 1, nil, 0)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_MZONE, 0, nil, ft)
    local g = aux.SelectUnselectGroup(rg, e, tp, 1, 1, nil, 1, tp, HINTMSG_REMOVE, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
    g:DeleteGroup()
end

function s.e2con(e) return e:GetHandler() == Duel.GetAttacker() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, Card.IsSetCard, 1, false, nil, e:GetHandler(), 0x8) end
    local g = Duel.SelectReleaseGroupCost(tp, Card.IsSetCard, 1, 1, false, nil, e:GetHandler(), 0x8)
    e:SetLabel(g:GetFirst():GetAttack())
    Duel.Release(g, REASON_COST)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(e:GetLabel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e3filter1(c) return c:IsSetCard(0x8) end

function s.e3filter2(c, e, tp, chk)
    return c:IsType(TYPE_FUSION) and c:ListsArchetypeAsMaterial(0x3008) and c.dark_calling and
               (not chk or Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, true, false)
end

function s.e3excheck(sg, tp, exg, ssg, c)
    return ssg:IsExists(function(c, sg, tp, oc)
        local sg = sg + oc
        return Duel.GetLocationCountFromEx(tp, tp, sg, c) > 0
    end, 1, nil, sg, tp, c)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or not Duel.IsTurnPlayer(tp) end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mg = Duel.GetMatchingGroup(s.e3filter2, tp, LOCATION_EXTRA, 0, nil, e, tp)
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, s.e3filter1, 1, false, s.e3excheck, c, mg, c) end

    local g = Duel.SelectReleaseGroupCost(tp, s.e3filter1, 1, 1, false, s.e3excheck, c, mg, c)
    g:AddCard(c)
    Duel.Release(g, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e3filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, true):GetFirst()
    if tc and Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, true, false, POS_FACEUP) > 0 then tc:CompleteProcedure() end
end
