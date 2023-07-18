Duel.LoadScript("customutility.lua")

STAGE_ROOKIE = 1
STAGE_CHAMPION = 2
STAGE_ULTIMATE = 3
STAGE_MEGA = 4
STAGE_ULTRA = 5

SET_DIGI = 0xC55
SET_DIGITATION = 0x1C55

if not Digimon then
	Digimon={}
end

function Digimon.AddProc(c,stage,additional_race,summon_restrictions,rookies,champions,ultimates,megas,ultras,antibody)
    if type(summon_restrictions)=='boolean' and summon_restrictions then
        c:EnableUnsummonable()
        local e = Effect.CreateEffect(c)
        e:SetType(EFFECT_TYPE_SINGLE)
        e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e:SetCode(EFFECT_SPSUMMON_CONDITION)
        e:SetValue(Digimon.digitationlimit)
        c:RegisterEffect(e)
    end
    if stage >= STAGE_MEGA then
	    c:EnableUnsummonable()
    end
    local digitations = {}
    local stage = stage or STAGE_ROOKIE
    local rookies = rookies or {}
    local champions = champions or {}
    local ultimates = ultimates or {}
    local megas = megas or {}
    local ultras = ultras or {}
    local antibody = antibody or 0
    table.insert(digitations,rookies)
    table.insert(digitations,champions)
    table.insert(digitations,ultimates)
    table.insert(digitations,megas)
    table.insert(digitations,ultras)
    local m = c:GetMetatable()
    m.digitations = digitations
    m.stage = stage
    m.antibody = antibody
    if additional_race then
        local e = Effect.CreateEffect(c)
        e:SetType(EFFECT_TYPE_SINGLE)
        e:SetCode(EFFECT_ADD_RACE)
        e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e:SetRange(LOCATION_ALL)
        e:SetValue(additional_race)
        c:RegisterEffect(e)
    end
end

function Digimon.digitationlimit(e,se,sp,st)
	local eff=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT)
	return se:GetHandler():IsSetCard(SET_DIGITATION) or eff:GetHandler():IsSetCard(SET_DIGITATION) or e:GetHandler():IsStatus(STATUS_PROC_COMPLETE)
end

function Digimon.GetStage(c)
    local m = c:GetMetatable()
    return m.stage or 0
end

function Digimon.GetXAntibody(c)
    local m = c:GetMetatable()
    return m.antibody or 0
end

function Digimon.GetDigitations(c,stage)
    local m = c:GetMetatable()
    if not m.digitations then return {} end
    if stage then return m.digitations[stage] end
    return m.digitations
end

function Digimon.CanDigivolve(c,count)
    return #Digimon.GetDigitations(c,Digimon.GetStage(c) + ct) > 0
end

function Digimon.IsExistingDigitationToSummon(c,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    local g = Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,loc,nil,e,st,tp,ignore_conditions,ignore_limit,pos)
    local ct = 0
    for _,code in ipairs(Digimon.GetDigitations(c,Digimon.GetStage(c) + count)) do
        if g:IsExists(Card.IsCode,1,nil,code) then
            ct = ct + 1
        end
    end
    return ct > 0
end

function Digimon.SelectDigitationToSummon(c,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    if not Digimon.IsExistingDigitationToSummon(c,e,tp,loc,count,st,0,1,ignore_conditions,ignore_limit,pos) then return end
    local g = Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,loc,0,nil,e,st,tp,ignore_conditions,ignore_limit,pos):Filter(Card.IsCode,nil,table.unpack(Digimon.GetDigitations(c,Digimon.GetStage(c) + count)))
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    g = g:Select(tp,1,1,nil)
    g:KeepAlive()
    return g
end

function Digimon.SummonDigitation(c,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    local g = Digimon.SelectDigitationToSummon(c,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    if g and #g>0 then Duel.SpecialSummon(g,st,tp,tp,ignore_conditions,ignore_limit,pos) end
    g:DeleteGroup()
end

function Digimon.Digivolve(c,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    local count,st,ignore_conditions,ignore_limit,pos = count or 1,st or 0,ignore_conditions or false,ignore_limit or false,pos or POS_FACEUP
    if not Digimon.IsExistingDigitationToSummon(c,e,tp,loc,st,Digimon.GetStage(c) + count,nil,ignore_conditions,ignore_limit,pos) or not Digimon.CanDigivolve(c,count) then return end
    Duel.SendtoGrave(c,REASON_EFFECT)
    Digimon.SummonDigitation(c,e,tp,loc,st,ignore_conditions,ignore_limit,pos)
end