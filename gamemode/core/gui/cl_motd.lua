local PANEL = {}

function PANEL:Init()
	self:SetDraggable(true)
	self:SetSize(500, 600)
	self:DockPadding(10, 10, 10, 10)

	self:SetCloseOnPause(true)
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

derma.DefineControl("GUI_MOTD", "", PANEL, "CC_Frame")

GUI.Register("MOTD", function()
	return vgui.Create("GUI_MOTD")
end, true)
