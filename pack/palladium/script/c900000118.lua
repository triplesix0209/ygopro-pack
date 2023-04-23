-- Palladium Maiden Isis
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- look deck & set
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e1c)

    -- return to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_CONFIRM)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    if not c:IsSSetable() then return false end
    return (c:IsSetCard(0x13a) and c:IsSpellTrap()) or c:IsContinuousTrap()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 end end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local max = math.min(5, Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0))
    if max == 0 then return end

    local ac = max == 1 and max or Duel.AnnounceNumberRange(tp, 1, max)
    local g = Duel.GetDecktopGroup(tp, ac)
    Duel.ConfirmCards(tp, g)

    if g:IsExists(s.e1filter, 1, nil) and Duel.SelectYesNo(tp, 510) then
        local tc = Utility.GroupSelect(HINTMSG_SET, g, tp, 1, 1, nil, s.e1filter):GetFirst()
        Duel.DisableShuffleCheck()
        if Duel.SSet(tp, tc) > 0 and (tc:IsTrap() or tc:IsQuickPlaySpell()) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            ec1:SetCode(tc:IsTrap() and EFFECT_TRAP_ACT_IN_SET_TURN or EFFECT_QP_ACT_IN_SET_TURN)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
        end

        Duel.SortDecktop(tp, tp, ac - 1)
    else
        Duel.SortDecktop(tp, tp, ac)
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    return c:IsRelateToBattle() and bc and bc:IsRelateToBattle()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if chk == 0 then return c:IsAttackPos() and c:IsCanChangePosition() and bc:IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, bc, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() and c:IsAttackPos() and
        Duel.ChangePosition(c, POS_FACEUP_DEFENSE) > 0 then
        Duel.SendtoHand(bc, nil, REASON_EFFECT)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_COPY_INHERIT)
        ec1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_SELF_TURN, 2)
        c:RegisterEffect(ec1)
    end
end
