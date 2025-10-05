DEFINE_BASECLASS("CC_Frame")

local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW() * 2 / 3, ScrH() * 2 / 3)

	self:SetDraggable(true)
	self:SetCloseOnPause()

	self.Editor = self:Add("CC_CodeEditor")
	self.Editor:Dock(FILL)

	self.Editor.RunSaveCommand = function(pnl)
		netstream.Send("DevEditorSubmit", pnl:GetValue(), self.Map)
	end

	self.Editor.RunSaveAsCommand = function(pnl)
		netstream.Send("DevEditorSubmit", pnl:GetValue(), self.Map)

		self:Close()
	end

	self:MakePopup()
	self:Center()
end

function PANEL:SetText(code)
	self.Editor:SetText(code)
end

function PANEL:SetMap(map)
	self.Map = map

	if map then
		self:SetTopBar("Lua Console: " .. map)
	else
		self:SetTopBar("Lua Console: GLOBAL")
	end

	self:InvalidateLayout()
end

vgui.Register("GUI_DevEditor", PANEL, "CC_Frame")

GUI.Register("DevEditor", function(code, map)
	local instance = vgui.Create("GUI_DevEditor")

	instance:SetText(code)
	instance:SetMap(map)

	return instance
end, true)
