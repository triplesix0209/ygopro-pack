-- The Newborn Messiah
Duel.LoadScript("util.lua")
Duel.LoadScript("util_messiah.lua")
local s, id = GetID()

function s.initial_effect(c)
    Messiah.RegisterMessiahBabyEffect(s, c, id, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)

    -- link summon
    Link.AddProcedure(c,
        function(c, sc, sumtype, tp) return not c:IsType(TYPE_LINK, sc, sumtype, tp) and not c:IsType(TYPE_TOKEN, sc, sumtype, tp) end, 3, 3)

    -- draw
    local me1 = Effect.CreateEffect(c)
    me1:SetCategory(CATEGORY_DRAW + CATEGORY_HANDES)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetCountLimit(1, id)
    me1:SetCondition(s.me1con)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- avoid battle damage
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    me2:SetValue(1)
    c:RegisterEffect(me2)
end

function s.me1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 2) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
    Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 0, tp, 1)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    if Duel.Draw(p, 2, REASON_EFFECT) == 2 then
        Duel.ShuffleHand(tp)
        Duel.BreakEffect()
        Duel.DiscardHand(tp, nil, 1, 1, REASON_EFFECT + REASON_DISCARD)
    end
end
