function Xyz.AddTokenProcedure(c, f, lv, ct, token_filter, alterf, desc, maxct, op, mustbemat, exchk)
    Xyz.AddProcedure(c, f, lv, ct, alterf, desc, maxct, op, mustbemat, exchk)
    local mt = c:GetMetatable()
    mt.token_filter = token_filter
end