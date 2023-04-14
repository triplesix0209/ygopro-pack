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

    -- summon cannot be negate
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(sumsafe)

    -- activation and effect cannot be negate
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
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(nodis)

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

    -- no switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- no change battle position with effect
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

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

    -- no leave with effect
    local noleave = Effect.CreateEffect(c)
    noleave:SetType(EFFECT_TYPE_SINGLE)
    noleave:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noleave:SetCode(EFFECT_IMMUNE_EFFECT)
    noleave:SetRange(LOCATION_MZONE)
    noleave:SetValue(function(e, re)
        if not re then return false end

        local rc = re:GetHandler()
        return rc ~= e:GetHandler() and re:IsHasCategory(CATEGORY_TOHAND + CATEGORY_TODECK + CATEGORY_TOGRAVE + CATEGORY_REMOVE) and
                   (not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <= Divine.GetDivineHierarchy(c))
    end)
    c:RegisterEffect(noleave)
    local noleave_destroy = noleave:Clone()
    noleave_destroy:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    noleave_destroy:SetValue(function(e, re)
        local rc = re:GetHandler()
        return rc ~= e:GetHandler() and (not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <= Divine.GetDivineHierarchy(c))
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

    -- redirect attack & effect target
    local redirect = Effect.CreateEffect(c)
    redirect:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    redirect:SetCode(EVENT_SUMMON_SUCCESS)
    redirect:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.GetTurnPlayer() == 1 - tp and e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
    end)
    redirect:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetTargetRange(0, LOCATION_MZONE)
        ec1:SetValue(function(e, c) return c ~= e:GetHandler() end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)

        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_FIELD)
        ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_CANNOT_DISABLE)
        ec2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        ec2:SetRange(LOCATION_MZONE)
        ec2:SetTargetRange(LOCATION_MZONE, 0)
        ec2:SetTarget(function(e, tc) return tc ~= c end)
        ec2:SetValue(aux.tgoval)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec2)

        for i = 1, Duel.GetCurrentChain() do
            local tgp, tg = Duel.GetChainInfo(i, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TARGET_CARDS)
            if tgp ~= tp and tg and tg:IsExists(function(c, tp) return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) end, 1, nil, tp) then
                local g = Group.FromCards(c):Merge(tg:Filter(function(c, tp)
                    return c:IsControler(tp) and not c:IsLocation(LOCATION_MZONE)
                end, nil, tp))
                Duel.ChangeTargetCard(i, g)
            end
        end

        local ac = Duel.GetAttacker()
        if ac and ac:IsControler(1 - tp) and ac:CanAttack() and ac:IsRelateToBattle() and not ac:IsImmuneToEffect(e) then
            Duel.CalculateDamage(ac, c)
        end
    end)
    c:RegisterEffect(redirect)
    local redirect2 = redirect:Clone()
    redirect2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(redirect2)
    local redirect3 = redirect:Clone()
    redirect3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(redirect3)

    -- return to where was special summon
    local spreturn = Effect.CreateEffect(c)
    spreturn:SetDescription(666002)
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

    -- summon cannot be negate
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(sumsafe)

    -- effect activation and activated effect cannot be negate
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

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

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

    -- battle position cannot be changed by effect
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

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

    -- no leave with effect
    local noleave = Effect.CreateEffect(c)
    noleave:SetType(EFFECT_TYPE_SINGLE)
    noleave:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noleave:SetCode(EFFECT_IMMUNE_EFFECT)
    noleave:SetRange(LOCATION_MZONE)
    noleave:SetValue(function(e, re)
        if not re then return false end

        local rc = re:GetHandler()
        return rc ~= e:GetHandler() and re:IsHasCategory(CATEGORY_TOHAND + CATEGORY_TODECK + CATEGORY_TOGRAVE + CATEGORY_REMOVE) and
                   (not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <= Divine.GetDivineHierarchy(c))
    end)
    c:RegisterEffect(noleave)
    local noleave_destroy = noleave:Clone()
    noleave_destroy:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    noleave_destroy:SetValue(function(e, re)
        local rc = re:GetHandler()
        return rc ~= e:GetHandler() and (not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <= Divine.GetDivineHierarchy(c))
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

function ResetEffectFilter(te, c)
    local tc = te:GetOwner()
    if tc == c or tc:ListsCode(c:GetCode()) then return false end
    return not te:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_FIELD_ONLY) and
               (te:GetTarget() == aux.PersistentTargetFilter or not te:IsHasType(EFFECT_TYPE_GRANT)) and te:GetCode() ~= EFFECT_SPSUMMON_PROC
end
