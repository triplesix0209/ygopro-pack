-- Millennium Ascension
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {39913299}
s.listed_series = {SET_PALLADIUM}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- activation and effect cannot be negated
    local nonegate = Effect.CreateEffect(c)
    nonegate:SetType(EFFECT_TYPE_FIELD)
    nonegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nonegate:SetCode(EFFECT_CANNOT_INACTIVATE)
    nonegate:SetRange(LOCATION_ONFIELD)
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

    -- cannot disable summon "palladium"
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTarget(function(e, c) return c:GetOwner() == e:GetOwnerPlayer() and c:IsSetCard(SET_PALLADIUM) end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
    c:RegisterEffect(e1c)

    -- grave protect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetRange(LOCATION_FZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- "the true name" inactivatable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_INACTIVATE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e3b)

    -- add "the true name"
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PREDRAW)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- place card underneath
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_PHASE + PHASE_END)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.e5con)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- gain effect
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_ADJUST)
    e6:SetRange(LOCATION_FZONE)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e2filter(c, tp, re) return c:IsRelateToEffect(re) and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) end

function s.e2discheck(tp, ev, category, re)
    local ex, tg, ct, p, v = Duel.GetOperationInfo(ev, category)
    if tg and #tg > 0 then return tg:IsExists(s.e2filter, 1, nil, tp, re) end
    return false
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if rp == tp or not Duel.IsChainDisablable(ev) then return end

    local res = false
    if not res and s.e2discheck(tp, ev, CATEGORY_SPECIAL_SUMMON, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_REMOVE, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_TOHAND, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_TODECK, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_TOEXTRA, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_EQUIP, re) then res = true end
    if not res and s.e2discheck(tp, ev, CATEGORY_LEAVE_GRAVE, re) then res = true end

    if res then
        Utility.HintCard(e)
        Duel.NegateEffect(ev)
    end
end

function s.e3val(e, ct)
    local p = e:GetHandler():GetControler()
    local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
    local tc = te:GetHandler()
    return p == tp and tc:IsCode(39913299) and (loc & LOCATION_ONFIELD) ~= 0
end

function s.e4filter(c) return c:IsCode(39913299) and c:IsAbleToHand() end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and Duel.GetDrawCount(tp) > 0
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local dt = Duel.GetDrawCount(tp)
    if dt == 0 then return end
    _replace_count = 1
    _replace_max = dt

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_DRAW_COUNT)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_DRAW)
    Duel.RegisterEffect(ec1, tp)
    if _replace_count > _replace_max or not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e4filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, g)
        Duel.ShuffleHand(tp)
        Duel.ShuffleDeck(tp)

        if Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 then
            Duel.BreakEffect()
            Duel.ConfirmCards(tp, Duel.GetDecktopGroup(tp, 1))
        end
    end
end

function s.e5filter(c) return c:IsFieldSpell() or c:IsType(TYPE_CONTINUOUS) end

function s.e5con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(tp) end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e5filter, tp, LOCATION_DECK, 0, 1, nil) end
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e5filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then Duel.Overlay(c, g) end
end

function s.e6filter(c) return c:IsFieldSpell() or c:IsType(TYPE_CONTINUOUS) end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.e6filter, nil)
    local g = og:Filter(function(c) return c:GetFlagEffect(id) == 0 end, nil)
    if #g <= 0 then return end

    for tc in g:Iter() do
        local code = tc:GetOriginalCode()
        if not og:IsExists(function(c, code) return c:IsCode(code) and c:GetFlagEffect(id) > 0 end, 1, tc, code) then
            tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 0)
            local cid = c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD)
            local reset = Effect.CreateEffect(c)
            reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            reset:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            reset:SetCode(EVENT_ADJUST)
            reset:SetRange(LOCATION_MZONE)
            reset:SetLabel(cid)
            reset:SetLabelObject(tc)
            reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                local cid = e:GetLabel()
                local c = e:GetHandler()
                local tc = e:GetLabelObject()
                local g = c:GetOverlayGroup():Filter(function(c) return c:GetFlagEffect(id) > 0 end, nil)
                if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
                    c:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            reset:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(reset, true)
        end
    end
end
