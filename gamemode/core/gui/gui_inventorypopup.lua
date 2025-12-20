local PANEL = {}

function PANEL:Init()
	local padding = ui.Scale(10)

	self:SetSize(ui.Scale(540), ui.Scale(420))
	self:DockPadding(padding, padding, padding, padding)

	self:SetDraggable(true)
	self:SetCloseOnPause()

	self:MakePopup()
	self:Center()

	self.TheirInventory = self:Add("CC_ItemList")
	self.TheirInventory:Dock(FILL)

	self.TheirInventory:Receiver("StoreItem", function(pnl, icons, dropped)
		if not dropped then
			return
		end

		icons[1]:GetItem():RunAction(lp, "Move", pnl.Inventory.ID)
	end)

	self.TheirInventory.OnIconAdded = function(_, icon)
		icon:Droppable("TakeItem")
	end
end

function PANEL:OnClose()
	if self.Inventory then
		netstream.Send("ClearInventoryListener", self.Inventory.ID)
	end

	self:Remove()
end

function PANEL:GetInventoryName()
	local inv = self.Inventory
	local storeType = inv.StoreType
	local parent = inv:GetParent()

	if storeType == INV_PLAYER then
		return string.format("%s (%s credits)", parent:VisibleRPName(), parent:GetMoney())
	elseif storeType == INV_STASH then
		return string.format("Stash (%s)", parent:VisibleRPName())
	elseif storeType == INV_ITEM then
		return parent:GetName()
	elseif storeType == INV_ENTITY then
		return parent.PrintName
	end

	return "Unknown"
end

function PANEL:Setup(inventory)
	self.Inventory = inventory
	self.TheirInventory:Populate(inventory)
	self:SetTopBar("Inventory - " .. self:GetInventoryName())
end

vgui.Register("GUI_InventoryPopup", PANEL, "CC_Frame")

ui.Register("InventoryPopup", function(id)
	local playerMenu = ui.Get("PlayerMenu")

	if not IsValid(playerMenu) then
		playerMenu = ui.Open("PlayerMenu")
	else
		playerMenu:SelectMenu(2)
	end

	local panel = vgui.Create("GUI_InventoryPopup")
	local inventory = Inventory.Get(id)

	panel:Setup(inventory)
	panel:MoveRightOf(playerMenu, -panel:GetWide() + 40)
	panel:MoveBelow(playerMenu, -panel:GetTall() + 40)

	return panel
end)
