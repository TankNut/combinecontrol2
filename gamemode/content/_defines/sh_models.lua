-- UNSC
ModelData.AddHands("models/ishi/suno/halo_rebirth/player/innie/male", {Model = Model("models/ishi/suno/halo_rebirth/player/innie/male/innie_m_arms.mdl")})
ModelData.AddHands("models/ishi/suno/halo_rebirth/player/innie/female", {Model = Model("models/ishi/suno/halo_rebirth/player/innie/female/innie_f_arms.mdl")})

ModelData.AddHands("models/ishi/halo_rebirth/player/marines/male", {Model = Model("models/ishi/halo_rebirth/player/marines/male/marine_m_arms.mdl")})
ModelData.AddHands("models/ishi/halo_rebirth/player/marines/female", {Model = Model("models/ishi/halo_rebirth/player/marines/female/marine_f_arms.mdl")})

ModelData.AddHands("models/ishi/halo_rebirth/player/offduty/male", {Model = Model("models/ishi/halo_rebirth/player/offduty/male/offduty_m_arms.mdl")})
ModelData.AddHands("models/ishi/halo_rebirth/player/offduty/female", {Model = Model("models/ishi/halo_rebirth/player/offduty/female/offduty_f_arms.mdl")})

ModelData.AddHands("models/ishi/halo_rebirth/player/odst/male", {Model = Model("models/ishi/halo_rebirth/player/odst/male/odst_m_arms.mdl")})
ModelData.AddHands("models/ishi/halo_rebirth/player/odst/female", {Model = Model("models/ishi/halo_rebirth/player/odst/female/odst_f_arms.mdl")})


-- Spartans (INCREDIBLY BROKEN)
-- ModelData.AddHands("models/models/valk/haloreach/unsc/spartan", {Model = Model("models/models/valk/haloreach/unsc/spartan/arms/c_arms_spartan.mdl")})

-- Grunts
local grunts = "models/valk/haloreach/covenant/characters/grunt"

ModelData.AddHands(grunts, {Model = Model("models/valk/haloreach/covenant/characters/grunt/grunt_hands.mdl")})
ModelData.AddHull(grunts, {
	Standing = {Vector(-10, -10, 0), Vector(10, 10, 55), Vector(0, 0, 42)},
	Crouching = {Vector(-10, -10, 0), Vector(10, 10, 36), Vector(0, 0, 30)}
})

ModelData.AddViews(grunts, {
	CamPos = {Vector(80, 0, 45), Vector(100, 0, 55)},
	LookAt = {Vector(0, 0, 30), Vector(10, 0, 40)}
})

-- Elites
local elites = "models/halo_reach/players/elite"

ModelData.AddHull(elites, {
	Standing = {Vector(-16, -16, 0), Vector(16, 16, 85), Vector(0, 0, 70)},
	Crouching = {Vector(-16, -16, 0), Vector(16, 16, 65), Vector(0, 0, 50)},
})

ModelData.AddViews(elites, {
	CamPos = {Vector(120, 0, 55), Vector(100, 0, 70)},
	LookAt = {Vector(0, 0, 40), Vector(10, 0, 70)},
	Sequence = "idle_all_automatic_02"
})

-- Jackals/skirmishers
local jackals = {
	"models/halo_reach/characters/players/covenant/jackal",
	"models/halo_reach/characters/players/covenant/skirmisher"
}

ModelData.AddHull(jackals, {
	Standing = {Vector(-10, -10, 0), Vector(10, 10, 56), Vector(0, 0, 52)},
	Crouching = {Vector(-10, -10, 0), Vector(10, 10, 36), Vector(0, 0, 28)}
})

ModelData.AddViews(jackals, {
	CamPos = {Vector(110, 0, 45), Vector(80, 0, 50)},
	LookAt = {Vector(0, 0, 30), Vector(18, -2, 50)},
	Sequence = "idle_all_03"
})

-- Hunters
local hunters = "models/valk/haloreach/covenant/characters/hunter"

ModelData.AddHands(hunters, {Model = Model("models/valk/haloreach/covenant/characters/hunter/c_arms_hunter.mdl")})
ModelData.AddHull(hunters, {
	Standing = {Vector(-36, -36, 0), Vector(36, 36, 100), Vector(0, 0, 80)},
	Crouching = {Vector(-36, -36, 0), Vector(36, 36, 80), Vector(0, 0, 64)}
})

ModelData.AddViews(hunters, {
	CamPos = {Vector(170, 0, 70), Vector(100, 0, 95)},
	LookAt = {Vector(0, 0, 60), Vector(25, 0, 95)}
})

-- CTP overrides
if CLIENT then
	ctp:AddBoneOverride("models/halo_reach/players/elite", {
		head = "b_head",
		neck = "b_neck"
	})

	ctp:AddBoneOverride("models/halo_reach/characters/players/covenant/jackal", {
		head = "b_head",
		neck = "b_neck0"
	})

	ctp:AddBoneOverride("models/halo_reach/characters/players/covenant/skirmisher", {
		head = "b_head",
		neck = "b_neck0"
	})
end
