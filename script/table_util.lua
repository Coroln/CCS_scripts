function contains(tab,element)
	for _,value in pairs(tab) do
		if value==element then
			return true
		end
	end
	return false
end

function removeall(tab,element)
	for _,value in pairs(tab) do
		if value==element then
			table.remove(tab,value)
		end
	end
end

function filter(t,f,ex,...)
	local t2 = {}
	for _, v in ipairs(t) do
		if f(v,...) and v~=ex then 
			table.insert(t2,v)
		end
	end
	return t2
end

function filterCount(t,f,ex,...)
	return #tableFilter(t,f,ex,...)
end

function any(t,f,...)
	for _, v in ipairs(t) do
		if f(v,...) then return true end
	end
	return false
end

function all(t,f,...)
	for _, v in ipairs(t) do
		if not f(v,...) then return false end
	end
	return true
end

function forEach(t,f,...)
	for _, v in ipairs(t) do
		f(v,...)
	end
end

function concat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end