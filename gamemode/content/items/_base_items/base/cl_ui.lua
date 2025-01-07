local equip = Color(100, 160, 210, 25)
local temp = Color(0, 127, 31, 25)

function ITEM:GetHighlightColor()
	if self:IsEquipped() then
		return equip
	end

	if self:IsTemporaryItem() then
		return temp
	end
end

function ITEM:RemovePanels()
	for panel in pairs(self.Panels) do
		panel:Remove()
	end

	table.Empty(self.Panels)
end

function ITEM:OpenActionMenu(context)
	local actions = self:GetAvailableActions(context)

	if #actions < 1 then
		return
	end

	local dmenu = DermaMenu()
	dmenu:SetPos(gui.MousePos())

	for _, action in ipairs(actions) do
		local options = action.SubOptions

		if isfunction(options) then
			options = action.SubOptions(self, lp)
		end

		if options and #options > 0 then
			local parent = dmenu:AddSubMenu(action.Name)

			for _, v in ipairs(options) do
				parent:AddOption(v.Name, function()
					self:RunAction(lp, action.ID, v.Value)
				end)
			end
		else
			dmenu:AddOption(action.Name, function()
				self:RunAction(lp, action.ID)
			end)
		end
	end

	dmenu:Open()
end

local defaultColor = Color(192, 192, 192)
local template = [[
<font=CombineControl.LabelBig><col=%s>%s</col></font>
<font=CombineControl.LabelSmall>%s</font>]]

function ITEM:GetTooltip()
	return string.format(template, self:GetRarityData().Color or defaultColor, self:GetName(), self:GetDescription())
end

function ITEM:DrawTooltip()
	if not self.Tooltip then
		self.Tooltip = scribe.Parse(self:GetTooltip(), 256)
	end

	local x, y = gui.MouseX() + 15 , gui.MouseY() + 5
	local w, h = self.Tooltip:GetSize()

	w = math.max(w, 256)

	surface.SetDrawColor(30, 30, 30, 230)
	surface.DrawRect(x - 5, y - 5, w + 10, h + 10)

	surface.SetDrawColor(20, 20, 20, 230)
	surface.DrawOutlinedRect(x - 5, y - 5, w + 10, h + 10)

	self.Tooltip:Draw(x, y)
end
