local PANEL = {}

function PANEL:Init()
	self:SetSize(540, 420)
	self:DockPadding(10, 10, 10, 10)

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

		icons[1]:GetItem():RunAction(lp, "Store", pnl.Inventory.ID)
	end)

	self.TheirInventory.OnIconAdded = function(_, icon)
		icon:Droppable("TakeItem")
	end
end

function PANEL:OnClose()
	netstream.Send("ClearInventoryListener", self.Inventory.ID)

	self:Remove()
end

function PANEL:GetInventoryName()
	local storeType = self.Inventory.StoreType

	if storeType == INV_PLAYER then
		local ply = self.Inventory:GetPlayer()

		return string.format("%s (%s credits)", ply:VisibleRPName(), ply:GetMoney())
	elseif storeType == INV_ITEM then
		return self.Inventory:GetItem():GetName()
	end

	return "Unknown"
end

function PANEL:Setup(inventory)
	self.Inventory = inventory
	self.TheirInventory:Populate(inventory)
	self:SetTopBar("Inventory - " .. self:GetInventoryName())
end

derma.DefineControl("GUI_InventoryPopup", "", PANEL, "CC_Frame")

GUI.Register("InventoryPopup", function(id)
	local playerMenu = GUI.Get("PlayerMenu")

	if not IsValid(playerMenu) then
		playerMenu = GUI.Open("PlayerMenu")
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
