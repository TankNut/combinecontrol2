local isDeveloper = FindMetaTable("Player").IsDeveloper

Settings.Add("RainbowPhysgun", {
	Name = "Rainbow Physics Gun",
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isDeveloper
}, "Developer")
