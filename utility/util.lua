Duel.LoadScript("util_dimension.lua")

-- init
if not aux.UtilityProcedure then aux.UtilityProcedure = {} end
if not Utility then Utility = aux.UtilityProcedure end

-- constant
Utility.INFINITY_ATTACK = 999999

-- function
function Utility.RegisterGlobalEffect(c, eff, filter, param1, param2, param3, param4, param5)
    local g = Duel.GetMatchingGroup(filter, c:GetControler(), LOCATION_ALL, 0, nil, param1, param2, param3, param4, param5)
    for tc in aux.Next(g) do tc:RegisterEffect(eff:Clone()) end
end

function Utility.DeckEditAddCardToDeck(tp, code, condition_code, count_alias)
    if Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp, LOCATION_ALL, 0, 1, nil, code) then return end
    if condition_code ~= nil then
        if not count_alias and not Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp, LOCATION_ALL, 0, 1, nil, condition_code) then return end
        if count_alias and not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ALL, 0, 1, nil, condition_code) then return end
    end

    Duel.SendtoDeck(Duel.CreateToken(tp, code), tp, SEQ_DECKBOTTOM, REASON_RULE)
end

function Utility.DeckEditAddCardToExtraFaceup(tp, code, condition_code, count_alias)
    if Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp, LOCATION_ALL, 0, 1, nil, code) then return end
    if condition_code ~= nil then
        if not count_alias and not Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp, LOCATION_ALL, 0, 1, nil, condition_code) then return end
        if count_alias and not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ALL, 0, 1, nil, condition_code) then return end
    end

    Duel.SendtoExtraP(Duel.CreateToken(tp, code), tp, REASON_RULE)
end

function Utility.DeckEditAddCardToDimension(tp, code, condition_code, count_alias)
    if Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp, LOCATION_ALL, 0, 1, nil, code) then return end
    if condition_code ~= nil then
        if not count_alias and not Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp, LOCATION_ALL, 0, 1, nil, condition_code) then return end
        if count_alias and not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ALL, 0, 1, nil, condition_code) then return end
    end

    local c = Duel.CreateToken(tp, code)
    Dimension.SendToDimension(c, REASON_RULE)
    Dimension.AddProcedure(c)
end

function Utility.CheckActivateEffectCanApply(ec, e, tp, neglect_con, neglect_cost, copy_info)
    local te = ec:CheckActivateEffect(neglect_con, neglect_cost, copy_info)
    return Utility.CheckEffectCanApply(te, e, tp)
end

function Utility.ApplyActivateEffect(ec, e, tp, neglect_con, neglect_cost, copy_info)
    local te = ec:CheckActivateEffect(neglect_con, neglect_cost, copy_info)
    return Utility.ApplyEffect(te, e, tp)
end

function Utility.CheckEffectCanApply(te, e, tp)
    if not te then return false end
    local tg = te:GetTarget()
    if not tg then return true end
    return tg(te, tp, Group.CreateGroup(), PLAYER_NONE, 0, e, REASON_EFFECT, PLAYER_NONE, 0)
end

function Utility.ApplyEffect(te, e, tp, rc)
    Duel.ClearTargetCard()
    if not te then return false end
    if not rc then rc = te:GetHandler() end
    local tg = te:GetTarget()
    local op = te:GetOperation()

    if tg then
        tg(te, tp, Group.CreateGroup(), PLAYER_NONE, 0, e, REASON_EFFECT, PLAYER_NONE, 1)
        local ctg = Duel.GetTargetCards(e)
        if #ctg > 0 then Duel.HintSelection(ctg) end
    end
    Duel.BreakEffect()
    if rc then
        rc:CreateEffectRelation(te)
        Duel.BreakEffect()
    end

    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    if g ~= nil then for etc in aux.Next(g) do etc:CreateEffectRelation(te) end end
    if op then op(te, tp, Group.CreateGroup(), PLAYER_NONE, 0, e, REASON_EFFECT, PLAYER_NONE, 1) end

    if rc then rc:ReleaseEffectRelation(te) end
    if g ~= nil then for etc in aux.Next(g) do etc:ReleaseEffectRelation(te) end end
    Duel.BreakEffect()
    return true
end

function Utility.HintCard(target)
    local code = target
    if type(target) == "Card" then
        code = target:GetOriginalCode()
    elseif type(target) == "Effect" then
        code = target:GetHandler():GetOriginalCode()
    end
    Duel.Hint(HINT_CARD, 0, code)
end

Utility.GroupSelect = aux.FunctionWithNamedArgs(function(hintmsg, g, tp, min, max, ex, filter, check, breakcon, cancelable, e)
    -- default value
    if hintmsg == nil then hintmsg = HINTMSG_SELECT end
    if min == nil then min = 1 end
    if max == nil then max = min end
    if cancelable == nil then cancelable = false end

    -- init
    local sg = Group.CreateGroup()
    local mg = g:Clone()
    if filter ~= nil then mg = mg:Filter(filter, ex) end

    -- skip cases
    if check ~= nil and not check(mg, e, tp, mg) then return sg end
    if #mg < min then return sg end
    if #mg == min then return mg end

    -- normal select
    if check == nil then
        Duel.Hint(HINT_SELECTMSG, tp, hintmsg)
        return mg:Select(tp, min, max, cancelable, ex)
    end

    -- select unselect
    while true do
        local finishable = #sg >= min and #sg <= max and finishable
        Duel.Hint(HINT_SELECTMSG, tp, hintmsg)
        local sc = Group.SelectUnselect(mg, sg, tp, finishable, cancelable, min, max)
        if sc == nil then break end

        if sg:IsContains(sc) then
            sg:RemoveCard(sc)
            mg:AddCard(sc)
        else
            sg:AddCard(sc)
            mg:RemoveCard(sc)
        end

        if breakcon == nil then
            if #sg >= min and #sg <= max and check(sg, e, tp, mg) then break end
        else
            if breakcon(sg, e, tp, mg) then break end
        end
    end
    return sg
end, "hintmsg", "g", "tp", "min", "max", "ex", "filter", "check", "breakcon", "cancelable", "e")

function Utility.SelectMatchingCard(hintmsg, sel_player, f, player, s, o, min, max, ex, ...)
    return Utility.GroupSelect(hintmsg, Duel.GetMatchingGroup(f, player, s, o, ex, ...), sel_player, min, max, ex)
end

function Utility.IsOwnAny(f, player, ...)
    local g = Duel.GetMatchingGroup(f, player, LOCATION_ALL, LOCATION_ALL, nil, ...)
    g:Merge(Dimension.Zones(player):Filter(f, nil, ...))
    return g:IsExists(function(c) return c:GetOwner() == player end, 1, nil)
end

function Utility.GainInfinityAtk(c, reset, effect_handler)
    if not effect_handler then effect_handler = c end

    local e1 = Effect.CreateEffect(effect_handler)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(function(e)
        local c = e:GetHandler()
        local g = Duel.GetMatchingGroup(nil, 0, LOCATION_MZONE, LOCATION_MZONE, c)
        if #g == 0 then
            return Utility.INFINITY_ATTACK - c:GetAttack()
        else
            local _, val = g:GetMaxGroup(Card.GetAttack)
            if val <= Utility.INFINITY_ATTACK then
                return Utility.INFINITY_ATTACK - c:GetAttack()
            else
                return val
            end
        end
    end)
    if reset then e1:SetReset(reset) end
    c:RegisterEffect(e1)

    local e2 = Effect.CreateEffect(effect_handler)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return ep ~= tp end)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local dmg = Utility.INFINITY_ATTACK
        if Duel.GetLP(ep) > dmg then dmg = Duel.GetLP(ep) end
        Duel.ChangeBattleDamage(ep, dmg)
    end)
    if reset then e2:SetReset(reset) end
    c:RegisterEffect(e2)
end

function Utility.AvatarInfinity(root, c)
    aux.GlobalCheck(root, function()
        local id = c:GetOriginalCode()

        function AvatarFilter(c) return c:IsHasEffect(21208154) and not c:IsHasEffect(id) end

        function AvatarVal(e)
            local c = e:GetHandler()

            local atk = 0
            local g = Duel.GetMatchingGroup(function(tc) return tc:IsFaceup() and not tc:IsHasEffect(21208154) end, 0, LOCATION_MZONE, LOCATION_MZONE,
                nil)
            if #g > 0 then
                local tg, val = g:GetMaxGroup(Card.GetAttack)
                if not tg:IsExists(aux.TRUE, 1, c) then
                    g:RemoveCard(c)
                    tg, val = g:GetMaxGroup(Card.GetAttack)
                end

                atk = val
            end

            if atk >= c:GetBaseAttack() then
                if atk >= Utility.INFINITY_ATTACK then
                    return atk
                else
                    return atk + 100
                end
            else
                return c:GetBaseAttack()
            end
        end

        local avataratk = Effect.CreateEffect(c)
        avataratk:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        avataratk:SetCode(EVENT_ADJUST)
        avataratk:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return Duel.IsExistingMatchingCard(AvatarFilter, tp, 0xff, 0xff, 1, nil) end)
        avataratk:SetOperation(function(e, tp, eg, ev, ep, re, r, rp)
            local g = Duel.GetMatchingGroup(AvatarFilter, tp, 0xff, 0xff, nil)
            for tc in aux.Next(g) do
                local eff = Effect.CreateEffect(tc)
                eff:SetType(EFFECT_TYPE_SINGLE)
                eff:SetCode(id)
                tc:RegisterEffect(eff)

                local atkteffs = {tc:GetCardEffect(EFFECT_SET_ATTACK_FINAL)}
                for _, eff in ipairs(atkteffs) do
                    if eff:GetOwner() == tc and eff:IsHasProperty(EFFECT_FLAG_REPEAT) then eff:SetValue(AvatarVal) end
                end

                local defteffs = {tc:GetCardEffect(EFFECT_SET_DEFENSE_FINAL)}
                for _, eff in ipairs(defteffs) do
                    if eff:GetOwner() == tc and eff:IsHasProperty(EFFECT_FLAG_REPEAT) then eff:SetValue(AvatarVal) end
                end
            end
        end)
        Duel.RegisterEffect(avataratk, 0)
    end)
end

function Utility.RegisterMultiEffect(s, index, eff)
    if not s.effects then s.effects = {} end
    s.effects[index] = eff
end

function Utility.MultiEffectTarget(s, extg)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            for i = 1, #s.effects, 1 do
                if not s.effects[i]:GetTarget() or s.effects[i]:GetTarget()(e, tp, eg, ep, ev, re, r, rp, chk) then return true end
            end
            return false
        end

        local opt = {}
        local sel = {}
        for i = 1, #s.effects, 1 do
            if not s.effects[i]:GetTarget() or s.effects[i]:GetTarget()(e, tp, eg, ep, ev, re, r, rp, 0) then
                table.insert(opt, s.effects[i]:GetDescription())
                table.insert(sel, i)
            end
        end
        local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]

        e:SetCategory(e:GetCategory() + s.effects[op]:GetCategory())
        e:SetProperty(e:GetProperty() + s.effects[op]:GetProperty())
        if s.effects[op]:GetTarget() then s.effects[op]:GetTarget()(e, tp, eg, ep, ev, re, r, rp, chk) end

        s.sel_effect = op
        if extg then extg(e, tp, eg, ep, ev, re, r, rp, chk) end
    end
end

function Utility.MultiEffectOperation(s)
    return function(e, tp, eg, ep, ev, re, r, rp) s.effects[s.sel_effect]:GetOperation()(e, tp, eg, ep, ev, re, r, rp) end
end

function Utility.GetListEffect(c, filter, ...)
    local res = {}
    local effect_codes = {...}

    if #effect_codes == 0 then
        local effects = {c:GetCardEffect()}
        for _, effect in ipairs(effects) do if filter == nil or filter(effect, c) then res[#res + 1] = effect end end
    else
        for _, effect_code in ipairs(effect_codes) do
            local effects = {c:GetCardEffect(effect_code)}
            for _, effect in ipairs(effects) do if filter == nil or filter(effect, c) then res[#res + 1] = effect end end
        end
    end

    return #res == 0 and nil or res
end

function Utility.ResetListEffect(c, filter, ...)
    local effect_codes = {...}

    if #effect_codes == 0 then
        local effects = {c:GetCardEffect()}
        for _, effect in ipairs(effects) do if filter == nil or filter(effect, c) then ResetEffect(c, effect) end end
    else
        for _, effect_code in ipairs(effect_codes) do
            local effects = {c:GetCardEffect(effect_code)}
            for _, effect in ipairs(effects) do if filter == nil or filter(effect, c) then ResetEffect(c, effect) end end
        end
    end
end

function ResetEffect(c, e)
    if e:IsHasType(EFFECT_TYPE_FIELD) then
        local reset = Effect.CreateEffect(c)
        reset:SetType(EFFECT_TYPE_SINGLE)
        reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
        reset:SetCode(EFFECT_IMMUNE_EFFECT)
        reset:SetRange(LOCATION_MZONE)
        reset:SetLabelObject(e)
        reset:SetValue(function(e, te) return te == e:GetLabelObject() end)
        reset:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(reset)
    else
        e:Reset()
    end
end
