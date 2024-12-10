function ITEM:DrawUIHighlight(x, y, w, h)
	if self:IsTemporaryItem() then
		draw.RoundedBox(8, x, y, w, h, Color(0, 127, 31, 25))
	end

	if self:IsEquipped() then
		draw.RoundedBox(8, x, y, w, h, Color(100, 160, 210, 25))
	end
end

function ITEM:IsSelected()
	return IsValid(CCP.PlayerMenu) and CCP.PlayerMenu.SelectedItem == self.ID
end

function ITEM:ConfigureModelPanel(icon)
	icon:SetModel(self:GetModel())

	local ent = icon:GetEntity()

	self:SetItemAppearance(ent)

	local tab = PositionSpawnIcon(ent, ent:GetPos())

	icon:SetFOV(tab.fov)
	icon:SetCamPos(tab.origin)
	icon:SetLookAng(tab.angles)
end

function ITEM:CreateInventoryIcon()
	local item = self
	local icon = vgui.Create("DModelPanel")
	icon.Item = item

	icon:SetSize(48, 48)

	self.Icon = icon
	self:ConfigureModelPanel(icon)

	local p = icon.Paint

	function icon:Paint(w, h)
		item:DrawUIHighlight(2, 2, w - 4, h - 4)

		p(self, w, h)
	end

	function icon:LayoutEntity()
	end

	function icon:DoRightClick(category)
		self:DoClick()

		local actions = item:GetAvailableActions(category or "Rightclick")

		if #actions < 1 then
			return
		end

		local dmenu = DermaMenu()
		dmenu:SetPos(gui.MousePos())

		for _, action in ipairs(actions) do
			local options = action.SubOptions

			if isfunction(options) then
				options = action.SubOptions(item, lp)
			end

			if options and #options > 0 then
				local parent = dmenu:AddSubMenu(action.Name)

				for _, v in ipairs(options) do
					parent:AddOption(v.Name, function()
						item:RunAction(lp, action.Name, v.Value)
					end)
				end
			else
				dmenu:AddOption(action.Name, function()
					item:RunAction(lp, action.Name)
				end)
			end
		end

		dmenu:Open()
	end

	function icon:OnCursorEntered()
		GAMEMODE.CursorItem = item
	end

	function icon:OnCursorExited()
		if GAMEMODE.CursorItem and GAMEMODE.CursorItem == item then
			GAMEMODE.CursorItem = nil
		end
	end

	return icon
end

local template = [[
<font=CombineControl.LabelBig><colour=ltgrey>%s</colour></font>
<font=CombineControl.LabelSmall><colour=white>%s</colour></font>
]]

function ITEM:DrawTooltip()
	if not self.Tooltip or self.ReloadTooltip then
		self.Tooltip = markup.Parse(string.format(template, self:GetName(), self:GetDescription()), 256)
		self.ReloadTooltip = false
	end

	local x, y = gui.MouseX() + 15 , gui.MouseY() + 5
	local w, h = self.Tooltip:Size()

	surface.SetDrawColor(0, 0, 0, 240)
	surface.DrawRect(x - 5, y - 5, w + 10, h + 10)

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawOutlinedRect(x - 5, y - 5, w + 10, h + 10)

	self.Tooltip:Draw(x, y)
end
