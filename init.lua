Card.IsCanBeXyzMaterial=(function()
    local oldfunc = Card.IsCanBeXyzMaterial
	return function(c, xyz_monster, player, reason)
        if xyz_monster.allowtoken == nil then
            return oldfunc(c, xyz_monster, player, reason)
        end
		return xyz_monster.xyz_filter(c, xyz_monster.allowtoken(c, player, xyz_monster, reason), xyz_monster, player)
	end
end)()