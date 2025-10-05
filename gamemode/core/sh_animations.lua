module("Animation", package.seeall)

List = List or {}
Cache = {}

local PLAYER = FindMetaTable("Player")

function Register(name, controller)
	List[name] = inherit.Register("animations", name, controller, controller.Base or "base")
end

function Get(mdl)
	return Cache[mdl] or Find(mdl)
end

function RegisterFolder(dir)
	file.Iterate(dir, "shared.lua", "LUA", function(path, folder)
		local name = string.FileName(path)

		if name == "shared" then
			name = string.FileName(folder)
		end

		_G.CONTROLLER = {}

		shared(path)

		Register(string.gsub(name, "^anim_", ""), CONTROLLER)

		CONTROLLER = nil
	end)
end

function Find(mdl)
	local match
	local matchLength = 0

	for _, controller in pairs(List) do
		local models = controller.Models

		for _, model in ipairs(models) do
			if model == mdl then
				Cache[mdl] = controller

				return controller
			elseif string.find(model, mdl) and #model > matchLength then
				match = controller
				matchLength = #model
			end
		end
	end

	local controller = match or List[GAMEMODE.DefaultAnimationController]

	Cache[mdl] = controller

	return controller
end

if SERVER then
	function PLAYER:PlayGesture(name)
		self:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM, self:LookupSequence(name))
	end

	function PLAYER:PlayLoopingGesture(name)
		self:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM_GESTURE_SEQUENCE, self:LookupSequence(name))
	end

	function PLAYER:CancelGesture()
		self:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM, -1)
	end
end

function GM:CalcMainActivity(ply, vel)
	local plyTable = ply:GetTable()

	plyTable.CalcIdeal = ACT_INVALID
	plyTable.CalcSeqOverride = -1

	Get(ply:GetModel()):CalcMainActivity(ply, vel)

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function GM:UpdateAnimation(ply, vel, max)
	max = max * ply:GetModelScale()

	Get(ply:GetModel()):UpdateAnimation(ply, vel, max)
end

function GM:TranslateActivity(ply, act)
	return Get(ply:GetModel()):TranslateActivity(ply, act)
end

function GM:DoAnimationEvent(ply, event, data)
	if event == PLAYERANIMEVENT_JUMP then
		ply.m_bJumping = true
		ply.m_bFirstJumpFrame = true
		ply.m_flJumpStartTime = CurTime()
	elseif event == PLAYERANIMEVENT_CUSTOM then
		if data == -1 then -- Cancel
			ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
		else
			ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, data, 0, true)
		end

		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_CUSTOM_GESTURE_SEQUENCE then
		ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, data, 0, false)

		return ACT_INVALID
	end

	return Get(ply:GetModel()):DoAnimationEvent(ply, event, data)
end

function GM:PlayerShouldTaunt(ply, act)
	return Get(ply:GetModel()).CanAct
end
