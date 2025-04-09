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
	Name = "Hide the player menu when equipping items",
	Private = true,
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "General")

Settings.Add("ConfirmItemDestruction", {
	Name = "Request confirmation when destroying items",
	ClientOnly = true,
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "General")

Settings.Add("AimCrosshairOnly", {
	Name = "Only show weapon crosshairs when aiming",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "General")

Settings.Add("PlayMusicVolume", {
	Name = "Played Music Volume",
	Hint = "Modifies the volume of music played by administrators.",
	ClientOnly = true,
	Default = 100,
	Validate = {
		validate.Min(0),
		validate.Max(200)
	},
	Panel = "CC_Setting_Slider",
	Args = {
		Min = 0,
		Max = 200,
		Notches = 20
	}
}, "General")

Settings.Add("PlayEffectVolume", {
	Name = "Played Effect Volume",
	Hint = "Modifies the volume of sound effects played by administrators.",
	ClientOnly = true,
	Default = 100,
	Validate = {
		validate.Min(0),
		validate.Max(200)
	},
	Panel = "CC_Setting_Slider",
	Args = {
		Min = 0,
		Max = 200,
		Notches = 20
	}
}, "General")
