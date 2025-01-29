-- Web integration
GM.Config.SteamGroupURL	= ""
GM.Config.WebsiteURL    = "http://taconbanana.com"

GM.Config.MapRedirect    = {}

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
	validate.Max(2000),
	validate.AllowedCharacters("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ áàâäçéèêëíìîïóòôöúùûüÿÁÀÂÄßÇÉÈÊËÍÌÎÏÓÒÔÖÚÙÛÜŸ.-0123456789',\n!?@#$%^&*(){}[]_=|\\\"><`~")
}

GM.Config.MaxCharacters = 15

GM.Config.ShortDescLength = 64

GM.Config.PlayerSight = 1024
GM.Config.ConsciousnessRate = 0.7

GM.Config.CitizenModels = {
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
GM.Config.FistsHaveEffectOnPlayers = true
GM.Config.DoorRammingEnabled = true
GM.Config.UntieOnDeath = true

GM.Config.MaxItemDescLength = 300

-- AFK Autokicker
GM.Config.AFKKickerEnabled = true
GM.Config.AFKPercentage = 0.90
GM.Config.AFKTime = 600

-- Admin stuff
GM.Config.DefaultLogLines = 200
GM.Config.MaxLogLines = 500
