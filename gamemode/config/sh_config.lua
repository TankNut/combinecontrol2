-- Web integration
GM.MOTDURL			= ""
GM.SteamGroupURL	= ""
GM.WebsiteURL		= "http://taconbanana.com"

-- ONLY ADDONS THAT HAVE CUSTOM MODELS OR TEXTURES FOR CLIENT DOWNLOADS
-- FOR THE LOVE OF GOD DON'T FUCK IT LIKE EVERY OTHER ITERATION DID
GM.WorkshopAddons = {}

GM.WorkshopMaps = {} -- Should not be needed, maps are automatically made available for download if mounted from the workshop collection

GM.MapRedirect = {}

GM.AllowedNameCharacters = "!?#abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 .-'áàâäçéèêëíìîïóòôöúùûüÿÁÀÂÄßÇÉÈÊËÍÌÎÏÓÒÔÖÚÙÛÜŸ"
GM.MinNameLength		= 3
GM.MaxNameLength		= 40
GM.MaxDescLength		= 2000
GM.MaxCharacters		= 15

GM.WeaponRecoilMul 		= Angle(0.5, 1, 0)
GM.PlayerSight 			= 1024
GM.ConsciousnessRate 	= 0.7

GM.CitizenModels = {
	["models/tnb/heads/trp/male_01.mdl"] = 4,
	["models/tnb/heads/trp/male_02.mdl"] = 4,
	["models/tnb/heads/trp/male_03.mdl"] = 4,
	["models/tnb/heads/trp/male_04.mdl"] = 4,
	["models/tnb/heads/trp/male_05.mdl"] = 4,
	["models/tnb/heads/trp/male_06.mdl"] = 4,
	["models/tnb/heads/trp/male_07.mdl"] = 4,
	["models/tnb/heads/trp/male_08.mdl"] = 4,
	["models/tnb/heads/trp/male_09.mdl"] = 4,
	["models/tnb/heads/trp/female_01.mdl"] = 4,
	["models/tnb/heads/trp/female_02.mdl"] = 4,
	["models/tnb/heads/trp/female_03.mdl"] = 2,
	["models/tnb/heads/trp/female_04.mdl"] = 2,
	["models/tnb/heads/trp/female_05.mdl"] = 3,
	["models/tnb/heads/trp/female_38.mdl"] = 4,
	["models/tnb/heads/trp/female_53.mdl"] = 3
}

-- General Gameplay
GM.FistsHaveEffectOnPlayers	= true
GM.DoorRammingEnabled		= true
GM.UntieOnDeath				= true

GM.MaxItemDescLength 		= 300

-- AFK Autokicker
GM.AFKKickerEnabled			= true
GM.AFKPercentage			= 0.90
GM.AFKTime					= 600

-- Admin stuff
GM.DefaultLogLines 			= 200
GM.MaxLogLines 				= 500
