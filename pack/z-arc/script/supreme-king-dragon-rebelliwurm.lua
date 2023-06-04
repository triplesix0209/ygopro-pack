-- Supreme King Dragon Rebelliwurm
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- rank
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- xyz limit
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    me1:SetValue(function(e, c)
        if not c then return false end
        return not c:IsRace(RACE_DRAGON) and not c:IsType(TYPE_PENDULUM)
    end)
    c:RegisterEffect(me1)

    -- special summon
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(2)
    me2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me2:SetType(EFFECT_TYPE_IGNITION)
    me2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    me2:SetRange(LOCATION_HAND + LOCATION_GRAVE + LOCATION_EXTRA)
    me2:SetCountLimit(1, id)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)

    -- xyz summon
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(1173)
    me3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me3:SetType(EFFECT_TYPE_IGNITION)
    me3:SetRange(LOCATION_MZONE)
    me3:SetCountLimit(1)
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)
end

function s.pe1filter(c, e, tp) return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) end

function s.pe1filter1(c, tp) return c:IsFaceup() and c:IsType(TYPE_XYZ) and Duel.IsExistingTarget(s.pe1filter2, tp, LOCATION_MZONE, 0, 1, c) end

function s.pe1filter2(c) return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:HasLevel() end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(s.pe1filter1, tp, LOCATION_MZONE, 0, 1, nil, tp) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tc1 = Duel.SelectTarget(tp, s.pe1filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, tp):GetFirst()
    e:SetLabelObject(tc1)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.pe1filter2, tp, LOCATION_MZONE, 0, 1, 1, tc1)
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    local tc1 = e:GetLabelObject()
    local tc2 = tg:GetFirst()
    if tc1 == tc2 then tc2 = tg:GetNext() end

    if not tc1:IsRelateToEffect(e) or tc1:IsFacedown() or not tc2:IsRelateToEffect(e) or tc2:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_CHANGE_RANK)
    ec1:SetValue(tc2:GetLevel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc1:RegisterEffect(ec1)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_XYZ_LEVEL)
    ec2:SetValue(function(e, c) return c:GetRank() end)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc1:RegisterEffect(ec2)
end

function s.me2filter(c)
    if c:IsFacedown() or c:IsDisabled() or c:IsAttack(0) then return false end
    if not c:HasLevel() then return false end
    return (c:IsRace(RACE_DRAGON) and c:IsAttackAbove(2500)) or c:IsType(TYPE_PENDULUM)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        if (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp, LOCATION_MZONE) == 0) or
            (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0) then return false end

        return Duel.IsExistingTarget(s.me2filter, tp, LOCATION_MZONE, 0, 1, nil) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.me2filter, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:IsAttack(0) or tc:IsDisabled() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(0)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE)
    tc:RegisterEffect(ec1b)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1c)

    if tc:IsImmuneToEffect(ec1) or tc:IsImmuneToEffect(ec1b) or tc:IsImmuneToEffect(ec1c) or not c:IsRelateToEffect(e) then return end
    Duel.AdjustInstantly(tc)

    if (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp, LOCATION_MZONE) == 0) or
        (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0) then return false end

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 and c:HasLevel() then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_CHANGE_LEVEL)
        ec2:SetValue(c:GetLevel())
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end

function s.me3filter1(c, e, tp, mc)
    local mg = Group.FromCards(c, mc)
    return c:IsCanBeXyzMaterial() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               Duel.IsExistingMatchingCard(s.me3filter2, tp, LOCATION_EXTRA, 0, 1, nil, tp, mg)
end

function s.me3filter2(c, tp, mg) return Duel.GetLocationCountFromEx(tp, tp, mg, c) > 0 and c:IsXyzSummonable(nil, mg) end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsPlayerCanSpecialSummonCount(tp, 2) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.me3filter1, tp, LOCATION_PZONE, 0, 1, nil, e, tp, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_PZONE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.me3filter1, tp, LOCATION_PZONE, 0, 1, 1, nil, e, tp, c):GetFirst()
    Duel.HintSelection(tc)
    if not Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1b)
    Duel.SpecialSummonComplete()

    if not c:IsRelateToEffect(e) then return end

    local mg = Group.FromCards(c, tc)
    local g = Duel.GetMatchingGroup(s.me3filter2, tp, LOCATION_EXTRA, 0, nil, tp, mg)
    if #g > 0 then Duel.XyzSummon(tp, g:Select(tp, 1, 1, nil):GetFirst(), nil, mg) end
end
