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
	local tooltip = scribe.Parse(self:GetTooltip(), 256)
	local x, y = gui.MouseX() + 15 , gui.MouseY() + 5
	local w, h = tooltip:GetSize()

	w = math.max(w, 256)

	surface.SetDrawColor(30, 30, 30, 230)
	surface.DrawRect(x - 5, y - 5, w + 10, h + 10)

	surface.SetDrawColor(20, 20, 20, 230)
	surface.DrawOutlinedRect(x - 5, y - 5, w + 10, h + 10)

	tooltip:Draw(x, y)
end

function ITEM:DrawItemIcon(w, h)
end
