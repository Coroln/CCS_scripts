--Majestic Synchron
--Rundas

local s, id = GetID()
function s.initial_effect(c)
    --Special from Hand
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Search on being Material
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1, id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

function s.rescon(sg, e, tp, mg)
    return sg:FilterCount(Card.IsType, nil, TYPE_TUNER) > 0
end

function s.spcon(e, c)
	if c == nil then return true end
	local tp = c:GetControler()
	local tdg = Duel.GetMatchingGroup(Card.IsAbleToDeckAsCost, tp, LOCATION_HAND, 0, e:GetHandler())
	return aux.SelectUnselectGroup(tdg, e, tp, 1, #tdg, s.rescon, 0)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp)
	local tdg = Duel.GetMatchingGroup(Card.IsAbleToDeckAsCost, tp, LOCATION_HAND, 0, e:GetHandler())
	local g = aux.SelectUnselectGroup(tdg, e, tp, 1, #tdg, s.rescon, 1, tp, HINTMSG_TODECK, nil, nil, true)
	if #g > 0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
	local g = e:GetLabelObject()
	if not g then return end
	Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_COST)
    local ct = g:FilterCount(Card.IsType, nil, TYPE_TUNER)
	g:DeleteGroup()
    --Register Effects on SS
    local e1 = Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetOperation(s.regop(c, ct))
    c:RegisterEffect(e1)
end

function s.regop(c, ct)
    return function(e, tp, eg, ep, ev, re, r, rp)
        local restrict = false
        if ct > 0 and Duel.GetMZoneCount(tp) > 0 and Duel.IsPlayerCanSpecialSummonCount(tp, 3) and Duel.IsPlayerCanSpecialSummonMonster(tp, id - 1, 0, TYPES_TOKEN, 0, 0, 0, RACE_DRAGON, ATTRIBUTE_LIGHT, POS_FACEUP, tp) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            --Summon Token
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_LEVEL)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            e1:SetValue(-1)
            c:RegisterEffect(e1)
            local token = Duel.CreateToken(tp, id - 1)
            Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP)
            restrict = true
        end
        if ct > 1 and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
            --Make Speedy Boi unaffected
            local e2 = Effect.CreateEffect(c)
            e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
            e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
            e2:SetCode(EVENT_BE_MATERIAL)
            e2:SetCondition(s.imcon)
            e2:SetOperation(s.imop)
            c:RegisterEffect(e2)
            restrict = true
        end
        if ct > 2 and Duel.SelectYesNo(tp, aux.Stringid(id, 5)) then
            --You shall not activate
            local e3 = Effect.CreateEffect(c)
            e3:SetDescription(aux.Stringid(id, 1))
            e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            e3:SetCode(EVENT_CHAINING)
            e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
            e3:SetOperation(s.chainop)
            Duel.RegisterEffect(e3, 1 - tp)
            local e4 = Effect.CreateEffect(c)
            e4:SetDescription(aux.Stringid(id, 2))
            e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            e4:SetCode(EVENT_SPSUMMON_SUCCESS)
            e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
            e4:SetOperation(s.sumsuc)
            Duel.RegisterEffect(e4, tp)
            restrict = true
        end
        if restrict == true then
            local e4 = Effect.CreateEffect(c)
            e4:SetDescription(aux.Stringid(id, 6))
            e4:SetType(EFFECT_TYPE_FIELD)
            e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
            e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e4:SetTargetRange(1,0)
            e4:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO) end)
            e4:SetReset(RESET_PHASE|PHASE_END)
            Duel.RegisterEffect(e4, tp)
        end
    end 
end

function s.imcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
	return r == REASON_SYNCHRO and rc:IsSynchroMonster() and rc:IsInExtraMZone(tp)
end

function s.imop(e, tp, eg, ep, ev, re, r, rp)
	local sync=e:GetHandler():GetReasonCard()
	local e1 = Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e, re) return e:GetOwnerPlayer() ~= re:GetOwnerPlayer() end)
	sync:RegisterEffect(e1)
end

function s.chainop(e, tp, eg, ep, ev, re, r, rp)
	local rc = re:GetHandler()
	if ep == tp and re:IsMonsterEffect() and rc:IsType(TYPE_SYNCHRO) then
		Duel.SetChainLimit(s.chainlm)
	end
end

function s.chainlm(e, rp, tp)
	return tp == rp
end

function s.sumsuc(e, tp, eg, ep, ev, re, r, rp)
	if not re:GetHandler():IsSynchroSummoned() then return end
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
	return r == REASON_SYNCHRO
end

function s.filter(c)
    local con1 = c:IsSetCard(SET_SYNCHRON) and c:IsMonster() and c:IsType(TYPE_TUNER)
    local con2 = c:IsSetCard(SET_SYNCHRO)

	return c:IsAbleToHand() and (con1 or con2)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end