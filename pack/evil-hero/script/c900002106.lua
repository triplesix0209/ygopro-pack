-- Evil HERO Bubbling Anger
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x6008}

function s.initial_effect(c)
    -- add name
    local addname = Effect.CreateEffect(c)
    addname:SetType(EFFECT_TYPE_SINGLE)
    addname:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    addname:SetCode(EFFECT_ADD_CODE)
    addname:SetValue(79979666)
    c:RegisterEffect(addname)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- avoid damage & destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetDescription(aux.Stringid(id, 0))
    e2b:SetCategory(CATEGORY_DESTROY)
    e2b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2b:SetCode(EVENT_DAMAGE_STEP_END)
    e2b:SetTarget(s.e2tg)
    e2b:SetOperation(s.e2op)
    c:RegisterEffect(e2b)

    -- draw
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_HANDES + CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x6008), tp, LOCATION_MZONE, 0, 1, nil)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local bc = e:GetHandler():GetBattleTarget()
    if chk == 0 then return bc and bc:IsRelateToBattle() end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, bc, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local bc = e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() then Duel.Destroy(bc, REASON_EFFECT) end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return (r & REASON_FUSION) == REASON_FUSION and c:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED) and c:IsFaceup()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 2) end

    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
    Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 0, tp, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp, chk)
    if Duel.Draw(tp, 2, REASON_EFFECT) > 0 then
        Duel.BreakEffect()
        Duel.ShuffleHand(tp)
        Duel.DiscardHand(tp, aux.TRUE, 1, 1, REASON_EFFECT + REASON_DISCARD)
    end
end
