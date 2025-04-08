module("Buttons", package.seeall)

All = All or {}
AccessTypes = AccessTypes or {}
TypeList = {}

EntityVar.Add("IsMapButton", {Default = false})
EntityVar.Add("ButtonName", {Default = ""})
EntityVar.Add("ButtonType", {Default = "default"})

GlobalVar.Add("ButtonData", {
	Default = {},
	ServerOnly = true,
	Persist = true,
	Mode = GLOBALVAR_MAP_NO_OVERRIDE
})

function Iterator()
	return pairs(All)
end

function AddAccessType(name, data)
	local color = Color(data.Color) or util.GetSeededColor(name, 0.5, 1)
	color.a = 50

	AccessTypes[name] = {
		Name = data.Name or name,
		Color = color,
		CanAccess = data.CanAccess or function(ent, ply) return true end,
		OnAccessGranted = data.OnAccessGranted or function(ent, ply) end,
		OnAccessDenied = data.OnAccessDenied or function(ent, ply, reason) end,
		PreUseCallback = data.PreUseCallback or function(ent, ply) end,
		PostUseCallback = data.PostUseCallback or function(ent, ply) end
	}

	table.insert(TypeList, name)
end

function GM:OnIsMapButtonChanged(ent)
	All[ent] = true
end

function GetAccessType(ent)
	return AccessTypes[ent:ButtonType()]
end

function OnRemoved(ent)
	All[ent] = nil
end

if SERVER then
	function Save()
		local data = {}

		for button in Iterator() do
			local mapCreationId = button:MapCreationID()

			if mapCreationId == -1 then
				continue
			end

			local props = {
				Name = button:ButtonName(true),
				Type = button:ButtonType(true)
			}

			if table.IsEmpty(props) then
				continue
			end

			data[mapCreationId] = props
		end

		GAMEMODE:SetButtonData(data)
	end

	function Load()
		local data = GAMEMODE:ButtonData()

		for button in Iterator() do
			if not IsValid(button) then
				continue
			end

			local entData = data[button:MapCreationID()]

			if entData then
				if entData.Name then
					button:SetButtonName(entData.Name, true)
				end

				if entData.Type and AccessTypes[entData.Type] then
					button:SetButtonType(entData.Type, true)
				end
			end
		end

		deferred.Cancel("buttons.save")
	end

	function GM:OnButtonDataChanged(old, new, loaded)
		if not loaded then
			return -- We only care about this when GlobalVars are loading in.
		end

		Load()
	end

	function OnCreated(ent)
		if not IsValid(ent) or ent:GetClass() != "func_button" then
			return
		end

		ent:SetIsMapButton(true)
	end

	function OnUse(ply, ent)
		if not ent:IsMapButton() then
			return
		end

		local define = GetAccessType(ent)
		local allowed, reason = define.CanAccess(ent, ply)

		if not allowed then
			define.OnAccessDenied(ent, ply, reason)

			return false
		end

		define.OnAccessGranted(ent, ply)
		define.PreUseCallback(ent, ply)

		-- Bit jank but it should work
		ply:Use(ent)

		define.PostUseCallback(ent, ply)

		return false
	end

	function GM:OnButtonNameChanged(ent, old, new, loaded)
		if not loaded then
			deferred.Call("buttons.save", 60, Save)
		end
	end

	function GM:OnButtonTypeChanged(ent, old, new, loaded)
		if not loaded then
			deferred.Call("buttons.save", 60, Save)
		end
	end
end
