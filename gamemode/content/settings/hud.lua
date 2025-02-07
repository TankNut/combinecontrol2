Settings.Add("HUD", {
	Name = "Enable HUD",
	ClientOnly = true,
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "HUD")

Settings.Add("Thirdperson", {
	Name = "Enable Thirdperson",
	ClientOnly = true,
	Default = false,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "HUD")

function GM:OnThirdpersonSettingChanged(ply, old, new)
	if new and ply:Alive() then
		ctp:Enable()
	else
		ctp:Disable()
	end
end
