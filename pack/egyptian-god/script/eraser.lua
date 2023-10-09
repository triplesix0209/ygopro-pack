-- The Wicked Deity Eraser
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.WickedGod(s, c, 1)

    -- atk/def value
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c) return Duel.GetFieldGroupCount(c:GetControler(), 0, LOCATION_ONFIELD) * 1000 end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e1b)

    -- suicide
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- erase field
    local e3reg = Effect.CreateEffect(c)
    e3reg:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3reg:SetCode(EVENT_LEAVE_FIELD_P)
    e3reg:SetOperation(s.e3regop)
    c:RegisterEffect(e3reg)
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetLabelObject(e3reg)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDestructable() and c:IsSummonType(SUMMON_TYPE_NORMAL) end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Destroy(c, REASON_EFFECT)
end

function s.e3regop(e, tp, eg, ep, ev, re, r, rp) e:SetLabel(Divine.GetDivineHierarchy(e:GetHandler())) end

function s.e3filter(c, divine_hierarchy) return Divine.GetDivineHierarchy(c) <= divine_hierarchy end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Utility.HintCard(e)

    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil, e:GetLabelObject():GetLabel())
    Duel.SendtoGrave(g, REASON_EFFECT + REASON_RULE)
end
