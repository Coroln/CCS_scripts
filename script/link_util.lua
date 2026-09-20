function Link.AddSpellTrapProcedure(c, f, min, max, st_filter, specialchk, desc)
    Link.AddProcedure(c, f, min, max, specialchk, desc)
    local mt = c:GetMetatable()
    mt.st_filter = st_filter
end