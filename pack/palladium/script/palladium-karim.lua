-- Palladium Gardna Karim
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- to defense
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- def down
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- change attack target
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BE_BATTLE_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- negate effect target
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(1116)
    e4:SetCategory(CATEGORY_DISABLE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFaceup() and c:IsAttackPos() then Duel.ChangePosition(c, POS_FACEUP_DEFENSE) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToBattle() or Duel.GetAttackTarget() ~= c or not c:IsDefensePos() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_DEFENSE)
    ec1:SetValue(-800)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bt = eg:GetFirst()
    return r ~= REASON_REPLACE and bt ~= c and bt:IsControler(tp) and bt:IsFaceup() and bt:IsSetCard(0x13a)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ac = Duel.GetAttacker()
    if c:IsFaceup() and c:IsRelateToEffect(e) and ac:CanAttack() and not ac:IsImmuneToEffect(e) then Duel.CalculateDamage(ac, c) end
end

function s.e4filter(c, tp) return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x13a) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if c:IsStatus(STATUS_BATTLE_DESTROYED) or ep == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not tg then return false end
    if re:GetHandler():IsDisabled() or not Duel.IsChainDisablable(ev) then return false end
    return tg:IsContains(c) or tg:IsExists(s.e4filter, 1, c, tp)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetDefense() >= 800 end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if not c:IsFaceup() or c:GetDefense() < 800 or not c:IsRelateToEffect(e) or c:IsStatus(STATUS_BATTLE_DESTROYED) then return end

    if Duel.NegateEffect(ev) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
        ec1:SetCode(EFFECT_UPDATE_DEFENSE)
        ec1:SetValue(-800)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(ec1)
    end
end
