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

function HUD:DrawPlayer(ply, x, y)
	if Settings.Get("SeeAllPlayersArmor") and ply:GetMaxArmor() > 0 then
		y = self:DrawLine(string.format("%s%%", ply:Armor()), "CombineControl.PlayerFont", x, y, colorArmor)
	end

	if Settings.Get("SeeAllPlayersHealth") then
		y = self:DrawLine(string.format("%s%%", ply:Health()), "CombineControl.PlayerFont", x, y, colorHealth)
	end

	if Settings.Get("SeeAllPlayersTyping") and ply:Typing() then
		y = self:DrawLine(ply:GetTypingString(), "CombineControl.LabelSmallItalic", x, y, colorNormal)
	end

	if Settings.Get("SeeAllPlayersNicks") then
		y = self:DrawLine(ply:Nick(), "CombineControl.PlayerFont", x, y, colorNick)
	end

	if Settings.Get("SeeAllPlayersNames") then
		y = self:DrawLine(ply:VisibleRPName(), "CombineControl.PlayerFont", x, y, team.GetColor(ply:Team()))
	end
end

function HUD:PaintBackground(w, h)
	if Settings.Get("SeeAllPlayers") then
		for _, ply in player.Iterator() do
			if ply == lp then
				continue
			end

			local ent = self:GetPlayer(ply)
			local pos = (ent:EyePos() + Vector(0, 0, 10)):ToScreen()

			self:DrawPlayer(ply, pos.x, pos.y)
		end
	end
end
