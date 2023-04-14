-- Majestic Life Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    SignerDragon.AddMajesticProcedure(c, s, SignerDragon.CARD_LIFE_STREAM_DRAGON)
    SignerDragon.AddMajesticReturn(c, SignerDragon.CARD_LIFE_STREAM_DRAGON)

    -- equip spells
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- damage conversion
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_REVERSE_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1, 0)
    e2:SetValue(function(e, re, r, rp, rc) return (r & REASON_EFFECT) ~= 0 end)
    c:RegisterEffect(e2)

    -- negate & change position
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DISABLE + CATEGORY_POSITION)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c, tp, ec) return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, tp, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, 0, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e1filter), tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, nil,
        tp, c)
    if #g == 0 then return end

    local ft = math.min(Duel.GetLocationCount(tp, LOCATION_SZONE), 3)
    local sg = Utility.GroupSelect(HINTMSG_EQUIP, g, tp, 1, ft)
    if #sg > 0 then
        for tc in sg:Iter() do
            Duel.Equip(tp, tc, c, true, true)

            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(3060)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            ec1:SetRange(LOCATION_MZONE)
            ec1:SetValue(aux.indoval)
            tc:RegisterEffect(ec1)
            local ec1b = ec1:Clone()
            ec1b:SetDescription(3061)
            ec1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
            ec1b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
            ec1b:SetValue(aux.tgoval)
            tc:RegisterEffect(ec1b)
        end
        Duel.EquipComplete()
    end
end

function s.e3filter(c) return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(s.e3filter, tp, 0, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local tc = Duel.SelectTarget(tp, s.e3filter, tp, 0, LOCATION_MZONE, 1, 1, nil):GetFirst()

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, tc, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_POSITION, tc, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsDisabled() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1b)

    if tc:IsImmuneToEffect(ec1) or tc:IsImmuneToEffect(ec1b) then return end
    Duel.AdjustInstantly(tc)

    if Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then
        Duel.ChangePosition(tc, POS_FACEUP_DEFENSE, 0, POS_FACEUP_ATTACK, 0)
    end
end
