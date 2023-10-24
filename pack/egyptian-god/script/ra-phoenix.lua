-- Sun Divine Dragon of Ra - Immortal Phoenix
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 10000080}

function s.initial_effect(c)
    s.divine_hierarchy = 2
    Dimension.AddProcedure(c)

    -- dimension change (special summon)
    Dimension.RegisterChange({
        handler = c,
        flag_id = id + 1000000000,
        event_code = EVENT_SPSUMMON_SUCCESS,
        filter = function(c, sc)
            return c:IsCode(CARD_RA) and c:GetOwner() == sc:GetOwner() and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsControler(c:GetOwner()) and
                       c:IsAttackPos()
        end,
        custom_op = function(e, tp, mc)
            local c = e:GetHandler()
            Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
            local op = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2))
            if op == 0 then return end

            local divine_evolution = Divine.IsDivineEvolution(mc)
            Dimension.Change(mc, c)
            if divine_evolution then Divine.RegisterDivineEvolution(c) end
        end
    })

    -- dimension change (self destroy)
    Dimension.RegisterChange({
        handler = c,
        flag_id = id + 200000,
        custom_reg = function(c, flag_id)
            local dms = Effect.CreateEffect(c)
            dms:SetType(EFFECT_TYPE_CONTINUOUS)
            dms:SetCode(EFFECT_DESTROY_REPLACE)
            dms:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
                local sc = e:GetHandler()
                local g = eg:Filter(s.dmsfilter, nil, sc:GetOwner())
                if chk == 0 then return #g > 0 end
                for tc in g:Iter() do tc:RegisterFlagEffect(flag_id + 1000000000 * (tc:GetOwner() + 1), 0, 0, 1) end
                return true
            end)
            dms:SetValue(function(e, c) return s.dmsfilter(c, e:GetHandler():GetOwner()) end)
            Duel.RegisterEffect(dms, 0)
        end,
        custom_op = function(e, tp, mc)
            local c = e:GetHandler()
            local atk = mc:GetAttack()
            local def = mc:GetDefense()

            local divine_evolution = Divine.IsDivineEvolution(mc)
            Dimension.Change(mc, c)
            if divine_evolution then Divine.RegisterDivineEvolution(c) end

            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            ec1:SetRange(LOCATION_MZONE)
            ec1:SetCode(EFFECT_SET_BASE_ATTACK)
            ec1:SetValue(atk)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(ec1)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
            ec1b:SetValue(def)
            c:RegisterEffect(ec1b)

            c:RegisterFlagEffect(id + 200000, 0, 0, 1)
        end
    })

    -- cannot be Tributed, or be used as a material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_UNRELEASABLE_SUM)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e1b)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    c:RegisterEffect(e1b)

    -- destroy equip
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EVENT_EQUIP)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local g = eg:Filter(function(ec) return ec:GetEquipTarget() == e:GetHandler() end, nil)
        if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
    end)
    c:RegisterEffect(e2)

    -- immune & indes & no battle damage
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()
        return c ~= tc and (not tc:IsMonster() or Divine.GetDivineHierarchy(tc) <= Divine.GetDivineHierarchy(c))
    end)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3b:SetValue(function(e, tc) return Divine.GetDivineHierarchy(tc) <= Divine.GetDivineHierarchy(e:GetHandler()) end)
    c:RegisterEffect(e3b)
    local e3c = e3b:Clone()
    e3c:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(e3c)

    -- cannot attack
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e4:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e4)

    -- perform attack
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetCategory(CATEGORY_TOGRAVE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetHintTiming(TIMING_MAIN_END + TIMINGS_CHECK_MONSTER)
    e5:SetCondition(s.e5con)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
    local e5b = Effect.CreateEffect(c)
    e5b:SetCategory(CATEGORY_TOGRAVE)
    e5b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e5b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e5b:SetCode(EVENT_BATTLED)
    e5b:SetCondition(s.e5atkcon)
    e5b:SetOperation(s.e5atkop)
    c:RegisterEffect(e5b)

    -- return
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 4))
    e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e6:SetCode(EVENT_PHASE + PHASE_END)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.dmsfilter(c, tp)
    local re = c:GetReasonEffect()
    if c:IsReason(REASON_REPLACE) then return false end
    return c:IsReason(REASON_EFFECT) and re and re:GetHandler() == c and c:IsControler(tp) and c:IsFaceup() and c:IsCode(CARD_RA)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsAttackPos() and Duel.GetCurrentPhase() < PHASE_END and not Duel.GetAttacker() end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetFlagEffect(id) == 0 and (Duel.CheckLPCost(tp, 1000) or c:GetFlagEffect(id + 200000) > 0) end

    if c:GetFlagEffect(id + 200000) == 0 then
        Duel.PayLPCost(tp, 1000)
    else
        c:ResetFlagEffect(id + 200000)
    end
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_CHAIN, 0, 1)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACKTARGET)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_MZONE, 1, 1, c)
    Duel.SetTargetCard(g)

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    Duel.CalculateDamage(c, tc)
end

function s.e5atkcon(e, tp, eg, ep, ev, re, r, rp) return Duel.GetAttacker() == e:GetHandler() and e:GetHandler():GetBattleTarget() end

function s.e5atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if not c:GetFlagEffect(id) or not bc:IsRelateToBattle() then return end

    Duel.SendtoGrave(bc, REASON_EFFECT)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Dimension.Zones(c:GetOwner()):Filter(function(c) return c:IsCode(10000080) and c:IsType(Dimension.TYPE) end, nil):GetFirst()
    if tc then
        local divine_evolution = Divine.IsDivineEvolution(c)
        Dimension.Change(c, tc, c:GetMaterial())
        if divine_evolution then Divine.RegisterDivineEvolution(tc) end
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end
