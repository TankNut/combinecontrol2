local BaseClass = inherit.Get("hud", "base")

HUD.Name = "Player Labels"

HUD.Setting = "PlayerLabels"

HUD.ExtraSettings = {
	{"Legacy", {
		Name = "    Use Legacy Mode",
		Hint = "Show labels for every player in range, not just the one you're looking at.",
		ClientOnly = true,
		Default = false,
		Validate = validate.Bool(),
		Panel = "CC_Setting_Bool",
		Dark = true
	}},
	{"ShowNames", {
		Name = "    Show Character Names",
		ClientOnly = true,
		Default = true,
		Validate = validate.Bool(),
		Panel = "CC_Setting_Bool",
		Dark = true
	}},
	{"ShowDescriptions", {
		Name = "    Show Descriptions",
		ClientOnly = true,
		Default = true,
		Validate = validate.Bool(),
		Panel = "CC_Setting_Bool",
		Dark = true
	}},
	{"ShowTyping", {
		Name = "    Show Typing Indicators",
		ClientOnly = true,
		Default = true,
		Validate = validate.Bool(),
		Panel = "CC_Setting_Bool",
		Dark = true
	}},
	{"AlwaysTyping", {
		Name = "    Always Show Typing Indicators",
		ClientOnly = true,
		Default = true,
		Validate = validate.Bool(),
		Panel = "CC_Setting_Bool",
		Dark = true
	}}
}

function HUD:Initialize()
	self.Cache = {}
end

function HUD:ShouldDraw()
	if Settings.Get("SeeAll") then
		return false
	end

	return BaseClass.ShouldDraw(self)
end

function HUD:Think()
	local ct = CurTime()
	local ft = FrameTime()

	for _, ply in player.Iterator() do
		if ply == lp then
			continue
		end

		if not self.Cache[ply] then
			self.Cache[ply] = {
				Alpha = 0,
				FadeTime = ct,
				LegacyAlpha = 0,
				LegacyFade = ct,
				Entity = ply
			}
		end

		local cache = self.Cache[ply]

		local ent = self:GetPlayer(ply)
		local canSee = lp:CanSee(ent, true)

		cache.Entity = ent

		if canSee and lp:GetEyeTrace().Entity == ent then
			cache.Alpha = math.min(cache.Alpha + ft, 1)
			cache.FadeTime = ct + 0.05
		elseif cache.FadeTime < ct then
			cache.Alpha = math.max(cache.Alpha - ft, 0)
		end

		if canSee then
			cache.LegacyAlpha = math.min(cache.LegacyAlpha + ft, 1)
			cache.LegacyFade = ct + 0.05
		elseif cache.LegacyFade < ct then
			cache.LegacyAlpha = math.max(cache.LegacyAlpha - ft, 0)
		end
	end
end

function HUD:DrawPlayer(ply, cache)
	local lines = {}
	local alpha = self:GetExtraSetting("Legacy") and cache.LegacyAlpha or cache.Alpha
	local typingAlpha = self:GetExtraSetting("AlwaysTyping") and cache.LegacyAlpha or alpha

	if alpha > 0 then
		if self:GetExtraSetting("ShowNames") then
			table.insert(lines, {
				scribe.Parse(string.format("<f=CombineControl.PlayerFont><ol><team=%s>%s", ply:Team(), ply:VisibleRPName())), alpha
			})
		end

		if self:GetExtraSetting("ShowDescriptions") then
			local desc = ply:ShortDescription()

			if #desc > 0 then
				table.insert(lines, {
					scribe.Parse("<f=CombineControl.PlayerFont><ol><c=#DCDCDC>" .. ply:ShortDescription()), alpha
				})
			end
		end
	end

	if typingAlpha > 0 and self:GetExtraSetting("ShowTyping") and ply:Typing() then
		table.insert(lines, {
			scribe.Parse("<f=CombineControl.LabelMediumItalic><ol><c=cc_normal>" .. ply:GetTypingString()), typingAlpha
		})
	end

	if #lines > 0 then
		self:AddWorldLabel(cache.Entity:EyePos() + Vector(0, 0, 10), lines)
	end
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

		if ply:IsDormant() or ply:GetNoDraw() or not ply:Alive() then
			continue
		end

		self:DrawPlayer(ply, cache)
	end
end
