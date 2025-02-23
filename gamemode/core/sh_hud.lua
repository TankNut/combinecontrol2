module("Hud", package.seeall)

List = List or {}

function Register(name, hud)
	List[name] = inherit.Register("hud", name, hud, hud.Base or "base")

	if hud.Setting then
		Settings.Add("Hud" .. hud.Setting, {
			Name = "Draw " .. hud.Name,
			ClientOnly = true,
			Default = true,
			Validate = validate.Bool(),
			Panel = "CC_Setting_Bool"
		}, "Hud")

		if CLIENT then
			hook.Add("OnHud" .. hud.Setting .. "SettingChanged", "hud", Rebuild)
		end
	end

	if hud.ExtraSettings then
		for _, setting in ipairs(hud.ExtraSettings) do
			Settings.Add("Hud" .. (hud.Setting or "") .. setting[1], setting[2], "Hud")
		end
	end
end

function RegisterFolder(dir)
	file.Iterate(dir, "_hud.lua", "LUA", function(path, folder)
		if SERVER then
			AddCSLuaFile(path)

			return
		end

		local name = string.FileName(path)

		if name == "_hud" then
			name = string.FileName(folder)
		end

		_G.HUD = {}

		include(path)

		Register(string.gsub(name, "^hud_", ""), HUD)

		HUD = nil
	end)
end

if SERVER then
	return
end

Active = Active or {}
Lookup = Lookup or {}

Labels = {}

function Event(name, ...)
	for _, element in ipairs(Active) do
		local func = element["On" .. name .. "Event"]

		if func then
			func(element, ...)
		end
	end
end

function Clear()
	for _, element in ipairs(Active) do
		element:OnRemove()
	end

	Active = {}
	Lookup = {}
end

function Add(id)
	assert(Rebuilding, "Cannot use Hud.Add outside of GM:GetHudElements")
	assert(List[id], "Attempt to add unknown hud type: " .. id)

	Rebuilding[id] = true
end

function Rebuild()
	Rebuilding = {}

	hook.Run("GetHudElements")

	local elements = Rebuilding

	Rebuilding = nil

	for id in pairs(elements) do
		if not Lookup[id] then
			local element = inherit.Instance("hud", id)

			table.insert(Active, element)

			Lookup[id] = element

			element:Initialize()
		end
	end

	for id, element in pairs(Lookup) do
		if not elements[id] then
			element:OnRemove()

			for index, v in ipairs(Active) do
				if v == element then
					table.remove(Active, index)

					break
				end
			end

			Lookup[id] = nil
		end
	end

	table.SortByMember(Active, "DrawOrder", true)
end

function WorldLabel(text, font, color, alpha)
	if alpha == 0 then
		return nil
	end

	return {
		Text = text,
		Font = font,
		Color = color,
		Alpha = alpha or 255
	}
end

function AddWorldLabel(pos, lines)
	local screen = pos:ToScreen()

	if not screen.visible then
		return
	end

	table.insert(Labels, {
		Pos = pos,
		Screen = screen,
		Lines = lines
	})
end

-- Stripped down and optimized version of draw.SimpleText
local function simpleText(text, font, x, y, color, alpha)
	text = tostring(text)
	surface.SetFont(font)

	local w = surface.GetFontSize(font, text)

	x = x - (w * 0.5)

	surface.SetTextPos(x, y)
	surface.SetTextColor(color.r, color.g, color.b, alpha)
	surface.DrawText(text)
end

local colorBlack = Color(0, 0, 0)
local background = Color(0, 0, 0)
local spacing = 20
local margin = 2

function DrawWorldLabels()
	local eye = EyePos()

	table.sort(Labels, function(a, b)
		return a.Pos:DistToSqr(eye) > b.Pos:DistToSqr(eye)
	end)

	local mult = Settings.Get("WorldLabelBackgrounds")

	for _, label in ipairs(Labels) do
		local x = math.ceil(label.Screen.x)
		local y = math.ceil(label.Screen.y)

		if mult > 0 then
			local w = 0
			local alpha = 0

			for _, line in ipairs(label.Lines) do
				w = math.max(w, surface.GetFontSize(line.Font, line.Text))
				alpha = math.max(alpha, line.Alpha)
			end

			local h = #label.Lines * spacing

			background.a = alpha * (mult * 0.01)

			draw.RoundedBox(0, x - w * 0.5 - margin, y - h + spacing - margin, w + margin * 2, h + margin * 2, background)
			surface.SetDrawColor(colorBlack)
		end

		for _, line in SortedPairs(label.Lines) do
			simpleText(line.Text, line.Font, x + 1, y + 1, colorBlack, line.Alpha)
			simpleText(line.Text, line.Font, x, y, line.Color, line.Alpha)

			y = y - spacing
		end
	end

	Labels = {}
end

function GM:GetHudElements()
	for id, class in pairs(List) do
		if class:ShouldAddElement() then
			Add(id)
		end
	end
end

function GM:PreDrawHUD()
	Cache = {}

	for _, element in ipairs(Active) do
		element:Think()
	end
end

function GM:HUDPaint()
	WeaponSelect.Draw()

	local w, h = ScrW(), ScrH()

	for _, element in ipairs(Active) do
		if element:ShouldDraw() then
			element:Paint(w, h)
		end
	end

	local wep = lp:GetActiveWeapon()

	if IsValid(wep) and wep.HUDPaint then
		wep:HUDPaint()
	end
end

function GM:HUDPaintBackground()
	local w, h = ScrW(), ScrH()

	for _, element in ipairs(Active) do
		if element:ShouldDraw() then
			element:PaintBackground(w, h)
		end
	end

	local wep = lp:GetActiveWeapon()

	if IsValid(wep) and wep.HUDPaintBackground then
		wep:HUDPaintBackground()
	end

	DrawWorldLabels()
end

local disabled = table.Lookup({
	"CHudWeaponSelection", "CHudAmmo", "CHudSecondaryAmmo",
	"CHudHealth", "CHudBattery", "CHudHistoryResource",
	"CHUDAutoAim", "CHudChat"
})

function GM:HUDShouldDraw(str)
	if disabled[str] then
		return false
	end

	if str == "CHudCrosshair" and not IsValid(lp:GetActiveWeapon()) then
		return false
	end

	return true
end
