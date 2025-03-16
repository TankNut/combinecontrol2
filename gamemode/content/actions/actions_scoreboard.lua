Action.Add("ScoreboardGoto", {
	Name = "Goto Player",
	ClientOnly = true,
	Priority = 100,

	Admin = true,

	NoContextEntity = true,
	Context = "Scoreboard",

	CanRun = function(self, ply) return self != ply end,
	Client = function(self, ply)
		RunConsoleCommand("rpa_goto", self:SteamID())
	end
})

Action.Add("ScoreboardBring", {
	Name = "Bring Player",
	ClientOnly = true,
	Priority = 90,

	Admin = true,

	NoContextEntity = true,
	Context = "Scoreboard",

	CanRun = function(self, ply) return self != ply end,
	Client = function(self, ply)
		RunConsoleCommand("rpa_bring", self:SteamID())
	end
})

Action.Add("ScoreboardHidden", {
	Name = "Toggle Hidden",
	ClientOnly = true,
	Priority = 80,

	Admin = true,

	NoContextEntity = true,
	Context = "Scoreboard",

	Client = function(self, ply)
		RunConsoleCommand("rpa_setcharhidden", self:SteamID(), tostring(1 - self:CharacterHidden()))
	end
})


Action.Add("ScoreboardMuted", {
	Name = "Toggle Muted",
	ClientOnly = true,
	Priority = 70,

	Admin = true,

	NoContextEntity = true,
	Context = "Scoreboard",

	Client = function(self, ply)
		RunConsoleCommand("rpa_oocmute", self:SteamID(), tostring(1 - self:OOCMuted()))
	end
})

Action.Add("ScoreboardCharacters", {
	Name = "List Characters",
	ClientOnly = true,
	Priority = 60,

	Admin = true,

	NoContextEntity = true,
	Context = "Scoreboard",

	Client = function(self, ply)
		RunConsoleCommand("rpa_listcharacters", self:SteamID())
	end
})
