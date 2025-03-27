local isAdmin = FindMetaTable("Player").IsAdmin

Settings.Add("HideAdminBadge", {
	Name = "Hide admin badge from players",
	Hint = "Prevents your admin badge from appearing next to your name on the scoreboard for all players except for other admins.",
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")

Settings.Add("ShowItemClass", {
	Name = "Show item class on examine",
	Hint = "Shows the spawnable item class (e.g., bag_developer) next to an item's given or custom name when examining an item.",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")

Settings.Add("UnderstandLanguages", {
	Name = "Understand all character languages",
	Hint = "Allows you to read all chat messages regardless of their language, but does not allow you to speak with all language commands.",
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")

Settings.Add("SeeHiddenCharacters", {
	Name = "Hide hidden characters on the scoreboard",
	Hint = "Prevents characters marked as hidden, except for your own, from appearing on the scoreboard.",
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")
