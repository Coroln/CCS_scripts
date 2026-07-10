Card.IsCanBeXyzMaterial = (function()
    local oldfunc = Card.IsCanBeXyzMaterial
	return function(c, xyz_monster, player, reason)
        if xyz_monster.allowtoken == nil then
            return oldfunc(c, xyz_monster, player, reason)
        end
		return xyz_monster.xyz_filter(c, xyz_monster.allowtoken(c, player, xyz_monster, reason), xyz_monster, player)
	end
end)()

Link.AddProcedure = (function()
    local oldfunc = Link.AddProcedure
	return function(c, f, min, max, specialchk, desc)
        oldfunc(c, f, min, max, specialchk, desc)
        local mt = c:GetMetatable()
        mt.link_filter = function(mc, ignorespelltrap, link, tp) return mc and (not f or f(mc, link, SUMMON_TYPE_LINK|MATERIAL_LINK, tp)) and (not (mc:IsType(TYPE_SPELL) and not mc:IsType(TYPE_TRAP)) or ignorespelltrap) end
	end
end)()

Card.IsCanBeLinkMaterial = (function()
    local oldfunc = Card.IsCanBeLinkMaterial
	return function(c, link_monster, player)
        if link_monster.allowspelltrap == nil or link_monster.link_filter == nil then
            return oldfunc(c, link_monster, player)
        end
		return link_monster.link_filter(c, link_monster.allowspelltrap(c, player, link_monster), link_monster, player)
	end
end)()