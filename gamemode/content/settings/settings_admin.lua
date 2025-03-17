local isAdmin = FindMetaTable("Player").IsAdmin

Settings.Add("HideAdminBadge", {
	Name = "Hide admin badge from players",
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")

Settings.Add("ShowItemClass", {
	Name = "Show item class on examine",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")

Settings.Add("UnderstandLanguages", {
	Name = "Understand all character languages",
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")
