local PANEL = {}
DEFINE_BASECLASS("DModelPanel")

AccessorFunc(PANEL, "Item", "Item")
AccessorFunc(PANEL, "OrbitDistance", "OrbitDistance")

function PANEL:Init()
	self:SetSize(48, 48)
end

function PANEL:SetItem(item)
	self.Item = item
	self.Item.Panels[self] = true
	self:SetModel(item:GetModel())

	local ent = self:GetEntity()

	item:SetItemAppearance(ent)

	self:SetOrbitDistance(ent:GetModelRadius() + 75)

	local angle, fov = item:GetIconCamera()

	self:SetLookAng(angle)
	self:SetFOV(fov)
end

function PANEL:OnRemove()
	BaseClass.OnRemove(self)

	self.Item.Panels[self] = nil

	if GAMEMODE.CursorItem == self.Item then
		GAMEMODE.CursorItem = nil
	end
end

function PANEL:LayoutEntity(ent)
	self.colColor = ent:GetColor()

	local mins, maxs = ent:GetModelBounds()

	self.OrbitPoint = (mins + maxs) / 2
	self.vCamPos = self.OrbitPoint - self.aLookAngle:Forward() * self.OrbitDistance
end

function PANEL:OnCursorEntered()
	GAMEMODE.CursorItem = self.Item
end

function PANEL:OnCursorExited()
	if GAMEMODE.CursorItem and GAMEMODE.CursorItem == self.Item then
		GAMEMODE.CursorItem = nil
	end
end

function PANEL:DoDoubleClick()
	GUI.Open("ItemPopup", self.Item)
end

function PANEL:DoRightClick(category)
	self.Item:OpenActionMenu(category)
end

function PANEL:ItemUpdated()
	self:SetItem(self.Item)
end

function PANEL:Paint(w, h)
	local col = self.Item:GetHighlightColor()

	if col then
		draw.RoundedBox(8, 0, 0, w, h, col)
	end

	BaseClass.Paint(self, w, h)

	if self.Item:GetRarity() != RARITY_COMMON then
		local color = self.Item:GetRarityData().Color

		draw.NoTexture()
		surface.SetDrawColor(color.r, color.g, color.b, 230)

		draw.Circle(w - 6, h - 6, 4, 8)
		surface.DrawCircle(w - 6, h - 6, 4, 20, 20, 20, 230)
	end

	self.Item:DrawItemIcon(w, h)
end

derma.DefineControl("CC_ItemIcon", "", PANEL, "DModelPanel")
