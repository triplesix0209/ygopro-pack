-- Ra's Apostle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 4059313, 77432167}

function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    c:EnableReviveLimit()

    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE

    -- link summon
    Link.AddProcedure(c, nil, 3, 3)

    -- search divine-beast
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- triple tribute
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e3:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e3:SetValue(function(e, c) return c:IsAttribute(ATTRIBUTE_DIVINE) end)
    c:RegisterEffect(e3)

    -- cannot attack
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e4)

    -- additional tribute summon
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e5:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_HAND, 0)
    e5:SetCondition(function(e) return Duel.IsMainPhase() and e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
    e5:SetTarget(aux.TargetBoolFunction(Card.IsRace, RACE_DIVINE))
    e5:SetValue(1)
    c:RegisterEffect(e5)

    -- effect gain
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e6:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e6:SetCode(EVENT_BE_PRE_MATERIAL)
    e6:SetCondition(s.e6regcon)
    e6:SetOperation(s.e6regop)
    c:RegisterEffect(e6)
end

function s.e1filter(c) return c:IsCode(CARD_RA) and c:IsAbleToHand() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return
            not Utility.IsOwnAny(Card.IsCode, tp, CARD_RA) or Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = nil
    if Utility.IsOwnAny(Card.IsCode, tp, CARD_RA) then
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    else
        tc = Duel.CreateToken(tp, CARD_RA)
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c) return not c:IsRace(RACE_DIVINE) end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    Duel.RegisterEffect(ec1b, tp)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    Duel.RegisterEffect(ec1c, tp)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetMaterial()

    local atk = 0
    for tc in aux.Next(g) do atk = atk + tc:GetPreviousAttackOnField() end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
end

function s.e6regcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return r == REASON_SUMMON and rc:IsFaceup() and rc:IsCode(CARD_RA)
end

function s.e6regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local atk = 0
    local def = 0
    local mg = rc:GetMaterial()
    for tc in aux.Next(mg) do
        atk = atk + tc:GetPreviousAttackOnField()
        def = def + tc:GetPreviousDefenseOnField()
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
    rc:RegisterEffect(ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(def)
    rc:RegisterEffect(ec1b, true)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_SUMMON_SUCCESS)
    ec2:SetOperation(s.e6op)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec2, true)
end

function s.e6filter(c, code) return c:IsCode(code) and c:IsAbleToHand() end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local b1 = not Utility.IsOwnAny(Card.IsCode, tp, 4059313) or
                   Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, 4059313)
    local b2 = not Utility.IsOwnAny(Card.IsCode, tp, 77432167) or
                   Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, 77432167)

    local opt = {}
    local sel = {}
    if b1 then
        table.insert(opt, aux.Stringid(id, 3))
        table.insert(sel, 1)
    end
    if b2 then
        table.insert(opt, aux.Stringid(id, 4))
        table.insert(sel, 2)
    end
    if #opt == 0 or not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then return end

    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    local code = op == 1 and 4059313 or 77432167
    local tc = nil
    if Utility.IsOwnAny(Card.IsCode, tp, code) then
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e6filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, code):GetFirst()
    else
        tc = Duel.CreateToken(tp, code)
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
end
