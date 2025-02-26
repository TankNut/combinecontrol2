GM.EntityTable = {
	prop = { },
	item = { },
	paper = { },
	npc = { },
	door = { },
}

language.Add("npc_clawscanner", "Claw Scanner")
language.Add("npc_combine_camera", "Combine Camera")
language.Add("npc_helicopter", "Helicopter")
language.Add("npc_barnacle_tongue_tip", "Barnacle Tongue Tip")
language.Add("prop_vehicle_apc", "APC")
language.Add("npc_fisherman", "Fisherman")

function draw.DrawTextShadow(text, font, x, y, col1, col2, align)
	if align != 0 then

		draw.DrawText(text, font, x + 1, y + 1, col2, align) -- Less efficient than surface, so we only use this if we need special alignment stuff.
		draw.DrawText(text, font, x, y, col1, align)

	else

		surface.SetFont(font)

		surface.SetTextColor(col2)
		surface.SetTextPos(x + 1, y + 1)
		surface.DrawText(text)
		surface.SetTextColor(col1)
		surface.SetTextPos(x, y)
		surface.DrawText(text)

	end
end

local matBlurScreen = Material("pp/blurscreen")

function draw.DrawBackgroundBlur(frac, x, y, w, h)
	DisableClipping(true)

	surface.SetMaterial(matBlurScreen)
	surface.SetDrawColor(255, 255, 255, 255)

	for i = 1, 3 do

		matBlurScreen:SetFloat("$blur", frac * 5 * (i / 3))
		matBlurScreen:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x or 0, y or 0, w or ScrW(), h or ScrH())

	end

	DisableClipping(false)
end

function GM:DrawWorldText(pos, text, noz)
	local ang = (pos - EyePos()):Angle()

	cam.Start3D2D(pos, Angle(0, ang.y - 90, 90), 0.25)
		if noz then
			render.DepthRange(0, 0)
		end

		render.PushFilterMag(TEXFILTER.NONE)
		render.PushFilterMin(TEXFILTER.NONE)
			surface.SetFont("BudgetLabel")

			local w, h = surface.GetTextSize(text)

			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(-w * 0.5, -h * 0.5)

			surface.DrawText(text)
		render.PopFilterMin()
		render.PopFilterMag()

		if noz then
			render.DepthRange(0, 1)
		end
	cam.End3D2D()
end

GM.ThirdCurPos = Vector()
GM.ThirdCurAng = Angle()
GM.ThirdDestPos = Vector()
GM.ThirdDestAng = Angle()

GM.NPCDrawBlacklist = {
	"npc_antlion_grub",
	"npc_barnacle_tongue_tip",
	"npc_bullseye",
	"monster_generic"
}

GM.TypeText = {
	"Typing...",
	"Radioing...",
	"Requesting..."
}

function GM:DrawEntities()
	if cookie.GetNumber("cc_noscopelabels", 0) == 1 then
		local weapon = LocalPlayer():GetActiveWeapon()

		if IsValid(weapon) and weapon.InScope and weapon:InScope() then
			PlayerCache = {}

			for _, v in player.Iterator() do
				v.HUDAlpha = 0
				v.TitleAlpha = 0
			end

			for _, tab in pairs({"prop", "item", "paper", "npc"}) do
				for _, v in pairs(self.EntityTable[tab]) do
					v.HUDAlpha = 0
				end
			end

			return
		end
	end

	for k, v in pairs(self.EntityTable.paper) do

		if not IsValid(v) then table.remove(self.EntityTable.paper, k) continue end
		if not v.HUDAlpha then v.HUDAlpha = 0 end

		local distance = LocalPlayer():GetPos():Distance(v:GetPos())

		if distance > self:GetPlayerSight() / 2 and not Settings.Get("SeeAll") then
			continue
		end

		local a, b = v:GetRotatedAABB(v:OBBMins(), v:OBBMaxs())
		local wpos = (v:GetPos() + (a + b) / 2)
		local pos = wpos:ToScreen()

		if Settings.Get("SeeAll") or (pos.visible and LocalPlayer():CanSee(v)) then
			v.HUDAlpha = math.Clamp(v.HUDAlpha + FrameTime(), 0, 1)
		elseif v.HUDAlpha > 0 then
			v.HUDAlpha = math.Clamp(v.HUDAlpha - FrameTime(), 0, 1)
		end

		if v.HUDAlpha > 0 then
			draw.DrawTextShadow("Paper", "CombineControl.PlayerFont", pos.x, pos.y, Color(200, 200, 200, v.HUDAlpha * 255), Color(0, 0, 0, v.HUDAlpha * 255), 1)
			pos.y = pos.y + 20

			draw.DrawTextShadow("Press C to read.", "CombineControl.LabelSmall", pos.x, pos.y, Color(200, 200, 200, v.HUDAlpha * 255), Color(0, 0, 0, v.HUDAlpha * 255), 1)
			pos.y = pos.y + 16
		end
	end
end

function GM:DrawDoors()
	-- Indexing some variables to cut down on unnecessary calls
	local sight = self:GetPlayerSight()
	local eyeEnt = LocalPlayer():GetEyeTrace().Entity

	for k, v in pairs(self.EntityTable.door) do
		-- Doors without an original name don't need to be drawn, they aren't buyable and don't have names to show
		if #v:DoorOriginalName() < 1 then continue end
		if not IsValid(v) then table.remove(self.EntityTable.door, k) continue end
		if not v.HUDAlpha then v.HUDAlpha = 0 end

		local a, b = v:GetRotatedAABB(v:OBBMins(), v:OBBMaxs())
		local wpos = (v:GetPos() + (a + b) / 2)

		local pos = wpos:ToScreen()

		if pos.visible and v:GetPos():Distance(LocalPlayer():GetPos()) <= sight then
			-- GetEyeTrace() is already cached for us, let's use that instead of doing a new trace FOR EVERY VISIBLE DOOR ON EVERY FRAME
			if eyeEnt == v then
				v.HUDAlpha = math.Clamp(v.HUDAlpha + FrameTime(), 0, 1)
			elseif v.HUDAlpha > 0 then
				v.HUDAlpha = math.Clamp(v.HUDAlpha - FrameTime(), 0, 1)
			end
		else
			v.HUDAlpha = math.Clamp(v.HUDAlpha - FrameTime(), 0, 1)
		end

		if v.HUDAlpha > 0 then
			local name = v:DoorOriginalName()

			if v:DoorName() != "" then
				name = v:DoorName()
			end

			draw.DrawTextShadow(name, "CombineControl.PlayerFont", pos.x, pos.y, Color(200, 200, 200, v.HUDAlpha * 255), Color(0, 0, 0, v.HUDAlpha * 255), 1)
			pos.y = pos.y + 20

			if (v:DoorType() == DOOR_BUYABLE or v:DoorType() == DOOR_BUYABLE_ASSIGNABLE) and #v:DoorOwners() == 0 and #v:DoorAssignedOwners() == 0 then
				draw.DrawTextShadow(util.FormatCurrency(v:DoorPrice()), "CombineControl.PlayerFont", pos.x, pos.y, Color(226, 205, 95, v.HUDAlpha * 255), Color(0, 0, 0, v.HUDAlpha * 255), 1)
				pos.y = pos.y + 20
			end

			if Settings.Get("SeeAll") then
				local tab = v:DoorOwners()
				table.Merge(tab, v:DoorAssignedOwners())

				for _, owner in pairs(tab) do
					local ply = nil

					for _, l in player.Iterator() do
						if l:CharID() == owner then
							ply = l
						end
					end

					local text = "Owner: CharID #" .. owner

					if IsValid(ply) then
						text = "Owner: " .. ply:VisibleRPName()
					end

					draw.DrawTextShadow(text, "CombineControl.PlayerFont", pos.x, pos.y, Color(200, 200, 200, v.HUDAlpha * 255), Color(0, 0, 0, v.HUDAlpha * 255), 1)
					pos.y = pos.y + 20
				end
			end
		end
	end
end

GM.WeaponOutText = {}
GM.WeaponOutText["weapon_physgun"] = "Your physgun is out! Switch to your hands when you're done building."
GM.WeaponOutText["weapon_physcannon"] = "Your gravgun is out! Switch to your hands when you're done moving things."
GM.WeaponOutText["gmod_tool"] = "Your toolgun is out! Switch to your hands when you're done building."

function GM:DrawAmmo()
	if LocalPlayer():InVehicle() then
		return
	end

	local w = LocalPlayer():GetActiveWeapon()

	if w != NULL then
		if (LocalPlayer():Holstered()) and w.Holsterable or (w.GetHolstered and w:GetHolstered()) then
			surface.SetFont("CombineControl.LabelGiant")
			local x1, y1 = surface.GetTextSize("Press B to unholster.")

			draw.RoundedBox(0, ScrW() - 24 - x1, ScrH() - 24 - y1, x1 + 4, y1 + 4, Color(30, 30, 30, 200))
			draw.DrawTextShadow("Press B to unholster.", "CombineControl.LabelGiant", ScrW() - 22 - x1, ScrH() - 22 - y1, Color(200, 200, 200, 255), Color(0, 0, 0, 255), 0)

			return
		elseif w.UnholsterText then
			surface.SetFont("CombineControl.LabelGiant")
			local x1, y1 = surface.GetTextSize(w.UnholsterText)

			draw.RoundedBox(0, ScrW() - 24 - x1, ScrH() - 24 - y1, x1 + 4, y1 + 4, Color(30, 30, 30, 200))
			draw.DrawTextShadow(w.UnholsterText, "CombineControl.LabelGiant", ScrW() - 22 - x1, ScrH() - 22 - y1, Color(200, 200, 200, 255), Color(0, 0, 0, 255), 0)

			return
		elseif self.WeaponOutText[w:GetClass()] then
			surface.SetFont("CombineControl.LabelMassive")
			local x1, y1 = surface.GetTextSize(self.WeaponOutText[w:GetClass()])

			draw.RoundedBox(0, ScrW() - 24 - x1, ScrH() - 24 - y1, x1 + 4, y1 + 4, Color(30, 30, 30, 200))
			draw.DrawTextShadow(self.WeaponOutText[w:GetClass()], "CombineControl.LabelMassive", ScrW() - 22 - x1, ScrH() - 22 - y1, Color(200, 0, 0, 255), Color(0, 0, 0, 255), 0)

			return
		end

		if (w.Firearm or w.Tekka) and w.Primary.ClipSize > -1 then
			local clip = w:Clip1()

			surface.SetFont("CombineControl.HUDAmmo")

			local x1, y1 = surface.GetTextSize(clip)
			local y2 = surface.GetFontHeight("CombineControl.HUDAmmo")

			local x = x1
			local y = math.max(y1, y2)

			draw.RoundedBox(0, ScrW() - 24 - x, ScrH() - 24 - y, x + 4, y + 4, Color(30, 30, 30, 200))
			draw.DrawTextShadow(clip, "CombineControl.HUDAmmo", ScrW() - 22 - x, ScrH() - 22 - y, Color(200, 200, 200, 255), Color(0, 0, 0, 255), 0)

			if w.Firemodes then
				local text = w:GetFiremode().Name

				surface.SetFont("CombineControl.LabelGiant")

				local x3, y3 = surface.GetTextSize(text)

				draw.RoundedBox(0, ScrW() - 24 - x3, ScrH() - 28 - y - y3, x3 + 4, y3 + 4, Color(30, 30, 30, 200))
				draw.DrawTextShadow(text, "CombineControl.LabelGiant", ScrW() - 22 - x3, ScrH() - 26 - y - y3, Color(200, 200, 200, 255), Color(0, 0, 0, 255), 0)
			end
		end

		if w.GetHudText then
			local clip, firemode = w:GetHudText()

			if not clip then
				return
			end

			surface.SetFont("CombineControl.HUDAmmo")

			local x1, y1 = surface.GetTextSize(clip)
			local y2 = surface.GetFontHeight("CombineControl.HUDAmmo")

			local x = x1
			local y = math.max(y1, y2)

			draw.RoundedBox(0, ScrW() - 24 - x, ScrH() - 24 - y, x + 4, y + 4, Color(30, 30, 30, 200))
			draw.DrawTextShadow(clip, "CombineControl.HUDAmmo", ScrW() - 22 - x, ScrH() - 22 - y, Color(200, 200, 200, 255), Color(0, 0, 0, 255), 0)

			if firemode then
				surface.SetFont("CombineControl.LabelGiant")

				local x3, y3 = surface.GetTextSize(firemode)

				draw.RoundedBox(0, ScrW() - 24 - x3, ScrH() - 28 - y - y3, x3 + 4, y3 + 4, Color(30, 30, 30, 200))
				draw.DrawTextShadow(firemode, "CombineControl.LabelGiant", ScrW() - 22 - x3, ScrH() - 26 - y - y3, Color(200, 200, 200, 255), Color(0, 0, 0, 255), 0)
			end
		end
	end
end

net.Receive("nWarnName", function(len)
	GAMEMODE.NameWarning = true
	GAMEMODE.NameWarningStart = CurTime()
end)

function GM:DrawUnconnected()
	if not lp:HasCharacter() and not vgui.CursorVisible() then
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(0, 0, ScrW(), ScrH())

		draw.DrawBackgroundBlur(1)

		draw.DrawText("Please wait...", "CombineControl.LabelGiant", ScrW() / 2, ScrH() / 2, Color(200, 200, 200, 255), 1)
	end
end

net.Receive("nFlashRed", function(len)
	GAMEMODE.FlashRedStart = CurTime()
end)

function GM:DrawDamage()
	if self.FlashRedStart and LocalPlayer():Alive() then
		local t = CurTime() - self.FlashRedStart
		local a = 0

		if t < 0.1 then
			a = 0.5
		elseif t < 0.6 then
			a = 0.5 - (t - 0.1)
		end

		if a > 0 then
			surface.SetDrawColor(128, 0, 0, 255 * a)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		end
	end
end

function GM:HUDPaint()
	if not CCP or not lp:HasCharacter() then return end

	WeaponSelect.Draw()

	if Settings.Get("HUD") then
		self:DrawDamage()
		self:DrawDoors()

		self:DrawEntities()
		self:DrawPlayerInfo()
		self:DrawHealthBars()

		self:DrawAmmo()
	end

	self:DrawUnconnected()

	local wep = LocalPlayer():GetActiveWeapon()

	if IsValid(wep) and wep.HUDPaint then
		wep:HUDPaint()
	end
end

function GM:PostDrawOpaqueRenderables()
	for _, v in player.Iterator() do
		local wep = v:GetActiveWeapon()

		if IsValid(wep) and wep.PostDrawOpaqueRenderables then
			wep:PostDrawOpaqueRenderables()
		end
	end
end

function GM:PostDrawTranslucentRenderables()
	for _, v in player.Iterator() do
		local wep = v:GetActiveWeapon()

		if IsValid(wep) and wep.PostDrawTranslucentRenderables then
			wep:PostDrawTranslucentRenderables()
		end
	end
end

function GM:PostRenderVGUI()
	if self.CursorItem and cookie.GetNumber("cc_tooltips", 1) == 1 then
		self.CursorItem:DrawTooltip()
	end
end

function GM:GetCursorEnt()
	local trace = {}
	trace.start = LocalPlayer():GetShootPos()
	trace.endpos = trace.start + gui.ScreenToVector(gui.MousePos()) * 32768
	trace.filter = LocalPlayer()
	local tr = util.TraceLine(trace)

	if IsValid(tr.Entity) then
		return tr.Entity
	end
end

local col = Color(255, 0, 255, 255)

function GM:PreDrawHalos()
	if Settings.Get("SeeAll") and IsValid(LocalPlayer():GetActiveWeapon()) and GAMEMODE.WeaponOutText[LocalPlayer():GetActiveWeapon():GetClass()] then
		local tab = {}

		for _, v in pairs(GAMEMODE.EntityTable.prop) do -- Only props can be permapropped so...
			if not IsValid(v) then
				continue
			end

			if v:IsProtectedEntity() then
				if v:GetClass() == "prop_effect" then
					table.insert(tab, v.AttachedEntity)
				else
					table.insert(tab, v)
				end
			end
		end

		halo.Add(tab, col, 1, 1, 1, true, false)
	end
end

local frame = 0

function GM:RenderScreenspaceEffects()
	self.BaseClass:RenderScreenspaceEffects()

	if FrameNumber() == frame then
		return
	end

	frame = FrameNumber()

	if self.FlashbangStart and LocalPlayer():Alive() then
		local t = CurTime() - self.FlashbangStart
		local a = 0

		if t < 5 then
			a = 1
		elseif t < 7 then
			a = 1 - (t - 5) / 2
		end

		local tab = {}

		tab[ "$pp_colour_addr" ] 		= 0
		tab[ "$pp_colour_addg" ] 		= 0
		tab[ "$pp_colour_addb" ] 		= 0
		tab[ "$pp_colour_brightness" ] 	= a
		tab[ "$pp_colour_contrast" ] 	= 1
		tab[ "$pp_colour_colour" ] 		= 1
		tab[ "$pp_colour_mulr" ] 		= 0
		tab[ "$pp_colour_mulg" ] 		= 0
		tab[ "$pp_colour_mulb" ] 		= 0

		DrawColorModify(tab)
	end

	local weapon = lp:GetActiveWeapon()

	if IsValid(weapon) and weapon.RenderScreenspaceEffects then
		weapon:RenderScreenspaceEffects()
	end
end

function GM:PlayerStartVoice(ply)
	if not game.IsDedicated() then
		self.BaseClass:PlayerStartVoice(ply)
	end
end

function GM:PlayerEndVoice(ply)
	if not game.IsDedicated() then
		self.BaseClass:PlayerEndVoice(ply)
	end
end
