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

local modes = {
	[HEALTH_NONE] = "Hide",
	[HEALTH_PERCENTAGE] = "Percentages",
	[HEALTH_ABSOLUTE] = "Absolute values",
	[HEALTH_ABSOLUTE_MAX] = "Absolute values and max"
}

local modeValidate = validate.InList(table.GetKeys(modes))
local modeArgs = table.Map(modes, function(...) return {...} end)

Settings.Add("SeeAllPlayersHealth", {
	Name = "    Show Health",
	ClientOnly = true,
	Default = HEALTH_PERCENTAGE,
	Validate = modeValidate,
	Panel = "CC_Setting_Dropdown",
	CanAccess = isAdmin,
	Args = modeArgs,
	Dark = true
}, "SeeAll")

Settings.Add("SeeAllPlayersArmor", {
	Name = "    Show Armor",
	ClientOnly = true,
	Default = HEALTH_PERCENTAGE,
	Validate = modeValidate,
	Panel = "CC_Setting_Dropdown",
	CanAccess = isAdmin,
	Args = modeArgs,
	Dark = true
}, "SeeAll")

Settings.Add("SeeAllItems", fallback({Name = "See Items", Dark = false}, toggle), "SeeAll")
Settings.Add("SeeAllNPCs", fallback({Name = "See NPC's", Dark = false}, toggle), "SeeAll")

HUD.Name = "SeeAll"

function HUD:ShouldAddElement()
	if not lp:IsAdmin() then
		return false
	end

	return BaseClass.ShouldAddElement(self)
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
		table.insert(lines, {
			scribe.Parse(string.format("<f=CombineControl.PlayerFont><ol><team=%s>%s", ply:Team(), ply:VisibleRPName()))
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
		local mode = Settings.Get("SeeAllPlayersHealth")

		if mode == HEALTH_PERCENTAGE then
			table.insert(health, string.format("<c=#c80000>%.0f%%", (ply:Health() / ply:GetMaxHealth()) * 100))
		elseif mode == HEALTH_ABSOLUTE then
			table.insert(health, string.format("<c=#c80000>%s", ply:Health()))
		elseif mode == HEALTH_ABSOLUTE_MAX then
			table.insert(health, string.format("<c=#c80000>%s/%s", ply:Health(), ply:GetMaxHealth()))
		end

		mode = Settings.Get("SeeAllPlayersArmor")

		if mode == HEALTH_PERCENTAGE then
			table.insert(health, string.format("<c=#003FFF>%.0f%%", math.Guard(ply:Armor() / ply:GetMaxArmor()) * 100))
		elseif mode == HEALTH_ABSOLUTE then
			table.insert(health, string.format("<c=#003FFF>%s", ply:Armor()))
		elseif mode == HEALTH_ABSOLUTE_MAX then
			table.insert(health, string.format("<c=#003FFF>%s/%s", ply:Armor(), ply:GetMaxArmor()))
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

	self:AddWorldLabel(item:WorldSpaceCenter(), {
		{scribe.Parse(string.format("<f=CombineControl.PlayerFont><ol><c=rarity_%s>%s", rarity.Name, item:GetItemName()))}
	})
end

function HUD:DrawNPC(npc)
	if not npc:Alive() then
		return
	end

	self:AddWorldLabel(npc:EyePos() + Vector(0, 0, 10), {
		{scribe.Parse("<f=CombineControl.PlayerFont><ol><c=#C8C864><lang>" .. npc:GetClass())}
	})
end

function HUD:PaintBackground(w, h)
	if Settings.Get("SeeAllPlayers") then
		for _, ply in player.Iterator() do
			if ply == lp and (not lp:ShouldDrawLocalPlayer() or lp:GetViewEntity() == lp) then
				continue
			end

			self:DrawPlayer(ply)
		end
	end

	if Settings.Get("SeeAllItems") then
		for item in EntityCache.Iterator("items") do
			self:DrawItem(item)
		end
	end

	if Settings.Get("SeeAllNPCs") then
		for npc in EntityCache.Iterator("npcs") do
			self:DrawNPC(npc)
		end
	end
end
