Settings.Add("Newbie", {
	Name = "Mark me as an Inexperienced Roleplayer",
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "General")

Settings.Add("UITransparency", {
	Name = "UI Transparency",
	ClientOnly = true,
	Default = 60,
	Validate = {
		validate.Min(0),
		validate.Max(100)
	},
	Panel = "CC_Setting_Slider",
	Args = {
		Max = 100,
		Notches = 20
	}
}, "General")

Settings.Add("EquipTogglesMenu", {
	Name = "Toggle the player menu when equipping items",
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "General")
