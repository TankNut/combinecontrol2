local BaseClass = inherit.Get("hud", "base")

HUD.Name = "Item Labels"

HUD.Setting = "ItemLabels"

HUD.ExtraSettings = {
	{"ShowWeight", {
		Name = "    Show Weight",
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

	for item in pairs(EntityCache.Get("items")) do
		if not self.Cache[item] then
			self.Cache[item] = {
				Alpha = 0,
				FadeTime = ct,
			}
		end

		local cache = self.Cache[item]

		if lp:CanSee(item, lp:GetSightRange() * 0.5) then
			cache.Alpha = math.min(cache.Alpha + ft, 1)
			cache.FadeTime = ct + 0.05
		elseif cache.FadeTime < ct then
			cache.Alpha = math.max(cache.Alpha - ft, 0)
		end
	end
end

function HUD:DrawItem(item, cache)
	local rarity = Item.Rarities[item:GetRarity()]

	local lines = {
		{scribe.Parse(string.format("<f=CombineControl.PlayerFont><ol><c=rarity_%s>%s", rarity.Name, item:GetItemName())), cache.Alpha}
	}

	if self:GetExtraSetting("ShowWeight") then
		table.insert(lines, {
			scribe.Parse(string.format("<medium><ol><dark>Weight: %s kg", item:GetItemWeight())), cache.Alpha
		})
	end

	self:AddWorldLabel(item:WorldSpaceCenter(), lines)
end

function HUD:PaintBackground(w, h)
	if Settings.Get("SeeAll") then
		return
	end

	for item, cache in pairs(self.Cache) do
		if not IsValid(item) then
			self.Cache[item] = nil

			continue
		end

		if item:IsDormant() then
			continue
		end

		self:DrawItem(item, cache)
	end
end
