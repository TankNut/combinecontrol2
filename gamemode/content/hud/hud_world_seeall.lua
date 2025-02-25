local BaseClass = inherit.Get("hud", "base")
local isAdmin = FindMetaTable("Player").IsAdmin

local toggle = {
	ClientOnly = true,
	Default = true,
	Validate = validate.Bool(),
	Panel = "CC_Setting_Bool",
	CanAccess = isAdmin,
	Dark = true
}

local fallback = function(dest, values)
	for k, v in pairs(values) do
		if dest[k] == nil then
			dest[k] = v
		end
	end

	return dest
end

Settings.Add("SeeAll", fallback({
	Name = "Enable SeeAll",
	Default = false,
	Dark = false
}, toggle), "SeeAll")

Settings.Add("SeeAllPlayers", fallback({Name = "See Players", Dark = false}, toggle), "SeeAll")
Settings.Add("SeeAllPlayersNames", fallback({Name = "    Show Character Names"}, toggle), "SeeAll")
Settings.Add("SeeAllPlayersNicks", fallback({Name = "    Show Player Names"}, toggle), "SeeAll")
Settings.Add("SeeAllPlayersTyping", fallback({Name = "    Show Typing"}, toggle), "SeeAll")
Settings.Add("SeeAllPlayersHealth", fallback({Name = "    Show Health"}, toggle), "SeeAll")
Settings.Add("SeeAllPlayersArmor", fallback({Name = "    Show Armor"}, toggle), "SeeAll")

Settings.Add("SeeAllItems", fallback({Name = "See Items", Dark = false}, toggle), "SeeAll")

HUD.Name = "SeeAll"

function HUD:Initialize()
end

function HUD:ShouldAddElement()
	return lp:IsAdmin()
end

function HUD:ShouldDraw()
	if not Settings.Get("SeeAll") then
		return false
	end

	return BaseClass.ShouldDraw(self)
end

function HUD:DrawPlayer(ply)
	local lines = {}

	if Settings.Get("SeeAllPlayersNames") then
		local color = ColorToHex(team.GetColor(ply:Team()))

		table.insert(lines, {
			scribe.Parse(string.format("<f=CombineControl.PlayerFont><ol><c=%s>%s", color, ply:VisibleRPName()))
		})
	end

	if Settings.Get("SeeAllPlayersNicks") then
		table.insert(lines, {
			scribe.Parse("<f=CombineControl.PlayerFont><ol><c=#57A5FF>" .. ply:Nick())
		})
	end

	if Settings.Get("SeeAllPlayersTyping") and ply:Typing() then
		table.insert(lines, {
			scribe.Parse("<f=CombineControl.LabelMediumItalic><ol><c=cc_normal>" .. ply:GetTypingString())
		})
	end

	do
		local health = {}

		if Settings.Get("SeeAllPlayersHealth") then
			table.insert(health, string.format("<c=#c80000>%s%%", ply:Health()))
		end

		if Settings.Get("SeeAllPlayersArmor") and ply:GetMaxArmor() > 0 then
			table.insert(health, string.format("<c=#003FFF>%s%%", ply:Armor()))
		end

		if #health > 0 then
			table.insert(lines, {
				scribe.Parse("<f=CombineControl.PlayerFont><ol>" ..  table.concat(health, " "))
			})
		end
	end

	if #lines > 0 then
		self:AddWorldLabel(self:GetPlayer(ply):EyePos() + Vector(0, 0, 10), lines)
	end
end

function HUD:DrawItem(item)
	local rarity = Item.Rarities[item:GetRarity()]

	self:AddWorldLabel(item:WorldSpaceCenter() + Vector(0, 0, 10), {
		{scribe.Parse(string.format("<f=CombineControl.PlayerFont><ol><c=rarity_%s>%s", rarity.Name, item:GetItemName()))}
	})
end

function HUD:PaintBackground(w, h)
	if Settings.Get("SeeAllPlayers") then
		for _, ply in player.Iterator() do
			if ply == lp then
				continue
			end

			self:DrawPlayer(ply)
		end
	end

	if Settings.Get("SeeAllItems") then
		for item in pairs(EntityCache.Get("items")) do
			self:DrawItem(item)
		end
	end
end
