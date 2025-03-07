DEFINE_BASECLASS("CC_Frame")

local PANEL = {}

function PANEL:Init()
	self:SetDraggable(true)

	self.TopBar = self:Add("Panel")
	self.TopBar:DockPadding(5, 10, 5, 10)
	self.TopBar:Dock(TOP)

	self.TopBar.Paint = function(_, w, h)
		surface.SetDrawColor(0, 0, 0, 70)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	self.MenuButtons = {}
	self.SelectedMenu = 0

	self.Content = self:Add("Panel")
	self.Content:DockMargin(10, 10, 10, 10)
	self.Content:Dock(FILL)
end

function PANEL:Think()
	BaseClass.Think(self)

	-- self:MoveToBack()
end

function PANEL:PerformLayout(w, h)
	BaseClass.PerformLayout(self, w, h)

	self.TopBar:SetTall(50)
end

function PANEL:Populate()
	self:InvalidateLayout(true)

	local space = self.TopBar:GetWide() - 10
	local count = table.Count(self.MenuButtons)

	space = space - (count * 10)

	local width = math.floor(space / count)
	local selected = 0

	for index, option in SortedPairs(self.MenuButtons) do
		local button = self.TopBar:Add("DButton")

		button:DockMargin(5, 0, 5, 0)
		button:Dock(LEFT)
		button:SetText(option.Name)
		button:SetWide(width)

		option.Button = button

		button.DoClick = function()
			if isfunction(option.Panel) then
				option.Panel()
			else
				self:SelectMenu(index)
			end
		end

		if option.Default then
			selected = index
		end
	end

	self:SelectMenu(selected)
end

function PANEL:SelectMenu(index)
	if self.SelectedMenu == index then
		return
	end

	self.SelectedMenu = index
	self.Content:Clear()

	local option = self.MenuButtons[index]
	local panel = self.Content:Add(option.Panel)

	panel:Dock(FILL)

	self:UpdateMenuButtons()
end

function PANEL:ShouldDisableMenu(option)
	if not option.Panel then
		return true
	end

	if option.Callback and not option.Callback then
		return true
	end

	return false
end

function PANEL:UpdateMenuButtons()
	for _, option in pairs(self.MenuButtons) do
		option.Button:SetDisabled(self:ShouldDisableMenu(option))
	end
end

function PANEL:AddMenu(order, name, panel, callback, default)
	self.MenuButtons[order] = {
		Name = name,
		Panel = panel,
		Callback = callback,
		Default = default
	}
end

derma.DefineControl("CC_BaseMenu", "", PANEL, "CC_Frame")
