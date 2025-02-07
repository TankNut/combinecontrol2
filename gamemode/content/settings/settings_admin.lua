local isAdmin = FindMetaTable("Player").IsAdmin

Settings.Add("SeeAll", {
	Name = "Enable SeeAll",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")
