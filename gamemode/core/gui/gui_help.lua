local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 500)

	self:SetToggleKey("gm_showhelp")
	self:SetDraggable(true)
	self:SetCloseOnPause(true)
	self:SetTopBar("Help Menu")

	self.LeftBar = self:Add("Panel")
	self.LeftBar:DockPadding(10, 10, 10, 10)
	self.LeftBar:SetWidth(150)
	self.LeftBar:Dock(LEFT)

	self.LeftBar.Paint = function(_, w, h)
		surface.SetDrawColor(0, 0, 0, 70)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	self.MenuButtons = {}
	self.InitialMenu = math.huge
	self.SelectedMenu = 0

	self.Content = self:Add("Panel")
	self.Content:DockPadding(10, 10, 10, 10)
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

function PANEL:Populate()
	for index, option in SortedPairs(self.MenuButtons) do
		local button = self.LeftBar:Add("DButton")

		button:DockMargin(0, 0, 0, 5)
		button:Dock(TOP)
		button:SetText(option.Name)

		button.DoClick = function()
			self:SelectMenu(index)
		end

		option.Button = button
	end

	self:SelectMenu(self.InitialMenu)
end

function PANEL:SelectMenu(index)
	if self.SelectedMenu == index then
		return
	end

	self.SelectedMenu = index
	self.Content:Clear()

	local option = self.MenuButtons[index]

	self.ContentScroll = self.Content:Add("DScrollPanel")
	self.ContentScribe = self.ContentScroll:Add("ScribeLabel")

	if isfunction(option.Content) then
		self.ContentScribe:SetText(option.Content())
	else
		self.ContentScribe:SetText(option.Content)
	end

	self.ContentScribe:Dock(TOP)
	self.ContentScribe:SetAutoStretchVertical(true)

	self.ContentScroll:SetVerticalScrollbarEnabled(true)
	self.ContentScroll:Dock(FILL)
end

derma.DefineControl("GUI_HelpMenu", "", PANEL, "CC_Frame")

GUI.Register("HelpMenu", function()
	local instance = vgui.Create("GUI_HelpMenu")

	hook.Run("PopulateHelpMenu", instance)

	instance:Populate()

	return instance
end, true)
