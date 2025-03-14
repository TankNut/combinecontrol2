module("Hud", package.seeall)

List = List or {}

if CLIENT then
	EntityCache.Add("items", function(ent) return ent:GetClass() == "cc_item" end)
	EntityCache.Add("npcs", function(ent) return ent:IsNPC() end)
	EntityCache.Add("props", function(ent) return PROP_CLASSES[ent:GetClass()] and not ent:CreatedByMap() end)
end

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

local background = Color(0, 0, 0)
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

		local w, h = 0, 0
		local alpha = 0

		for _, instance in ipairs(label.Lines) do
			instance[2] = instance[2] or 1

			if instance[2] > 0 then
				w = math.max(w, instance[1]:GetWide())
				h = h + instance[1]:GetTall()

				alpha = math.max(alpha, instance[2])
			end
		end

		if mult > 0 then
			background.a = math.Remap(mult * alpha, 0, 100, 0, 255)

			draw.RoundedBox(0, x - w * 0.5 - margin, y - h - margin, w + margin * 2, h + margin * 2, background)
		end

		for _, instance in SortedPairs(label.Lines, true) do
			if instance[2] > 0 then
				instance[1]:Draw(x, y, instance[2], TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

				y = y - instance[1]:GetTall()
			end
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
	"CHUDAutoAim", "CHudChat", "CHUDQuickInfo"
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
