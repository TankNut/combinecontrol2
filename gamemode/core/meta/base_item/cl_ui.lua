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

	self.Panels = {}
end

function ITEM:TriggerPanelUpdate()
	for panel in pairs(self.Panels) do
		panel:ItemUpdated()
	end
end

function ITEM:OpenActionMenu(context)
	local menuData = self:GetActionMenuData(context)

	if #menuData < 1 then
		return
	end

	local dmenu = util.BuildMenu(menuData)

	dmenu:SetSkin("CombineControl")
	dmenu:Open()
end

local template = [[<font=CombineControl.LabelGiant><col=%s>%s</col></font>

<font=CombineControl.LabelSmall>%s<reset>

<font=CombineControl.LabelSmall><col=cc_disabled>%s]]

function ITEM:GetTooltip()
	return string.format(template, "rarity_" .. self:GetRarity(),
		self:GetName(), self:GetDescription(),
		string.format("Weight: %s kg", self:GetWeight()))
end

function ITEM:DrawTooltip()
	local maxWidth = ui.Scale(256)

	local border = ui.Scale(5)
	local border2 = border * 2

	local tooltip = scribe.Parse(self:GetTooltip(), maxWidth)
	local x, y = gui.MouseX() + ui.Scale(15), gui.MouseY() + border
	local w, h = tooltip:GetSize()

	w = math.max(w, maxWidth)

	surface.SetDrawColor(30, 30, 30, 230)
	surface.DrawRect(x - border, y - border, w + border2, h + border2)

	surface.SetDrawColor(20, 20, 20, 230)
	surface.DrawOutlinedRect(x - border, y - border, w + border2, h + border2)

	tooltip:Draw(x, y)
end

function ITEM:DrawItemIcon(w, h)
end
