-- Clash of Souls
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS, CARD_YUBEL}
s.listed_series = {SET_ARMED_DRAGON, SET_ULTIMATE_CRYSTAL, SET_YUBEL}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMING_END_PHASE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- extra material
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1, id)
    e2:SetCost(aux.bfgcost)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp, to_tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, true, false, POS_FACEUP_ATTACK, to_tp) and
               (c:IsCode(CARD_YUBEL) or c:IsSetCard({SET_ARMED_DRAGON, SET_ULTIMATE_CRYSTAL}))
end

function s.e1check1(e, tp)
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp, tp) and
               Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_NEOS), tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.e1check2(e, tp)
    return Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp, 1 - tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return s.e1check1(e, tp) or s.e1check2(e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_HAND + LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = Duel.SelectEffect(tp, {s.e1check1(e, tp), aux.Stringid(id, 0)}, {s.e1check2(e, tp), aux.Stringid(id, 1)})

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp,
        op == 1 and tp or 1 - tp):GetFirst()
    if not tc then return end

    if Duel.SpecialSummonStep(tc, 0, tp, op == 1 and tp or 1 - tp, true, false, POS_FACEUP_ATTACK) then
        -- cannot attack directly
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3207)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)

        -- cannot activate effect
        local ec2 = Effect.CreateEffect(c)
        ec2:SetDescription(3302)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec2:SetCode(EFFECT_CANNOT_TRIGGER)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec2)
    end
    Duel.SpecialSummonComplete()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CHAIN_MATERIAL)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(s.e2chaintg)
    ec1:SetOperation(s.e2chainop)
    ec1:SetValue(s.e2chainval)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2chainfilter(c, e) return c:IsMonster() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e) end

function s.e2chaintg(e, te, tp, value)
    if not value or value & SUMMON_TYPE_FUSION == 0 then return Group.CreateGroup() end
    return Duel.GetMatchingGroup(s.e2chainfilter, tp, LOCATION_HAND + LOCATION_MZONE, LOCATION_MZONE, nil, te)
end

function s.e2chainop(e, te, tp, tc, mat, sumtype, sg, sumpos)
    local c = e:GetHandler()
    if not sumtype then sumtype = SUMMON_TYPE_FUSION end
    tc:SetMaterial(mat)
    Duel.SendtoGrave(mat, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
    Duel.BreakEffect()
    if sg then
        sg:AddCard(tc)
    else
        Duel.SpecialSummonStep(tc, sumtype, tp, tp, false, false, sumpos)
    end

    if mat:IsExists(Card.IsSetCard, 1, nil, SET_YUBEL) then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 3))

        -- indes effect
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        ec1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetValue(1)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
        tc:RegisterEffect(ec1)

        -- recover
        local ec2 = Effect.CreateEffect(c)
        ec2:SetDescription(1119)
        ec2:SetCategory(CATEGORY_RECOVER)
        ec2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
        ec2:SetCode(EVENT_BATTLE_CONFIRM)
        ec2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            local bc = e:GetHandler():GetBattleTarget()
            return bc and bc:IsControler(1 - tp) and bc:GetDefense() > 0
        end)
        ec2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
            if chk == 0 then return true end
            local bc = e:GetHandler():GetBattleTarget()
            Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, bc:GetDefense())
        end)
        ec2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local bc = e:GetHandler():GetBattleTarget()
            if bc and bc:IsFaceup() and bc:IsControler(1 - tp) and bc:IsRelateToBattle() then
                Duel.Recover(tp, bc:GetDefense(), REASON_EFFECT)
            end
        end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
        tc:RegisterEffect(ec2)
    end

    if mat:IsExists(Card.IsSetCard, 1, nil, SET_ARMED_DRAGON) then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 4))

        -- indes battle
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        ec1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetValue(1)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
        tc:RegisterEffect(ec1)

        -- prevent actvations when battling
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_FIELD)
        ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec2:SetCode(EFFECT_CANNOT_ACTIVATE)
        ec2:SetRange(LOCATION_MZONE)
        ec2:SetTargetRange(0, 1)
        ec2:SetCondition(function(e) return Duel.GetAttacker() == e:GetHandler() end)
        ec2:SetValue(function(e, re, tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
        tc:RegisterEffect(ec2)
    end

    if mat:IsExists(Card.IsSetCard, 1, nil, SET_ULTIMATE_CRYSTAL) then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 5))

        -- untargetable
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        ec1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetValue(aux.tgoval)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
        tc:RegisterEffect(ec1)

        -- disable
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_FIELD)
        ec2:SetCode(EFFECT_DISABLE)
        ec2:SetRange(LOCATION_MZONE)
        ec2:SetTargetRange(0, LOCATION_MZONE)
        ec2:SetCondition(function(e)
            local c = e:GetHandler()
            return Duel.GetAttacker() == c and c:GetBattleTarget() and
                       (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL)
        end)
        ec2:SetTarget(function(e, c) return c == e:GetHandler():GetBattleTarget() end)
        tc:RegisterEffect(ec2)
        local ec2b = ec2:Clone()
        ec2b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec2b)
    end
end

function s.e2chainval(tc) return tc:ListsCodeAsMaterial(CARD_NEOS) end
