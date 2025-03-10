local isAdmin = FindMetaTable("Player").IsAdmin

Settings.Add("ShowItemClass", {
	Name = "Show item class on examine",
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin
}, "Admin")

Settings.Add("EditMode", {
	Default = false,
	Validate = validate.Bool(),
	CanAccess = isAdmin
})
