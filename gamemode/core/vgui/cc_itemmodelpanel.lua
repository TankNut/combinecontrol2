local PANEL = {}

AccessorFunc(PANEL, "FirstPerson", "FirstPerson")
AccessorFunc(PANEL, "OrbitDistance", "OrbitDistance")

function PANEL:Init()
	self.mx = 0
	self.my = 0

	self.aLookAngle = angle_zero

	self:SetOrbitDistance(100)
end

function PANEL:SetItem(item)
	self:SetModel(item:GetModel())

	local ent = self:GetEntity()

	item:SetItemAppearance(ent)

	self:SetOrbitDistance(ent:GetModelRadius() + 75)
	self:InvalidateParent(true)
	self:InvalidateLayout(true)

	local angle, fov = item:GetIconCamera()
	local ratio = self:GetWide() / self:GetTall()

	self:SetLookAng(angle)
	self:SetFOV(fov * ratio)
end

function PANEL:OnMousePressed(mousecode)
	self:SetCursor("none")
	self:MouseCapture(true)

	self.Capturing = true
	self.MouseCode = mousecode

	self:SetFirstPerson(true)
	self:CaptureMouse()
end

function PANEL:LayoutEntity(ent)
	self.colColor = ent:GetColor()

	local mins, maxs = ent:GetModelBounds()

	self.OrbitPoint = (mins + maxs) / 2
	self.vCamPos = self.OrbitPoint - self.aLookAngle:Forward() * self.OrbitDistance
end

function PANEL:Think()
	if self.Capturing then
		self:FirstPersonControls()
	end
end

function PANEL:CaptureMouse()
	local x, y = input.GetCursorPos()

	local dx = x - self.mx
	local dy = y - self.my

	local centerx, centery = self:LocalToScreen(self:GetWide() * 0.5, self:GetTall() * 0.5)

	input.SetCursorPos(centerx, centery)

	self.mx = centerx
	self.my = centery

	return dx, dy
end

function PANEL:FirstPersonControls()
	local x, y = self:CaptureMouse()

	self.aLookAngle:RotateAroundAxis(self.aLookAngle:Right(), y * -0.5)
	self.aLookAngle:RotateAroundAxis(self.aLookAngle:Up(), x * -0.5)
end

function PANEL:OnMouseWheeled(dlta)
	local scale = self:GetFOV() / 180

	self.fFOV = math.Clamp(self.fFOV + dlta * -10.0 * scale, 0.001, 179)
end

function PANEL:OnMouseReleased(mousecode)
	self:SetCursor("arrow")
	self:MouseCapture(false)

	self.Capturing = false
end

local developer = GetConVar("developer")

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 70)
	surface.DrawRect(0, 0, w, h)

	render.ClearDepth()

	DModelPanel.Paint(self, w, h)

	surface.SetDrawColor(self:GetSkin().Colors.Border)
	surface.DrawOutlinedRect(0, 0, w, h)

	if developer:GetBool() then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(w * 0.25, 0, h, h)

		local ang = Angle(self.aLookAngle)

		ang:Normalize()

		local _, y = draw.SimpleText(string.format("%.2f %.2f %.2f", ang.p, ang.y, ang.r), "BudgetLabel", 2)
		local ratio = w / h

		draw.SimpleText(string.format("%.2f", self.fFOV / ratio), "BudgetLabel", 2, y)
	end
end

vgui.Register("CC_ItemModelPanel", PANEL, "DModelPanel")
