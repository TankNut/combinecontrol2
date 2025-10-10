Action.Add("ScoreboardGoto", {
	Name = "Goto Player",
	ClientOnly = true,
	Priority = 100,

	Access = ACTION_ADMIN,
	Context = "Scoreboard",

	--CanRun = function(self, ply) return self != ply end,
	Client = function(self, ply)
		RunConsoleCommand("rpa_goto", self:SteamID())
	end
})

Action.Add("ScoreboardBring", {
	Name = "Bring Player",
	ClientOnly = true,
	Priority = 90,

	Access = ACTION_ADMIN,
	Context = "Scoreboard",

	--CanRun = function(self, ply) return self != ply end,
	Client = function(self, ply)
		RunConsoleCommand("rpa_bring", self:SteamID())
	end
})

Action.Add("ScoreboardHidden", {
	Name = "Toggle Hidden",
	ClientOnly = true,
	Priority = 80,

	Access = ACTION_ADMIN,
	Context = "Scoreboard",

	Client = function(self, ply)
		RunConsoleCommand("rpa_setcharhidden", self:SteamID(), not self:CharacterHidden())
	end
})

Action.Add("ScoreboardMuted", {
	Name = "Toggle Muted",
	ClientOnly = true,
	Priority = 70,

	Access = ACTION_ADMIN,
	Context = "Scoreboard",

	Client = function(self, ply)
		RunConsoleCommand("rpa_oocmute", self:SteamID(), not self:OOCMuted())
	end
})

Action.Add("ScoreboardEditInventory", {
	Name = "Edit Inventory",
	ClientOnly = true,
	Priority = 60,

	Access = ACTION_ADMIN,
	Context = "Scoreboard",

	-- CanRun = function(self, ply) return self != ply end,
	Client = function(self, ply)
		RunConsoleCommand("rpa_editinventory", self:SteamID())
	end
})

Action.Add("ScoreboardCharacterID", {
	Name = "Copy CharID",
	ClientOnly = true,
	Priority = 50,

	Access = ACTION_ADMIN,
	Context = "Scoreboard",

	Client = function(self, ply)
		lp:SendChat("NOTICE", string.format("Copied %s's Character ID (%d) to your clipboard", self:Nick(), self:CharID()))

		SetClipboardText(self:CharID())
	end
})

Action.Add("ScoreboardSteamID", {
	Name = "Copy SteamID",
	ClientOnly = true,
	Priority = 40,

	Access = ACTION_ADMIN,
	Context = "Scoreboard",

	Client = function(self, ply)
		lp:SendChat("NOTICE", string.format("Copied %s's Steam ID (%s) to your clipboard", self:Nick(), self:SteamID()))

		SetClipboardText(self:SteamID())
	end
})

Action.Add("ScoreboardCharacters", {
	Name = "List Characters",
	ClientOnly = true,
	Priority = 30,

	Access = ACTION_ADMIN,
	Context = "Scoreboard",

	Client = function(self, ply)
		RunConsoleCommand("rpa_listcharacters", self:SteamID())
	end
})
