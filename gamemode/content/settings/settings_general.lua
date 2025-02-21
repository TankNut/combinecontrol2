Settings.Add("Newbie", {
	Name = "Mark me as an Inexperienced Roleplayer",
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "General")

Settings.Add("TransparentBackgrounds", {
	Name = "Use Transparent Backgrounds on Menus",
	ClientOnly = true,
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "General")
