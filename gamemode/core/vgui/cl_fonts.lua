GM.FontFace = system.IsOSX() and "ChatFont" or "Myriad Pro"

surface.CreateFont("CombineControl.Window", {
	font = GM.FontFace,
	size = 14,
	weight = 500
})

for name, size in pairs({Stupid = 50, Massive = 30, Giant = 22, Big = 18, Medium = 16, Small = 14, Tiny = 12}) do
	local fontName = "CombineControl.Label" .. name

	surface.CreateFont(fontName, {
		font = GM.FontFace,
		size = size,
		weight = 500
	})

	surface.CreateFont(fontName .. "Bold", {
		font = GM.FontFace,
		size = size,
		weight = 1600
	})

	surface.CreateFont(fontName .. "Italic", {
		font = GM.FontFace,
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

scribe.Register({
	Name = {"chat"},
	Components = {
		{"big"},
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
	Push = function(self) self.Context:PushColor(Color("cc_dark")) end,
	Pop = function(self) self.Context:PopColor() end,
})
