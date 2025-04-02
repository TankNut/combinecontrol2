local fonts = {
	[CHAT_FONT_DEFAULT] = "Default",
	[CHAT_FONT_LEGACY] = "Legacy",
	[CHAT_FONT_TACOSCRIPT] = "TacoScript 2"
}

local fontValidate = validate.InList(table.GetKeys(fonts))
local fontArgs = table.Map(fonts, function(...) return {...} end)

Settings.Add("ChatFont", {
	Name = "Chat Font",
	ClientOnly = true,
	Default = CHAT_FONT_DEFAULT,
	Validate = fontValidate,
	Panel = "CC_Setting_Dropdown",
	Args = fontArgs
}, "Chat")

Settings.Add("ChatFontScale", {
	Name = "Font Scale",
	ClientOnly = true,
	Default = 1.0,
	Validate = {
		validate.Min(0.5),
		validate.Max(2.0)
	},
	Panel = "CC_Setting_Slider",
	Args = {
		Min = 1.0,
		Max = 2.0,
		Decimals = 2,
		Notches = 10
	}
}, "Chat")

Settings.Add("ChatScale", {
	Name = "Window Scale",
	ClientOnly = true,
	Default = 1.0,
	Validate = {
		validate.Min(0.8),
		validate.Max(1.5)
	},
	Panel = "CC_Setting_Slider",
	Args = {
		Min = 0.8,
		Max = 1.5,
		Decimals = 2,
		Notches = 7
	}
}, "Chat")

Settings.Add("ExpandChatInput", {
	Name = "Multi-line Input Box",
	ClientOnly = true,
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool"
}, "Chat")
