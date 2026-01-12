-- General config
GM.Config.InternalName = "project-testbed" -- Used for figuring out what folder within data/combinecontrol we want to put our stuff
GM.Config.ServerName = "Project Testbed"

GM.Config.CommunityLinks = {
	{"Community Forums", "https://taconbanana.com"}
}

GM.Config.MapOverrides = {} -- Makes the script believe it's running on a different map, useful for maps with different versions but identical layouts

GM.Config.SettingCategories = {
	"Developer",
	"General",
	"Chat",
	"Controls",
	"Keybinds",
	"Hud",
	"Contributor",
	"Admin",
	"SeeAll"
}

-- Chat
GM.Config.ChatLimit = 500

-- Gameplay
GM.Config.SprintSlow = 0.5 -- By how much to slow the player down if they're sprinting in a non-forward direction
GM.Config.OverweightSlow = nil -- Whether we should limit the speed of overweight players

GM.Config.VoicelineDelay = 2 -- How much time must pass between player voicelines

GM.Config.MeleeBlockMultiplier = 0.4
GM.Config.FistBlockMultiplier = 0.7 -- It helps... a bit

GM.Config.MaxItemDescLength = 300

GM.Config.InteractRange = 82 -- Source default for +use
GM.Config.EntityRange = 256
GM.Config.PlayerSight = 1024

GM.Config.ConsciousnessRate = 0.7

GM.Config.LoneWolfCounter = 3 -- How many friendly/neutral NPC's a player can kill before being considered a lone wolf
GM.Config.NPCCalloutRadius = 256 -- Range at which an NPC will alert allies when angered

GM.Config.StashCooldown = util.Duration("15 min")
GM.Config.StashRange = 128

-- Characters
GM.Config.BaseModels = {
	-- Male
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_alfie.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_carl.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_donnie.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_fabrice.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_gilberto.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_islambek.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_john.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_jose.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_michael.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_ray.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_rob.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_yasser.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_g_yohannes.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_heretic.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/male/offduty_snippy.mdl"),
	-- Female
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_faridah.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_hank.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_katya.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_linda.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_ltd.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_miia.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_neca.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_reid.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_tequila.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_wallaby.mdl"),
	Model("models/ishi/halo_rebirth/player/offduty/female/offduty_arzu.mdl")
}

GM.Config.CharacterNameRules = {
	validate.Required(),
	validate.String(),
	validate.Min(3),
	validate.Max(40)
}

GM.Config.CharacterDescriptionRules = {
	validate.Required(),
	validate.String(),
	validate.Max(2000)
}

GM.Config.MaxCharacters = 15
GM.Config.ShortDescLength = 64

GM.Config.BotGenerator = "marine"

-- Admin stuff
GM.Config.LogLines = 200

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

	ItemCustomization = TOOLTRUST_TRUSTED, -- Can customize the name or description of an item

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
		["nocollide"] = TOOLTRUST_TRUSTED,
		["nocollideworld"] = TOOLTRUST_TRUSTED,
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
	["effects"] = 10,
	["props"] = 50,
	["ragdolls"] = 0
}

GM.Config.DonatorLimits = {
	["effects"] = 20,
	["props"] = 100,
	["ragdolls"] = 10
}

GM.Config.LimitMultipliers = {
	[TOOLTRUST_BANNED] = 0,
	[TOOLTRUST_UNTRUSTED] = 0.5,
	[TOOLTRUST_TRUSTED] = 1,
	[TOOLTRUST_ADVANCED] = 2,
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
