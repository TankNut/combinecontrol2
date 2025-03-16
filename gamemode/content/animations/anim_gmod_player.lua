local BaseClass = inherit.Get("animations", "base")

CONTROLLER.Models = {
	"^models/player/.+"
}

CONTROLLER.UseIK = true
CONTROLLER.CanAct = true

function CONTROLLER:CalcMainActivity(ply, vel)
	local plyTable = ply:GetTable()
	local GM = GAMEMODE

	plyTable.CalcIdeal = ACT_MP_STAND_IDLE
	plyTable.CalcSeqOverride = -1

	GM:HandlePlayerLanding(ply, vel, plyTable.m_bWasOnGround)

	local bool = GM:HandlePlayerNoClipping(ply, vel, plyTable) or GM:HandlePlayerDriving(ply, plyTable) or GM:HandlePlayerVaulting(ply, vel, plyTable) or GM:HandlePlayerJumping(ply, vel, plyTable) or GM:HandlePlayerDucking(ply, vel, plyTable) or GM:HandlePlayerSwimming(ply, vel, plyTable)

	if not bool then
		local len2d = vel:Length2D()

		if len2d > Lerp(0.5, ply:GetWalkSpeed(), ply:GetRunSpeed()) then
			ply.CalcIdeal = ACT_MP_RUN
		elseif len2d > 0.5 then
			ply.CalcIdeal = ACT_MP_WALK
		end
	end

	ply.m_bWasOnGround = ply:IsOnGround()
	ply.m_bWasNoclipping = ply:GetMoveType() == MOVETYPE_NOCLIP and not ply:InVehicle()
end

function CONTROLLER:UpdateRadioAnimation(ply)
	if ply:IsPlayingTaunt() then return end

	local plyTable = ply:GetTable()

	plyTable.RadioWeight = plyTable.RadioWeight or 0

	local cmd = ply:Typing()
	local isTyping = cmd and Chat.Commands[cmd].Radio

	if isTyping then
		plyTable.RadioWeight = math.Approach(plyTable.RadioWeight, 1, FrameTime() * 5.0)
	else
		plyTable.RadioWeight = math.Approach(plyTable.RadioWeight, 0, FrameTime() * 5.0)
	end

	if plyTable.RadioWeight > 0 then
		ply:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
		ply:AnimSetGestureWeight(GESTURE_SLOT_VCD, plyTable.RadioWeight)
	end
end

function CONTROLLER:UpdateAnimation(ply, vel, max)
	BaseClass.UpdateAnimation(self, ply, vel, max)

	local len = vel:Length()
	local rate = 1

	if len > 0.2 then
		rate = len / max
	end

	if ply:WaterLevel() >= 2 then
		rate = math.max(rate, 0.5)
	elseif not ply:IsOnGround() and len >= 1000 then
		rate = 0.1
	end

	ply:SetPlaybackRate(rate)

	if CLIENT and ply:InVehicle() then
		local vehicle = ply:GetVehicle()
		local steer = vehicle:GetPoseParameter("vehicle_steer") * 2 - 1

		if vehicle:GetClass() == "prop_vehicle_prisoner_pod" then
			steer = 0
			ply:SetPoseParameter("aim_yaw", math.NormalizeAngle(ply:GetAimVector():Angle().y - vehicle:GetAngles().y - 90))
		end

		ply:SetPoseParameter("vehicle_steer", steer)
	end

	self:UpdateRadioAnimation(ply)
end
