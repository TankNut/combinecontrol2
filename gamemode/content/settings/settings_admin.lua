local isAdmin = FindMetaTable("Player").IsAdmin

Settings.Add("HideAdminBadge", {
	Name = "Hide admin badge from players",
	Hint = "Hides your admin badge from the scoreboard for everyone except for other admins.",
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")

Settings.Add("ShowItemClass", {
	Name = "Show item class on examine",
	Hint = "Shows the spawnable item class (e.g. bag_developer) next to an item's name when examining it.",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")

Settings.Add("AdminRadio", {
	Name = "See all radio messages",
	Hint = "Lets you see radio messages sent on every frequency regardless of your own radio's settings.",
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")

Settings.Add("UnderstandLanguages", {
	Name = "Understand all character languages",
	Hint = "Lets your character understand all languages, but not speak them.",
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")

Settings.Add("ShowHiddenCharacters", {
	Name = "Show hidden characters on the scoreboard",
	Hint = "Show characters that are normally hidden from you on the scoreboard.",
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")
