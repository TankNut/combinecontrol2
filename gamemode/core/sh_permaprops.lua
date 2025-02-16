module("PermaProps", package.seeall)

List = List or {}

EntityVar.Add("PermaProp", {Default = false})
EntityVar.Add("PermaPropInfo", {ServerOnly = true})

local whitelist = {
	["prop_physics"] = true,
	["prop_effect"] = true
}

local toggleSaved = console.AddCommand("rpa_togglesaved", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) and whitelist[ent:GetClass()] then
		-- Context that gets passed to OnPermaPropChanged to write to PermaPropInfo
		Admin = ply

		ent:SetPermaProp(not ent:PermaProp())

		Admin = nil
	end
end)

toggleSaved:SetDescription("Toggles persistence on a prop or effect")
toggleSaved:SetExecutionContext(console.Server)
toggleSaved:SetAccess(console.IsAdmin)
toggleSaved:SetNoConsole()

hook.Add("IsProtectedEntity", "plugins.permaprops", function(ent)
	if ent:PermaProp() then
		return true
	end
end)

if SERVER then
	local dir = DataFolder .. "permaprops/"

	file.CreateDir(dir)

	function GM:WritePermaPropData(data, ent)
		data.Class = ent:GetClass()

		local mdl = data.Class == "prop_effect" and ent.AttachedEntity or ent

		data.Model = mdl:GetModel()
		data.Skin = mdl:GetSkin()

		data.Pos = ent:GetPos()
		data.Ang = ent:GetAngles()

		data.CollisionGroup = ent:GetCollisionGroup()

		data.RenderMode = mdl:GetRenderMode()
		data.RenderFX = mdl:GetRenderFX()

		data.Color = mdl:GetColor()

		local mat = mdl:GetMaterial()

		if #mat > 0 then
			data.Material = mat
		else
			local submaterials = {}

			for i = 0, 31 do
				local submat = mdl:GetSubMaterial(i)

				if #submat > 0 then
					submaterials[i] = submat
				end
			end

			if table.Count(submaterials) > 0 then
				data.SubMaterials = submaterials
			end
		end

		data.Description = ent:PropDescription()
		data.PropInfo = ent:PermaPropInfo()

		data.SteamID = ent:OwnerID()
		data.Name = ent:OwnerName()
	end

	function Save()
		local data = {}

		for ent in pairs(List) do
			local entData = {}

			hook.Run("WritePermaPropData", entData, ent)

			table.insert(data, entData)
		end

		file.Write(dir .. game.GetMapOverride() .. ".txt", sfs.encode(data))

		timer.Remove("plugins.permaprops.save")
	end

	function GM:ReadPermaPropData(data)
		local ent = ents.Create(data.Class)

		ent:SetModel(data.Model)
		ent:SetSkin(data.Skin)

		ent:SetPos(data.Pos)
		ent:SetAngles(data.Ang)

		ent:Spawn()
		ent:Activate()

		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
			phys:Sleep()
		else
			ent:Remove()

			return
		end

		local mdl = data.Class == "prop_effect" and ent.AttachedEntity or ent

		ent:SetCollisionGroup(data.CollisionGroup)

		mdl:SetRenderMode(data.RenderMode)
		mdl:SetRenderFX(data.RenderFX)

		mdl:SetColor(data.Color)

		if data.Material then
			mdl:SetMaterial(data.Material)
		elseif data.SubMaterials then
			for index, mat in pairs(data.SubMaterials) do
				mdl:SetSubMaterial(index, mat)
			end
		end

		ent:SetOwnerID(data.SteamID, true)
		ent:SetOwnerName(data.Name, true)

		ent:SetPropDescription(data.Description, true)
		ent:SetPermaPropInfo(data.PropInfo, true)
		ent:SetPermaProp(true, true)
	end

	function Load()
		local path = dir .. game.GetMapOverride() .. ".txt"

		if not file.Exists(path, "DATA") then
			return
		end

		for ent in pairs(List) do
			ent:Remove()
		end

		for _, data in ipairs(sfs.decode(file.Read(path, "DATA"))) do
			hook.Run("ReadPermaPropData", data)
		end

		timer.Remove("plugins.permaprops.save")
	end

	function GM:OnPermaPropChanged(ent, old, new, loaded)
		List[ent] = new and true or nil

		if loaded then
			return
		end

		if new then
			local propInfo = ent:PermaPropInfo() or {}

			propInfo.Admin = Admin and string.format("%s (%s)", Admin:VisibleRPName(), Admin:SteamID()) or nil
			propInfo.Time = os.time()

			ent:SetPermaPropInfo(propInfo)

			undo.ReplaceEntity(ent, NULL)
			cleanup.ReplaceEntity(ent, NULL)

			constraint.RemoveAll(ent)

			local phys = ent:GetPhysicsObject()

			if IsValid(phys) then
				phys:EnableMotion(false)
				phys:Sleep()
			end
		end

		timer.Create("plugins.permaprops.save", 60, 1, function()
			Save()
		end)
	end

	hook.Add("GetPropInfo", "plugins.permaprops", function(args, ply, ent)
		local data = args[2]
		local info = ent:PermaPropInfo()

		if ent:PermaProp() and info then
			table.insert(data, "<c=white>-- PermaProp info --</c>")
			table.insert(data, info.Admin and "  Permapropped by: " .. info.Admin or "Permapropped through unknown means")
			table.insert(data, string.format("  Saved: %s ago", string.NiceTime(os.difftime(os.time(), info.Time))))
		end
	end, POST_HOOK_RETURN)

	hook.Add("EntityTakeDamage", "plugins.permaprops", function(ent)
		if List[ent] then
			return true
		end
	end)

	hook.Add("EntityRemoved", "plugins.permaprops", function(ent)
		if List[ent] then
			List[ent] = nil
		end
	end)

	local function runQueuedSave()
		if timer.Exists("plugins.permaprops.save") then
			Save()
		end
	end

	hook.Add("ShutDown", "plugins.permaprops", runQueuedSave)
	hook.Add("PreCleanupMap", "plugins.permaprops", runQueuedSave)

	hook.Add("PostCleanupMap", "plugins.permaprops", Load)
	hook.Add("InitPostEntity", "plugins.permaprops", Load)
end
