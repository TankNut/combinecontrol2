local PANEL = {}

function PANEL:Init()
	self:SetSize(ui.Scale(800), ui.Scale(500))

	self:SetToggleKey("gm_showhelp")
	self:SetDraggable(true)
	self:SetCloseOnPause()
	self:SetTopBar("Help Menu")

	local padding = ui.Scale(10)

	self.LeftBar = self:Add("Panel")
	self.LeftBar:DockPadding(padding, padding, padding, padding)
	self.LeftBar:SetWidth(ui.Scale(150))
	self.LeftBar:Dock(LEFT)

	self.LeftBar.Paint = function(_, w, h)
		surface.SetDrawColor(0, 0, 0, 70)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	self.MenuButtons = {}
	self.AdminButtons = {}

	self.InitialMenu = math.huge

	self.Content = self:Add("Panel")
	self.Content:DockPadding(padding, padding, padding, padding)
	self.Content:Dock(FILL)

	self:MakePopup()
	self:Center()
end

function PANEL:AddMenu(order, name, content)
	self.MenuButtons[order] = {
		Name = name,
		Content = content
	}

	if order < self.InitialMenu then
		self.InitialMenu = order
	end
end

function PANEL:AddAdminMenu(order, name, content)
	self.AdminButtons[order] = {
		Name = name,
		Content = content
	}
end

function PANEL:Populate()
	local margin = ui.Scale(5)
	local w, h = ui.Scale(64), ui.Scale(22)

	for index, option in SortedPairs(self.MenuButtons) do
		local button = self.LeftBar:Add("DButton")

		button:SetSize(w, h)
		button:DockMargin(0, 0, 0, margin)
		button:Dock(TOP)
		button:SetText(option.Name)

		button.DoClick = function()
			self:SelectMenu(option.Content)
		end
	end

	if lp:IsAdmin() then
		for index, option in SortedPairs(self.AdminButtons, true) do
			local button = self.LeftBar:Add("DButton")

			button:SetSize(w, h)
			button:DockMargin(0, margin, 0, 0)
			button:Dock(BOTTOM)
			button:SetText("ADMIN: " .. option.Name)

			button.DoClick = function()
				self:SelectMenu(option.Content)
			end
		end
	end

	self:SelectMenu(self.MenuButtons[self.InitialMenu].Content)
end

function PANEL:SelectMenu(content)
	self.Content:Clear()

	self.ContentScroll = self.Content:Add("DScrollPanel")
	self.ContentScribe = self.ContentScroll:Add("ScribeLabel")

	self.ContentScribe:Dock(TOP)
	self.ContentScribe:SetAutoStretchVertical(true)

	self.ContentScroll:SetVerticalScrollbarEnabled(true)
	self.ContentScroll:Dock(FILL)

	if isfunction(content) then
		self.ContentScribe:SetText(content())
	else
		self.ContentScribe:SetText(content)
	end
end

vgui.Register("GUI_HelpMenu", PANEL, "CC_Frame")

ui.Register("HelpMenu", function()
	local instance = vgui.Create("GUI_HelpMenu")

	hook.Run("PopulateHelpMenu", instance)

	instance:Populate()

	return instance
end, true)
