module("WeaponSelect", package.seeall)

Debug = false -- Forces weapon select to always be open

HangTime = 1
FadeTime = 1

OpenTime = OpenTime or -HangTime - FadeTime

Slots = {
	"Basic", -- SLOT_BASIC
	"Weapons", -- SLOT_WEAPONS
	"Misc" -- SLOT_MISC
}

SlotFallback = SLOT_MISC
SlotOverrides = {
	["weapon_physgun"] = {SLOT_MISC, 1},
	["weapon_physcannon"] = {SLOT_MISC, 2},
	["gmod_tool"] = {SLOT_MISC, 3}
}

WeaponNames = {
	["weapon_physgun"] = "Physics Gun",
	["weapon_physcannon"] = "Gravity Gun",
	["gmod_tool"] = "Tool Gun"
}

Slot = SLOT_BASIC
SlotIndex = 1

-- Sounds
MoveSound = Sound("common/wpn_moveselect.wav")
SelectSound = Sound("common/wpn_select.wav")

-- Visual options
Width = 200
Height = 30

Spacing = 20
WeaponSpacing = 10

TextInset = 10

BaseColor = Color(30, 30, 30)
TextColor = Color(200, 200, 200)
ActiveColor = Color(100, 40, 40)

InfoHeight = surface.GetFontHeight("CombineControl.WepSelectInfo")

function IsOpen()
	if Debug then
		return true
	end

	return CurTime() - OpenTime < (HangTime + FadeTime)
end

function Bind(bind, down)
	if not down or lp:KeyDown(IN_ATTACK) or lp:KeyDown(IN_ATTACK2) then
		return
	end

	if string.find(bind, "slot") then
		local slot = tonumber(string.gsub(bind, "slot", ""), 10)

		if slot and slot > 0 and slot <= #Slots then
			SelectSlot(slot)
		end

		return true
	elseif string.find(bind, "invprev") then
		Scroll(-1)

		return true
	elseif string.find(bind, "invnext") then
		Scroll(1)

		return true
	elseif IsOpen() then
		if string.find(bind, "attack2") then
			Close()

			return true
		elseif string.find(bind, "attack") then
			SelectWeapon()

			return true
		end
	end
end

function Close()
	surface.PlaySound(SelectSound)
	OpenTime = -HangTime - FadeTime
end

function SelectWeapon()
	local weapon = GetWeapons(Slot)[SlotIndex]

	if IsValid(weapon) then
		input.SelectWeapon(weapon)
	end

	Close()
end

function SelectSlot(slot)
	local tab = GetWeapons(slot)

	if #tab == 0 then
		return
	end

	surface.PlaySound(MoveSound)

	if slot == Slot then
		if not IsOpen() then
			SlotIndex = 1
		else
			SlotIndex = SlotIndex + 1

			if SlotIndex > #tab then
				SlotIndex = 1
			end
		end
	else
		SlotIndex = 1
		Slot = slot
	end

	OpenTime = CurTime()
end

function Scroll(dir)
	if #lp:GetWeapons() == 0 then
		return
	end

	surface.PlaySound(MoveSound)

	if IsOpen() then
		SlotIndex = SlotIndex + dir
	end

	if SlotIndex > #GetWeapons(Slot) then
		Slot = Slot + 1

		while #GetWeapons(Slot) == 0 do
			Slot = Slot + 1

			if Slot > #Slots then
				Slot = 1
			end
		end

		SlotIndex = 1
	elseif SlotIndex < 1 then
		Slot = Slot - 1

		while #GetWeapons(Slot) == 0 do
			Slot = Slot - 1

			if Slot < 1 then
				Slot = #Slots
			end
		end

		SlotIndex = #GetWeapons(Slot)
	end

	OpenTime = CurTime()
end

function GetSlot(weapon)
	local override = SlotOverrides[weapon:GetClass()]

	if override then
		return override[1]
	end

	local slot = weapon.Slot

	if not slot or slot < 1 or slot > #Slots then
		return SlotFallback
	end

	return slot
end

function GetSlotPos(weapon)
	local override = SlotOverrides[weapon:GetClass()]

	if override then
		return override[2]
	end

	local slot = weapon.SlotPos

	if not slot then
		-- Unsorted shit gets added to the bottom, below everything else
		return weapon:GetCreationTime() + 100
	end

	return slot
end

function GetName(weapon)
	return WeaponNames[weapon:GetClass()] or weapon:GetPrintName()
end

function GetWeapons(slot)
	local tab = {}

	for _, weapon in pairs(lp:GetWeapons()) do
		if GetSlot(weapon) == slot then
			table.insert(tab, weapon)
		end
	end

	table.sort(tab, function(a, b)
		return GetSlotPos(a) < GetSlotPos(b)
	end)

	return tab
end

function Draw()
	if not IsOpen() then
		return
	end

	local alpha
	local time = CurTime() - OpenTime

	if Debug then
		alpha = 1
	elseif time < HangTime then
		alpha = 1
	else
		alpha = math.Remap(time, HangTime, HangTime + FadeTime, 1, 0)
	end

	local scrW = ScrW()

	local cSlot = ColorAlpha(BaseColor, 100 * alpha)
	local cSlotActive = ColorAlpha(BaseColor, 200 * alpha)

	local cText = ColorAlpha(TextColor, 200 * alpha)
	local cTextShadow = Color("black", 200 * alpha)

	local cTextActive = ColorAlpha(TextColor, 255 * alpha)
	local cTextActiveShadow = Color("black", 200 * alpha)

	local totalWidth = (#Slots * Width) + ((#Slots - 1) * Spacing)
	local startX = (scrW * 0.5) - totalWidth * 0.5

	for slot, name in ipairs(Slots) do
		local i = slot - 1
		local active = Slot == slot

		local x = startX + (i * Width) + (i * Spacing)

		draw.RoundedBox(0, x, Spacing, Width, Height, active and cSlotActive or cSlot)

		local textX = x + Width * 0.5
		local textY = Spacing + Height * 0.5

		draw.SimpleText(name, "CombineControl.WepSelectHeader",
			textX + 1, textY + 1,
			active and cTextActiveShadow or cTextShadow,
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(name, "CombineControl.WepSelectHeader",
			textX, textY,
			active and cTextActive or cText,
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local cWeapon = ColorAlpha(BaseColor, 200 * alpha)
	local cWeaponActive = ColorAlpha(ActiveColor, 200 * alpha)

	local y = Height + Spacing * 2

	for index, weapon in ipairs(GetWeapons(Slot)) do
		local name = GetName(weapon)
		local nameW, nameH = surface.GetFontSize("CombineControl.WepSelectWep", name)
		local h = nameH + TextInset * 2

		local active = SlotIndex == index
		local infoText

		if active and weapon.InfoText then
			infoText = string.Explode("\n", weapon.InfoText)

			h = math.max(h, #infoText * InfoHeight + (TextInset * 2))
		end

		draw.RoundedBox(0, startX, y, totalWidth, h, active and cWeaponActive or cWeapon)
		draw.DrawTextShadow(name, "CombineControl.WepSelectWep", startX + TextInset, y + TextInset, cText, cTextShadow)

		if infoText then
			for k, v in ipairs(infoText) do
				draw.DrawTextShadow(v, "CombineControl.WepSelectInfo", startX + nameW + TextInset * 2, y + TextInset + (k * InfoHeight) - InfoHeight, cText, cTextShadow)
			end
		end

		y = y + h + WeaponSpacing
	end
end
