GM.FontFace = system.IsOSX() and "Verdana" or "Tahoma"

scribe.DefaultFont = "CombineControl.LabelMedium"
scribe.DefaultColor = Color("cc_normal")

function GM:CreateFonts()
	surface.CreateFont("CombineControl.Window", {
		font = self.FontFace,
		size = 14,
		weight = 500
	})

	surface.CreateFont("CombineControl.World", {
		font = self.FontFace,
		size = 2048,
		weight = ScreenScale(7)
	})

	for name, size in pairs({Stupid = 50, Massive = 30, Giant = 22, Big = 18, Medium = 16, Small = 14, Tiny = 12}) do
		size = ui.Scale(size)

		local fontName = "CombineControl.Label" .. name

		surface.CreateFont(fontName, {
			font = self.FontFace,
			size = size,
			weight = 500
		})

		surface.CreateFont(fontName .. "Bold", {
			font = self.FontFace,
			size = size,
			weight = 1600
		})

		surface.CreateFont(fontName .. "Italic", {
			font = self.FontFace,
			size = size,
			weight = 500,
			italic = true
		})

		local COMPONENT = {
			Name = {string.lower(name)}
		}

		function COMPONENT:Push() self.Context:PushFont(fontName) end
		function COMPONENT:Pop() self.Context:PopFont() end

		scribe.Register(COMPONENT)
	end

	surface.CreateFont("CombineControl.PlayerFont", {
		font = self.FontFace,
		size = ui.Scale(17),
		weight = 700
	})

	surface.CreateFont("CombineControl.Ammo", {
		font = self.FontFace,
		size = ui.Scale(50),
		weight = 500
	})

	surface.CreateFont("CombineControl.AmmoSmall", {
		font = self.FontFace,
		size = ui.Scale(30),
		weight = 500
	})

	surface.CreateFont("CombineControl.WepSelectHeader", {
		font = self.FontFace,
		size = ui.Scale(20),
		weight = 700
	})

	surface.CreateFont("CombineControl.WepSelectWep", {
		font = self.FontFace,
		size = ui.Scale(18),
		weight = 500
	})

	surface.CreateFont("CombineControl.WepSelectInfo", {
		font = self.FontFace,
		size = ui.Scale(16),
		weight = 500
	})

	surface.CreateFont("CombineControl.ChatRadio", {
		font = "Lucida Console",
		size = ui.Scale(14),
		weight = 500
	})

	surface.CreateFont("CombineControl.ChatRadioBold", {
		font = "Lucida Console",
		size = ui.Scale(14),
		weight = 1600
	})

	surface.CreateFont("CombineControl.ChatRadioItalic", {
		font = "Lucida Console",
		size = ui.Scale(14),
		weight = 500,
		italic = true
	})

	hook.Run("CreateChatFonts")

	surface.GetFontSize:Clear()
end

local fonts = {
	[CHAT_FONT_DEFAULT] = {
		Face = GM.FontFace,
		Size = 18,
		Weight = 500
	},
	[CHAT_FONT_LEGACY] = {
		Face = "Myriad Pro",
		Size = 18,
		Weight = 500
	},
	[CHAT_FONT_TACOSCRIPT] = {
		Face = "Verdana",
		Size = 14,
		Weight = 800
	}
}

function GM:CreateChatFonts()
	local preset = fonts[Settings.Get("ChatFont")]
	local size = Settings.Get("ChatFontScale")

	surface.CreateFont("CombineControl.ChatFont", {
		font = preset.Face,
		size = preset.Size * size,
		weight = preset.Weight
	})

	surface.CreateFont("CombineControl.ChatFontBold", {
		font = preset.Face,
		size = preset.Size * size,
		weight = 1600
	})

	surface.CreateFont("CombineControl.ChatFontItalic", {
		font = preset.Face,
		size = preset.Size * size,
		weight = preset.Weight,
		italic = true
	})
end

function GM:OnChatFontSettingChanged(ply, old, new, loaded)
	hook.Run("CreateChatFonts")
end

function GM:OnChatFontScaleSettingChanged(ply, old, new)
	hook.Run("CreateChatFonts")
end

scribe.Register({
	Name = {"chat"},
	Components = {
		{"font", "CombineControl.ChatFont"},
		{"outline", "1"}
	}
}, "compound")

scribe.Register({
	Name = {"bold", "b"},
	Push = function(self) self.Context:PushFont(self.Context.Font .. "Bold") end,
	Pop = function(self) self.Context:PopFont() end
})

scribe.Register({
	Name = {"italic", "i"},
	Push = function(self) self.Context:PushFont(self.Context.Font .. "Italic") end,
	Pop = function(self) self.Context:PopFont() end
})

scribe.Register({
	Name = {"dark"},
	Components = {{"color", "cc_dark"}}
}, "compound")

scribe.Register({
	Name = {"new"},
	Components = {{"color", "cc_new"}}
}, "compound")

scribe.Register({
	Name = {"upd"},
	Components = {{"color", "cc_update"}}
}, "compound")

scribe.Register({
	Name = {"rem"},
	Components = {{"color", "cc_remove"}}
}, "compound")

scribe.Register({
	Name = {"fix"},
	Components = {{"color", "cc_fix"}}
}, "compound")
