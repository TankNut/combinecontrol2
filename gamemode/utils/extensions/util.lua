util.GetModelMaterials = Memoize(function(mdl)
	local ent

	if CLIENT then
		ent = ClientsideModel(mdl)
	else
		ent = ents.Create("prop_dynamic")
		ent:SetModel(mdl)
		ent:Spawn()
		ent:Activate()
	end

	local materials = ent:GetMaterials()

	ent:Remove()

	return materials
end)

function util.SafeCopy(val)
	local valType = type(val)

	if valType == "table" then
		return IsColor(val) and val:Copy() or table.FullCopy(val)
	elseif valType == "Vector" then
		return Vector(val)
	elseif valType == "Angle" then
		return Angle(val)
	elseif valType == "VMatrix" then
		return Matrix(val)
	end

	return val
end

local typeCache = {}

for k, v in pairs(_G) do
	if string.sub(k, 1, 5) == "TYPE_" then
		typeCache[v] = k
	end
end

typeCache[0] = "TYPE_NONE"

function util.TypeIDToString(typeID)
	return typeCache[typeID] or typeCache[0]
end

-- Gmod only ever uses STEAM_0
function util.IsValidSteamID(steamid)
	return string.match(steamid, "^STEAM_0:%d:%d+$") != nil
end

function util.GetModelSkins(mdl)
	local info = util.GetModelInfo(mdl)

	return info and info.SkinCount or 1
end

local femaleModels = table.Lookup({
	"models/player/alyx.mdl",
	"models/player/mossman.mdl",
	"models/player/mossman_arctic.mdl",
	"models/player/p2_chell.mdl",
	"models/player/police_fem.mdl"
})

function util.GetModelGender(mdl)
	mdl = mdl or string.lower(mdl)

	if femaleModels[mdl] or string.find(mdl, "female") then
		return "female"
	end

	return "male"
end

function util.GetSeededColor(seed, s, v)
	math.randomseed(util.CRC(seed))

	local col = HSVToColor(math.random(360), s, v)

	math.randomseed(os.time())

	return col
end
