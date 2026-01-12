local isDeveloper = FindMetaTable("Player").IsDeveloper

Settings.Add("RainbowPhysgun", {
	Name = "Enable rainbow physgun",
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isDeveloper
}, "Developer")
