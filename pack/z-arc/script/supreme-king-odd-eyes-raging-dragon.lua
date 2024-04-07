-- Supreme King Odd-Eyes Raging Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_ODD_EYES}
s.material_setcode = {SET_ODD_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- link summon
    Link.AddProcedure(c, s.lnkmatfilter, 2, 2, s.lnkcheck)

    -- overscale
    local pensum = Effect.CreateEffect(c)
    pensum:SetType(EFFECT_TYPE_SINGLE)
    pensum:SetCode(511004423)
    c:RegisterEffect(pensum)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_LINK) == SUMMON_TYPE_LINK or (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)

    -- pendulum set
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- cannot be Tributed, or be used as a material
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    me1:SetCode(EFFECT_UNRELEASABLE_SUM)
    me1:SetRange(LOCATION_MZONE)
    me1:SetValue(1)
    c:RegisterEffect(me1)
    local me1b = me1:Clone()
    me1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(me1b)
    local me1c = me1:Clone()
    me1c:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    c:RegisterEffect(me1c)

    -- cannot return to deck
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me2:SetCode(EFFECT_CANNOT_TO_DECK)
    me2:SetRange(LOCATION_MZONE)
    me2:SetValue(1)
    c:RegisterEffect(me2)

    -- place into pendulum zone
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(2203)
    me3:SetCategory(CATEGORY_DESTROY)
    me3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me3:SetCode(EVENT_DESTROYED)
    me3:SetProperty(EFFECT_FLAG_DELAY)
    me3:SetCondition(s.me3con)
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)

    -- gain effect
    local me4 = Effect.CreateEffect(c)
    me4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    me4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    me4:SetCode(EVENT_SPSUMMON_SUCCESS)
    me4:SetCondition(s.me4con)
    me4:SetOperation(s.me4op)
    c:RegisterEffect(me4)
    local me4check = Effect.CreateEffect(c)
    me4check:SetType(EFFECT_TYPE_SINGLE)
    me4check:SetCode(EFFECT_MATERIAL_CHECK)
    me4check:SetValue(s.me4check)
    me4check:SetLabelObject(me4)
    c:RegisterEffect(me4check)

    -- indes
    local me5 = Effect.CreateEffect(c)
    me5:SetType(EFFECT_TYPE_SINGLE)
    me5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    me5:SetRange(LOCATION_MZONE)
    me5:SetCondition(s.effcon)
    me5:SetValue(aux.indoval)
    c:RegisterEffect(me5)

    -- can make a second attack
    local me6 = Effect.CreateEffect(c)
    me6:SetType(EFFECT_TYPE_SINGLE)
    me6:SetCode(EFFECT_EXTRA_ATTACK)
    me6:SetCondition(s.effcon)
    me6:SetValue(1)
    c:RegisterEffect(me6)

    -- negate & destroy
    local me7 = Effect.CreateEffect(c)
    me7:SetDescription(aux.Stringid(id, 2))
    me7:SetCategory(CATEGORY_DESTROY)
    me7:SetType(EFFECT_TYPE_IGNITION)
    me7:SetRange(LOCATION_MZONE)
    me7:SetCountLimit(1)
    me7:SetCondition(s.effcon)
    me7:SetTarget(s.me7tg)
    me7:SetOperation(s.me7op)
    c:RegisterEffect(me7)
end

function s.lnkmatfilter(c, sc, st, tp) return c:IsRace(RACE_DRAGON, sc, st, tp) end

function s.lnkcheckfilter(c, sc, st, tp) return c:IsSetCard(SET_ODD_EYES, sc, st, tp) and c:IsType(TYPE_PENDULUM, sc, st, tp) end

function s.lnkcheck(g, sc, st, tp)
    if not g:IsExists(s.lnkcheckfilter, 1, nil, sc, st, tp) then return false end

    local ritual = 0
    local fusion = 0
    local synchro = 0
    local xyz = 0
    local link = 0
    local effect = 0
    for tc in g:Iter() do
        if tc:IsType(TYPE_RITUAL) and ritual == 0 then
            ritual = 1
        elseif tc:IsType(TYPE_FUSION) and fusion == 0 then
            fusion = 1
        elseif tc:IsType(TYPE_SYNCHRO) and synchro == 0 then
            synchro = 1
        elseif tc:IsType(TYPE_XYZ) and xyz == 0 then
            xyz = 1
        elseif tc:IsType(TYPE_LINK) and link == 0 then
            link = 1
        elseif effect == 0 then
            effect = 1
        end
    end
    return ritual + fusion + synchro + xyz + link + effect > 1
end

function s.pe1filter(c)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.pe1filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil) end
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_TOFIELD, tp, s.pe1filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil)
    if #g > 0 then Duel.MoveToField(g:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
end

function s.me3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if chk == 0 then return #g > 0 end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if Duel.Destroy(g, REASON_EFFECT) > 0 and c:IsRelateToEffect(e) then Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
end

function s.me4checkfilter(c, sc) return c:IsType(TYPE_PENDULUM, sc, SUMMON_TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end

function s.me4check(e, c)
    local g = c:GetMaterial()
    if g:IsExists(s.me4checkfilter, 1, nil, c) then
        e:GetLabelObject():SetLabel(1)
    else
        e:GetLabelObject():SetLabel(0)
    end
end

function s.me4con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel() == 1 end

function s.me4op(e, tp, eg, ep, ev, re, r, rp)
    e:GetHandler():RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 1))
end

function s.effcon(e) return e:GetHandler():GetFlagEffect(id) > 0 end

function s.me7tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ng = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSpellTrap), tp, 0, LOCATION_ONFIELD, nil)
    local dg = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    if chk == 0 then return #dg > 0 end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, ng, #ng, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, dg, #dg, 0, 0)
end

function s.me7op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ng = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSpellTrap), tp, 0, LOCATION_ONFIELD, nil)
    for tc in ng:Iter() do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec1b)
        if tc:IsType(TYPE_TRAPMONSTER) then
            local ec1c = Effect.CreateEffect(c)
            ec1c:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            tc:RegisterEffect(ec1c)
        end
    end
    Duel.AdjustInstantly()

    local dg = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    local ct = Duel.Destroy(dg, REASON_EFFECT)
    if ct > 0 and c:IsFaceup() and c:IsRelateToEffect(e) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(ct * 200)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end
