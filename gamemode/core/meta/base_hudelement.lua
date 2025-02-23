local HUD = {}

HUD.Name = "Unnamed Hud Element"

HUD.Default = false -- Whether the element is added to the hud by default
HUD.Setting = false -- If set, will add a setting to enable-disable the hud element based on the value of CLASS.Default

HUD.ExtraSettings = {}

HUD.AlwaysDraw = false -- Whether the element draws when the hud is disabled

HUD.DrawOrder = 0

function HUD:IsValid()
	return Hud.Lookup[self.ClassName] == self
end

function HUD:ShouldAddElement()
	if self.Setting then
		return Settings.Get("Hud" .. self.Setting)
	end

	return self.Default
end

function HUD:Initialize()
end

function HUD:Think()
end

function HUD:OnRemove()
end

function HUD:GetExtraSetting(key)
	return Settings.Get("Hud" .. (self.Setting or "") .. key)
end

function HUD:GetCache(key, fallback)
	local val = Hud.Cache[key]

	return val != nil and val or fallback
end

function HUD:SetCache(key, val)
	Hud.Cache[key] = val
end

function HUD:ShouldDraw()
	if self.AlwaysDraw then
		return true
	end

	return Settings.Get("Hud")
end

function HUD:GetPlayer(ply)
	return ply:IsRagdolled() and ply:GetRagdoll() or ply
end

function HUD:DrawAlignedRect(x, y, w, h, color, xAlign, yAlign)
	if xAlign == TEXT_ALIGN_CENTER then
		x = x - w * 0.5
	elseif xAlign == TEXT_ALIGN_RIGHT then
		x = x - w
	end

	if yAlign == TEXT_ALIGN_CENTER then
		y = y - h * 0.5
	elseif yAlign == TEXT_ALIGN_BOTTOM then
		y = y - h
	end

	if color then
		surface.SetDrawColor(color)
	end

	surface.DrawRect(x, y, w, h)
end

function HUD:StartWorldLabel()
	self._Label = {}
end

function HUD:AddWorldLabel(pos, ...)
	if self._Label then
		table.insert(self._Label, Hud.WorldLabel(pos, ...))
	else
		Hud.AddWorldLabel(pos, {Hud.WorldLabel(...)})
	end
end

function HUD:EndWorldLabel(pos)
	if #self._Label > 0 then
		Hud.AddWorldLabel(pos, self._Label)
	end

	self._Label = nil
end

function HUD:Paint(w, h)
end

function HUD:PaintBackground(w, h)
end

inherit.Register("hud", "base", HUD)
