-- Obsidianoh, Dragon Deity of Event Horizons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    DragonRuler.RegisterDeityEffect(s, c, id, ATTRIBUTE_DARK)

    -- untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or (c:GetMutualLinkedGroupCount() > 0 and c:IsType(TYPE_PENDULUM)) end)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- copy effect & multi attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- equip
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 3))
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCost(DragonRuler.DeityCost(aux.Stringid(id, 0), ATTRIBUTE_DARK, s.e3costextra))
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

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local eg = c:GetEquipGroup()
    if chk == 0 then return eg:IsExists(Card.IsAbleToGraveAsCost, 1, nil, tp) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = eg:FilterSelect(tp, Card.IsAbleToGraveAsCost, 1, 1, nil)
    e:SetLabelObject(g:GetFirst())

    Duel.SendtoGrave(g, REASON_COST)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    if tc and not tc:IsType(TYPE_TRAPMONSTER) and c:IsRelateToEffect(e) and c:IsFaceup() then
        c:CopyEffect(tc:GetOriginalCode(), RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 1)
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_ATTACK_ALL)
    ec1:SetValue(1)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e3filter(c, tp) return c:IsMonster() and (c:IsControler(tp) or c:IsAbleToChangeControler()) end

function s.e3costextra(sc, e, tp)
    return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_GRAVE, LOCATION_MZONE + LOCATION_GRAVE, 1, Group.FromCards(e:GetHandler(), sc), tp)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_MZONE + LOCATION_GRAVE, LOCATION_MZONE + LOCATION_GRAVE, c, tp)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, g, 1, PLAYER_ALL, LOCATION_MZONE + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_EQUIP, tp, s.e3filter, tp, LOCATION_MZONE + LOCATION_GRAVE, LOCATION_MZONE + LOCATION_GRAVE, 1, 1,
        c, tp):GetFirst()
    if not tc or tc:IsForbidden() or (not tc:IsControler(tp) and not tc:CheckUniqueOnField(tp)) or Duel.GetLocationCount(tp, LOCATION_SZONE) == 0 then
        return
    end
    Duel.HintSelection(Group.FromCards(tc))

    if Duel.Equip(tp, tc, c, true) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_EQUIP_LIMIT)
        ec1:SetLabelObject(c)
        ec1:SetValue(function(e, c) return c == e:GetLabelObject() end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_EQUIP)
        ec2:SetCode(EFFECT_UPDATE_ATTACK)
        ec2:SetValue(1000)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end
