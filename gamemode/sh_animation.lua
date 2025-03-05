local PLAYER = FindMetaTable("Player")

GM.AnimTable = {}

GM.AnimTable["models/vortigaunt.mdl"] = {}
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_STAND_IDLE] 				= ACT_IDLE
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_WALK] 						= ACT_WALK
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_RUN] 						= ACT_RUN
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_CROUCH_IDLE] 				= "CrouchIdle"
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_CROUCHWALK] 				= ACT_WALK
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_ATTACK_STAND_PRIMARYFIRE] 	= ACT_IDLE
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_IDLE
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_RELOAD_STAND] 				= ACT_IDLE
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_RELOAD_CROUCH] 			= ACT_IDLE
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_JUMP] 						= ACT_RUN
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_SWIM_IDLE] 				= ACT_IDLE
GM.AnimTable["models/vortigaunt.mdl"][ACT_MP_SWIM] 						= ACT_IDLE
GM.AnimTable["models/vortigaunt.mdl"][ACT_LAND] 						= ACT_IDLE

GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"] = {}
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_STAND_IDLE] 				= ACT_IDLE_ANGRY
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_WALK] 						= ACT_WALK
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_RUN] 						= ACT_RUN
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_CROUCH_IDLE] 				= "CrouchIdle"
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_CROUCHWALK] 				= ACT_WALK
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_ATTACK_STAND_PRIMARYFIRE] 	= ACT_IDLE_ANGRY
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_IDLE_ANGRY
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_RELOAD_STAND] 				= ACT_IDLE_ANGRY
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_RELOAD_CROUCH] 			= ACT_IDLE_ANGRY
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_JUMP] 						= ACT_RUN
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_SWIM_IDLE] 				= ACT_IDLE_ANGRY
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_MP_SWIM] 						= ACT_IDLE_ANGRY
GM.AnimTable["models/vortigaunt.mdl"]["_UNHOLSTERED"][ACT_LAND] 						= ACT_IDLE_ANGRY

GM.AnimTable["models/tnb/player/trp/t400.mdl"] = table.Copy(GM.AnimTable["models/vortigaunt.mdl"])

GM.AnimTable["models/tnb/player/trp/t400.mdl"][ACT_MP_STAND_IDLE] = "airgunidle"

GM.AnimTable["models/tnb/player/trp/t500_reaver.mdl"] = table.Copy(GM.AnimTable["models/vortigaunt.mdl"])

GM.AnimTable["models/antlion_guard.mdl"] = {}
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_STAND_IDLE] 				= ACT_IDLE
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_WALK] 						= ACT_WALK
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_RUN] 						= ACT_RUN
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_CROUCH_IDLE] 				= ACT_IDLE
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_CROUCHWALK] 				= ACT_WALK
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_ATTACK_STAND_PRIMARYFIRE] 	= ACT_IDLE
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] 	= ACT_IDLE
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_RELOAD_STAND] 				= ACT_IDLE
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_RELOAD_CROUCH] 				= ACT_IDLE
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_JUMP] 						= ACT_RUN
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_SWIM_IDLE] 					= ACT_IDLE
GM.AnimTable["models/antlion_guard.mdl"][ACT_MP_SWIM] 						= ACT_IDLE
GM.AnimTable["models/antlion_guard.mdl"][ACT_LAND] 							= ACT_IDLE

GM.AnimTable["models/tnb/player/trp/t100.mdl"] = GM.AnimTable["models/antlion_guard.mdl"]
GM.AnimTable["models/tnb/player/trp/t200.mdl"] = GM.AnimTable["models/antlion_guard.mdl"]
GM.AnimTable["models/tnb/player/trp/t200.mdl"][ACT_MP_JUMP] = ACT_WALK

GM.AnimTable["models/babygarg.mdl"] = {}
GM.AnimTable["models/babygarg.mdl"][ACT_MP_STAND_IDLE] 						= ACT_IDLE
GM.AnimTable["models/babygarg.mdl"][ACT_MP_WALK] 							= ACT_WALK
GM.AnimTable["models/babygarg.mdl"][ACT_MP_RUN] 							= ACT_WALK
GM.AnimTable["models/babygarg.mdl"][ACT_MP_CROUCH_IDLE] 					= ACT_IDLE
GM.AnimTable["models/babygarg.mdl"][ACT_MP_CROUCHWALK] 						= ACT_WALK
GM.AnimTable["models/babygarg.mdl"][ACT_MP_ATTACK_STAND_PRIMARYFIRE] 		= ACT_IDLE
GM.AnimTable["models/babygarg.mdl"][ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] 		= ACT_IDLE
GM.AnimTable["models/babygarg.mdl"][ACT_MP_RELOAD_STAND] 					= ACT_IDLE
GM.AnimTable["models/babygarg.mdl"][ACT_MP_RELOAD_CROUCH] 					= ACT_IDLE
GM.AnimTable["models/babygarg.mdl"][ACT_MP_JUMP] 							= ACT_WALK
GM.AnimTable["models/babygarg.mdl"][ACT_MP_SWIM_IDLE] 						= ACT_IDLE
GM.AnimTable["models/babygarg.mdl"][ACT_MP_SWIM] 							= ACT_IDLE
GM.AnimTable["models/babygarg.mdl"][ACT_LAND] 								= ACT_IDLE

GM.AnimTable["models/tnb/player/trp/t300_new.mdl"] = GM.AnimTable["models/babygarg.mdl"]

GM.AnimTable["models/pigeon.mdl"] = {}
GM.AnimTable["models/pigeon.mdl"][ACT_MP_STAND_IDLE] 				= ACT_IDLE
GM.AnimTable["models/pigeon.mdl"][ACT_MP_WALK] 						= ACT_WALK
GM.AnimTable["models/pigeon.mdl"][ACT_MP_RUN] 						= ACT_RUN
GM.AnimTable["models/pigeon.mdl"][ACT_MP_CROUCH_IDLE] 				= ACT_IDLE
GM.AnimTable["models/pigeon.mdl"][ACT_MP_CROUCHWALK] 				= ACT_WALK
GM.AnimTable["models/pigeon.mdl"][ACT_MP_ATTACK_STAND_PRIMARYFIRE] 	= ACT_IDLE
GM.AnimTable["models/pigeon.mdl"][ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_IDLE
GM.AnimTable["models/pigeon.mdl"][ACT_MP_RELOAD_STAND] 				= ACT_IDLE
GM.AnimTable["models/pigeon.mdl"][ACT_MP_RELOAD_CROUCH] 			= ACT_IDLE
GM.AnimTable["models/pigeon.mdl"][ACT_MP_JUMP] 						= ACT_HOP
GM.AnimTable["models/pigeon.mdl"][ACT_MP_SWIM_IDLE] 				= ACT_IDLE
GM.AnimTable["models/pigeon.mdl"][ACT_MP_SWIM] 						= ACT_IDLE
GM.AnimTable["models/pigeon.mdl"][ACT_LAND] 						= ACT_IDLE

GM.AnimTable["models/crow.mdl"] = GM.AnimTable["models/pigeon.mdl"]
GM.AnimTable["models/seagull.mdl"] = GM.AnimTable["models/pigeon.mdl"]

GM.AnimTable["models/combine_scanner.mdl"] = { }
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_STAND_IDLE]								= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_WALK] 									= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_RUN] 										= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_CROUCH_IDLE]								= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_CROUCHWALK] 								= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_ATTACK_STAND_PRIMARYFIRE] 				= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_ATTACK_CROUCH_PRIMARYFIRE]				= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_RELOAD_STAND] 							= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_RELOAD_CROUCH]							= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_JUMP] 									= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_SWIM_IDLE] 								= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_MP_SWIM] 									= ACT_IDLE
GM.AnimTable["models/combine_scanner.mdl"][ACT_LAND]										= ACT_IDLE

GM.AnimTable["models/shield_scanner.mdl"] = GM.AnimTable["models/combine_scanner.mdl"]

function GM:HandlePlayerNonPlayermodel(ply, vel)
	if not self.AnimTable[ply:GetModel()] then return end

	local tab = self.AnimTable[string.lower(ply:GetModel())]

	local wep = ply:GetActiveWeapon()

	if IsValid(wep) then
		local bool

		if wep.TRP then
			bool = wep:IsLowered()
		elseif wep.Tekka then
			bool = wep:ShouldLower()
		else
			bool = ply:Holstered()
		end

		if not bool and tab["_UNHOLSTERED"] then
			tab = tab["_UNHOLSTERED"]
		end
	end

	if tab[ply.CalcIdeal] then

		if type(tab[ply.CalcIdeal]) == "number" then

			ply.CalcIdeal = tab[ply.CalcIdeal]

		else

			ply.CalcSeqOverride = ply:LookupSequence(tab[ply.CalcIdeal])

		end

	end
end

function GM:CalcMainActivity(ply, vel)
	if SERVER then
		if ply:KeyDown(IN_ATTACK2) then
			ply:SetInAttack2(true)
		else
			ply:SetInAttack2(false)
		end
	end

	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1

	self:HandlePlayerLanding(ply, vel, ply.m_bWasOnGround)

	local bool = self:HandlePlayerNoClipping(ply, vel) or self:HandlePlayerDriving(ply) or self:HandlePlayerVaulting(ply, vel) or self:HandlePlayerJumping(ply, vel) or self:HandlePlayerDucking(ply, vel) or self:HandlePlayerSwimming(ply, vel)

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

	self:HandlePlayerNonPlayermodel(ply, vel)

	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and wep.CalcMainActivity then
		wep:CalcMainActivity(ply, vel)
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function GM:UpdateAnimation(ply, vel, max)
	max = max * ply:GetModelScale()

	self.BaseClass:UpdateAnimation(ply, vel, max)

	if CLIENT then
		if self.AnimTable[ply:GetModel()] then
			ply:SetIK(false)
		else
			ply:SetIK(true)
		end
	end

	local moveang = Vector(vel.x, vel.y, 0):Angle()
	local eyeang = Vector(ply:GetAimVector().x, ply:GetAimVector().y, 0):Angle()

	local diff = moveang.y - eyeang.y

	if diff > 180 then diff = diff - 360 end
	if diff < -180 then diff = diff + 360 end

	ply:SetPoseParameter("move_yaw", diff)

	if CLIENT then
		ply:InvalidateBoneCache()
	end

	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and wep.UpdateAnimation then
		wep:UpdateAnimation(ply, vel, max)
	end
end
