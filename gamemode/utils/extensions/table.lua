function table.Map(tab, func)
	local res = {}

	for k, v in pairs(tab) do
		res[k] = func(v, k)
	end

	return res
end

function table.Filter(tab, func)
	local res = {}

	if table.IsSequential(tab) then
		for k, v in ipairs(tab) do
			if func(k, v) then
				table.insert(res, v)
			end
		end
	else
		for k, v in pairs(tab) do
			if func(k, v) then
				res[k] = v
			end
		end
	end

	return res
end

function table.Lookup(tab)
	local res = {}

	for _, v in pairs(tab) do
		res[v] = true
	end

	return res
end

function table.Unique(tab)
	return table.GetKeys(table.Lookup(tab))
end

function table.Collapse(tab)
	local ret = {}

	for _, v in pairs(tab) do
		table.insert(ret, v)
	end

	return ret
end

function table.FullCopy(tab)
	local res = {}

	for k, v in pairs(tab) do
		res[k] = util.SafeCopy(v)
	end

	return res
end

function table.Cache(cache, val, callback)
	if cache[val] == nil then
		cache[val] = callback(val)
	end

	return cache[val]
end

-- Use with a table layout of tab[item] = weight
function table.WeightedRandom(tab)
	local sum = 0

	for _, chance in pairs(tab) do
		sum = sum + chance
	end

	local winner = math.random() * sum

	for key, chance in pairs(tab) do
		winner = winner - chance

		if winner <= 0 then
			return key
		end
	end
end
