-- General config
GM.Config.InternalName = "development" -- Used for figuring out what folder within data/combinecontrol we want to put our stuff
GM.Config.ServerName = "CombineControl: Development Server"

GM.Config.CommunityLinks = {
	{"Community Forums", "http://taconbanana.com"}
}

GM.Config.MapOverrides  = {} -- Makes the script believe it's running on a different map, useful for maps with different versions but identical layouts

-- Gameplay
GM.Config.FistsHaveEffectOnPlayers = true
GM.Config.DoorRammingEnabled = true
GM.Config.UntieOnDeath = true

GM.Config.MaxItemDescLength = 300

GM.Config.PlayerSight = 1024
GM.Config.ConsciousnessRate = 0.7

-- Characters
GM.Config.CharacterNameRules = {
	validate.Required(),
	validate.String(),
	validate.Min(3),
	validate.Max(40),
	validate.AllowedCharacters("!?#abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 .-'áàâäçéèêëíìîïóòôöúùûüÿÁÀÂÄßÇÉÈÊËÍÌÎÏÓÒÔÖÚÙÛÜŸ")
}

GM.Config.CharacterDescriptionRules = {
	validate.Required(),
	validate.String(),
	validate.Max(2000)
}

GM.Config.MaxCharacters = 15
GM.Config.ShortDescLength = 64

-- AFK autokicker
GM.Config.AFKKickerEnabled = true
GM.Config.AFKPercentage = 0.90
GM.Config.AFKTime = 600

-- Admin stuff
GM.Config.DefaultLogLines = 200
GM.Config.MaxLogLines = 500

-- Sandbox
GM.Config.ToolTrust = {
	Physgun = TOOLTRUST_UNTRUSTED, -- Given a physgun
	Toolgun = TOOLTRUST_UNTRUSTED, -- Given a toolgun

	PropSpawning = TOOLTRUST_UNTRUSTED, -- Able to spawn props
	SolidProps = TOOLTRUST_TRUSTED, -- Spawned props are solid
	BypassBlacklist = TOOLTRUST_ADVANCED, -- Able to spawn blacklisted props

	EntitySpawning = TOOLTRUST_ADMIN, -- Can spawn entities
	NPCSpawning = TOOLTRUST_ADMIN, -- Can spawn NPC's
	VehicleSpawning = TOOLTRUST_ADMIN, -- Can spawn vehicles
	WeaponSpawning = TOOLTRUST_DEVELOPER, -- Can spawn/give weapons

	IgnoreOwnership = TOOLTRUST_TRUSTED, -- Can phys/toolgun other people's entities

	ToolgunPlayers = TOOLTRUST_ADVANCED, -- Can toolgun other players
	PhysgunPlayers = TOOLTRUST_ADMIN, -- Can physgun other players
	FlingEntities = TOOLTRUST_TRUSTED, -- Can fling entities (entity velocity doesn't get reset on physgun drop)

	ToolFallback = TOOLTRUST_ADVANCED, -- Default tooltrust level for tools not listed below
	Tools = { -- Per-tool tooltrust level requirements
		-- Constraints
		["axis"] = TOOLTRUST_TRUSTED,
		["ballsocket"] = TOOLTRUST_TRUSTED,
		["elastic"] = TOOLTRUST_ADVANCED,
		["hydraulic"] = TOOLTRUST_ADVANCED,
		["motor"] = TOOLTRUST_ADVANCED,
		["muscle"] = TOOLTRUST_ADVANCED,
		["pulley"] = TOOLTRUST_TRUSTED,
		["rope"] = TOOLTRUST_TRUSTED,
		["slider"] = TOOLTRUST_TRUSTED,
		["unbreakable"] = TOOLTRUST_TRUSTED,
		["weld"] = TOOLTRUST_TRUSTED,
		["winch"] = TOOLTRUST_ADVANCED,
		-- Construction
		["door"] = TOOLTRUST_TRUSTED,
		["balloon"] = TOOLTRUST_TRUSTED,
		["button"] = TOOLTRUST_TRUSTED,
		["duplicator"] = TOOLTRUST_DEVELOPER, -- Unused/hard disabled
		["dynamite"] = TOOLTRUST_ADVANCED,
		["emitter"] = TOOLTRUST_TRUSTED,
		["hoverball"] = TOOLTRUST_ADVANCED,
		["lamp"] = TOOLTRUST_UNTRUSTED,
		["light"] = TOOLTRUST_UNTRUSTED,
		["nocollide"] = TOOLTRUST_UNTRUSTED,
		["nocollideworld"] = TOOLTRUST_UNTRUSTED,
		["physprop"] = TOOLTRUST_ADVANCED,
		["remover"] = TOOLTRUST_UNTRUSTED,
		["thruster"] = TOOLTRUST_ADVANCED,
		["weight"] = TOOLTRUST_ADVANCED,
		["wheel"] = TOOLTRUST_ADVANCED,
		-- Posing
		["eyeposer"] = TOOLTRUST_TRUSTED,
		["faceposer"] = TOOLTRUST_TRUSTED,
		["finger"] = TOOLTRUST_TRUSTED,
		["inflator"] = TOOLTRUST_DEVELOPER,
		-- Render
		["camera"] = TOOLTRUST_UNTRUSTED,
		["colour"] = TOOLTRUST_UNTRUSTED,
		["material"] = TOOLTRUST_UNTRUSTED,
		["paint"] = TOOLTRUST_TRUSTED,
		["submaterial"] = TOOLTRUST_UNTRUSTED,
		["trails"] = TOOLTRUST_ADVANCED,
		-- Robotboy655
		["rb655_easy_inspector"] = TOOLTRUST_ADMIN
	}
}

-- Mostly gmod defaults, need to tweak
GM.Config.Limits = {
	["balloons"] = 100,
	["buttons"] = 50,
	["cameras"] = 10,
	["constraints"] = 1000, -- Probably too high
	["doors"] = 5,
	["dynamite"] = 10,
	["effects"] = 20,
	["emitters"] = 20,
	["hoverballs"] = 50,
	["lamps"] = 3,
	["lights"] = 5,
	["npcs"] = 10,
	["props"] = 100,
	["ragdolls"] = 2,
	["ropeconstraints"] = 20,
	["sents"] = 100,
	["thrusters"] = 50,
	["vehicles"] = 4,
	["wheels"] = 50
}

GM.Config.LimitMultipliers = {
	[TOOLTRUST_BANNED] = 0,
	[TOOLTRUST_UNTRUSTED] = 0.5,
	[TOOLTRUST_TRUSTED] = 1,
	[TOOLTRUST_ADVANCED] = 1.5,
	[TOOLTRUST_ADMIN] = -1,
	[TOOLTRUST_DEVELOPER] = -1
}

GM.Config.ProtectedEntities = {
	"prop_door_rotating",
	"^func_",
	"prop_dynamic",
	"class C_BaseEntity"
}

GM.Config.ModelBlacklist = {
	"models/maxofs2d/",
	"models/balloons/",
	"models/perftest/",
	"models/props_explosive/",
	"models/props_phx/[^/]+%.mdl",
	"models/props_phx/huge/",
	"models/props_phx/misc/",
	"models/props_phx/trains/",
	"models/shadertest/",
	"models/combine_room/combine_monitor002.mdl",
	"models/combine_room/combine_monitor003a.mdl",
	"models/cranes/crane_frame.mdl",
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_c17/metalladder003.mdl",
	"models/props_combine/breen_tube.mdl",
	"models/props_combine/combine_bunker01.mdl",
	"models/props_combine/combine_tptimer.mdl",
	"models/props_combine/prison01.mdl",
	"models/props_combine/prison01c.mdl",
	"models/props_combine/prison01b.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_junk/propane_tank001a.mdl",
	"models/props_canal/canal_bridge01.mdl",
	"models/props_canal/canal_bridge02.mdl",
	"models/props_canal/canal_bridge03a.mdl",
	"models/props_phx/amraam.mdl",
	"models/props_phx/ball.mdl",
	"models/props_phx/mk-82.mdl",
	"models/props_phx/oildrum001_explosive.mdl",
	"models/props_phx/torpedo.mdl",
	"models/props_phx/ww2bomb.mdl"
}
