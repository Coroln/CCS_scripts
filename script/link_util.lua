function Link.AddSpellTrapProcedure(c, f, min, max, allowspelltrap, specialchk, desc)
    Link.AddProcedure(c, f, min, max, specialchk, desc)
    local mt = c:GetMetatable()
    mt.allowspelltrap = allowspelltrap
end