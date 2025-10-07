local PANEL = {}
DEFINE_BASECLASS("CC_Frame")

function PANEL:Init()
	local padding = ui.Scale(10)
	local margin = ui.Scale(5)

	self:SetSize(ui.Scale(400), ui.Scale(450))
	self:DockPadding(padding, padding, padding, padding)

	self:SetDraggable(true)
	self:SetCloseOnPause()

	self.ModelPanel = self:Add("CC_ItemModelPanel")
	self.ModelPanel:Dock(TOP)
	self.ModelPanel:SetTall(ui.Scale(200))

	self.Buttons = self:Add("Panel")
	self.Buttons:DockMargin(0, margin, 0, 0)
	self.Buttons:Dock(BOTTOM)
	self.Buttons:SetTall(ui.Scale(22 * 3 + 15))

	self.Right = self.Buttons:Add("Panel")
	self.Right:Dock(RIGHT)
	self.Right:SetWide(100)

	self.DestroyButton = self.Right:Add("DButton")
	self.DestroyButton:DockMargin(0, margin, 0, 0)
	self.DestroyButton:Dock(BOTTOM)
	self.DestroyButton:SetText("Destroy")
	self.DestroyButton.DoClick = function()
		self.Item:RunAction(lp, "Destroy")
	end

	self.DropButton = self.Right:Add("DButton")
	self.DropButton:Dock(BOTTOM)
	self.DropButton:DockMargin(0, margin, 0, 0)
	self.DropButton:SetText("Drop")
	self.DropButton.DoClick = function()
		self.Item:RunAction(lp, "Drop")
	end

	self.ActionButton = self.Right:Add("DButton")
	self.ActionButton:Dock(BOTTOM)
	self.ActionButton:DockMargin(0, margin, 0, 0)
	self.ActionButton:SetText("Actions")
	self.ActionButton.DoClick = function()
		self.Item:OpenActionMenu("Examine")
	end

	self.TitleLabel = self:Add("ScribeLabel")
	self.TitleLabel:DockMargin(0, margin, 0, 0)
	self.TitleLabel:Dock(TOP)

	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:Dock(FILL)

	self.DescriptionLabel = self.Scroll:Add("ScribeLabel")

	self.DataLabel = self.Buttons:Add("DLabel")
	self.DataLabel:Dock(FILL)
	self.DataLabel:SetContentAlignment(1)
	self.DataLabel:SetFont("CombineControl.LabelTiny")
	self.DataLabel:SetTextColor(self:GetSkin().Text.Disabled)

	self:MakePopup()
	self:Center()
end

function PANEL:Setup(item)
	self.Item = item
	self.Item.Panels[self] = true

	self.ModelPanel:SetItem(item)

	self:ItemUpdated()
end

function PANEL:ItemUpdated()
	local item = self.Item
	local name = item:GetName()

	self:SetTopBar(name)

	local title = string.format("<giant><c=rarity_%s>%s", item:GetRarity(), name)

	if Settings.Get("ShowItemClass") and hook.Run("CanSpawnItem", lp, item) then
		title = title .. string.format("<small><dark>\n%s", item.ClassName)
	end

	self.TitleLabel:SetText(title)
	self.TitleLabel:SizeToContentsY()

	self.DescriptionLabel:SetWide(self.Scroll:GetWide() - ui.Scale(15))
	self.DescriptionLabel:SetText("<font=CombineControl.LabelMedium>\n" .. item:GetDescription())
	self.DescriptionLabel:SizeToContentsY()

	self.DataLabel:SetText(string.format("Weight: %s kg\nTags: %s", item:GetWeight(), table.concat(item:GetTags(), ", ")))

	self.DestroyButton:SetDisabled(not item:CanRunAction(lp, "Destroy"))
	self.DropButton:SetDisabled(not item:CanRunAction(lp, "Drop"))
	self.ActionButton:SetDisabled(#item:GetActionMenuData("Examine") < 1)
end

function PANEL:OnRemove()
	self.Item.Panels[self] = nil
end

vgui.Register("GUI_ItemPopup", PANEL, "CC_Frame")

ui.Register("ItemPopup", function(item)
	for panel in pairs(item.Panels) do
		if panel:GetName() == "GUI_ItemPopup" and panel.Item == item then
			panel:MoveToFront()

			return
		end
	end

	local panel = vgui.Create("GUI_ItemPopup")

	panel:Setup(item)

	return panel
end)
