ctp = ctp or {} local ctp = ctp

ctp.AllowedClasses = {
	"player",
	"prop_",
	"npc_",
}

ctp.DisabledElements = {
	"CHudSuitPower",
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo",
	"CHudEPOE",
}

ctp.BoneList = {
	["pelvis"] = "ValveBiped.Bip01_Pelvis",
	["spine_1"] = "ValveBiped.Bip01_Spine",
	["spine_2"] = "ValveBiped.Bip01_Spine1",
	["spine_3"] = "ValveBiped.Bip01_Spine2",
	["spine_4"] = "ValveBiped.Bip01_Spine4",
	["neck"] = "ValveBiped.Bip01_Neck1",
	["head"] = "ValveBiped.Bip01_Head1",
	["right_clavicle"] = "ValveBiped.Bip01_R_Clavicle",
	["right_upper arm"] = "ValveBiped.Bip01_R_UpperArm",
	["right_forearm"] = "ValveBiped.Bip01_R_Forearm",
	["right_hand"] = "ValveBiped.Bip01_R_Hand",
	["left_clavicle"] = "ValveBiped.Bip01_L_Clavicle",
	["left_upper arm"] = "ValveBiped.Bip01_L_UpperArm",
	["left_forearm"] = "ValveBiped.Bip01_L_Forearm",
	["left_hand"] = "ValveBiped.Bip01_L_Hand",
	["right_thigh"] = "ValveBiped.Bip01_R_Thigh",
	["right_calf"] = "ValveBiped.Bip01_R_Calf",
	["right_foot"] = "ValveBiped.Bip01_R_Foot",
	["right_toe"] = "ValveBiped.Bip01_R_Toe0",
	["left_thigh"] = "ValveBiped.Bip01_L_Thigh",
	["left_calf"] = "ValveBiped.Bip01_L_Calf",
	["left_foot"] = "ValveBiped.Bip01_L_Foot",
	["left_toe"] = "ValveBiped.Bip01_L_Toe0",
	["none"] = "none",
}

ctp.DisabledHooks = {
	"CalcView",
	"CalcVehicleThirdPersonView",
}

ctp.HistoryCount = 10

local function HOOK(name, func)
	hook.Add(name, "ctp_" .. name, func or ctp[name])
end

local function UNHOOK(name)
	local unique = "ctp_" .. name
	local hooks = hook.GetTable()
	if hooks[name] and hooks[name][unique] then
		hook.Remove(name, unique)
	end
end

function ctp:Initialize()
	self.SmoothOrigin = self.SmoothOrigin or Vector(0, 0, 0)
	self.SmoothDirection = self.SmoothDirection or Vector(0, 0, 0)
	self.SmoothFOV = self.SmoothFOV or 0

	local vectors = {}

	for i = 1, self.HistoryCount do
		table.insert(vectors, vector_origin)
	end

	self.PrevOrigin = self.PrevOrigin or Vector(0, 0, 0)
	self.PlyPosHistory = vectors
	self.PrevDirection = self.PrevDirection or Vector(0, 0, 0)
	self.DirectionHistory = vectors
	self.PrevFOV = self.PrevFOV or 0

	self.RelativeOriginSpeed = 1

	self.Direction = self.Direction or Vector(0, 0, 0)

	self.Roll = self.Roll or 0
	self.SmoothRoll = self.SmoothRoll or 0

	self.CVars = {}

	self:InitCVars()
end

do -- luadata
	local luadata = {}

	local tab = 0

	luadata.Types = {
		["number"] = function(var)
			return ("%s"):format(var)
		end,
		["string"] = function(var)
			return ("%q"):format(var)
		end,
		["boolean"] = function(var)
			return ("%s"):format(var and "true" or "false")
		end,
		["Vector"] = function(var)
			return ("Vector(%s, %s, %s)"):format(var.x, var.y, var.z)
		end,
		["Angle"] = function(var)
			return ("Angle(%s, %s, %s)"):format(var.p, var.y, var.r)
		end,
		["table"] = function(var)
			if
				type(var.r) == "number" and
				type(var.g) == "number" and
				type(var.b) == "number" and
				type(var.a) == "number"
			then
				return ("Color(%s, %s, %s, %s)"):format(var.r, var.g, var.b, var.a)
			end

			tab = tab + 1
			local str = luadata.Encode(var, true)
			tab = tab - 1
			return str
		end,
	}

	function luadata.SetModifier(luaType, callback)
		luadata.Types[luaType] = callback
	end

	function luadata.Type(var)
		local t

		if IsEntity(var) then
			if var:IsValid() then
				t = "Entity"
			else
				t = "NULL"
			end
		else
			t = type(var)
		end

		if t == "table" and var.LuaDataType then
			t = var.LuaDataType
		end

		return t
	end

	function luadata.ToString(var)
		local func = luadata.Types[luadata.Type(var)]
		return func and func(var)
	end

	function luadata.Encode(tbl, __brackets)
		local str = __brackets and "{\n" or ""

		for key, value in pairs(tbl) do
			value = luadata.ToString(value)
			key = luadata.ToString(key)

			if key and value and key != "__index" then
				str = str .. ("\t"):rep(tab) ..  ("[%s] = %s,\n"):format(key, value)
			end
		end

		str = str .. ("\t"):rep(tab-1) .. (__brackets and "}" or "")

		return str
	end

	function luadata.Decode(str)
		local func = CompileString("return {\n" .. str .. "\n}", "luadata", false)

		if type(func) == "string" then
			MsgN("luadata decode error:")
			MsgN(func)

			return {}
		end

		local ok, err = pcall(func)

		if not ok then
			MsgN("luadata decode error:")
			MsgN(err)
			return {}
		end

		return err
	end

	do -- file extension
		function luadata.WriteFile(path, tbl)
			file.Write(path, luadata.Encode(tbl))
		end

		function luadata.ReadFile(path)
			return luadata.Decode(file.Read(path) or "")
		end
	end

	ctp.luadata = luadata
end

do -- CVars

	function ctp:InitCVars()
		self:RegisterCVar("threshold_enabled", "ThresholdEnabled", "boolean")
		self:RegisterCVar("threshold_radius", "ThresholdRadius", "float", nil, 10)

		self:RegisterCVar("offset_relative", "OffsetRelative", "boolean")
		self:RegisterCVar("offset_lock_z", "ZLockEnabled", "boolean")

		self:RegisterCVar("offset_fov_zoom_distance_enabled", "ZoomDistanceEnabled", "boolean")
		self:RegisterCVar("offset_fov_zoom_distance", "ZoomDistance", "float")
		self:RegisterCVar("offset_fov_zoom_distance_min", "MinZoomDistance", "float")
		self:RegisterCVar("offset_fov", "FOV", "float")
		self:RegisterCVar("offset_right", "Right", "float")
		self:RegisterCVar("offset_forward", "Forward", "float")
		self:RegisterCVar("offset_up", "Up", "float")

		self:RegisterCVar("smoother_origin", "OriginSmoother", "float")
		self:RegisterCVar("smoother_direction", "DirectionSmoother", "float")
		self:RegisterCVar("smoother_fov", "FOVSmoother", "float")

		self:RegisterCVar("lerp_aim", "AimLerp", "float")

		self:RegisterCVar("angles_roll_amount", "RollAmount", "float")

		self:RegisterCVar("angles_limit", "AngleLimitEnabled", "boolean")
		self:RegisterCVar("angles_limit_smooth", "AngleLimitSmoothEnabled", "boolean")

		self:RegisterCVar("angles_pitch", "UserPitch", "float")
		self:RegisterCVar("angles_yaw", "UserYaw", "float")
		self:RegisterCVar("angles_roll", "UserRoll", "float")

		self:RegisterCVar("movement_lock_pitch", "LockPitchEnabled", "boolean")

		self:RegisterCVar("center_offset_forward", "CenterOffsetForward", "float")
		self:RegisterCVar("center_offset_right", "CenterOffsetRight", "float")
		self:RegisterCVar("center_offset_up", "CenterOffsetUp", "float")

		self:RegisterCVar("bone_name", "Bone", "string")

		self:RegisterCVar("trace_enable", "TraceBlockEnabled", "boolean")
		self:RegisterCVar("trace_smooth", "TraceBlockSmoothEnabled", "boolean")
		self:RegisterCVar("trace_forward", "TraceForward", "float")
		self:RegisterCVar("trace_down", "TraceDown", "float")

		self:RegisterCVar("near_z", "NearZ", "float")

	end

	function ctp:GetCVarValue(name)
		return self[self.CVars[name]].GetVar()
	end

	local function clamp(num, min, max)
		if not min and not max then
			return num
		end

		if min and not max then
			return math.max(num, min)
		end

		if max and not min then
			return math.min(num, max)
		end

		return math.Clamp(num, min, max)
	end

	function ctp:RegisterCVar(name, namefunc, luaType, dontsave, min, max)
		name = name:lower()
		luaType = luaType or "float"

		local default = ctp.DefaultPresets[2].cvars[name] -- CombineControl Third person

		if not default then
			print("ctp missing default value for", name)

			default = 0
		end

		self.CVars[name] = {cvar = CreateClientConVar("cl_ctp_" .. name, default, not dontsave), type = luaType, dontsave = dontsave}

		local function GetVar()
			return
				luaType == "boolean" and self.CVars[name].cvar:GetBool() or
				luaType == "integer" and clamp(self.CVars[name].cvar:GetInt(), min, max) or
				luaType == "float" and clamp(self.CVars[name].cvar:GetFloat(), min, max) or
				luaType == "string" and self.CVars[name].cvar:GetString()
		end

		self.CVars[name].GetVar = GetVar

		self[(luaType == "boolean" and "Is" or "Get") .. namefunc] = function()
			return GetVar()
		end
	end
end

do -- Enable
	CreateClientConVar("ctp_enabled", "0", false, true)

	local META = FindMetaTable("Player")

	function META:IsCTPEnabled()
		return self:GetNWBool("ctp_enabled")
	end

	function ctp:Enable()
		-- For shit like ctp.Enable() to match gmod's way.
		self = self or ctp

		if self:IsEnabled() then
			return
		end

		self:ResetSmoothers()

		for _, event in pairs(ctp.DisabledHooks) do
			local hooks = hook.GetTable()[event]

			if hooks then
				self.OldHooks = self.OldHooks or {}
				self.OldHooks[event] = self.OldHooks[event] or {}
				self.OldHooks[event] = table.Copy(hooks)

				for name in pairs(hooks) do
					hook.Remove(event, name)
				end
			end
		end

		HOOK("CalcView", function(...) return ctp:CalcView(...) end)
		HOOK("CalcVehicleThirdPersonView", function(_, ...) return ctp:CalcView(...) end)
		HOOK("CreateMove", function(ucmd) return ctp:CreateMove(ucmd) end)
		HOOK("GUIMousePressed", function(...) return ctp:GUIMousePressed(...) end)
		HOOK("GUIMouseReleased", function(...) return ctp:GUIMouseReleased(...) end)
		HOOK("PreventScreenClicks", function(...) return ctp:PreventScreenClicks(...) end)

		self.Enabled = true

		RunConsoleCommand("ctp_enabled", "1")
	end

	function ctp:Disable()
		self = self or ctp

		if not self:IsEnabled() then
			return
		end

		if self.OldHooks then
			for event, hooks in pairs(self.OldHooks) do
				for name, func in pairs(hooks) do
					hook.Add(event, name, func)
				end
			end
		end

		UNHOOK("CalcView")
		UNHOOK("PreRender")
		UNHOOK("Think")
		UNHOOK("CalcVehicleThirdPersonView")
		UNHOOK("CreateMove")
		UNHOOK("GUIMousePressed")
		UNHOOK("GUIMouseReleased")
		UNHOOK("PreventScreenClicks")

		self.OldHooks = nil

		lp:SetEyeAngles(self:GetDirection():Angle())

		self.Enabled = false

		RunConsoleCommand("ctp_enabled", "0")
	end

	function ctp:IsEnabled()
		return self.Enabled
	end

	function ctp:Toggle()
		Settings.Set("Thirdperson", not Settings.Get("Thirdperson"))
	end

	function ctp:ShowMenu()
		if IsValid(ctp.Frame) then return end

		ctp.Frame = vgui.Create("ctp_MainFrame")
	end

	function ctp:CloseMenu()
		if IsValid(ctp.Frame) then ctp.Frame:Close() end
	end

	function ctp:IsMenuVisible()
		return IsValid(self.Frame)
	end

	function ctp:ToggleMenu()
		if ctp:IsMenuVisible() then
			ctp:CloseMenu()
		else
			ctp:ShowMenu()
		end
	end

	concommand.Add("ctp", function()
		ctp:Toggle()
	end)

	hook.Add("PopulateToolMenu", "ctp_PopulateToolMenu", function()
		spawnmenu.AddToolMenuOption("Options", "Visuals", "CTP", "CTP Options", "", "", function(panel)
			panel:AddPanel(vgui.Create("ctp_ContextMenu"))
		end)
	end)

end

do -- Presets
	do -- default
		ctp.DefaultPresets =
		{
			{
				["name"] = "Valve Thirdperson",
				["description"] = "This preset mimics valve's thirdperson camera",
				["cvars"] = {
					["offset_fov_zoom_distance"] = 1200,
					["smoother_origin"] = 40,
					["center_offset_forward"] = 0,
					["offset_right"] = 0,
					["trace_forward"] = 20,
					["lerp_aim"] = 100,
					["offset_up"] = 52,
					["threshold_radius"] = 0,
					["bone_name"] = "none",
					["angles_pitch"] = 0,
					["angles_roll_amount"] = 0,
					["movement_lock_pitch"] = 0,
					["trace_smooth"] = 1,
					["angles_yaw"] = 0,
					["threshold_enabled"] = 0,
					["smoother_direction"] = 40,
					["offset_fov_zoom_distance_enabled"] = 0,
					["offset_fov"] = 90,
					["offset_fov_zoom_distance_min"] = 7,
					["offset_relative"] = 1,
					["trace_down"] = 0,
					["offset_lock_z"] = 1,
					["offset_forward"] = -100,
					["angles_roll"] = 0,
					["center_offset_up"] = 0,
					["angles_limit"] = 0,
					["center_offset_right"] = 0,
					["trace_enable"] = 1,
					["angles_limit_smooth"] = 0,
					["near_z"] = 3,
					["smoother_fov"] = 40,
				},
			},
			{
				["name"] = "CombineControl Legacy Third Person",
				["description"] = "This preset mimics CombineControl's original thirdperson camera",
				["cvars"] = {
					["offset_fov_zoom_distance"] = 0,
					["smoother_origin"] = 6,
					["center_offset_forward"] = 0,
					["offset_right"] = 0,
					["trace_forward"] = 1,
					["lerp_aim"] = 85,
					["offset_up"] = 0,
					["threshold_radius"] = 10,
					["bone_name"] = "head",
					["angles_pitch"] = 0,
					["angles_roll_amount"] = 0,
					["movement_lock_pitch"] = 0,
					["trace_smooth"] = 0,
					["angles_yaw"] = 0,
					["threshold_enabled"] = 0,
					["smoother_direction"] = 6,
					["offset_fov_zoom_distance_enabled"] = 0,
					["offset_fov"] = 75,
					["offset_fov_zoom_distance_min"] = 0,
					["offset_relative"] = 1,
					["trace_down"] = 1,
					["offset_lock_z"] = 1,
					["offset_forward"] = -50,
					["angles_roll"] = 0,
					["center_offset_up"] = 0,
					["angles_limit"] = 0,
					["center_offset_right"] = 0,
					["trace_enable"] = 1,
					["angles_limit_smooth"] = 0,
					["near_z"] = 3,
					["smoother_fov"] = 40,
				},
			},
			{
				["name"] = "Cinematic",
				["description"] = " A cinematic camera",
				["cvars"] = {
					["offset_fov_zoom_distance"] = 800,
					["smoother_origin"] = 1,
					["center_offset_forward"] = 0,
					["offset_right"] = 0,
					["trace_forward"] = 20,
					["lerp_aim"] = 100,
					["offset_up"] = 0,
					["threshold_radius"] = 250,
					["bone_name"] = "none",
					["angles_pitch"] = 0,
					["angles_roll_amount"] = 0,
					["movement_lock_pitch"] = 0,
					["trace_smooth"] = 1,
					["angles_yaw"] = 0,
					["threshold_enabled"] = 1,
					["smoother_direction"] = 5,
					["offset_fov_zoom_distance_enabled"] = 0,
					["offset_fov"] = 50,
					["offset_fov_zoom_distance_min"] = 7,
					["offset_relative"] = 1,
					["trace_down"] = 30,
					["offset_lock_z"] = 1,
					["offset_forward"] = 0,
					["angles_roll"] = 0,
					["center_offset_up"] = 0,
					["angles_limit"] = 1,
					["center_offset_right"] = 0,
					["trace_enable"] = 1,
					["angles_limit_smooth"] = 1,
					["smoother_fov"] = 3,
				},
			}
		}
	end

	function ctp:SaveCVarPreset(name, description)
		local tbl = {}

		tbl.name = name
		tbl.description = description or "no description"
		tbl.cvars = {}

		for key, cvar in pairs(self.CVars) do
			if not cvar.dontsave then
				tbl.cvars[key] = cvar.GetVar()
			end
		end

		file.CreateDir("ctp")
		file.CreateDir("ctp/cvar_presets")

		ctp.luadata.WriteFile("ctp/cvar_presets/" .. name .. ".txt", tbl, "DATA")
	end

	function ctp:LoadCVarPreset(name)
		local tbl = self.CurrentPresets[name] or ctp.luadata.ReadFile("ctp/cvar_presets/" .. name .. ".txt")

		if not tbl.cvars then
			MsgN("CTP tried to load cvar preset '" .. name .. "' but it doesn't exist!")
			return
		end

		for key, value in pairs(tbl.cvars) do
			key = "cl_ctp_" .. key

			if not ConVarExists(key) then
				continue
			end

			RunConsoleCommand(key, tostring(value))
		end

		self.CurrentCVarPreset = tbl
	end

	function ctp:GetCurrentCVarPreset()
		return self.CurrentCVarPreset
	end

	function ctp:DeleteCVarPreset(name)
		file.Delete("ctp/cvar_presets/" .. name .. ".txt", "DATA")
	end

	ctp.CurrentPresets = {}

	function ctp:GetCVarPresets(folder)
		folder = folder or "ctp/cvar_presets/"

		local tbl = {}

		local files = file.Find(folder .. "*", "DATA")

		for key, preset in pairs(files) do
			local presetData = ctp.luadata.ReadFile(folder .. preset, "DATA")

			if presetData.cvars then
				tbl[presetData.name] = presetData.description != "none" and presetData.description or ""

				self.CurrentPresets[presetData.name] = presetData
			end
		end

		for key, preset in pairs(ctp.DefaultPresets) do
			tbl[preset.name] = preset.description != "none" and preset.description or ""

			self.CurrentPresets[preset.name] = preset
		end

		return tbl
	end
end

do -- Meta
	AccessorFunc(ctp, "Origin", "Origin")
	AccessorFunc(ctp, "PrevOrigin", "PrevOrigin")

	-- Max map grid size is 32000, so there's no need for the camera to go outside these boundaries. It also prevents INF and NAN
	function ctp:SetOrigin(a)
		self.Origin = Vector(math.Clamp(a.x, -32000, 32000), math.Clamp(a.y, -32000, 32000), math.Clamp(a.z, -32000, 32000))
	end

	AccessorFunc(ctp, "Direction", "Direction")
	AccessorFunc(ctp, "PrevDirection", "PrevDirection")
	AccessorFunc(ctp, "DesiredDirection", "DesiredDirection")

	function ctp:SetDirection(a)
		self.Direction = Vector(math.Clamp(a.x, -1, 1), math.Clamp(a.y, -1, 1), math.Clamp(a.z, -1, 1))
	end

	AccessorFunc(ctp, "Angles", "Angles")

	function ctp:GetAngles()
		return self:GetDirection():Angle()
	end

	function ctp:GetPrevAngles()
		return self:GetPrevDirection():Angle()
	end

	AccessorFunc(ctp, "Roll", "Roll")
	AccessorFunc(ctp, "FOV", "FOV")
	AccessorFunc(ctp, "PrevFOV", "PrevFOV")
	AccessorFunc(ctp, "RelativeOriginSpeed", "RelativeOriginSpeed")

	function ctp:GetFrameTime()
		return math.min(FrameTime(), 0.05)
	end

	function ctp:GetPlayerPos()
		if false and lp:GetVehicle():IsVehicle() then
			local ent = lp:GetVehicle()
			local pos = ent:GetPos() + Vector(0,0,36)

			pos = pos + (Angle(0, ent:GetAngles().p, 0):Forward() * -self:GetCenterOffsetRight())
			pos = pos + (Angle(0, ent:GetAngles().y, 0):Forward() * self:GetCenterOffsetForward())
			pos = pos + (ent:GetAngles():Up() * self:GetCenterOffsetUp())

			return pos
		else
			local bone = self:GetOverrideBone(lp:GetModel(), self:GetBone())
			local pos

			if bone then
				local id = lp:LookupBone(bone)

				if id then
					pos = lp:GetBonePosition(id)
				else
					pos = lp:GetPos() + Vector(0, 0, lp:GetCurrentViewOffset().z)
				end
			end

			if not pos then
				pos = lp:GetPos() + Vector(0,0,36)
			end

			pos = pos + (Angle(0, lp:EyeAngles().p, 0):Forward() * -self:GetCenterOffsetRight())
			pos = pos  + (Angle(0, lp:EyeAngles().y, 0):Forward() * self:GetCenterOffsetForward())
			pos = pos  + (lp:EyeAngles():Up() * self:GetCenterOffsetUp())

			return pos
		end
	end

	function ctp:ResetSmoothers()
		self.SmoothOrigin = lp:EyePos()
		self.SmoothDirection = lp:EyeAngles():Forward()
		self.SmoothFOV = lp:GetFOV()
	end

	function ctp:GetDirectionVelocity()
		return self.DirectionHistory[1] - self.DirectionHistory[self.HistoryCount-1]
	end

	function ctp:GetPlyPosDelta()
		return self.PlyPosHistory[1] - self.PlyPosHistory[self.HistoryCount-1]
	end

	function ctp:GetFOV()
		local wep = lp:GetActiveWeapon()

		if wep:IsValid() and wep:GetClass() == "gmod_camera" then
			return lp:GetFOV()
		end

		return self.FOV
	end
end

function ctp:ShouldDoThirdPerson(ply)
	return hook.Run("ShouldDoThirdPerson", ply)
end

do -- CalcView

	function ctp:CalcView()
		if GetViewEntity() != lp then return end

		if ctp:ShouldDoThirdPerson(lp) then

			self:PreCalcView()

			table.insert(self.PlyPosHistory, lp:GetPos())

			if #self.PlyPosHistory > self.HistoryCount then
				table.remove(self.PlyPosHistory, 1)
			end

			local pos = self.Origin
			local ang = self.Direction:Angle() + Angle(-self:GetUserPitch(), self:GetUserYaw(), self:GetUserRoll() + self.Roll) + LocalPlayer():GetViewPunchAngles()
			local fov = math.Clamp(self:GetFOV() or 0, 1, 150)

			local weapon = lp:GetActiveWeapon()

			if IsValid(weapon) and weapon.GetZoom then
				fov = fov / weapon:GetZoom()
			end

			local tbl = {
				origin = pos,
				angles = ang,
				fov = fov,

				znear = math.max(self:GetNearZ(), 0.1),
			}

			return tbl
		end
	end

	function ctp:PreCalcView()

		local ply = LocalPlayer()

		if not self.taunt_cam_hacked and ply.m_CurrentPlayerClass then
			local data = ply.m_CurrentPlayerClass.TauntCam

			if data then
				if data.CreateMove then
					local old = data.CreateMove
					data.CreateMove = function(...)
						if not self:IsEnabled() then
							return old(...)
						end
					end
				end

				--Simple check to make sure we're only drawing the local player when needed. Can probably be streamlined to reduce checks by a factor of two
				-- Overhead's not to major though.
				if ctp:ShouldDoThirdPerson(LocalPlayer()) then
					data.ShouldDrawLocalPlayer = true
				else
					data.ShouldDrawLocalPlayer = false
				end

				-- if data.ShouldDrawLocalPlayer then  --This method of local player drawing doesn't work with what we have in mind
				-- 	local old = data.ShouldDrawLocalPlayer
				-- 	data.ShouldDrawLocalPlayer = function(...)
				-- 		if not self:IsEnabled() then
				-- 			return old(...)
				-- 		end
				-- 	end
				-- end

				if data.CalcView then
					local old = data.CalcView
					data.CalcView = function(...)
						if not self:IsEnabled() then
							return old(...)
						end
					end
				end

				self.taunt_cam_hacked = true
			end
		end

		self.Origin = self:GetPlayerPos()
		self.Direction = vector_origin
		self.Angles = lp:EyeAngles()
		self.FOV = 0

		if self:IsZoomDistanceEnabled() then
			self:CalcFOV()
		end

		if not self:IsThresholdEnabled() then
			self:CalcOffsets()
		end

		if self:IsThresholdEnabled() then
			self:CalcThreshold()
		end

		self:CalcDirection()
		self:CalcRoll()

		if self:IsTraceBlockEnabled() and self:IsTraceBlockSmoothEnabled() then
			self:CalcTraceBlock()
		end

		if self:GetTraceDown() > 0 then
			self:CalcDownTrace()
		end

		if self:IsAngleLimitEnabled() and self:IsAngleLimitSmoothEnabled() then
			self:CalcAngleLimit()
		end

		self:CalcSmoothing()

		if self:IsAngleLimitEnabled() and not self:IsAngleLimitSmoothEnabled() then
			self:CalcAngleLimit()
		end

		if self:IsTraceBlockEnabled() and not self:IsTraceBlockSmoothEnabled() then
			self:CalcTraceBlock()
		end

		self.PrevOrigin = self.Origin
		self.PrevDirection = self.Direction
		self.PrevFOV = self.FOV
	end

	function ctp:CalcFOV()
		self:SetFOV(math.Clamp((-(self:GetPlayerPos() - self:GetPrevOrigin()):Length() + self:GetZoomDistance())  / (self:GetZoomDistance() / 100), self:GetMinZoomDistance(), 75))
	end

	function ctp:CalcOffsets()
		local offset

		if self:IsOffsetRelative() then
			local ang = lp:EyeAngles()

			if not self:IsZLockEnabled() then
				ang.p = 0
			end

			offset = LocalToWorld(Vector(self:GetForward(), -self:GetRight(), self:GetUp()), angle_zero, vector_origin, ang)
		else
			offset = Vector(-self:GetForward(), -self:GetRight(), self:GetUp())
		end

		self:SetOrigin(self:GetOrigin() + offset)

		return offset
	end

	function ctp:CalcDirection(origin)
		local lerp = self:GetAimLerp() / 100 * 2

		local player = ((origin or self:GetPlayerPos()) - self:GetPrevOrigin()):GetNormalized()
		local hitpos = (lp:GetEyeTraceNoCursor().HitPos - self:GetOrigin()):GetNormalized()
		local aim = lp:EyeAngles():Forward()

		local direction = Vector(0, 0, 0)

		if lerp < 1 then
			direction = LerpVector(lerp, player, hitpos)
		else
			direction = LerpVector(lerp - 1, hitpos, aim)
		end

		if false and lp:GetVehicle():IsVehicle() and self:IsWalkFocusEnabled() and (lp:KeyDown(IN_MOVELEFT) or lp:KeyDown(IN_MOVERIGHT) or lp:KeyDown(IN_BACK) or lp:KeyDown(IN_FORWARD)) then
			direction = player
		end

		self:SetDirection(direction)

		self:SetDesiredDirection(direction)

	end

	function ctp:CalcRoll()
		self:SetRoll(math.Clamp(WorldToLocal(lp:GetVelocity(), Angle(0, 0, 0), Vector(0, 0, 0), self:GetAngles()).y * (-self:GetRollAmount() / 500), -90, 90))
	end

	function ctp:CalcNoise()
		self.SmoothNoise = self.SmoothNoise or vector_origin

		self.SmoothNoise = LerpVector(self:GetFrameTime() * 0.07, self.SmoothNoise, VectorRand() * (math.random() > 0.95 and 20 or 1))

		self:SetDirection(self:GetDirection() + self.SmoothNoise)
	end

	function ctp:CalcThreshold()
		local distance = self:GetPlayerPos():Distance(self:GetPrevOrigin()) / (self:GetThresholdRadius() * 0.5)

		distance = math.Round(math.Clamp(distance ^ 7-0.2, 0, 1), 5)

		self:SetRelativeOriginSpeed(distance)
	end

	--Thanks to ralle for telling me how to do this!
	--I'm kind of hacking the jump it makes by doing a lerp

	function ctp:CalcAngleLimit()
		local pos = self:GetPlayerPos()

		local a1 = self:GetDirection():Angle()
		local a2 = (pos - self:GetPrevOrigin()):Angle()
		local FOV = self:GetFOV() / 3
		local dir = a2:Forward() * -1

		local dot = math.Clamp(Angle(0, a1.y, 0):Forward():Dot(dir), 0, 1)

		a1.p = a2.p + math.Clamp(math.AngleDifference(a1.p, a2.p), -FOV, FOV)
		FOV = FOV / (ScrH() / ScrW())
		a1.y = a2.y + math.Clamp(math.AngleDifference(a1.y, a2.y), -FOV, FOV)

		a1.p = math.NormalizeAngle(a1.p)
		a1.y = math.NormalizeAngle(a1.y)

		self:SetDirection(LerpVector(dot, a1:Forward(), dir * -1))
	end

	function ctp:CalcTraceBlock()
		local ply = lp
		local veh = ply:GetVehicle()

		local filter

		if veh:IsValid() then
			filter = ents.FindInSphere(veh:GetPos(), veh:BoundingRadius() * 4)
		else
			filter = ents.FindInSphere(ply:GetPos(), ply:BoundingRadius() * 4)
		end

		local trace_forward = util.TraceLine({
			start = self:GetPlayerPos(),
			endpos = self:GetOrigin(),
			filter = filter,
		})

		if trace_forward.Hit and trace_forward.Entity != lp and not trace_forward.Entity:IsPlayer() and not trace_forward.Entity:IsVehicle() then
			self:SetOrigin(trace_forward.HitPos + (self:GetDirection() * self:GetTraceForward()))
			self.SmoothOrigin = self:GetOrigin()
		end
	end

	function ctp:CalcDownTrace()
		local trace_down = util.QuickTrace(self:GetOrigin(), vector_up * -self:GetTraceDown())

		if trace_down.Hit then
			local origin = self:GetOrigin()
			origin.z = 0
			self:SetOrigin(origin + Vector(0,0,trace_down.HitPos.z + self:GetTraceDown()))
		end
	end

	function ctp:CalcSmoothing()
		if self:IsThresholdEnabled() then
			self.SmoothOrigin = LerpVector(self:GetFrameTime() * (self:GetOriginSmoother() / (self:GetThresholdRadius() / 500)) * self:GetRelativeOriginSpeed(), self.SmoothOrigin, self:GetOrigin())
		elseif self:GetOriginSmoother() < 35 then
			self.SmoothOrigin = LerpVector(self:GetFrameTime() * self:GetOriginSmoother(), self.SmoothOrigin, self:GetOrigin())
		else
			self.SmoothOrigin = self:GetOrigin()
		end

		if self:GetDirectionSmoother() < 35 then
			self.SmoothDirection = LerpVector(self:GetFrameTime() * self:GetDirectionSmoother(), self.SmoothDirection, self:GetDirection())
			self.SmoothRoll = Lerp(self:GetFrameTime() * self:GetDirectionSmoother(), self.SmoothRoll, self:GetRoll())
		else
			self.SmoothDirection = self:GetDirection()
		end

		if self:GetFOVSmoother() < 35 then
			self.SmoothFOV = Lerp(self:GetFrameTime() * self:GetFOVSmoother(), self.SmoothFOV, self:GetFOV())
		else
			self.SmoothFOV = self:GetFOV()
		end

		self:SetOrigin(self.SmoothOrigin)
		self:SetDirection(self.SmoothDirection)
		self:SetFOV(self.SmoothFOV)
		self:SetRoll(self.SmoothRoll)

	end

end

do -- Dragging
	function ctp:PreventScreenClicks()
		return true
	end

	function ctp:GUIMousePressed(code)
		if self.not_focused then return end

		if code == MOUSE_LEFT then
			self.MousePos = Vector(gui.MousePos())
			self.dragging = true
			if not self:GetOrigin() then self:SetOrigin(Vector()) end
			self.DragDistance = self:GetOrigin():Distance(self:GetPlayerPos())
		end
		if code == MOUSE_RIGHT then
			self.MouseY = gui.MouseY()
			self.dragzooming = true
		end
	end

	function ctp:GUIMouseReleased()
		self.dragging = false
		self.dragzooming = false
	end

	ctp.CornerDistance = 10
	ctp.MousePos = vector_origin
end

do -- Move
	function ctp:CreateMove(ucmd)
		self.UCMD = ucmd

		if self:IsLockPitchEnabled() then
			self:GetUCMD():SetViewAngles(Angle(0, self:GetUCMD():GetViewAngles().y, 0))
		end
	end

	function ctp:GetUCMD()
		return self.UCMD or lp:GetCurrentCommand()
	end
end

ctp:Initialize()

hook.Add("InitPostEntity", "ctp_InitPostEntity", function() ctp:Initialize() end)

do -- ui
	ctp.Spacing = 7
	ctp.FormFont = "DermaDefault"

	do -- ctp_Preset
		local PANEL = vgui.Register("ctp_Preset", {}, "DPanel")

		function PANEL:Init()
			self.choice = vgui.Create("DComboBox", self)

			self.choice.OnCursorEntered = function()
				self.choice:RequestFocus()
			end

			self.choice.OnCursorExited = function()
				self.choice:KillFocus()
			end

			self.choice.OnSelect = function(_,_,value)
				self.presetname = value

				self.currentdata = self:GetType() == "cvar" and ctp:GetCVarPresets()[value]

				if self.currentdata then
					self.choice:SetTooltip(self.currentdata)
				else
					self.choice:SetTooltip([[This preset has no description.
					You can make a description by typing it after a semicolon like so:
					valve thirdperson;this is just like the valve thirdperson camera!
					where the everything before " ; " is the name and everything after is the description]])
				end

				ctp:LoadCVarPreset(self.presetname)
			end

			self.save = vgui.Create("DButton", self)
			self.save:SetText("S")
			self.save:NoClipping(true)
			self.save:SetTooltip("Save")
			self.save.DoClick = function()
				--MsgN("Saving preset '" .. self.choice:GetValue() .. "'")

				Derma_StringRequest("filename", "enter the filename", self.presetname or "", function(str)
					local name, description = unpack(string.Explode(";", str))
					description = description or self.currentdata
					if self:GetType() == "cvar" then
						ctp:SaveCVarPreset(name, description)
					end
					self.choice:Clear()
					self:Refresh()
				end)
			end

			self.delete = vgui.Create("DButton", self)
			self.delete:SetText("X")
			self.delete:NoClipping(true)
			self.delete:SetTooltip("Delete")
			self.delete.DoClick = function()
				if self.presetname then
					MsgN("Deleting preset '" .. self.presetname .. "'")
					if self:GetType() == "cvar" then
						ctp:DeleteCVarPreset(self.presetname)
					end
					self.choice:Clear()
					self:Refresh()
				end
			end

		end

		AccessorFunc(PANEL, "Type", "Type")

		function PANEL:Refresh()
		end

		function PANEL:AddTable(tbl)
			for name, description in pairs(tbl) do
				self.choice:AddChoice(name, description != "" and description)
				if self:GetType() == "cvar" and ctp:GetCurrentCVarPreset() and ctp:GetCurrentCVarPreset().name == name then
					self.choice:ChooseOption(name)
				end
			end
		end

		function PANEL:PerformLayout()
			self.delete:SetWide(20)
			self.delete:AlignTop(ctp.Spacing)
			self.delete:AlignRight(ctp.Spacing)
			self.delete:SetTall(self:GetTall() - (ctp.Spacing * 2))

			self.save:SetWide(20)
			self.save:AlignTop(ctp.Spacing)
			self.save:MoveLeftOf(self.delete, ctp.Spacing)
			self.save:SetTall(self:GetTall() - (ctp.Spacing * 2))

			self.choice:AlignTop(ctp.Spacing)
			self.choice:AlignLeft(ctp.Spacing)
			self.choice:StretchRightTo(self.save, ctp.Spacing)
			self.choice:SetTall(self:GetTall() - (ctp.Spacing * 2))

		end
	end

	do -- ctp_Slider
		local PANEL = vgui.Register("ctp_Slider", {}, "DNumSlider")

		function PANEL:Init()
			self:CopyHeight(self.Wang)
			self:SetDark(true)

			self.Slider:SetTall(13)

			self:SetDecimals(1)
		end

		function PANEL:PerformLayout()
			self.Label:SetPos(0, 0)
			self.Label:CenterVertical()
			self.Label:SizeToContents()

			self.Wang:SizeToContents()
			self.Wang:SetWide(10)
			self.Wang:SetPos(0, 0)
			self.Wang:AlignRight(0)

			self.Slider:CenterVertical()
			self.Slider:MoveRightOf(self.Wang, ctp.Spacing)
			self.Slider:SetWide(self:GetParent():GetWide() - ctp.Spacing)
			self.Slider:SetSlideX(self.Wang:GetFraction())
		end

		function PANEL:SetText(str)
			DNumSlider.SetText(self, str)

			self.Label:SizeToContents()
			self:InvalidateLayout()
		end
	end

	do -- ctp_VectorSliders
		local PANEL = vgui.Register("ctp_VectorSliders", {}, "DForm")

		function PANEL:Init()
			self.xslider = vgui.Create("ctp_Slider", self)
			self:AddItem(self.xslider)

			self.yslider = vgui.Create("ctp_Slider", self)
			self:AddItem(self.yslider)

			self.zslider = vgui.Create("ctp_Slider", self)
			self:AddItem(self.zslider)

			self.reset = vgui.Create("DButton", self)
			self.reset:SetText("reset")
			self:AddItem(self.reset)

			self.BaseClass.Init(self)
		end

		function PANEL:SetText(title, x, y, z, tooltip)
			self:SetName(title)
			self.xslider:SetText(x)
			self.yslider:SetText(y)
			self.zslider:SetText(z)

			self:SetTooltip(tooltip)
		end

		function PANEL:SetMinMax(xmin, xmax, ymin, ymax, zmin, zmax)
			self.xslider:SetMin(not xmax and -xmin or xmin)
			self.xslider:SetMax(xmax or xmin)

			self.yslider:SetMin(ymin or -xmin)
			self.yslider:SetMax(ymax or xmin)

			self.zslider:SetMin(zmin or -xmin)
			self.zslider:SetMax(zmax or xmin)
		end

		function PANEL:SetCVars(x, y, z)
			x = "cl_ctp_" .. x
			y = "cl_ctp_" .. y
			z = "cl_ctp_" .. z

			self.xslider:SetConVar(x)
			self.yslider:SetConVar(y)
			self.zslider:SetConVar(z)

			self.reset.DoClick = function()
				RunConsoleCommand(x, 0)
				RunConsoleCommand(y, 0)
				RunConsoleCommand(z, 0)
			end
		end
	end

	do -- ctp_MainFrame
		local NumSlider = function(self, strLabel, strConVar, numMin, numMax, dec)
			local left = vgui.Create( "ctp_Slider", self )
			left:SetText( strLabel )
			left:SetMinMax( numMin, numMax )
			if dec then left:SetDecimals(dec) end

			left:SetConVar(strConVar)
			left:SizeToContents()

			self:AddItem(left, nil)

			return left
		end

		do -- ctp_SheetBase
			local PANEL = vgui.Register("ctp_SheetBase", {}, "DPanelList")

			function PANEL:Init()
				self:EnableHorizontal(false)
				self:EnableVerticalScrollbar(true)
				self:SetPadding(ctp.Spacing)
				self:SetSpacing(ctp.Spacing)

				self:Rebuild()
			end

			function PANEL:Paint(w, h)
				derma.SkinHook("Paint", "Tree", self, w, h)
			end
		end

		do -- ctp_SheetOrigin
			local PANEL = vgui.Register("ctp_SheetOrigin", {}, "ctp_SheetBase")

			function PANEL:Init()
				self.offset = vgui.Create("ctp_VectorSliders", self)
					self:AddItem(self.offset)
					self.offset:SetMinMax(100)
					self.offset:SetCVars("offset_right", "offset_forward", "offset_up")
					self.offset:SetText("Offset", "X", "Y", "Z",
						[[This controls the camera offset.
						It can be relative to player position or world position.]]
					)

				self.trace = vgui.Create("DForm", self)
					self:AddItem(self.trace)
					self.trace:SetName("Trace Block")
					self.trace.NumSlider = NumSlider

					self.trace:CheckBox("Enable Forward", "cl_ctp_trace_enable"):SetTooltip(
					[[Enables the trace block which will move the camera forward if
					something is in the way of the player and the camera]])

					self.trace:CheckBox("Smooth", "cl_ctp_trace_smooth"):SetTooltip(
					[[If this is checked, it will obey the position smoother]])

					self.trace:NumSlider("Forward", "cl_ctp_trace_forward", -100, 100, 2):SetTooltip(
					[[This is the how much forward the camera will go from the blocking point]])

					self.trace:NumSlider("Down Trace Length", "cl_ctp_trace_down", 0, 100, 2):SetTooltip(
					[[This will keep the camera from going too close to the ground.
					For instance if it's at 100, it will keep itself 100 units from ground]])

				self.threshold = vgui.Create("DForm", self)
					self:AddItem(self.threshold)
					self.threshold:SetName("Threshold")
					self.threshold.NumSlider = NumSlider

					self.threshold:CheckBox("Enable", "cl_ctp_threshold_enabled"):SetTooltip(
					[[If this is checked, the camera will stop following when it reaches the radius given]])

					self.threshold:NumSlider("Radius", "cl_ctp_threshold_radius", 0, 250, 0):SetTooltip(
					[[This is the radius of the threshold camera.]])

				self.misc = vgui.Create("DForm", self)
					self:AddItem(self.misc)
					self.misc:SetName("Misc")
					self.misc.NumSlider = NumSlider

					self.misc:CheckBox("Relative to player", "cl_ctp_offset_relative"):SetTooltip(
					[[If this is off the camera won't follow player angles.
					It's like mayamode in Valve's thirdperson camera]])

					self.misc:CheckBox("Follow pitch", "cl_ctp_offset_lock_z"):SetTooltip(
					[[If this is off, the camera won't follow the player's pitch.
					In other words the camera won't go up and down]])

					self.misc:NumSlider("Near Z", "cl_ctp_near_z", 1, 50, 1):SetTooltip(
					[[The higher this is the less flickering you will see. This is very useful for addons like PAC.]])

				self.BaseClass.Init(self)
			end
		end

		do -- ctp_SheetDirection
			local PANEL = vgui.Register("ctp_SheetDirection", {}, "ctp_SheetBase")

			function PANEL:Init()
				self.aim = vgui.Create("DForm", self)
					self:AddItem(self.aim)
					self.aim:SetName("Aim")
					self.aim.NumSlider = NumSlider

					self.aim:NumSlider("Lerp Aim", "cl_ctp_lerp_aim", 0, 100, 2):SetTooltip(
					[[This makes a lerp (blend) between what to aim at.
					0 = player
					50 = what the player sees
					100 the players aim]])

					self.aim:NumSlider("Zoom", "cl_ctp_offset_fov", 0, 150, 2):SetTooltip(
					[[The amount of zoom the camera should do]])

					self.aim:NumSlider("Roll Amount", "cl_ctp_angles_roll_amount", -100, 100, 2):SetTooltip(
					[[This will make the camera roll based on the player's side velocity.
					It obeys direction stiffness]])

				self.zoomdistance = vgui.Create("DForm", self)
					self:AddItem(self.zoomdistance)
					self.zoomdistance:SetName("Zoom Distance")
					self.zoomdistance.NumSlider = NumSlider

					self.zoomdistance:CheckBox("Enable", "cl_ctp_offset_fov_zoom_distance_enabled"):SetTooltip(
					[[Enabling this will make the camera zoom in further based on how far the player is from the camera]])

					self.zoomdistance:NumSlider("Distance", "cl_ctp_offset_fov_zoom_distance", 0, 400, 0):SetTooltip(
					[[The distance for when it should start zooming in]])

					self.zoomdistance:NumSlider("Minimum Zoom", "cl_ctp_offset_fov_zoom_distance_min", 0, 75, 0):SetTooltip(
					[[The minimum distance for distance zooming]])

				self.angles = vgui.Create("ctp_VectorSliders", self)
					self:AddItem(self.angles)
					self.angles:SetMinMax(180)
					self.angles:SetCVars("angles_pitch", "angles_yaw", "angles_roll")
					self.angles:SetText("Angle Offset", "P", "Y", "R",
					[[This controls the angle offset.]])

				self.angleslimit = vgui.Create("DForm", self)
					self:AddItem(self.angleslimit)
					self.angleslimit:SetName("Angle Limit")

					self.angleslimit:CheckBox("Enable", "cl_ctp_angles_limit"):SetTooltip(
					[[Turning this on will make it so the camera tries not to aim away
					from the player	thus making the player always visible. (well it will try to)]])

					self.angleslimit:CheckBox("Smooth", "cl_ctp_angles_limit_smooth"):SetTooltip(
					[[Enabling this will make the angle limit obey direction smoothness]])

				self.BaseClass.Init(self)
			end

		end

		do -- ctp_SheetMisc
			local PANEL = vgui.Register("ctp_SheetMisc", {}, "ctp_SheetBase")

			function PANEL:Init()
				self.smoothers = vgui.Create("DForm")
				self.smoothers:SetName("Stiffness")
				self.smoothers.NumSlider = NumSlider

				self.smoothers:NumSlider("Position", "cl_ctp_smoother_origin", 0, 40, 2):SetTooltip(
				[[Low values equal slow movement, while high values equal fast movement]])

				self.smoothers:NumSlider("Aim", "cl_ctp_smoother_direction", 0, 40, 2):SetTooltip(
				[[Low values equal slow movement, while high values equal fast movement]])

				self.smoothers:NumSlider("Zoom", "cl_ctp_smoother_fov", 0, 40, 2):SetTooltip(
				[[Low values equal slow movement, while high values equal fast movement]])

				self:AddItem(self.smoothers)

				self.center = vgui.Create("ctp_VectorSliders", self)
				self.center:SetMinMax(100)
				self.center:SetCVars("center_offset_right", "center_offset_forward", "center_offset_up")
				self.center:SetText("Center Offset", "X", "Y", "Z",
				[[This controls where the center of the player is for the camera.]])

				local choice = self.center:ComboBox("Bone", "cl_ctp_bone_name")

				choice:SetTooltip([[This controls the bone the camera will think where the
				player is.]])

				for key in SortedPairs(ctp.BoneList) do
					choice:AddChoice(key)
				end

				choice:ChooseOption(GetConVarString("cl_ctp_bone_name"))

				-- Pain
				choice:GetParent():SetTall(35)
				choice:SetTall(35)

				self:AddItem(self.center)

				self.BaseClass.Init(self)
			end

		end

		do -- ContextMenu
			local PANEL = vgui.Register("ctp_ContextMenu", {}, "DPanel")

			function PANEL:Init()
				self.preset = vgui.Create("ctp_Preset", self)
				self.preset:SetType("cvar")
				self.preset:AddTable(ctp:GetCVarPresets())
				self.preset.Refresh = function()
					self.preset:AddTable(ctp:GetCVarPresets())
				end

				self.enable = vgui.Create("DButton", self)
				self.enable:SetText("Toggle Thirdperson")
				self.enable.DoClick = function()
					ctp:Toggle()
				end

				self.sheet = vgui.Create("DPropertySheet", self)
				self.sheet:SetShowIcons(false)

				self.sheet:AddSheet(
					"Position",
					vgui.Create("ctp_SheetOrigin", self),
					nil,
					false,
					false,
					"This sheet is for controlling the position offsets such as where the camera is oriented around the player"
				)

				self.sheet:AddSheet(
					"Aim",
					vgui.Create("ctp_SheetDirection", self),
					nil,
					false,
					false,
					"This sheet is for controlling the aim settings such as where the camera is pointing or/and at what"
				)

				self.sheet:AddSheet(
					"Misc",
					vgui.Create("ctp_SheetMisc", self),
					nil,
					false,
					false,
					"This sheet is for misc options"
				)

				self:StretchToParent(ctp.Spacing, ctp.Spacing, ctp.Spacing, ctp.Spacing)
				self:SetTall(600)
			end

			function PANEL:PerformLayout()
				self.sheet:StretchToParent(ctp.Spacing, ctp.Spacing + 70, ctp.Spacing, ctp.Spacing)

				self.enable:MoveAbove(self.sheet, ctp.Spacing)
				self.enable:StretchBottomTo(self.sheet, ctp.Spacing)
				self.enable:AlignLeft(ctp.Spacing)
				self.enable:CopyWidth(self.sheet)

				self.preset:CopyWidth(self.sheet)
				self.preset:AlignTop(ctp.Spacing)
				self.preset:AlignLeft(ctp.Spacing)
				self.preset:StretchBottomTo(self.enable, ctp.Spacing)
			end
		end
	end

end

ctp.ModelOverrides = {}

function ctp:AddBoneOverride(mdl, bones)
	self.ModelOverrides[mdl] = bones
end

function ctp:GetOverrideBone(mdl, bone)
	for pattern, bones in pairs(self.ModelOverrides) do
		if string.find(mdl, pattern) then
			return bones[bone] or ctp.BoneList[bone]
		end
	end

	return ctp.BoneList[bone]
end
