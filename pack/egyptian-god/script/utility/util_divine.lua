-- init
if not aux.DivineProcedure then aux.DivineProcedure = {} end
if not Divine then Divine = aux.DivineProcedure end

-- constant: flag
Divine.FLAG_DIVINE_EVOLUTION = 513000065

-- function
function Divine.IsDivineEvolution(c) return c:GetFlagEffect(Divine.FLAG_DIVINE_EVOLUTION) > 0 end

function Divine.RegisterDivineEvolution(c)
    c:RegisterFlagEffect(Divine.FLAG_DIVINE_EVOLUTION, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, 666000)
end

function Divine.GetDivineHierarchy(c, get_base)
    if not c then return 0 end
    local divine_hierarchy = c.divine_hierarchy
    if not divine_hierarchy then divine_hierarchy = 0 end
    if get_base then return divine_hierarchy end

    if c:GetFlagEffect(Divine.FLAG_DIVINE_EVOLUTION) > 0 then divine_hierarchy = divine_hierarchy + 1 end

    return divine_hierarchy
end

function Divine.EgyptianGod(s, c, divine_hierarchy)
    s.divine_hierarchy = divine_hierarchy

    -- cannot special summon, except owner 
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st) return sp == e:GetOwnerPlayer() end)
    c:RegisterEffect(splimit)

    -- 3 tribute
    aux.AddNormalSummonProcedure(c, true, false, 3, 3)
    aux.AddNormalSetProcedure(c)

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(sumsafe)

    -- activation and effect cannot be negated
    local nonegate = Effect.CreateEffect(c)
    nonegate:SetType(EFFECT_TYPE_FIELD)
    nonegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nonegate:SetCode(EFFECT_CANNOT_INACTIVATE)
    nonegate:SetRange(LOCATION_MZONE)
    nonegate:SetTargetRange(1, 0)
    nonegate:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(nonegate)
    local nodiseff = nonegate:Clone()
    nodiseff:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(nodiseff)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(nomaterial)

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- battle position cannot be changed by effect
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

    -- destroy equip
    local noequip = Effect.CreateEffect(c)
    noequip:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    noequip:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noequip:SetCode(EVENT_EQUIP)
    noequip:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local g = eg:Filter(function(ec) return ec:GetEquipTarget() == e:GetHandler() end, nil)
        if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
    end)
    c:RegisterEffect(noequip)

    -- battle indes & avoid damage
    local indes = Effect.CreateEffect(c)
    indes:SetType(EFFECT_TYPE_SINGLE)
    indes:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    indes:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    indes:SetValue(function(e, tc)
        return tc and Divine.GetDivineHierarchy(tc) > 0 and Divine.GetDivineHierarchy(tc) < Divine.GetDivineHierarchy(e:GetHandler())
    end)
    c:RegisterEffect(indes)
    local nodmg = indes:Clone()
    nodmg:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(nodmg)

    -- cannot leave with effect
    local noleave = Effect.CreateEffect(c)
    noleave:SetType(EFFECT_TYPE_SINGLE)
    noleave:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noleave:SetCode(EFFECT_IMMUNE_EFFECT)
    noleave:SetRange(LOCATION_MZONE)
    noleave:SetValue(function(e, re)
        if not re or not re:IsHasCategory(CATEGORY_TOHAND + CATEGORY_TODECK + CATEGORY_TOGRAVE + CATEGORY_REMOVE) then return false end
        local c = e:GetHandler()
        local rc = re:GetHandler()
        return rc ~= c and not rc:ListsCode(c:GetCode()) and (not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <= Divine.GetDivineHierarchy(c))
    end)
    c:RegisterEffect(noleave)
    local noleave_destroy = noleave:Clone()
    noleave_destroy:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    noleave_destroy:SetValue(function(e, re)
        if not re then return false end
        local c = e:GetHandler()
        local rc = re:GetHandler()
        return rc ~= c and not rc:ListsCode(c:GetCode()) and (not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <= Divine.GetDivineHierarchy(c))
    end)
    c:RegisterEffect(noleave_destroy)
    local noleave_release = noleave_destroy:Clone()
    noleave_release:SetCode(EFFECT_UNRELEASABLE_EFFECT)
    c:RegisterEffect(noleave_release)

    -- effects applied for 1 turn
    local reset = Effect.CreateEffect(c)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    reset:SetRange(LOCATION_MZONE)
    reset:SetCode(EVENT_ADJUST)
    reset:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.GetCurrentPhase() == PHASE_END and Utility.GetListEffect(e:GetHandler(), ResetEffectFilter)
    end)
    reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) Utility.ResetListEffect(e:GetHandler(), ResetEffectFilter) end)
    c:RegisterEffect(reset)

    -- redirect attack & effect
    local redirect = Effect.CreateEffect(c)
    redirect:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    redirect:SetCode(EVENT_SPSUMMON_SUCCESS)
    redirect:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsAttackPos() then return end

        local ac = Duel.GetAttacker()
        if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and ac:CanAttack() and ac:GetAttackableTarget():IsContains(c) and
            Duel.SelectEffectYesNo(tp, c, 666002) then
            Duel.HintSelection(c, true)
            Duel.ChangeAttackTarget(c)
        end

        local te, tg = Duel.GetChainInfo(ev + 1, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TARGET_CARDS)
        if te and te ~= re and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and #tg == 1 and c:IsCanBeEffectTarget(te) and
            Duel.SelectEffectYesNo(tp, c, 666002) then Duel.ChangeTargetCard(ev + 1, Group.FromCards(c)) end
    end)
    c:RegisterEffect(redirect)

    -- return to where was special summon
    local spreturn = Effect.CreateEffect(c)
    spreturn:SetDescription(666003)
    spreturn:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    spreturn:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spreturn:SetRange(LOCATION_MZONE)
    spreturn:SetCode(EVENT_PHASE + PHASE_END)
    spreturn:SetCountLimit(1)
    spreturn:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsSummonType(SUMMON_TYPE_SPECIAL) then return false end
        return (c:IsPreviousLocation(LOCATION_GRAVE) and c:IsAbleToGrave()) or (c:IsPreviousLocation(LOCATION_REMOVED) and c:IsAbleToRemove())
    end)
    spreturn:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsPreviousLocation(LOCATION_GRAVE) then
            Duel.SendtoGrave(c, REASON_EFFECT)
        elseif c:IsPreviousLocation(LOCATION_REMOVED) then
            Duel.Remove(c, c:GetPreviousPosition(), REASON_EFFECT)
        end
    end)
    c:RegisterEffect(spreturn)
end

function Divine.WickedGod(s, c, divine_hierarchy)
    s.divine_hierarchy = divine_hierarchy

    -- cannot special summon
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- 3 tribute
    aux.AddNormalSummonProcedure(c, true, false, 3, 3)
    aux.AddNormalSetProcedure(c)

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(sumsafe)

    -- effect activation and activated effect cannot be negated
    local nonegate = Effect.CreateEffect(c)
    nonegate:SetType(EFFECT_TYPE_FIELD)
    nonegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nonegate:SetCode(EFFECT_CANNOT_INACTIVATE)
    nonegate:SetRange(LOCATION_MZONE)
    nonegate:SetTargetRange(1, 0)
    nonegate:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(nonegate)
    local nodiseff = nonegate:Clone()
    nodiseff:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(nodiseff)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(nomaterial)

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- battle position cannot be changed by effect
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

    -- destroy equip
    local noequip = Effect.CreateEffect(c)
    noequip:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    noequip:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noequip:SetCode(EVENT_EQUIP)
    noequip:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local g = eg:Filter(function(ec) return ec:GetEquipTarget() == e:GetHandler() end, nil)
        if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
    end)
    c:RegisterEffect(noequip)

    -- battle indes & avoid damage
    local indes = Effect.CreateEffect(c)
    indes:SetType(EFFECT_TYPE_SINGLE)
    indes:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    indes:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    indes:SetValue(function(e, tc)
        return tc and Divine.GetDivineHierarchy(tc) > 0 and Divine.GetDivineHierarchy(tc) < Divine.GetDivineHierarchy(e:GetHandler())
    end)
    c:RegisterEffect(indes)
    local nodmg = indes:Clone()
    nodmg:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(nodmg)

    -- cannot leave with effect
    local noleave = Effect.CreateEffect(c)
    noleave:SetType(EFFECT_TYPE_SINGLE)
    noleave:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noleave:SetCode(EFFECT_IMMUNE_EFFECT)
    noleave:SetRange(LOCATION_MZONE)
    noleave:SetValue(function(e, re)
        if not re or not re:IsHasCategory(CATEGORY_TOHAND + CATEGORY_TODECK + CATEGORY_TOGRAVE + CATEGORY_REMOVE) then return false end
        local c = e:GetHandler()
        local rc = re:GetHandler()
        return rc ~= c and not rc:ListsCode(c:GetCode()) and (not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <= Divine.GetDivineHierarchy(c))
    end)
    c:RegisterEffect(noleave)
    local noleave_destroy = noleave:Clone()
    noleave_destroy:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    noleave_destroy:SetValue(function(e, re)
        if not re then return false end
        local c = e:GetHandler()
        local rc = re:GetHandler()
        return rc ~= c and not rc:ListsCode(c:GetCode()) and (not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <= Divine.GetDivineHierarchy(c))
    end)
    c:RegisterEffect(noleave_destroy)
    local noleave_release = noleave_destroy:Clone()
    noleave_release:SetCode(EFFECT_UNRELEASABLE_EFFECT)
    c:RegisterEffect(noleave_release)

    -- effects applied for 1 turn
    local reset = Effect.CreateEffect(c)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    reset:SetRange(LOCATION_MZONE)
    reset:SetCode(EVENT_ADJUST)
    reset:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.GetCurrentPhase() == PHASE_END and Utility.GetListEffect(e:GetHandler(), ResetEffectFilter)
    end)
    reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) Utility.ResetListEffect(e:GetHandler(), ResetEffectFilter) end)
    c:RegisterEffect(reset)
end

function Divine.Apostle(id, c, god_code, tribute_filter, gain_op)
    -- search divine-beast
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
    e1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.IsExistingMatchingCard(function(c) return c:IsCode(god_code) and c:IsAbleToHand() end, tp, LOCATION_DECK + LOCATION_GRAVE, 0,
                1, nil)
        end
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, function(c) return c:IsCode(god_code) and c:IsAbleToHand() end, tp,
            LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end)
    c:RegisterEffect(e1)

    -- additional tribute summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_HAND, 0)
    e2:SetCondition(function(e) return Duel.IsMainPhase() and e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
    e2:SetTarget(tribute_filter)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- triple tribute
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e3:SetValue(tribute_filter)
    c:RegisterEffect(e3)

    -- effect gain
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BE_PRE_MATERIAL)
    e4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local rc = e:GetHandler():GetReasonCard()
        return r == REASON_SUMMON and rc:IsFaceup() and rc:IsCode(god_code)
    end)
    e4:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local rc = c:GetReasonCard()
        local eff = Effect.CreateEffect(c)
        eff:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        eff:SetCode(EVENT_SUMMON_SUCCESS)
        eff:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            if not Duel.IsExistingMatchingCard(function(c)
                if type(god_code) == 'table' then
                    for i, code in ipairs(god_code) do if not c:ListsCode(code) then return false end end
                else
                    if not c:ListsCode(god_code) then return false end
                end
                return c:IsSpellTrap() and c:IsAbleToHand()
            end, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) then return end
            if not Duel.SelectEffectYesNo(tp, rc, aux.Stringid(id, 1)) then return end

            local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, function(c)
                if type(god_code) == 'table' then
                    for i, code in ipairs(god_code) do if not c:ListsCode(code) then return false end end
                else
                    if not c:ListsCode(god_code) then return false end
                end
                return c:IsSpellTrap() and c:IsAbleToHand()
            end, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end)
        eff:SetReset(RESET_EVENT + RESETS_STANDARD)
        rc:RegisterEffect(eff, true)

        if (gain_op ~= nil) then gain_op(e, tp, eg, ep, ev, re, r, rp, rc) end
    end)
    c:RegisterEffect(e4)
end

function ResetEffectFilter(te, c)
    local tc = te:GetOwner()
    if tc == c or tc:ListsCode(c:GetCode()) then return false end
    if tc:IsMonster() and Divine.GetDivineHierarchy(tc) > Divine.GetDivineHierarchy(c) then return false end
    return not te:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_FIELD_ONLY) and
               (te:GetTarget() == aux.PersistentTargetFilter or not te:IsHasType(EFFECT_TYPE_GRANT)) and te:GetCode() ~= EFFECT_SPSUMMON_PROC
end
