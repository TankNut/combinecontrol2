DEFINE_BASECLASS("ScribeLabel")

local PANEL = {}

function PANEL:Init()
	self:SetDrawOnTop(true)
end

function PANEL:Close()
	self:Remove()
end

function PANEL:SetText(text)
	self:SetWide(ui.Scale(400))

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

	y = y - ui.Scale(50)
	y = math.min(y, ly - h - ui.Scale(10))
	y = math.max(y, ui.Scale(2))

	-- Fixes being able to be drawn off screen
	self:SetPos(math.Clamp(x - w * 0.5, 0, ScrW() - self:GetWide()), math.Clamp(y, 0, ScrH() - self:GetTall()))
end

function PANEL:Paint(w, h)
	self:PositionTooltip()

	local dis = DisableClipping(true)

	local colors = self:GetSkin().Colors

	local border = ui.Scale(4)
	local border2 = border * 2

	surface.SetDrawColor(colors.FillDark.r, colors.FillDark.g, colors.FillDark.b)
	surface.DrawRect(-border, -border, w + border2, h + border2)

	surface.SetDrawColor(colors.Border)
	surface.DrawOutlinedRect(-border, -border, w + border2, h + border2)

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

vgui.Register("CC_Tooltip", PANEL, "ScribeLabel")
