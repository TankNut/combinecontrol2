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

	for k, v in pairs(self.EntityTable.npc) do
		if not IsValid(v) then table.remove(self.EntityTable.npc, k) continue end
		if table.HasValue(self.NPCDrawBlacklist, v:GetClass()) then table.remove(self.EntityTable.npc, k) continue end
		if not Settings.Get("SeeAll") then continue end

		if not v.HUDAlpha then v.HUDAlpha = 0 end

		local pos = (v:EyePos() + Vector(0, 0, 10)):ToScreen()

		if (Settings.Get("SeeAll") and tobool(cookie.GetNumber("cc_seeallnpcs", 1))) and v:Health() > 0 then
			v.HUDAlpha = math.Clamp(v.HUDAlpha + FrameTime(), 0, 1)
		elseif v.HUDAlpha > 0 then
			v.HUDAlpha = math.Clamp(v.HUDAlpha - FrameTime(), 0, 1)
		end

		if v.HUDAlpha > 0 then
			draw.DrawTextShadow("#" .. v:GetClass(), "CombineControl.PlayerFont", pos.x, pos.y, Color(200, 200, 100, v.HUDAlpha * 255), Color(0, 0, 0, v.HUDAlpha * 255), 1)
			pos.y = pos.y + 20
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

function GM:DrawWarnings()
	if self.NameWarning and CurTime() - self.NameWarningStart < 15 then
		local t = CurTime() - self.NameWarningStart
		local a = 1

		if t < 1 then
			a = t
		elseif t > 14 then
			a = 1 - (t - 14)
		end

		local h = 250
		local dh = (ScrH() - h) / 2

		draw.RoundedBox(0, 0, dh, ScrW(), h, Color(30, 30, 30, 200 * a))

		draw.DrawText("YOU HAVE BEEN ISSUED A NAME WARNING", "CombineControl.LabelStupid", ScrW() / 2, dh + 20, Color(150, 20, 20, 255 * a), 1)
		draw.DrawText("An administrator considers your character's name to be inappropriate for Terminator RP.\n\nPlease change it through the player menu (F3) to a proper, realistic first and last name.\n\nIf you ignore this warning, you may be subject to a kick or ban.", "CombineControl.LabelGiant", ScrW() / 2, dh + 100, Color(200, 200, 200, 255 * a), 1)
	end
end

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

	local mode = lp:OverlayMode()

	if mode == OVERLAY_TARGET then
		self:DrawTargetHUD()
	end

	WeaponSelect.Draw()

	if Settings.Get("HUD") then
		self:DrawDamage()
		self:DrawDoors()

		if mode != OVERLAY_TARGET then
			self:DrawEntities()
			self:DrawPlayerInfo()
			self:DrawHealthBars()
		end

		self:DrawAmmo()
	end

	self:DrawWarnings()
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

	if self.MapPostDrawOpaqueRenderables then
		self:MapPostDrawOpaqueRenderables()
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

	local mode = LocalPlayer():OverlayMode()

	if mode == OVERLAY_NVG then
		self:DrawNVG()
	elseif mode == OVERLAY_TARGET then
		self:DrawTargetHUDPP()
	elseif mode == OVERLAY_THERMAL then
		self:DrawThermal()
	else
		if IsValid(self.NVGLight) then
			self.NVGLight:Remove()
			self.NVGLight = nil
		end
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

function GM:CreateNVGLight()
	self.NVGLight = ProjectedTexture()

	self.NVGLight:SetTexture("effects/flashlight001")
	self.NVGLight:SetFOV(60)
	self.NVGLight:SetFarZ(1000)
	self.NVGLight:SetEnableShadows(false)
end

GM.NVGScale = 0.5

function GM:DrawNVG()
	if not IsValid(self.NVGLight) then
		self:CreateNVGLight()
	end

	if self.NVGScale < 1 then
		self.NVGScale = self.NVGScale + 0.1 * (1 - self.NVGScale)
	else
		self.NVGScale = 1
	end

	self.NVGLight:SetBrightness(1.2 - self.NVGScale)

	self.NVGLight:SetPos(EyePos())
	self.NVGLight:SetAngles(EyeAngles())
	self.NVGLight:Update()

	local tab = {}

	tab["$pp_colour_addr"] 			= -1
	tab["$pp_colour_addg"] 			= -0.65
	tab["$pp_colour_addb"] 			= -1
	tab["$pp_colour_brightness"] 	= self.NVGScale * 0.8
	tab["$pp_colour_contrast"] 		= self.NVGScale * 1.106
	tab["$pp_colour_colour"] 		= 0
	tab["$pp_colour_mulr"] 			= 0.1
	tab["$pp_colour_mulg"] 			= 0.2
	tab["$pp_colour_mulb"] 			= 0.1

	DrawColorModify(tab)
	DrawBloom(0, self.NVGScale * 0.74, 2.97, 3.18, 4, self.NVGScale * 3.14, 240 / 255, 1, 1)
end

function GM:DrawTargetHUD()
	local target = LocalPlayer():GetEyeTrace().Entity

	if not IsValid(target) or not (target:IsPlayer() or target:IsNPC()) then
		target = nil
	end

	local pos

	if LocalPlayer():ShouldDrawLocalPlayer() then
		local vec = (LocalPlayer():EyeAngles() + LocalPlayer():GetViewPunchAngles()):Forward()
		local trace = util.TraceLine({
			start = LocalPlayer():GetShootPos(),
			endpos = LocalPlayer():EyePos() + (vec * 10000),
			filter = {LocalPlayer()}
		})

		local tab = trace.HitPos:ToScreen()

		pos = Vector(tab.x, tab.y, 0)
	else
		pos = Vector(ScrW() * 0.5, ScrH() * 0.5, 0)
	end

	self:DrawTargetHUDText(pos, target)
end

GM.TargetHUDUpdate = CurTime()
GM.TargetHUDText = {}
GM.TargetHUDFont = "CombineControl.CombineScanner"
GM.TargetHUDColor = Color(255, 0, 0)
GM.TargetHUDColorReprog = Color(0, 191, 255)

function GM:DrawTargetHUDText(pos, target)
	local col = ColorAlpha(LocalPlayer():Team() == TEAM_REPROG and self.TargetHUDColorReprog or self.TargetHUDColor, self.TargetScale * 255)
	local size = 80

	surface.SetDrawColor(col.r, col.g, col.b, col.a)
	surface.SetTexture(surface.GetTextureID("models/tnb/trpweapons/reticule_square"))

	surface.DrawTexturedRect(pos.x - size, pos.y - size, size * 2, size * 2)

	local dist = LocalPlayer():GetEyeTrace().HitPos:Distance(LocalPlayer():EyePos())

	draw.DrawText(string.format("DIST: %s (%s)", math.Round(dist * 0.0254), math.Round(dist)), "DebugFixed", pos.x - size, pos.y + size, col)
	draw.DrawText("BEARING: " .. math.floor(math.AngleToHeading(LocalPlayer():EyeAngles().y)), "DebugFixed", pos.x - size, pos.y + size + draw.GetFontHeight("DebugFixed"), col)

	if self.TargetHUDUpdate <= CurTime() then
		table.insert(self.TargetHUDText, 1, string.Right(tostring({}), 10))

		if #self.TargetHUDText > 8 then
			table.remove(self.TargetHUDText)
		end

		self.TargetHUDUpdate = CurTime() + 0.1
	end

	surface.SetFont(self.TargetHUDFont)

	local x = 20
	local y = 20

	local function drawText(text, align)
		align = align or TEXT_ALIGN_LEFT

		draw.DrawText(text, self.TargetHUDFont, x, y, col, align)

		y = y + surface.GetFontHeight(self.TargetHUDFont)
	end

	drawText("DATA RECV:")
	drawText("**********")

	for _, v in pairs(self.TargetHUDText) do
		drawText(v)
	end

	x = ScrW() - 20
	y = ScrH() * 0.4

	if target then
		local tab = {}
		local width = 0

		local function add(preface, text)
			width = math.max(width, #tostring(text))

			table.insert(tab, {preface, text})
		end

		add("389 TARGID", target:IsPlayer() and target:VisibleRPName() or "NULL")
		add("105 STRCTR", math.Round((target:Health() / target:GetMaxHealth()) * 100))

		if target:IsPlayer() then
			local weaponlist = target:GetWeapons()
			local output = {}

			for _, v in pairs(weaponlist) do
				if v.Tekka then
					table.insert(output, self:GetWeaponName(v))
				elseif v.TRP then
					table.insert(output, v.PrintName)
				end
			end

			table.sort(output)

			add("790 WEAPON", table.remove(output, 1) or "NULL")

			for _, v in pairs(output) do
				add("", v)
			end
		else
			add("790 WEAPON", "NULL")
		end

		drawText("TARGET ANALYSIS:", TEXT_ALIGN_RIGHT)
		drawText(string.rep("*", width + 12), TEXT_ALIGN_RIGHT)

		for _, v in pairs(tab) do
			drawText(string.format("%s  %-" .. width .. "s", unpack(v)), TEXT_ALIGN_RIGHT)
		end
	end

	x = 20
	y = ScrH() - 20 - (surface.GetFontHeight(self.TargetHUDFont) * 4)

	drawText("DEBUG QUERY")
	drawText("SYSCHECK...")
	drawText(string.format("NETWORK MASK: %s...", LocalPlayer():VisibleRPName()))
	drawText(string.format("STRCTR: %d/%d... VEL: %.2f M/S...", LocalPlayer():Health(), LocalPlayer():GetMaxHealth(), LocalPlayer():GetVelocity():Length() * 0.0254))
end

function GM:GetWeaponName(ent)
	local blacklist = {
		["admin"] = true,
		["drone"] = true,
		["dual"] = true,
		["infiltrator"] = true,
		["skynet"] = true,
		["tc"] = true,
		["tekka"] = true,
		["trp"] = true
	}

	local expl = string.Explode("_", ent:GetClass())
	local weapon = {}

	for _, v in pairs(expl) do
		if blacklist[v] then
			continue
		end

		table.insert(weapon, v)
	end

	return table.concat(weapon, "_")
end

function GM:DrawTargetHUDPP()
	if not IsValid(self.NVGLight) then
		self:CreateNVGLight()
	end

	self.TargetScale = math.Clamp(self.TargetScale + 0.02 * (1 - self.TargetScale), 0, 1)

	self.NVGLight:SetBrightness(1.2 - self.TargetScale)

	self.NVGLight:SetPos(EyePos())
	self.NVGLight:SetAngles(EyeAngles())
	self.NVGLight:Update()

	local tab = {}

	tab["$pp_colour_addr"] 			= 0
	tab["$pp_colour_addg"] 			= 0
	tab["$pp_colour_addb"] 			= 0
	tab["$pp_colour_brightness"] 	= 0
	tab["$pp_colour_contrast"] 		= 1 * self.TargetScale
	tab["$pp_colour_colour"] 		= 0
	tab["$pp_colour_mulr"] 			= 0.1 * self.TargetScale
	tab["$pp_colour_mulg"] 			= 0.1 * self.TargetScale
	tab["$pp_colour_mulb"] 			= 0.1 * self.TargetScale

	DrawColorModify(tab)

	local bloom = self.TargetScale * 2

	if bloom > 1 then
		bloom = 1 - (bloom - 1)
	end

	DrawBloom(0.07, bloom * 5, 9, 9, 1, 1, 1, 1, 1 )
end

local white = Material("engine/singlecolor")

function GM:DrawThermal()
	local tab = {}

	table.Add(tab, player.GetAll())
	table.Add(tab, ents.FindByClass("npc_*"))

	render.SetStencilEnable(true)

	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)

	render.SetStencilReferenceValue(1)

	render.SetStencilCompareFunction(STENCIL_ALWAYS)

	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)

	render.ClearStencil()

	render.SuppressEngineLighting(true)
	render.MaterialOverride(white)

	cam.Start3D()
		for _, v in pairs(tab) do
			local thermal = v:IsPlayer() and v:ThermalHidden() or false
			local ent = GAMEMODE:ShouldDrawStencilEnt(v)

			if not IsValid(ent) or ent:IsDormant() then
				continue
			end

			GAMEMODE:DrawStencilEnt(ent, thermal)
		end
	cam.End3D()

	render.MaterialOverride()
	render.SuppressEngineLighting(false)

	render.SetStencilCompareFunction(STENCIL_NOTEQUAL)

	DrawColorModify({
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = -0.1,
		["$pp_colour_contrast"] = 0.25,
		["$pp_colour_colour"] = 0,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	})

	DrawColorModify({
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 0,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	})

	render.SetStencilEnable(false)

	DrawBloom(0, 2, 1, 1, 1, 1, 1, 1, 1)
	DrawMotionBlur(0.5, 0.4, 0.04)
end

hook.Add("OnOverlayModeChanged", "CL.Hud.OverlayMode", function(ply, mode)
	local snd = (mode == OVERLAY_NONE) and "items/nvg_off.wav" or "items/nvg_on.wav"

	surface.PlaySound(snd)

	if mode == OVERLAY_NVG then
		GAMEMODE.NVGScale = 0
	elseif mode == OVERLAY_TARGET then
		GAMEMODE.TargetScale = 0
	end
end)

hook.Add("PreDrawOutlines", "CL.Hud.Outlines", function()
	if LocalPlayer():OverlayMode() != OVERLAY_TARGET then
		return
	end

	local target = LocalPlayer():GetEyeTrace().Entity

	if not IsValid(target) or not (target:IsPlayer() or target:IsNPC()) then
		target = nil
	end

	for _, v in ents.Iterator() do
		if not IsValid(v) then
			continue
		end

		if v:IsDormant() then
			continue
		end

		if not (v:IsNPC() or v:IsPlayer()) then
			continue
		end

		local ent = GAMEMODE:ShouldDrawStencilEnt(v)

		if not IsValid(ent) then
			continue
		end

		local color = (ent:IsPlayer() and ent != target) and GAMEMODE:GetTeamColor(ent) or color_white

		local tab = {ent}

		local weapon = ent.GetActiveWeapon and ent:GetActiveWeapon()

		if IsValid(weapon) then
			table.insert(tab, weapon)
		end

		outline.Add(tab, color, OUTLINE_MODE_VISIBLE)
	end
end)

function GM:ShouldDrawStencilEnt(ent)
	if ent:IsNPC() and ent:Health() > 0 then
		return ent
	elseif ent:IsPlayer() and ent:Alive() then
		local ragdoll = ent:Ragdoll()

		if IsValid(ragdoll) then
			return ragdoll
		end

		return not ent:GetNoDraw() and ent or false
	end

	return false
end

function GM:DrawStencilEnt(ent, thermal)
	ent:DrawModel()
end
