local isAdmin = FindMetaTable("Player").IsAdmin

Action.Add("SeeAll", {
	Name = "Admin Utilities/Toggle SeeAll",
	ClientOnly = true,
	Priority = 10,

	Self = true,
	Context = "Admin",

	CanRun = isAdmin,
	Client = function()
		Settings.Set("SeeAll", not Settings.Get("SeeAll"))
	end
})

local settings = {
	{"SeeAllPlayers", "Toggle Players"},
	{"SeeAllItems", "Toggle Items"},
	{"SeeAllNPCs", "Toggle NPC's"}
}

for k, setting in ipairs(settings) do
	Action.Add(setting[1], {
		Name = "Admin Utilities/Toggle SeeAll/" .. setting[2],
		ClientOnly = true,
		Priority = #settings - k,

		Self = true,
		Context = "Admin",

		CanRun = isAdmin,
		Client = function()
			Settings.Set(setting[1], not Settings.Get(setting[1]))
		end
	})
end

Action.Add("EditMode", {
	Name = "Toggle Edit Mode",

	Self = true,
	Context = "Admin",

	CanRun = isAdmin,
	Client = function()
		lp:SetEditMode(not lp:EditMode())
	end,
	Callback = function(ply)
		ply:SetEditMode(not ply:EditMode())
	end
})
