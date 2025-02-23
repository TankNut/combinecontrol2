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

Settings.Add("SeeAllItems", fallback({Name = "See Players", Dark = false}, toggle), "SeeAll")

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

local colorBlack = Color(0, 0, 0)
local colorNormal = Color("cc_normal")

local colorNick = Color(87, 165, 255)
local colorHealth = Color(200, 0, 0)
local colorArmor = Color(0, 63, 255)

function HUD:DrawLine(text, font, x, y, color)
	draw.DrawText(text, font, x + 1, y + 1, colorBlack, TEXT_ALIGN_CENTER)
	draw.DrawText(text, font, x, y, color, TEXT_ALIGN_CENTER)

	return y - 20
end

function HUD:DrawPlayer(ply)
	self:StartWorldLabel()

	if Settings.Get("SeeAllPlayersArmor") and ply:GetMaxArmor() > 0 then
		self:AddWorldLabel(ply:Armor() .. "%", "CombineControl.PlayerFont", colorArmor)
	end

	if Settings.Get("SeeAllPlayersHealth") then
		self:AddWorldLabel(ply:Health() .. "%", "CombineControl.PlayerFont", colorHealth)
	end

	if Settings.Get("SeeAllPlayersTyping") and ply:Typing() then
		self:AddWorldLabel(ply:GetTypingString(), "CombineControl.LabelSmallItalic", colorNormal)
	end

	if Settings.Get("SeeAllPlayersNicks") then
		self:AddWorldLabel(ply:Nick(), "CombineControl.PlayerFont", colorNick)
	end

	if Settings.Get("SeeAllPlayersNames") then
		self:AddWorldLabel(ply:VisibleRPName(), "CombineControl.PlayerFont", team.GetColor(ply:Team()))
	end

	self:EndWorldLabel(self:GetPlayer(ply):EyePos() + Vector(0, 0, 10))
end

function HUD:DrawItem(item)
	local rarity = Item.Rarities[item:GetRarity()]

	self:AddWorldLabel(item:WorldSpaceCenter() + Vector(0, 0, 10), item:GetItemName(), "CombineControl.PlayerFont", rarity.Color)
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
