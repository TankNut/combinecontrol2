Settings.Add("StickyKeySensitivity", {
	Name = "Sticky key sensitivity",
	Private = true,
	Default = 0.4,
	Validate = {
		validate.Min(0.1),
		validate.Max(1)
	},
	Panel = "CC_Setting_Slider",
	Args = {
		Max = 1,
		Notches = 10,
		Decimals = 2
	}
}, "Controls")

Settings.Add("AutoWalk", {
	Name = "Double-tap sticky directional keys",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "Controls")

Settings.Add("ToggleCrouch", {
	Name = "Toggle Crouch",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "Controls")

Settings.Add("ToggleSprint", {
	Name = "Toggle Sprint",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "Controls")

Settings.Add("ToggleFreelook", {
	Name = "Toggle Freelook (+walk)",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "Controls")

Settings.Add("StickyAim", {
	Name = "Toggle aim when tapped",
	Private = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "Controls")
