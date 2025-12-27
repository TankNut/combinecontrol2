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
	Crouching = {Vector(-10, -10, 0), Vector(10, 10, 55), Vector(0, 0, 30)},
})

Hull.AddModel("grunt",
	Model("models/valk/haloreach/covenant/characters/grunt/grunt_player.mdl"),
	Model("models/valk/haloreach/covenant/characters/grunt/grunt_player_honor.mdl"))


-- Elites
Hull.AddType("elite", {
	Standing = {Vector(-16, -16, 0), Vector(16, 16, 85), Vector(0, 0, 70)},
	Crouching = {Vector(-16, -16, 0), Vector(16, 16, 65), Vector(0, 0, 50)},
})

Hull.AddModel("elite",
	Model("models/halo_reach/players/elite_field_marshall.mdl"),
	Model("models/halo_reach/players/elite_general.mdl"),
	Model("models/halo_reach/players/elite_minor.mdl"),
	Model("models/halo_reach/players/elite_officer.mdl"),
	Model("models/halo_reach/players/elite_ranger.mdl"),
	Model("models/halo_reach/players/elite_specops.mdl"),
	Model("models/halo_reach/players/elite_ultra.mdl"),
	Model("models/halo_reach/players/elite_zealot.mdl"))

if CLIENT then
	ctp:AddBoneOverride("models/halo_reach/players/elite", {
		head = "b_head",
		neck = "b_neck"
	})

	ctp:AddBoneOverride("models/halo_reach/characters/players/covenant/skirmisher", {
		head = "b_head",
		neck = "b_neck0"
	})
end
