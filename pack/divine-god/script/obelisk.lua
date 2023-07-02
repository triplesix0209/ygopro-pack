-- Giant Divine Soldier of Obelisk
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.EgyptianGod(s, c, 1)

    -- cannot be target
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- damage & destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DAMAGE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMING_BATTLE_END)
    e2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.effcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- soul energy MAX
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_BATTLE_END)
    e3:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.effcost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    Utility.AvatarInfinity(s, c)
end

function s.effcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c) and c:GetAttackAnnouncedCount() == 0 and c:CanAttack() end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, c)
    Duel.Release(g, REASON_COST)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tn = Duel.GetTurnPlayer()
    return (tn == tp and Duel.IsMainPhase()) or (tn ~= tp and Duel.IsBattlePhase())
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return true end

    local dmg = c:GetAttack()
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    Duel.Damage(p, c:GetAttack(), REASON_EFFECT)

    local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e3filter(c) return c:IsFaceup() and Divine.GetDivineHierarchy(c) >= 2 end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.IsExistingMatchingCard(function(tc) return tc:IsFaceup() and Divine.GetDivineHierarchy(tc) >= 2 end, tp, LOCATION_MZONE,
        LOCATION_MZONE, 1, nil) and Duel.IsBattlePhase()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACKTARGET)
    local g = Duel.SelectMatchingCard(tp, nil, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetTargetCard(g)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Utility.GainInfinityAtk(c, RESET_PHASE + PHASE_DAMAGE_CAL)
        Duel.CalculateDamage(c, tc)
    end
end

