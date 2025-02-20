HUD.Name = "Player Labels"

HUD.Default = true
HUD.Setting = "PlayerLabels"

HUD.ExtraSettings = {
	{"Legacy", {
		Name = "- Use Legacy Mode",
		ClientOnly = true,
		Default = false,
		Validate = validate.Bool(),
		Panel = "CC_Setting_Bool"
	}}
}

function HUD:Initialize()
	self.Cache = {}
end

function HUD:GetEntity(ply)
	return ply:IsRagdolled() and ply:GetRagdoll() or ply
end

function HUD:IsVisible(ply)
	local ent = self:GetEntity(ply)

	if self:GetExtraSetting("Legacy") then
		return lp:CanSee(ent, true)
	else
		local tr = lp:GetEyeTrace()

		return tr.Entity == ent and (tr.Fraction * 32768) <= lp:GetSightRange()
	end
end

function HUD:Think()
	for _, ply in player.Iterator() do
		if ply == lp then
			continue
		end

		if not self.Cache[ply] then
			self.Cache[ply] = {
				Alpha = 0,
				FadeTime = CurTime()
			}
		end

		local cache = self.Cache[ply]

		if self:IsVisible(ply) then
			cache.Alpha = math.min(cache.Alpha + FrameTime(), 1)
			cache.FadeTime = CurTime() + 0.05
		elseif cache.FadeTime < CurTime() then
			cache.Alpha = math.max(cache.Alpha - FrameTime(), 0)
		end
	end
end

local colorBlack = Color(0, 0, 0)
local colorDescription = Color(220, 220, 220)

function HUD:DrawText(text, font, x, y, color, alpha)
	colorBlack.a = alpha
	draw.DrawText(text, font, x + 1, y + 1, colorBlack, TEXT_ALIGN_CENTER)

	color.a = alpha
	draw.DrawText(text, font, x, y, color, TEXT_ALIGN_CENTER)

	return y - 20
end

function HUD:DrawPlayer(ply, x, y, alpha)
	local desc = ply:ShortDescription()

	if #desc > 0 then
		y = self:DrawText(desc, "CombineControl.PlayerFont", x, y, colorDescription, alpha)
	end

	self:DrawText(ply:VisibleRPName(), "CombineControl.PlayerFont", x, y, team.GetColor(ply:Team()), alpha)
end

function HUD:PaintBackground(w, h)
	if Settings.Get("SeeAll") then
		return
	end

	for ply, cache in pairs(self.Cache) do
		if not IsValid(ply) then
			self.Cache[ply] = nil

			continue
		end

		if ply:IsDormant() or not ply:Alive() then
			continue
		end

		local ent = self:GetEntity(ply)
		local pos = (ent:EyePos() + Vector(0, 0, 10)):ToScreen()

		if not pos.visible then
			continue
		end

		self:DrawPlayer(ply, pos.x, pos.y, cache.Alpha * 255)
	end
end
