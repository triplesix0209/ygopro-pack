-- Supreme King Servant Dragon Odd-Eyes
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_DRAGON, SET_SUPREME_KING_GATE}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- start of duel
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    startup:SetCode(EVENT_STARTUP)
    startup:SetRange(0xff)
    startup:SetOperation(s.startupop)
    Duel.RegisterEffect(startup, 0)
end

function s.startupfilter(c) return c:IsSetCard(SET_ODD_EYES) and c:IsType(TYPE_PENDULUM) and c:IsAttack(2500) end

function s.startupop(e)
    local c = e:GetHandler()
    local tp = c:GetOwner()

    local g = Duel.GetMatchingGroup(s.startupfilter, tp, LOCATION_DECK, 0, nil)
    if #g > 0 then Duel.SendtoExtraP(g, tp, REASON_EFFECT) end
end
