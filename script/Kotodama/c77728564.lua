--Kotodama, Essence of Words
--Coroln
local s,id=GetID()
s.kept = {[0]={},[1]={}}
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Destroy all other cards 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--neither player can control monsters with the same name
	--"card is active" marker (for adjust detection)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(id)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) end)
    c:RegisterEffect(e5)
    --Cannot Normal Summon monsters if duplicate name exists
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_CANNOT_SUMMON)
    e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e6:SetRange(LOCATION_MZONE)
    e6:SetTargetRange(1,1)
    e6:SetTarget(s.sumlimit)
    c:RegisterEffect(e6)
    --Cannot Flip Summon
    local e7=e6:Clone()
    e7:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    c:RegisterEffect(e7)
    --Prevent Special Summon in same “TCBOO style”
    local e8=e6:Clone()
    e8:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    c:RegisterEffect(e8)
    aux.GlobalCheck(s,function()
        local ge=Effect.GlobalEffect()
        ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_ADJUST)
        ge:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ge:SetOperation(s.adjustop)
        Duel.RegisterEffect(ge,0)
    end)
	--negate
	--Floodgate negate
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e9:SetCode(EVENT_CHAINING)
    e9:SetRange(LOCATION_MZONE)
    e9:SetCondition(s.negcon)
    e9:SetOperation(s.negop)
    c:RegisterEffect(e9)
	if not _G.s_spelltrap_counter then
		_G.s_spelltrap_counter = {}
	end
    if not s.global_check2 then
		s.global_check2=true

		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAIN_SOLVED)

		ge2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			local te=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
			if not te then return end

			local rc=te:GetHandler()
			if not rc or not rc:IsType(TYPE_SPELL+TYPE_TRAP) then return end

			local code=rc:GetCode()

			_G.s_spelltrap_counter[code]=(_G.s_spelltrap_counter[code] or 0)+1
		end)

		Duel.RegisterEffect(ge2,0)
	end
	--increase atk
	local e11=Effect.CreateEffect(c)
	e11:SetCategory(CATEGORY_ATKCHANGE)
	e11:SetType(EFFECT_TYPE_IGNITION)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCountLimit(1)
	e11:SetTarget(s.atktg)
	e11:SetOperation(s.atkop)
	c:RegisterEffect(e11)
end
s.listed_names={19406822}
--special summon
function s.filter(c)
	return c:IsCode(19406822) and c:IsCode(19406822)==c:IsOriginalCode(19406822)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),aux.FaceupFilter(s.filter),1,false,1,true,c,c:GetControler(),nil,false,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,aux.FaceupFilter(s.filter),1,1,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
--Destroy all other cards
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--neither player can control monsters with the same name
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
    local tp=sump
    if targetp then tp=targetp end
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_MZONE,0,1,c)
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
    local phase=Duel.GetCurrentPhase()
    if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
    if not Duel.IsExistingMatchingCard(function(c) return c:IsHasEffect(id) end,0,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
        s.kept[0]={}
        s.kept[1]={}
        return
    end
    for p=0,1 do
        local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
        local byName={}
        --group monsters by current name
        for tc in aux.Next(g) do
            local code=tc:GetCode()
            byName[code]=byName[code] or Group.CreateGroup()
            byName[code]:AddCard(tc)
        end
        for code,grp in pairs(byName) do
            if #grp>1 then
                local keep=nil
                -- if we already stored a kept monster, try to reuse it
                local keptFID=s.kept[p][code]
                if keptFID then
                    for tc in aux.Next(grp) do
                        if tc:GetFieldID()==keptFID then
                            keep=tc
                            break
                        end
                    end
                end
                -- if invalid or gone, choose again
                if not keep or not keep:IsRelateToField() then
                    Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)
                    keep=grp:Select(p,1,1,nil):GetFirst()
                    s.kept[p][code]=keep:GetFieldID()
                end
                -- send all others
                for tc in aux.Next(grp) do
                    if tc~=keep then
                        Duel.SendtoGrave(tc,REASON_RULE)
                    end
                end
                Duel.Readjust()
                return -- re-run cleanly after state change
            else
                -- cleanup cache if only 1 remains
                s.kept[p][code]=nil
            end
        end
    end
end
--negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if not (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)) then return false end
    local rc=re:GetHandler()
    if not rc then return false end
    local code=rc:GetCode()
    -- (1) field check (exclude itself)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_SZONE,LOCATION_SZONE,re:GetHandler())
    local field_check=g:IsExists(function(c)
        return c:IsCode(code) and c~=rc
    end,1,nil)
    -- (2) true activation count
    local count=_G.s_spelltrap_counter[code] or 0
    local history_check=(count>=1)
    return field_check or history_check
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local rc=re:GetHandler()
        if rc and rc:IsRelateToEffect(re) then
            Duel.Destroy(rc,REASON_EFFECT)
			--Cannot activate their effects
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3302)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			rc:RegisterEffect(e1)
        end
    end
end
--increase atk
function s.atkfilter(c,atk)
	return c:IsFaceup() and c:IsMonster()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(s.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	return g:GetClassCount(Card.GetOriginalCode)*500
end