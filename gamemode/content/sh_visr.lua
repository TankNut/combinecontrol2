PlayerVar.Add("VISR", {Default = false, Private = true})

Action.Add("ToggleVISR", {
	Name = "Toggle VISR",
	Piority = 15,

	Target = ACTION_SELF,
	Context = "SelfContext",

	CanRun = function(self)
		return self:HasBuff("visr")
	end,

	Callback = function(self)
		self:SetVISR(not self:VISR())
	end
})


if SERVER then
	return
end

local npcColor = Color(213, 190, 115)

local function addChildren(ent, tab)
	for _, child in ipairs(ent:GetChildren()) do
		if child:GetClass() == "cc_attachment" or child:IsWeapon() then
			table.insert(tab, child)
		end
	end
end

local function getEntities(ent)
	local tab = {ent}

	addChildren(ent, tab)

	if ent:IsNPC() then
		return tab, npcColor, true
	elseif ent:IsPlayer() and ent:Alive() then
		if ent:IsCloaked() then
			return false
		end

		local color = team.GetColor(ent:Team())
		local ragdoll = ent:GetRagdoll()

		if IsValid(ragdoll) then
			table.insert(tab, ragdoll)

			addChildren(ragdoll, tab)
		end

		local vehicle = ent:GetVehicle()

		if IsValid(vehicle) then
			table.insert(tab, vehicle)

			local parent = vehicle:GetParent()

			if IsValid(parent) then
				table.insert(tab, parent)

				for _, child in ipairs(parent:GetChildren()) do
					table.insert(tab, child)
				end
			end
		end

		return tab, color
	end

	return tab, color_white
end

local overlay = Material("taconbanana/halo/hud/overlay_odst")

hook.Add("PreDrawHUD", "visr", function()
	if not lp:VISR() or not render.IsFirstPerson() or not Settings.Get("DrawOverlays") then
		return
	end

	cam.Start2D()
		surface.SetMaterial(overlay)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	cam.End2D()
end)

hook.Add("RenderScreenspaceEffects", "visr", function()
	if not lp:VISR() then
		return
	end

	DrawColorModify({
		["$pp_colour_addr"] = 0.1,
		["$pp_colour_addg"] = 0.1,
		["$pp_colour_addb"] = 0,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_brightness"] = -0.1,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	})

	DrawBloom(0.07, 0.5, 1, 1, 1, 1, 1, 1, 1)
end)

hook.Add("PreDrawOutlines", "visr", function()
	if not lp:VISR() then
		return
	end

	local tab = EntityCache.Copy("npcs")

	table.Add(tab, player.GetAll())

	local colors = {}

	for _, base in pairs(tab) do
		if not IsValid(base) or base:IsDormant() then
			continue
		end

		local entities, color = getEntities(base)

		if not entities then
			continue
		end

		local hex = color:ToHex(true)

		colors[hex] = colors[hex] or {
			_color = color
		}

		for _, ent in ipairs(entities) do
			table.insert(colors[hex], ent)
		end
	end

	for col, entities in pairs(colors) do
		local color = entities._color
		entities._color = nil

		outline.Add(entities, color, true, 0.01)
	end
end)
