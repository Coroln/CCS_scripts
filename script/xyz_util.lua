function Xyz.AddTokenProcedure(c, f, lv, ct, allowtoken, alterf, desc, maxct, op, mustbemat, exchk)
    Xyz.AddProcedure(c, f, lv, ct, alterf, desc, maxct, op, mustbemat, exchk)
    local mt = c:GetMetatable()
    mt.allowtoken = allowtoken
end