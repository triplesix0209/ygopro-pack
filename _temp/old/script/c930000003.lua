-- Thor, Aesir of Thunder
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x6042, 0x4b}
s.material_setcode = {0x6042}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.AesirGodEffect(c)

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, sumtype, tp)
        return c:IsSetCard(0x6042, sc, sumtype, tp) or
                   c:IsHasEffect(EFFECT_SYNSUB_NORDIC)
    end, 1, 1, Synchro.NonTuner(nil), 2, 99)

    -- negate
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- damage
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(UtilNordic.RebornCondition)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() == tp end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE,
                                           1, nil)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ng = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(ng) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec1b)
    end

    local g = Duel.GetMatchingGroup(function(c)
        return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
    end, tp, 0, LOCATION_MZONE, nil)
    if not c:IsRelateToEffect(e) or c:IsFacedown() or not c:IsOnField() or #g ==
        0 or not Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then return end
    local sc = Utility.GroupSelect(g, tp, 1, nil, HINTMSG_FACEUP):GetFirst()
    if sc then
        Duel.HintSelection(Group.FromCards(sc))
        c:CopyEffect(sc:GetOriginalCodeRule(),
                     RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 1)
    end
end

function s.e2filter(c) return c:IsFaceup() and c:IsSetCard(0x4b) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ct =
        Duel.GetMatchingGroupCount(s.e2filter, tp, LOCATION_MZONE, 0, nil)
    if chk == 0 then return ct > 0 end
    Duel.SetTargetPlayer(1 - tp)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, ct * 800)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    local ct =
        Duel.GetMatchingGroupCount(s.e2filter, tp, LOCATION_MZONE, 0, nil)
    Duel.Damage(p, ct * 800, REASON_EFFECT)
end
