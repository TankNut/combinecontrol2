Settings.Add("Hud", {
	Name = "Enable Hud",
	ClientOnly = true,
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "Hud")

Settings.Add("Thirdperson", {
	Name = "Enable Thirdperson",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "Hud")

function GM:OnThirdpersonSettingChanged(ply, old, new, loaded)
	if new then
		ctp:Enable()
	else
		ctp:Disable()
	end
end

Settings.Add("WorldLabelBackgrounds", {
	Name = "World label background opacity",
	ClientOnly = true,
	Default = 0,
	Validate = {
		validate.Min(0),
		validate.Max(100)
	},
	Panel = "CC_Setting_Slider",
	Args = {
		Max = 100,
		Notches = 1
	}
}, "Hud")
