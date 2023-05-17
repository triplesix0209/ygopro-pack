-- Dark Flare Paladin of Palladium
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.material_setcode = {SET_PALLADIUM}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, 71703785, s.fusfilter)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st) end)
    c:RegisterEffect(splimit)

    -- equip
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e2con)
    e1:SetTarget(s.e2tg)
    e1:SetOperation(s.e2op)
    c:RegisterEffect(e1)
    aux.AddEREquipLimit(c, nil, aux.FilterBoolFunction(Card.IsMonster), Card.EquipByEffectAndLimitRegister, e1)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, c)
        local tp = c:GetControler()
        return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace, c:GetRace()), tp, LOCATION_MZONE + LOCATION_GRAVE,
            LOCATION_MZONE + LOCATION_GRAVE, c) * 500
    end)
    c:RegisterEffect(e2)

    -- negate
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- multi attack
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE + PHASE_BATTLE_START)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.fusfilter(c, fc, sumtype, tp) return c:IsLevelAbove(7) and c:IsRace(RACE_WARRIOR, fc, sumtype, tp) end

function s.e2filter(c, tp) return c:IsMonster() and c:CheckUniqueOnField(tp) and not c:IsForbidden() end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, tp) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, tp)

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) then
        c:EquipByEffectAndLimitRegister(e, tp, tc, nil, true)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_EQUIP)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(500)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec2 = ec1:Clone()
        ec2:SetCode(EFFECT_ADD_RACE)
        ec2:SetValue(tc:GetRace())
        tc:RegisterEffect(ec2)
    end
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD, nil)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    if not Duel.IsChainNegatable(ev) then return false end

    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    return (re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)) or
               (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and tg and tg:IsExists(Card.IsOnField, 1, nil))
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, #eg, 0, 0)
    if rc:IsDestructable() and rc:IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, #eg, 0, 0) end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Destroy(eg, REASON_EFFECT) end
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() == tp end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = c:GetEquipGroup()
    if chk == 0 then return g:IsExists(Card.IsAbleToGraveAsCost, 1, nil) end

    local sg = Utility.GroupSelect(HINTMSG_TOGRAVE, g, tp, 1, 1, nil, Card.IsAbleToGraveAsCost)
    Duel.SendtoGrave(sg, REASON_COST)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(1115)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_ATTACK_ALL)
    ec1:SetValue(1)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetDescription(aux.Stringid(id, 2))
    ec1b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec1b:SetCode(EVENT_BATTLED)
    ec1b:SetOperation(s.e4disop)
    c:RegisterEffect(ec1b)
end

function s.e4disop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if not bc or not bc:IsStatus(STATUS_BATTLE_DESTROYED) then return end

    local ec1 = Effect.CreateEffect(e:GetOwner())
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_CANNOT_TRIGGER)
    ec1:SetCondition(function(e) return e:GetHandler():IsMonster() end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD & ~(RESET_LEAVE | RESET_TOGRAVE))
    bc:RegisterEffect(ec1)
end
