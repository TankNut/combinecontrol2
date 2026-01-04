-- Neuter absolutely everything we can get away with
list.RemoveEntry("DesktopWindows", "Draconic Menu")

local function killReceivers(tab)
	for _, name in ipairs(tab) do
		net.Receive(name, stub)
	end
end

concommand.Remove("drc_refreshcolours")
concommand.Remove("draconic_menu")
concommand.Remove("draconic_thirdperson")
concommand.Remove("draconic_thirdperson_swapshoulder")
concommand.Remove("draconic_thirdperson_openeditor")
concommand.Remove("draconic_firstperson_toggle")
concommand.Remove("draconic_voicesets_menu_toggle")

hook.Remove("StartCommand", "drc_InteractionBlocks")
hook.Remove("PlayerDroppedWeapon", "drc_Unreadyweapon")
hook.Remove("DoPlayerDeath", "drc_PlayerDeathEvents")
hook.Remove("OnPlayerHitGround", "drc_WeaponFPLandingAnimations")
hook.Remove("PlayerSwitchWeapon", "drc_stfu2")
hook.Remove("PlayerTick", "drc_movementhook")
hook.Remove("PlayerSwitchWeapon", "drc_weaponswitchanim")
hook.Remove("Tick", "drc_ForceThingsToFunction")
hook.Remove("ScalePlayerDamage", "drc_locationalscale_ply")
hook.Remove("KeyRelease", "DRC_FootStepShuffle")
hook.Remove("PlayerFootstep", "DRC_FootStepSets")
hook.Remove("EntityEmitSound", "DRC_Footsteps_Wade")
hook.Remove("OnPlayerHitGround", "DRC_Footsteps_Landing")
hook.Remove("PlayerCanPickupWeapon", "drc_PreventBatteryAmmoPickup")
hook.Remove("AllowPlayerPickup", "drc_PreventAnnoyance")
hook.Remove("PlayerTick", "drc_PlayerTickEvents")
hook.Remove("OnEntityCreated", "drc_OnEntityCreated")
hook.Remove("PlayerAmmoChanged", "drc_StopImpulse101FromBreakingBatteries")
hook.Remove("EntityEmitSound", "drc_timewarpsnd")
hook.Remove("OnEntityCreated", "DRC_WeaponTracker")
hook.Remove("EntityRemoved", "DRC_WeaponTracker_Remove")
hook.Remove("CalcMainActivity", "DRC_BarnacleGrab")
hook.Remove("Tick", "DRC_I_Wrote_This_When_I_Ran_Out_Of_Options")

if CLIENT then
	hook.Remove("CalcView", "DRC_EFP_CalcView")
	hook.Remove("CalcViewModelView", "DRC_EFP_CalcViewModelView")
	hook.Remove("Think", "DRC_ExpFP_Body")
	hook.Remove("HUDShouldDraw", "DRC_HideBaseCrosshairThirdperson")
	hook.Remove("HUDPaint", "drc_crosshair") -- Why is all of this done through hooks? Wtf?
	hook.Remove("HUDPaint", "drc_scope")
	hook.Remove("HUDPaint", "drc_inspection_menu")
	hook.Remove("PreDrawViewModel", "drc_inspection_dof")
	hook.Remove("HUDPaint", "drc_interactiontext")
	hook.Remove("PreDrawViewModel", "drc_interact_hidevm")
	hook.Remove("PostDrawViewModel", "drc_interact_hidevm")
	hook.Remove("PostDrawViewHands", "drc_interact_hidevm")
	hook.Remove("HUDPaint", "drc_debug_hud")
	hook.Remove("PreDrawViewModel", "DrcLerp_Debug")
	hook.Remove("Tick", "DRC_PreventBrokenHUD")
	hook.Remove("HUDShouldDraw", "DRC_Camera")
	hook.Remove("PlayerTick", "DRC_SpeakingPoseParam")
	hook.Remove("PlayerStartVoice", "DRC_SpeakingPoseParam_MarkTrue")
	hook.Remove("PlayerEndVoice", "DRC_SpeakingPoseParam_MarkFalse")
	hook.Remove("CreateClientsideRagdoll", "Draconic_FunnyPlayerCorpses_Client")
	hook.Remove("PlayerBindPress", "DRC_ClientsideHotkeys")
	hook.Remove("CalcView", "!DrcLerp")
	hook.Remove("CalcViewModelView", "DRC_SWEP_Effects")
	hook.Remove("HUDPaint", "drc_DebugUI")
	hook.Remove("HUDPaint", "drc_TraceInfo")
	hook.Remove("PostDrawTranslucentRenderables", "drc_DebugStuff")
	hook.Remove("PostDrawTranslucentRenderables", "DRC_LightVolumeRendering")
	hook.Remove("Think", "DRC_Lighting")
	hook.Remove("HUDPaint", "DRC_ColourBlindness") -- Fun idea but we can do that ourselves if we want to
	hook.Remove("RenderScreenspaceEffects", "DRC_Camera_Overlays")
	hook.Remove("GetMotionBlurValues", "drc_modifiedmotionblur")
	hook.Remove("Think", "DRC_AggressiveCulling")
	hook.Remove("CreateMove", "!drc_thirdpersoncontrol")
	hook.Remove("PrePlayerDraw", "!drc_thirdpersonlook")
	hook.Remove("CalcView", "!drc_thirdperson")
	hook.Remove("Tick", "VoiceSets_MenuTimeout")
	hook.Remove("PlayerBindPress", "VoiceSets_Menu")
	hook.Remove("HUDPaintBackground", "VoiceSets_HUD")
	hook.Remove("CreateClientsideRagdoll", "drc_playerragdollcolours")

	hook.Add("InitPostEntity", "DRC_HolyFuck", function()
		DRC.LocalPlayer = LocalPlayer()

		timer.Remove("DRC_RefreshLocalPlayer")
	end)
else
	killReceivers({
		"DRC_ApplyPlayermodel", -- Why the fuck does this exist and let people freely change models
		"DRCVoiceSet_CL",
		"DRC_PlayerSquadHelp",
		"DRC_PlayerSquadMove",
		"DRC_WeaponAttachSwitch",
		"DRC_WeaponCamoSwitch",
		"DRC_WeaponAttachClose",
		--"DRC_ReceiveLightColour", -- Might become a problem later, not sure what it's used for
		"DRC_Nuke",
		"DRC_KYS"
	})

	hook.Remove("DoPlayerDeath", "VoiceSets_Death")
	hook.Remove("PlayerDeath", "Draconic_FunnyPlayerCorpses")
	hook.Remove("PlayerSpawn", "VoiceSets_Spawn")
	hook.Remove("PostEntityTakeDamage", "VoiceSets_Damage")
	hook.Remove("PlayerStartTaunt", "VoiceSets_Taunts")
	hook.Remove("EntityEmitSound", "VoiceSets_Responses")
	hook.Remove("EntityTakeDamage", "VoiceSets_VehicleChecks")
	hook.Remove("PlayerEnteredVehicle", "VoiceSets_EnterVehicle")
	hook.Remove("PlayerLeaveVehicle", "VoiceSets_ExitVehicle")
	hook.Remove("PostEntityTakeDamage", "VoiceSets_PostKill")
	hook.Remove("PlayerTick", "DRC_VoiceSetsBreathing")
	hook.Remove("PlayerTick", "DRC_VoiceSetsIdling")
	hook.Remove("PlayerSwitchFlashlight", "drc_IntegratedLights")
	hook.Remove("PlayerSpawn", "drc_DoPlayerSettings")
	hook.Remove("CreateEntityRagdoll", "drc_playerragdollcolours")
	hook.Remove("OnNPCKilled", "drc_stfu3")
	hook.Remove("ScaleNPCDamage", "drc_locationalscale_npc")
	hook.Remove("PlayerGiveSWEP", "drc_GivePickupOnlyWeapon")
	hook.Remove("WeaponEquip", "VoiceSets_WeaponEquip")
	hook.Remove("PlayerSpawnedNPC", "drc_NPCWeaponOverride")

end
