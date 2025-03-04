DEFINE_BASECLASS("ScribeLabel")

local PANEL = {}

function PANEL:Init()
	self:SetDrawOnTop(true)
end

function PANEL:Close()
	self:Remove()
end

function PANEL:SetText(text)
	self:SetWide(400)

	BaseClass.SetText(self, text)

	self:SetSize(self.Scribe:GetSize())
end

function PANEL:PositionTooltip()
	if not IsValid(self.TargetPanel) then
		self:Close()

		return
	end

	self:InvalidateLayout(true)

	local x, y = input.GetCursorPos()
	local w, h = self:GetSize()

	local _, ly = self.TargetPanel:LocalToScreen(0, 0)

	y = y - 50
	y = math.min(y, ly - h - 10)

	if y < 2 then
		y = 2
	end

	-- Fixes being able to be drawn off screen
	self:SetPos(math.Clamp(x - w * 0.5, 0, ScrW() - self:GetWide()), math.Clamp(y, 0, ScrH() - self:GetTall()))
end

function PANEL:Paint(w, h)
	self:PositionTooltip()

	local dis = DisableClipping(true)

	local colors = self:GetSkin().Colors

	surface.SetDrawColor(colors.FillDark.r, colors.FillDark.g, colors.FillDark.b)
	surface.DrawRect(-4, -4, w + 8, h + 8)

	surface.SetDrawColor(colors.Border)
	surface.DrawOutlinedRect(-4, -4, w + 8, h + 8)

	DisableClipping(dis)

	BaseClass.Paint(self, w, h)
end

local convar = GetConVar("tooltip_delay")

function PANEL:OpenForPanel(panel)
	self.TargetPanel = panel
	self.OpenDelay = isnumber(panel.numTooltipDelay) and panel.numTooltipDelay or convar:GetFloat()

	self:PositionTooltip()

	-- Use the parent panel's skin
	self:SetSkin(panel:GetSkin().Name)

	if self.OpenDelay > 0 then
		self:SetVisible(false)

		timer.Simple(self.OpenDelay, function()
			if not IsValid(self) or not IsValid(panel) then
				return
			end

			self:PositionTooltip()
			self:SetVisible(true)
		end)
	end
end

derma.DefineControl("CC_Tooltip", "", PANEL, "ScribeLabel")
