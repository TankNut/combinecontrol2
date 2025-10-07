local PANEL = {}

function PANEL:Init()
	local padding = ui.Scale(10)

	self:SetDraggable(true)
	self:SetSize(ui.Scale(500), ui.Scale(600))
	self:DockPadding(padding, padding, padding, padding)

	self:SetCloseOnPause()
	self:SetTopBar("MOTD")

	self:Populate()

	self:MakePopup()
	self:Center()
end

function PANEL:Populate()
	self.ContentScroll = self:Add("DScrollPanel")
	self.ContentScribe = self.ContentScroll:Add("ScribeLabel")

	self.ContentScribe:SetText(GAMEMODE.MOTD)
	self.ContentScribe:Dock(TOP)
	self.ContentScribe:SetAutoStretchVertical(true)

	self.ContentScroll:SetVerticalScrollbarEnabled(true)
	self.ContentScroll:Dock(FILL)
end

vgui.Register("GUI_MOTD", PANEL, "CC_Frame")

ui.Register("MOTD", function()
	return vgui.Create("GUI_MOTD")
end, true)
