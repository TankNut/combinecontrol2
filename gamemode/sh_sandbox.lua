if SERVER then
	net.Receive("nSetPropDesc", function(len, ply)
		local MAX_CHARS = 140

		local ent = net.ReadEntity()
		local description = string.Trim(net.ReadString())

		if #description > MAX_CHARS then
			net.Start("nPropDescTooLong")
				net.WriteFloat(MAX_CHARS)
			net.Send(ply)
		else
			if IsValid(ent) then
				GAMEMODE:WriteLog("sandbox_propdesc", {Char = GAMEMODE:LogCharacter(ply), Ply = GAMEMODE:LogPlayer(ply), Ent = tostring(ent), Before = ent:PropDescription(), After = description})
				ent:SetPropDescription(description)
			end
		end
	end)
end

net.Receive("nPropDescTooLong", function (len)
	if SERVER then return end

	local maxChars = net.ReadFloat()
	lp:SendChat("ERROR", "Prop descriptions are limited to " .. maxChars)
end)

GM.PropBlacklist = {
	"*models/maxofs2d/",
	"*models/balloons/",
	"*models/perftest/",
	"*models/props_explosive/",
	"*models/props_phx/[^/]+%.mdl",
	"*models/props_phx/huge/",
	"*models/props_phx/misc/",
	"*models/props_phx/trains/",
	"*models/shadertest/",
	"models/combine_room/combine_monitor002.mdl",
	"models/combine_room/combine_monitor003a.mdl",
	"models/cranes/crane_frame.mdl",
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_c17/metalladder003.mdl",
	"models/props_c17/furniturechair001a.mdl",
	"models/props_combine/breen_tube.mdl",
	"models/props_combine/combine_bunker01.mdl",
	"models/props_combine/combine_tptimer.mdl",
	"models/props_combine/prison01.mdl",
	"models/props_combine/prison01c.mdl",
	"models/props_combine/prison01b.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_junk/propane_tank001a.mdl",
	"models/props_canal/canal_bridge01.mdl",
	"models/props_canal/canal_bridge02.mdl",
	"models/props_canal/canal_bridge03a.mdl",
	"models/vehicles/car001b_hatchback.mdl",
	"models/props_phx/amraam.mdl",
	"models/props_phx/ball.mdl",
	"models/props_phx/mk-82.mdl",
	"models/props_phx/oildrum001_explosive.mdl",
	"models/props_phx/torpedo.mdl",
	"models/props_phx/ww2bomb.mdl"
}

GM.PropWhitelist = {
	"models/props_c17/furniturestove001a.mdl",
}

GM.ToolTrustBasic = {
	"weld",
	"nocollide",
	"remover",
	"camera",
	"colour",
	"material",
	"rope",
	"winch",
	"ballsocket",
	"nocollideworld",
	"door",
	"button"
}

GM.ToolTrustBlacklist = {
	"duplicator",
	"balloon",
	"dynamite",
	"eyeposer",
	"faceposer",
	"finger",
	"inflator",
	"trails",
	"creator",
	"rb655_easy_inspector",
	"rb655_easy_bodygroup",
	"particlecontrol_proj",
	"streamradio_gui_color_global",
	"streamradio_gui_color_individual",
	"streamradio_gui_skin",
	"particlecontrol",
	"particlecontrol_tracer"
}

GM.SandboxBlacklist = {
	"prop_door_rotating",
	"func_door_rotating",
	"func_door",
	"func_monitor",
	"func_brush",
	"func_detail",
	"func_lod",
	"prop_dynamic",
	"prop_dynamic_override",
	"func_breakable",
	"func_movelinear",
	"func_button",
	"func_breakable_surf",
	"env_headcrabcanister",
}

function GM:LimitReachedProcess(ply, str)
	if game.SinglePlayer() then return true end

	if not IsValid(ply) then
		return true
	end

	local c = cvars.Number("sbox_max" .. str, 0)

	if str == "props" then
		if ply:ToolTrust() == TOOLTRUST_BASIC then c = c * 2 end
		if ply:ToolTrust() == TOOLTRUST_ADVANCED then c = c * 5 end
	end

	if ply:GetCount(str) < c or c < 0 then return true end

	ply:LimitHit(str)

	return false
end

function GM:ContextMenuOpen()
	return LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool" and not CCP.ContextMenu
end

function GM:PlayerGiveSWEP(ply, weapon, info)
	return ply:IsSuperAdmin()
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function GM:PlayerSpawnedProp(ply, model, ent)
	if not table.HasValue(self.PropWhitelist, string.lower(model)) then
		if not ply:IsAdmin() and ent:BoundingRadius() > 800 and ply:ToolTrust() == TOOLTRUST_ADVANCED then
			self:LogSandbox("[S] " .. ply:VisibleRPName() .. " tried to spawn prop " .. model .. ", but it was too big (" .. math.Round(ent:BoundingRadius()) .. " > 800).", ply)

			ent:Remove()

			net.Start("nAddNotification")
				net.WriteString("That prop is too big.")
			net.Send(ply)

			return false
		end

		if not ply:IsAdmin() and ent:BoundingRadius() > 200 and ply:ToolTrust() == TOOLTRUST_BASIC then
			self:LogSandbox("[S] " .. ply:VisibleRPName() .. " tried to spawn prop " .. model .. ", but it was too big (" .. math.Round(ent:BoundingRadius()) .. " > 200).", ply)

			ent:Remove()

			net.Start("nAddNotification")
				net.WriteString("That prop is too big.")
			net.Send(ply)

			return false
		end

		if not ply:IsAdmin() and ent:BoundingRadius() > 100 and ply:ToolTrust() == TOOLTRUST_BANNED then
			self:LogSandbox("[S] " .. ply:VisibleRPName() .. " tried to spawn prop " .. model .. ", but it was too big (" .. math.Round(ent:BoundingRadius()) .. " > 100).", ply)

			ent:Remove()

			net.Start("nAddNotification")
				net.WriteString("That prop is too big.")
			net.Send(ply)

			return false
		end
	end

	-- if ply:ToolTrust() < TOOLTRUST_BASIC and not ply:IsAdmin() then
	-- 	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	-- end

	return self.BaseClass:PlayerSpawnedProp(ply, model, ent)
end

function GM:PlayerSpawnEffect(ply, model)
	if ply:IsAdmin() then
		if SERVER then
			self:WriteLog("sandbox_spawn_generic", {Char = self:LogCharacter(ply), Ply = self:LogPlayer(ply), Mdl = model})
			self:LogSandbox("[E] " .. ply:VisibleRPName() .. " spawned effect " .. model .. ".", ply)
		end

		return true
	end

	if ply:PassedOut() then return false end
	if ply:TiedUp() then return false end

	if ply:PropTrust() == PROPTRUST_BANNED then return false end

	if ply:ToolTrust() < TOOLTRUST_ADVANCED then
		if not ply.NextPropSpawn then ply.NextPropSpawn = 0 end
		if CurTime() < ply.NextPropSpawn then return false end
		ply.NextPropSpawn = CurTime() + 1
	end

	if not ply:Alive() then return false end

	if ply:DonatorActive() or self:LimitReachedProcess(ply, "effects") then
		if SERVER then
			self:WriteLog("sandbox_spawn_generic", {Char = self:LogCharacter(ply), Ply = self:LogPlayer(ply), Mdl = model})
			self:LogSandbox("[E] " .. ply:VisibleRPName() .. " spawned effect " .. model .. ".", ply)
		end

		return true
	end

	return false
end

function GM:PlayerSpawnNPC(ply, npctype, weapon)
	if ply:IsAdmin() then
		if SERVER then
			self:WriteLog("sandbox_spawn_npc", {Char = self:LogCharacter(ply), Ply = self:LogPlayer(ply), Class = npctype})
			self:LogSandbox("[N] " .. ply:VisibleRPName() .. " spawned NPC " .. npctype .. ".", ply)
		end

		return true
	end

	return false
end

function GM:PlayerSpawnProp(ply, model)
	model = model:lower():gsub("\\", "/")

	if ply:IsAdmin() then
		if SERVER then
			self:WriteLog("sandbox_spawn_generic", {Char = self:LogCharacter(ply), Ply = self:LogPlayer(ply), Mdl = model})
			self:LogSandbox("[S] " .. ply:VisibleRPName() .. " spawned prop " .. model .. ".", ply)
		end

		return true
	end

	if ply:PassedOut() then return false end
	if ply:TiedUp() then return false end

	if ply:PropTrust() == PROPTRUST_BANNED then return false end

	if ply:ToolTrust() < TOOLTRUST_ADVANCED then
		if not ply.NextPropSpawn then ply.NextPropSpawn = 0 end
		if CurTime() < ply.NextPropSpawn then return false end
		ply.NextPropSpawn = CurTime() + 1
	end

	if table.HasValue(self.PropBlacklist, string.lower(model)) then
		if CLIENT then
			GAMEMODE:AddNotification("That prop is banned.")
		end

		return false
	end

	for _, v in pairs(self.PropBlacklist) do
		if string.find(v, "*") == 1 and string.find(string.lower(model), string.sub(v, 2), nil, true) then
			if CLIENT then
				GAMEMODE:AddNotification("That prop is banned.")
			end

			return false
		end
	end

	if not ply:Alive() then return false end

	if ply:DonatorActive() or self:LimitReachedProcess(ply, "props") then
		if SERVER then
			self:WriteLog("sandbox_spawn_generic", {Char = self:LogCharacter(ply), Ply = self:LogPlayer(ply), Mdl = model})
			self:LogSandbox("[S] " .. ply:VisibleRPName() .. " spawned prop " .. model .. ".", ply)
		end

		return true
	end

	return false
end

function GM:PlayerSpawnRagdoll(ply, model)
	if ply:IsAdmin() then
		if SERVER then
			self:WriteLog("sandbox_spawn_generic", {Char = GAMEMODE:LogCharacter(ply), Ply = GAMEMODE:LogPlayer(ply), Mdl = model})
			self:LogSandbox("[R] " .. ply:VisibleRPName() .. " spawned ragdoll " .. model .. ".", ply)
		end

		return true
	end

	if ply:PassedOut() then return false end
	if ply:TiedUp() then return false end

	if ply:DonatorActive() or self:LimitReachedProcess(ply, "ragdolls") then
		if SERVER then
			self:WriteLog("sandbox_spawn_generic", {Char = GAMEMODE:LogCharacter(ply), Ply = GAMEMODE:LogPlayer(ply), Mdl = model})
			self:LogSandbox("[R] " .. ply:VisibleRPName() .. " spawned ragdoll " .. model .. ".", ply)
		end

		return true
	end

	return false
end

function GM:PlayerSpawnSENT(ply, class)
	local whitelisted = false

	if ply:IsAdmin() or whitelisted then
		if SERVER then
			self:WriteLog("sandbox_spawn_entity", {Char = GAMEMODE:LogCharacter(ply), Ply = GAMEMODE:LogPlayer(ply), Class = class})
			self:LogSandbox("[E] " .. ply:VisibleRPName() .. " spawned entity " .. class .. ".", ply)
		end

		return true
	end

	return false
end

function GM:PlayerSpawnSWEP(ply, class, info)
	if not ply:IsAdmin() then
		return false
	end

	if SERVER then
		self:WriteLog("sandbox_spawn_weapon", {Char = GAMEMODE:LogCharacter(ply), Ply = GAMEMODE:LogPlayer(ply), Class = class})
		self:LogSandbox("[W] " .. ply:VisibleRPName() .. " spawned SWEP " .. class .. ".", ply)
	end

	return true
end

function GM:PlayerSpawnVehicle(ply, model, name, tab)
	if ply:IsAdmin() then
		if SERVER then
			self:WriteLog("sandbox_spawn_vehicle", {Char = GAMEMODE:LogCharacter(ply), Ply = GAMEMODE:LogPlayer(ply), Type = name})
			self:LogSandbox("[V] " .. ply:VisibleRPName() .. " spawned vehicle " .. name .. ".", ply)

		end

		return true
	end

	return false
end

function GM:NoToolLog(ply, tr, tool)
	if tool == "paint" then return true end
	if tool == "duplicator" then return true end
	if tool == "creator" then return true end

	if tool == "remover" and tr.Entity == game.GetWorld() then
		return true
	end

	if IsValid(tr.Entity) then
		local c = tr.Entity:GetClass()

		if c == "gmod_" .. tool then
			return true
		end
	end

	return false
end

local blacklist = {
	["persist"] = true,
	["drive"] = true,
	["bonemanipulate"] = true,
	["remove"] = true,
	["npc_bigger"] = true,
	["npc_smaller"] = true
}

function GM:CanProperty(ply, prop, ent)
	if not ply:IsAdmin() then
		return false
	end

	if ent:IsProtectedEntity() then
		return false
	end

	if blacklist[prop] then
		return false
	end

	return true
end

function GM:PostCleanupMap()
	if SERVER then
		for _, v in player.Iterator() do
			self:PlayerLoadout(v)
			self:PlayerCheckInventory(v)
		end
	end
end


function GM:DrawPhysgunBeam(ply, weapon, bOn, target, boneid, pos)
	return true
end
