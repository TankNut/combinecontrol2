-- UNSC
Hands.AddModel("models/ishi/suno/halo_rebirth/player/innie/male", {Model = Model("models/ishi/suno/halo_rebirth/player/innie/male/innie_m_arms.mdl")})
Hands.AddModel("models/ishi/suno/halo_rebirth/player/innie/female", {Model = Model("models/ishi/suno/halo_rebirth/player/innie/female/innie_f_arms.mdl")})

Hands.AddModel("models/ishi/halo_rebirth/player/marines/male", {Model = Model("models/ishi/halo_rebirth/player/marines/male/marine_m_arms.mdl")})
Hands.AddModel("models/ishi/halo_rebirth/player/marines/female", {Model = Model("models/ishi/halo_rebirth/player/marines/female/marine_f_arms.mdl")})

Hands.AddModel("models/ishi/halo_rebirth/player/offduty/male", {Model = Model("models/ishi/halo_rebirth/player/offduty/male/offduty_m_arms.mdl")})
Hands.AddModel("models/ishi/halo_rebirth/player/offduty/female", {Model = Model("models/ishi/halo_rebirth/player/offduty/female/offduty_f_arms.mdl")})

Hands.AddModel("models/ishi/halo_rebirth/player/odst/male", {Model = Model("models/ishi/halo_rebirth/player/odst/male/odst_m_arms.mdl")})
Hands.AddModel("models/ishi/halo_rebirth/player/odst/female", {Model = Model("models/ishi/halo_rebirth/player/odst/female/odst_f_arms.mdl")})


-- Spartans (INCREDIBLY BROKEN)
-- Hands.AddModel("models/models/valk/haloreach/unsc/spartan", {Model = Model("models/models/valk/haloreach/unsc/spartan/arms/c_arms_spartan.mdl")})


-- Grunts
Hands.AddModel("models/valk/haloreach/covenant/characters/grunt", {Model = Model("models/valk/haloreach/covenant/characters/grunt/grunt_hands.mdl")})

Hull.AddType("grunt", {
	Standing = {Vector(-10, -10, 0), Vector(10, 10, 55), Vector(0, 0, 42)},
	Crouching = {Vector(-10, -10, 0), Vector(10, 10, 36), Vector(0, 0, 30)},
})

Hull.AddModel("grunt", "models/valk/haloreach/covenant/characters/grunt")

-- Elites
Hull.AddType("elite", {
	Standing = {Vector(-16, -16, 0), Vector(16, 16, 85), Vector(0, 0, 70)},
	Crouching = {Vector(-16, -16, 0), Vector(16, 16, 65), Vector(0, 0, 50)},
})

Hull.AddModel("elite", "models/halo_reach/players/elite")

-- Jackals/skirmishers
Hull.AddType("jackal", {
	Standing = {Vector(-10, -10, 0), Vector(10, 10, 56), Vector(0, 0, 52)},
	Crouching = {Vector(-10, -10, 0), Vector(10, 10, 36), Vector(0, 0, 28)}
})

Hull.AddModel("jackal",
	"models/halo_reach/characters/players/covenant/jackal",
	"models/halo_reach/characters/players/covenant/skirmisher")

-- Hunters
Hull.AddType("hunter", {
	Standing = {Vector(-36, -36, 0), Vector(36, 36, 100), Vector(0, 0, 80)},
	Crouching = {Vector(-36, -36, 0), Vector(36, 36, 80), Vector(0, 0, 64)},
})

Hull.AddModel("hunter", "models/valk/haloreach/covenant/characters/hunter")

Hands.AddModel("models/valk/haloreach/covenant/characters/hunter", {Model = Model("models/valk/haloreach/covenant/characters/hunter/c_arms_hunter.mdl")})


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
