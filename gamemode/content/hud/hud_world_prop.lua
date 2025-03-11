HUD.Name = "Prop Labels"

HUD.Default = true
HUD.Setting = "PropLabels"

HUD.Offset = Vector(0, 0, 10)

function HUD:Initialize()
	self.Cache = {}
end

function HUD:Think()
	local ct = CurTime()
	local ft = FrameTime()

	for ent in pairs(EntityCache.Get("props")) do
		if not self.Cache[ent] then
			self.Cache[ent] = {
				Alpha = 0,
				FadeTime = ct,
			}
		end

		local cache = self.Cache[ent]

		-- Todo: Port over GetVisible from Eternity?
		if lp:CanSee(ent, Config.Get("EntityRange")) then
			cache.Alpha = math.min(cache.Alpha + ft, 1)
			cache.FadeTime = ct + 0.05
		elseif cache.FadeTime < ct then
			cache.Alpha = math.max(cache.Alpha - ft, 0)
		end
	end
end

function HUD:DrawPropDescription(ent, cache)
	if not ent:PropDescription() then
		return
	end

	self:AddWorldLabel(ent:WorldSpaceCenter() + self.Offset, {
		{scribe.Parse("<f=CombineControl.PlayerFont><ol>" .. ent:PropDescription()), cache.Alpha}
	})
end

function HUD:DrawOwnershipInfo(ent, cache)
	if not ent:OwnerName() then
		return
	end

	self:AddWorldLabel(ent:WorldSpaceCenter() + self.Offset, {
		{scribe.Parse("<f=CombineControl.PlayerFont><ol>" .. ent:OwnerName()), cache.Alpha},
		{scribe.Parse("<small><ol>" .. ent:OwnerID()), cache.Alpha}
	})
end

function HUD:PaintBackground(w, h)
	for ent, cache in pairs(self.Cache) do
		if not IsValid(ent) then
			self.Cache[ent] = nil

			continue
		end

		if ent:IsDormant() then
			continue
		end

		local weapon = lp:GetActiveWeapon()

		if not IsValid(weapon) or not WEAPONS_TOOLS[weapon:GetClass()] then
			self:DrawPropDescription(ent, cache)
		else
			self:DrawOwnershipInfo(ent, cache)
		end
	end
end
