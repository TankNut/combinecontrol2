module("ModelData", package.seeall)

-- Using this to index
CACHE_MISS = CACHE_MISS or {}

Cache = Cache or {
	Hands = {},
	Hulls = {},
	Views = {}
}

Hands = Hands or {}
Hulls = Hulls or {}
Views = Views or {}

function ClearCache()
	for key in pairs(Cache) do
		Cache[key] = {}
	end
end

function Add(tab, matches, data)
	if not istable(matches) then
		matches = {matches}
	end

	for _, match in ipairs(matches) do
		tab[match] = data
	end
end

function Find(mdl, tab, cache)
	local cached = cache[mdl]

	if cached == CACHE_MISS then
		return
	elseif cached != nil then
		return cached
	end

	local matchLength = 0
	local match

	for model, data in SortedPairs(tab) do
		if model == mdl then
			match = data

			break
		elseif string.find(mdl, model) and #model > matchLength then
			matchLength = #model
			match = data
		end
	end

	if match == nil then
		cache[mdl] = CACHE_MISS

		return
	end

	cache[mdl] = match

	return match
end

-- Hands

function AddHands(matches, data)
	Add(Hands, matches, data)
end

function GetHands(mdl)
	local hands = Find(mdl, Hands, Cache.Hands)

	return hands and table.Copy(hands) or {
		Model = Model("models/weapons/c_arms_hev.mdl")
	}
end

-- Hulls

DefaultHull = {
	Standing = {Vector(-10, -10, 0), Vector(10, 10, 72), Vector(0, 0, 66)},
	Crouching = {Vector(-10, -10, 0), Vector(10, 10, 36), Vector(0, 0, 38)},
}

function AddHull(matches, data)
	data.Standing = data.Standing or Default.Standing
	data.Crouching = data.Crouching or data.Standing

	Add(Hulls, matches, data)
end

function GetHull(mdl)
	return Find(mdl, Hulls, Cache.Hulls) or DefaultHull
end

-- Views

function AddViews(matches, data)
	Add(Views, matches, data)
end

function GetViews(mdl)
	return Find(mdl, Views, Cache.Views) or {
		CamPos = {Vector(100, 0, 50), Vector(50, 0, 64)},
		LookAt = {Vector(0, 0, 36), Vector(0, 0, 64)}
	}
end
