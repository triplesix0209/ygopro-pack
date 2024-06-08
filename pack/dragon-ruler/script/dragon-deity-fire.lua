-- Rubyoh, Dragon Deity of Fire Storms
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_FIRE)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsType(TYPE_PENDULUM)) end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- inflict damage
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con1)
    e2:SetTarget(s.e2tg1)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2b:SetCode(EVENT_DESTROYED)
    e2b:SetCondition(s.e2con2)
    e2b:SetTarget(s.e2tg2)
    c:RegisterEffect(e2b)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3b:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL + 1) end)
    e3b:SetCost(aux.TRUE)
    c:RegisterEffect(e3b)
end

function s.e2con1(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsRelateToBattle() end

function s.e2tg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local tc = e:GetHandler():GetBattleTarget()
    local atk = tc:GetBaseAttack()
    if atk < 0 then atk = 0 end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(atk)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, atk)
end

function s.e2con2(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT) ~= 0 and re:GetHandler() == e:GetHandler() and eg:IsExists(Card.IsMonster, 1, nil)
end

function s.e2tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local atk = 0
    for tc in eg:Iter() do if tc:GetBaseAttack() > 0 then atk = atk + tc:GetBaseAttack() end end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(atk)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, atk)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end

function s.e3filter(c) return
    c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true)) end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.e3filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, c)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, PLAYER_ALL, LOCATION_ONFIELD)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, c):GetFirst()
    if not tc then return end
    Duel.HintSelection(Group.FromCards(tc))

    Duel.Destroy(tc, REASON_EFFECT)
end