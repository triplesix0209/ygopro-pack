-- Heretic of Albaz
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ALBAZ}

function s.initial_effect(c)
    -- change name
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE)
    e1:SetValue(CARD_ALBAZ)
    c:RegisterEffect(e1)

    -- fusion summon
    local params = {
        fusfilter = nil,
        matfilter = Fusion.InHandMat(Card.IsAbleToRemove),
        extrafil = s.e2fusextra,
        extratg = s.e2extratarget,
        extraop = Fusion.BanishMaterial,
        gc = Fusion.ForcedHandler
    }
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    e2:SetHintTiming(0, TIMING_MAIN_END + TIMINGS_CHECK_MONSTER)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetCondition(function() return Duel.IsMainPhase() end)
    e2:SetTarget(Fusion.SummonEffTG(params))
    e2:SetOperation(Fusion.SummonEffOP(params))
    c:RegisterEffect(e2)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost, tp, LOCATION_ONFIELD, 0, 1, nil) end
    local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, Card.IsAbleToGraveAsCost, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.e2fusextra(e, tp, mg) return Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_GRAVE, LOCATION_GRAVE, nil), s.e2fuscheck end

function s.e2fuscheck(tp, sg, fc) return sg:FilterCount(function(c) return c:IsControler(tp) and c:IsLocation(LOCATION_HAND) end, nil) == 1 end

function s.e2extratarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, e:GetHandler(), 0, tp, LOCATION_GRAVE)
end
