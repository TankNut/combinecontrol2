local function CheckAdmin(ply, sa)
	if not IsValid(ply) then
		return false
	end

	if not ply:IsAdmin() then
		ply:SendChat("ERROR", "You need to be an admin to do this")

		return false
	elseif sa and not ply:IsSuperAdmin() then
		ply:SendChat("ERROR", "You need to be a superadmin to do this")

		return false
	end

	return true
end

function concommand.AddAdmin(cmd, func, sa, typeList)
	local function c(len, ply)
		local args = net.ReadTable()

		if not CheckAdmin(ply, sa) then
			return
		end

		if typeList and #typeList > 0 then
			for k, v in pairs(typeList) do
				local arg = args[k]

				if v == TYPE_BOOL then
					local val = tobool(arg)

					args[k] = val
				elseif v == TYPE_STRING then
					local val

					if k == #typeList then
						val = tostring(table.concat(args, " ", k))
					else
						val = tostring(arg)
					end

					val = string.Trim(val)

					if val == "nil" then
						val = ""
					end

					args[k] = val
				elseif v == TYPE_NUMBER then
					local val = tonumber(arg)

					if not val then
						val = 0
					end

					args[k] = val
				elseif v == TYPE_ENTITY then -- Players
					local val = GAMEMODE:FindPlayer(arg, ply)

					if not IsValid(val) then
						ply:SendChat("ERROR", "No target found")

						return
					end

					args[k] = val
				end
			end

			func(ply, unpack(args))
		else
			func(ply)
		end
	end

	if CLIENT then
		concommand.Add(cmd, function(ply, cmd, args)
			net.Start("CC.CMD." .. cmd)
				net.WriteTable(args)
			net.SendToServer()
		end)
	else
		util.AddNetworkString("CC.CMD." .. cmd)
		net.Receive("CC.CMD." .. cmd, c)
	end
end

concommand.AddAdmin("rpa_stopsound", function(ply)
	net.Start("nAStopSound")
	net.Broadcast()
end, false)

concommand.AddAdmin("rpa_invisible", function(ply, targ, bool)
	GAMEMODE:WriteLog("admin_invisible", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ), Bool = bool})
	targ:SetNoDraw(bool)
end, false, {TYPE_ENTITY, TYPE_BOOL})

concommand.AddAdmin("rpa_namewarn", function(ply, targ)
	GAMEMODE:WriteLog("admin_namewarn", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ)})

	net.Start("nWarnName")
	net.Send(targ)
end, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_kill", function(ply, targ)
	targ:Kill()

	targ:SendChat("NOTICE", ply:Nick() .. " killed you")

	GAMEMODE:WriteLog("admin_kill", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ)})
end, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_slap", function(ply, targ)
	targ:SetVelocity(Vector(math.random(-400, 400), math.random(-400, 400), math.random(400, 600)))

	targ:SendChat("NOTICE", ply:Nick() .. " slapped you")

	GAMEMODE:WriteLog("admin_slap", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ)})
end, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_ko", function(ply, targ)
	targ:SetConsciousness(0)
	targ:PassOut()

	targ:SendChat("NOTICE", ply:Nick() .. " knocked you out")

	GAMEMODE:WriteLog("admin_ko", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ)})
end, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_wakeup", function(ply, targ)
	targ:SetConsciousness(100)
	targ:WakeUp()

	targ:SendChat("NOTICE", ply:Nick() .. " woke you up")

	GAMEMODE:WriteLog("admin_wake", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ)})
end, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_kick", function(ply, targ, arg)
	local targNick = targ:Nick()
	local reason = "Kicked by " .. ply:Nick()

	if #arg > 0 then
		reason = reason .. " (" .. arg .. ")"
	end

	GAMEMODE:WriteLog("admin_kick", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ), Reason = arg})

	targ:Kick(reason)

	if #arg > 0 then
		Chat.Send(player.GetAll(), "NOTICE", ply:Nick() .. " kicked " .. targNick .. " (" .. arg .. ")")
	else
		Chat.Send(player.GetAll(), "NOTICE", ply:Nick() .. " kicked " .. targNick)
	end
end, false, {TYPE_ENTITY, TYPE_STRING})

concommand.AddAdmin("rpa_ban", function(ply, targ, duration, reason)
	if duration < 0 then
		ply:SendChat("ERROR", "Invalid duration")

		return
	end

	if #reason <= 0 then
		ply:SendChat("ERROR", "Missing reason")

		return
	end

	if GAMEMODE:SteamIDIsBanned(targ:SteamID()) then
		ply:SendChat("ERROR", "Player is already banned")

		return
	end

	duration = math.Round(duration)
	local targNick = targ:VisibleRPName()
	local perma = duration == 0
	local message = (perma and "Permabanned by " or "Banned by ") .. ply:Nick() .. (perma and "" or " for " .. duration .. " minutes") .. " (" .. reason .. ")"

	if not targ:IsBot() then
		targ:AddAutomatedPlayerNote("Ban log", reason, ply:Nick())

		GAMEMODE:AddBan(targ:SteamID(), duration, reason, ply:SteamID())
	end

	GAMEMODE:WriteLog("admin_ban", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ), Reason = reason, Duration = duration})

	targ:Kick(message)

	Chat.Send(player.GetAll(), "NOTICE", ply:Nick() .. (perma and " Permabanned " or " Banned ") .. targNick .. (perma and "" or " for " .. string.NiceTime(duration * 60)) .. " (" .. reason .. ")")
end, false, {TYPE_ENTITY, TYPE_NUMBER, TYPE_STRING})

concommand.AddAdmin("rpa_banoffline", function(ply, steamid, duration, reason)
	if not IsValidSteamID(steamid) then
		ply:SendChat("ERROR", "SteamID is invalid")

		return
	end

	if duration < 0 then
		ply:SendChat("ERROR", "Duration is invalid")

		return
	end

	if #reason <= 0 then
		ply:SendChat("ERROR", "Missing reason")

		return
	end

	if GAMEMODE:SteamIDIsBanned(steamid) then
		ply:SendChat("ERROR", "Player is already banned")

		return
	end

	duration = math.Round(duration)

	local perma = duration == 0

	GAMEMODE:AddBan(steamid, duration, reason, ply:SteamID())
	GAMEMODE:WriteLog("admin_ban", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(steamid), Reason = reason, Duration = duration})

	ply:SendChat("NOTICE", (perma and "Permabanned " or "Banned ") .. steamid .. (perma and "" or " for " .. string.NiceTime(duration * 60)) .. " (" .. reason .. ")")
end, false, {TYPE_STRING, TYPE_NUMBER, TYPE_STRING})

concommand.AddAdmin("rpa_unban", function(ply, steamid)
	if not IsValidSteamID(steamid) then
		ply:SendChat("ERROR", "SteamID is invalid")

		return
	end

	local bans = GAMEMODE:LookupBans(steamid)

	if table.Count(bans) < 1 then
		ply:SendChat("ERROR", "No bans found")

		return
	end

	for id, data in pairs(bans) do
		GAMEMODE:RemoveBan(id, steamid, "Unbanned by " .. ply:SteamID(), ply:SteamID())
	end

	GAMEMODE:WriteLog("admin_unban", {Admin = GAMEMODE:LogPlayer(ply), SteamID = steamid})

	ply:SendChat("NOTICE", "Unbanned " .. steamid)
end, false, {TYPE_STRING})

concommand.AddAdmin("rpa_givemoney", function(ply, targ, amt)
	if amt == 0 then
		ply:SendChat("ERROR", "Invalid amount")

		return
	end

	targ:AddMoney(amt)

	GAMEMODE:WriteLog("admin_givemoney", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ), Amount = amt})
end, false, {TYPE_ENTITY, TYPE_NUMBER})

concommand.AddAdmin("rpa_seeall", function(ply)
	net.Start("nASeeAll")
	net.Send(ply)
end, false)

concommand.AddAdmin("rpa_tie", function(ply, targ)
	targ:SetTiedUp(true)
end, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_untie", function(ply, targ)
	targ:SetTiedUp(false)
end, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_setcharflag", function(ply, targ, flag)
	targ:SetCharFlags(flag)

	targ:StripWeapons()

	GAMEMODE:PlayerCheckFlag(targ)
	GAMEMODE:PlayerLoadout(targ)

	GAMEMODE:LogAdmin("[F] " .. ply:Nick() .. " changed player " .. targ:CharacterName() .. "'s character flag to \"" .. flag .. "\"", ply)

	if flag == "" then
		ply:SendChat("NOTICE", "You removed " .. targ:CharacterName() .. "'s character flag")
		targ:SendChat("NOTICE", ply:Nick() .. " removed your character flag")
	else
		ply:SendChat("NOTICE", "You set " .. targ:CharacterName() .. "'s character flag to \"" .. flag .. "\" (" .. GAMEMODE:CharFlagPrintName(flag) .. ")")
		targ:SendChat("NOTICE", ply:Nick() .. " set your character flag to \"" .. flag .. "\" (" .. GAMEMODE:CharFlagPrintName(flag) .. ")")
	end
end, false, {TYPE_ENTITY, TYPE_STRING})

concommand.AddAdmin("rpa_flagsroster", function(ply)
	local function cb(res)
		if #res > 0 then
			net.Start("nAFlagsRoster")
				net.WriteTable(res)
			net.Send(ply)

			GAMEMODE:LogSQL("Player " .. ply:Nick() .. " retrieved flags roster")
		else
			ply:SendChat("ERROR", "Could not retrieve flag roster")
		end
	end
	GAMEMODE.SQL:Query([[
		SELECT RPName, CharFlags FROM $chars
			WHERE CharFlags != '' AND Deleted = 0
		]], cb)
end, false)

concommand.AddAdmin("rpa_editinventory", function(ply, targ)
	for _, v in pairs(targ.Inventory) do
		v:AddNetworkedPlayer(ply)
	end

	net.Start("nAEditInventory")
		net.WriteEntity(targ)
		net.WriteFloat(targ:CharacterMoney())
	net.Send(ply)
end, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_playurl", function(ply, url, volume)
	if url == "" then
		ply:SendChat("ERROR", "Invalid syntax: rpa_playurl [url] [vol]")
		return
	end

	if volume == 0 then
		volume = 1
	end

	math.Clamp(volume, 0, 1)

	GAMEMODE:WriteLog("admin_playurl", {Admin = GAMEMODE:LogPlayer(ply), URL = url})

	net.Start("nAPlayURL")
		net.WriteString(ply:Nick())
		net.WriteString(url)
		net.WriteFloat(volume)
	net.Broadcast()
end, false, {TYPE_STRING, TYPE_NUMBER})

concommand.AddAdmin("rpa_stopurl", function(ply)
	net.Start("nAStopURL")
	net.Broadcast()
end, false)

concommand.AddAdmin("rpa_playmusic", function(ply, snd)
	GAMEMODE:LogAdmin("[M] " .. ply:Nick() .. " played music (" .. snd .. ")", ply)

	net.Start("nAPlayMusic")
		net.WriteString(snd)
	net.Broadcast()
end, false, {TYPE_STRING})


concommand.AddAdmin("rpa_playmusictarget", function(ply, targ, snd)
	GAMEMODE:LogAdmin("[M] " .. ply:Nick() .. " played music (" .. snd .. ") to " .. targ:Nick(), ply)

	net.Start("nAPlayMusic")
		net.WriteString(snd)
	net.Send(targ)
end, false, {TYPE_ENTITY, TYPE_STRING})

concommand.AddAdmin("rpa_stopmusic", function(ply)
	GAMEMODE:LogAdmin("[M] " .. ply:Nick() .. " stopped any playing music", ply)

	net.Start("nAStopMusic")
	net.Broadcast()
end, false)

local function createitem(ply, class, temp, ...)
	local args = {...}

	if GAMEMODE.ItemClasses[class] then
		GAMEMODE:LogAdmin("[I] " .. ply:Nick() .. " spawned item \"" .. class .. "\"", ply)
		GAMEMODE:CreateItem(ply, class, args, temp)
	else
		local match = nil

		for k in SortedPairs(GAMEMODE.ItemClasses) do
			if string.find(k, class) then
				if not match then
					match = k
				else
					match = nil

					break
				end
			end
		end

		if match then
			GAMEMODE:LogAdmin("[I] " .. ply:Nick() .. " spawned item \"" .. match .. "\"", ply)
			GAMEMODE:CreateItem(ply, match, args, temp)
		else
			net.Start("nAListItems")
				net.WriteString(class)
			net.Send(ply)
		end
	end
end

concommand.AddAdmin("rpa_playoverwatch", function(ply, line)
	if GAMEMODE.OverwatchLines[line] then
		GAMEMODE:LogAdmin("[O] " .. ply:Nick() .. " played overwatch line \"" .. GAMEMODE.OverwatchLines[line][2] .. "\"", ply)

		net.Start("nAPlayOverwatch")
			net.WriteFloat(line)
		net.Broadcast()
	end
end, false, {TYPE_STRING})

concommand.AddAdmin("rpa_playoverwatchradio", function(ply, sentence)
	for _, v in player.Iterator() do
		EmitSentence(sentence, v:GetPos(), v:EntIndex(), 0, 0.5, 100, 0, 100)
	end
end, true, {TYPE_STRING})

concommand.AddAdmin("rpa_spawnmortar", function(ply, count, range)
	local trace = ply:GetEyeTrace()
	count = math.Clamp(count, 1, 20)
	range = math.Clamp(range, 300, 900)

	if trace.HitSky then
		ply:SendChat("ERROR", "You can't target the skybox")

		return
	end

	local traceSky = util.TraceLine({start = trace.HitPos + Vector(0, 0, 10), endpos = trace.HitPos + Vector(0, 0, 16383), mask = MASK_SOLID})

	if not traceSky.HitSky then
		ply:SendChat("ERROR", "Cannot trace up to the sky")

		return
	end

	local callSpot = traceSky.HitPos

	for i = 1, count do
		timer.Simple(i * 0.4, function()
			local randVec = Vector(math.Rand(-range, range), math.Rand(-range, range), 0)
			local start = callSpot + (count > 1 and randVec or Vector())

			local traceGround = util.TraceLine({start = start - Vector(0, 0, 10), endpos = trace.HitPos - Vector(0, 0, 16383), mask = MASK_SOLID})

			if not util.IsInWorld(start) or math.deg(math.acos(traceGround.HitNormal:Dot(Vector(0, 0, 1)))) > 80 then
				return
			end

			local pos = traceGround.HitPos

			local mortar = ents.Create("func_tankmortar")
				mortar:SetPos(pos)
				mortar:SetAngles(Angle(90, 0, 0))
				mortar:SetKeyValue("iMagnitude", 90000)
				mortar:SetKeyValue("firedelay", 2)
				mortar:SetKeyValue("warningtime", 2)
				mortar:SetKeyValue("incomingsound", "Weapon_Mortar.Incomming")
			mortar:Spawn()

			local target = ents.Create("info_target")
				target:SetPos(pos)
				target:SetName(tostring(target))
			target:Spawn()

			mortar:DeleteOnRemove(target)

			mortar:Fire("SetTargetEntity", target:GetName(), 0)
			mortar:Fire("Activate", "", 0)
			mortar:Fire("FireAtWill", "", 0)
			mortar:Fire("Deactivate", "", 2)
			mortar:Fire("kill", "", 1)

			mortar:EmitSound("Weapon_Mortar.Single")
		end)
	end
end, false, {TYPE_NUMBER, TYPE_NUMBER})

concommand.AddAdmin("rpa_createfire", function(ply, duration)
	local time = math.Clamp(duration, 1, 86400)
	local tr = ply:GetEyeTrace()

	local fire = ents.Create("env_fire")
	fire:SetPos(tr.HitPos)
	fire:SetKeyValue("spawnflags", "1")
	fire:SetKeyValue("attack", "4")
	fire:SetKeyValue("firesize", "128")
	fire:Spawn()
	fire:Activate()
	fire:Fire("Enable", "")
	fire:Fire("StartFire", "")

	SafeRemoveEntityDelayed(fire, time)
end, false, {TYPE_NUMBER})

concommand.AddAdmin("rpa_togglesaved", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) and (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_effect") then
		local val = 1 - ent:PropSaved()

		ent:SetPropSaved(val)
		ent.NoDamage = tobool(val)

		undo.ReplaceEntity(ent, NULL)
		cleanup.ReplaceEntity(ent, NULL)

		constraint.RemoveAll(ent)

		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
			phys:Sleep()
		end

		GAMEMODE:SaveSavedProps()
		GAMEMODE:LogAdmin("[T] " .. ply:Nick() .. " togglesaved (" .. ent:PropSaved() .. ") " .. ent:GetModel() .. " belonging to " .. ent:PropCreator(), ply)
	end
end, false)

concommand.AddAdmin("rpa_unowndoor", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) and ent:IsDoor() then
		ent:ResetDoor()
	end
end, false)

concommand.AddAdmin("rpa_hidebadge", function(ply, bool)
	ply:SetHideAdmin(not ply:HideAdmin())
end, false)

concommand.AddAdmin("rpa_hide", function(ply, targ)
	targ:SetHidden(not targ:Hidden())
end, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_playernotes", function(ply, targ)
	GAMEMODE:PlayerNotes(ply, targ)
end, false, {TYPE_ENTITY})

local nametotrait = {}
nametotrait["none"] = TRAIT_NONE

concommand.AddAdmin("rpa_settrait", function(ply, targ, trait)
	local name = string.lower(trait) or "none"

	trait = nametotrait[name]

	if not trait then
		ply:SendChat("ERROR", "Invalid trait")

		return
	end

	targ:SetTrait(trait)

	GAMEMODE:LogAdmin("[T] " .. ply:Nick() .. " changed player " .. targ:CharacterName() .. "'s trait to " .. name .. ".", ply)

	ply:SendChat("NOTICE", "You set " .. targ:CharacterName() .. "'s trait to " .. name)
	targ:SendChat("NOTICE", ply:Nick() .. " set your trait to " .. name)
end, false, {TYPE_ENTITY, TYPE_STRING})

local nametolang = {}
nametolang["english"] = LANG_ENGLISH
nametolang["russian"] = LANG_RUSSIAN
nametolang["chinese"] = LANG_CHINESE
nametolang["japanese"] = LANG_JAPANESE
nametolang["spanish"] = LANG_SPANISH
nametolang["french"] = LANG_FRENCH
nametolang["german"] = LANG_GERMAN
nametolang["italian"] = LANG_ITALIAN

concommand.AddAdmin("rpa_givelang", function(ply, targ, lang)
	local name = string.lower(lang) or "english"

	lang = nametolang[name]

	if not lang then
		ply:SendChat("ERROR", "Invalid language")

		return
	end

	if targ:HasLang(lang) then
		ply:SendChat("ERROR", "They already speak this langauge")

		return
	end

	targ:SetLang(targ:Lang() + lang)

	GAMEMODE:LogAdmin("[T] " .. ply:Nick() .. " gave player " .. targ:CharacterName() .. " " .. name .. ".", ply)

	ply:SendChat("NOTICE", "You gave " .. targ:CharacterName() .. " the ability to speak " .. name)
	targ:SendChat("NOTICE", ply:Nick() .. " gave you the ability to speak " .. name)
end, false, {TYPE_ENTITY, TYPE_STRING})

concommand.AddAdmin("rpa_takelang", function(ply, targ, lang)
	local name = string.lower(lang) or "english"

	lang = nametolang[name]

	if not lang then
		ply:SendChat("ERROR", "Invalid language")

		return
	end

	if not targ:HasLang(lang) then
		ply:SendChat("ERROR", "They don't speak this langauge")

		return
	end

	targ:SetLang(targ:Lang() - lang)

	GAMEMODE:LogAdmin("[T] " .. ply:Nick() .. " took " .. name .. " from " .. targ:CharacterName() .. ".", ply)

	ply:SendChat("NOTICE", "You took the ability to speak " .. name .. " from " .. targ:CharacterName())
	targ:SendChat("NOTICE", ply:Nick() .. " took away the ability to speak " .. name)
end, false, {TYPE_ENTITY, TYPE_STRING})

local function OOCMute(ply, targ)
	local val = not tobool(targ:IsOOCMuted())
	local str = " unmuted "

	if val then
		str = " muted "
	end

	targ:SetIsOOCMuted(val)

	GAMEMODE:LogAdmin("[M] " .. ply:Nick() .. str .. targ:Nick() .. " from OOC.", ply)

	ply:SendChat("NOTICE", "You" .. str .. targ:CharacterName() .. " from OOC")
	targ:SendChat("NOTICE", ply:Nick() .. str .. "you from OOC")
end

-- local nametolicense = {}
-- nametolicense["generic"] = BUSINESS_GENERIC
-- nametolicense["clothing"] = BUSINESS_CLOTHING
-- nametolicense["medical"] = BUSINESS_MEDICAL
-- nametolicense["weaponry"] = BUSINESS_WEAPONRY
-- nametolicense["illegal"] = BUSINESS_ILLEGAL
-- nametolicense["quartermaster"] = BUSINESS_QUARTERMASTER

-- concommand.AddAdmin("rpa_givelicense", function(ply, targ, license)
-- 	local name = string.lower(license) or "generic"

-- 	license = nametolicense[name]

-- 	if not license then
-- 		ply:SendChat("ERROR", "Invalid license")

-- 		return
-- 	end

-- 	if targ:HasLicense(license) then
-- 		ply:SendChat("ERROR", "They already have this license")

-- 		return
-- 	end

-- 	targ:SetBusinessLicenses(targ:BusinessLicenses() + license)
-- 	targ:UpdateCharacterField("BusinessLicenses", targ:BusinessLicenses())

-- 	GAMEMODE:LogAdmin("[T] " .. ply:Nick() .. " gave player " .. targ:CharacterName() .. " a " .. name .. " license.", ply)

-- 	ply:SendChat("NOTICE", "You gave " .. targ:CharacterName() .. " the " .. name .. " license.")
-- 	targ:SendChat("NOTICE", ply:Nick() .. " gave you the " .. name .. " license.")
-- end, false, {TYPE_ENTITY, TYPE_STRING})

-- concommand.AddAdmin("rpa_takelicense", function(ply, targ, license)
-- 	local name = string.lower(license) or "generic"

-- 	license = nametolicense[name]

-- 	if not license then
-- 		ply:SendChat("ERROR", "Invalid license")

-- 		return
-- 	end

-- 	if not targ:HasLicense(license) then
-- 		ply:SendChat("ERROR", "They don't have this license")

-- 		return
-- 	end

-- 	targ:SetBusinessLicenses(targ:BusinessLicenses() - license)
-- 	targ:UpdateCharacterField("BusinessLicenses", targ:BusinessLicenses())

-- 	GAMEMODE:LogAdmin("[T] " .. ply:Nick() .. " took " .. targ:CharacterName() .. "'s " .. name .. " license.", ply)

-- 	ply:SendChat("NOTICE", "You took " .. targ:CharacterName() .. "'s " .. name .. " license.")
-- 	targ:SendChat("NOTICE", ply:Nick() .. " took your " .. name .. " license.")
-- end, false, {TYPE_ENTITY, TYPE_STRING})

concommand.AddAdmin("rpa_oocmute", OOCMute, false, {TYPE_ENTITY})
concommand.AddAdmin("rpa_mute", OOCMute, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_travelban", function(ply, targ)
	local val = not tobool(targ:IsTravelBanned())
	local str = " unbanned "

	if val then
		str = " banned "
	end

	targ:SetIsTravelBanned(val)

	GAMEMODE:LogAdmin("[M] " .. ply:Nick() .. " " .. str .. " " .. targ:Nick() .. " from travelling.", ply)

	ply:SendChat("NOTICE", "You" .. str .. targ:CharacterName() .. " from travelling")
	targ:SendChat("NOTICE", ply:Nick() .. str .. "you from travelling")
end, false, {TYPE_ENTITY})

concommand.AddAdmin("rpa_charlist", function(ply, steamid)
	if not GAMEMODE:IsValidSteamID(steamid) then
		ply:SendChat("ERROR", "SteamID is invalid")

		return
	end

	GAMEMODE:GetCharacterList(steamid, ply)
end, false, {TYPE_STRING})

-- concommand.AddAdmin("rpa_getchardata", function(ply, id)
-- 	id = math.Round(id)

-- 	if id < 1 then
-- 		ply:SendChat("ERROR", "Character ID is invalid")

-- 		return
-- 	end

-- 	GAMEMODE:GetCharacterData(id, ply)
-- end, false, {TYPE_NUMBER})

concommand.AddAdmin("rpa_getcharinv", function(ply, id)
	id = math.Round(id)

	if id < 1 then
		ply:SendChat("ERROR", "Character ID is invalid")

		return
	end

	GAMEMODE:GetCharacterInventory(id, ply)
end, false, {TYPE_NUMBER})

concommand.AddAdmin("rpa_wipecharflags", function(ply, id)
	id = math.Round(id)

	if id < 1 then
		ply:SendChat("ERROR", "Character ID is invalid")

		return
	end

	local offline = true

	for _, v in player.Iterator() do
		if v:CharID() == id then
			v:SetCharFlags("")

			v:SetCombineFlag("")

			v:SendChat("NOTICE", ply:Nick() .. " has wiped your flags")

			offline = false

			break
		end
	end

	GAMEMODE:LogAdmin("[F] " .. ply:Nick() .. " has wiped the flags of character " .. id .. ".", ply)
end, false, {TYPE_NUMBER})

concommand.AddAdmin("rpa_deleteitem", function(ply, id)
	id = math.Round(id)

	if id < 1 then
		ply:SendChat("ERROR", "Item ID is invalid")

		return
	end

	local item = GAMEMODE:GetItem(id)

	if item then
		ply:SendChat("ERROR", "This item is currently loaded, delete it through a different method")

		return
	else
		local function cb()
			if IsValid(ply) then
				ply:SendChat("NOTICE", "You've deleted item #" .. id)
			end

			GAMEMODE:WriteLog("admin_deleteitem", {Admin = GAMEMODE:LogPlayer(ply), ID = id})
		end

		GAMEMODE.SQL:Query([[
			UPDATE $items SET Deleted = 1
				WHERE id = ?
			]], id, cb)
	end
end, false, {TYPE_NUMBER})

concommand.AddAdmin("rpa_restoreitem", function(ply, id)
	id = math.Round(id)

	if id < 1 then
		ply:SendChat("ERROR", "Item ID is invalid")

		return
	end

	local item = GAMEMODE:GetItem(id)

	if item then
		ply:SendChat("ERROR", "This item is already loaded and doesn't have to be restored")

		return
	end

	local function cb()
		GAMEMODE:DBLoadItems({id})

		if IsValid(ply) then
			ply:SendChat("NOTICE", "You've restored item #" .. id .. " to your inventory")
		end

		GAMEMODE:WriteLog("admin_restoreitem", {Admin = GAMEMODE:LogPlayer(ply), ID = id})
	end

	GAMEMODE.SQL:Query([[
		UPDATE $items SET Deleted = 0, StorageType = ?, CharacterID = ?
			WHERE id = ?
		]], ITEM_PLAYER, ply:CharID(), id, cb)
end, false, {TYPE_NUMBER})

concommand.AddAdmin("rpa_charlookup", function(ply, name)
	GAMEMODE:CharacterLookup(name, ply)
end, false, {TYPE_STRING})

concommand.AddAdmin("rpa_adminradio", function(ply, bool)
	ply:SetAdminRadio(bool)
end, false, {TYPE_BOOL})

function GM:PlayerNoClip(ply)
	if ply:PassedOut() then return false end
	if ply:Bottify() then return false end

	if not ply:IsAdmin() and not ply:IsEventCoordinator() then

		if CLIENT and IsFirstTimePredicted() then

			lp:SendChat("ERROR", "You need to be an admin to do this.")

		end

		return false

	end

	if SERVER then

		if ply:IsEFlagSet(EFL_NOCLIP_ACTIVE) then

			ply:GodDisable()
			ply:SetNoTarget(false)
			ply:SetNoDraw(false)
			ply:SetNotSolid(false)

			if ply:GetActiveWeapon() != NULL then

				ply:GetActiveWeapon():SetNoDraw(false)
				ply:GetActiveWeapon():SetColor(Color(255, 255, 255, 255))

			end

			if ply.NoclipPos then

				ply:SetPos(ply.NoclipPos)
				ply.NoclipPos = nil

			end

		else

			ply:GodEnable()
			ply:SetNoTarget(true)
			ply:SetNoDraw(true)
			ply:SetNotSolid(true)

			if ply:GetActiveWeapon() != NULL then

				ply:GetActiveWeapon():SetNoDraw(true)
				ply:GetActiveWeapon():SetColor(Color(255, 255, 255, 0))

			end

			if ply:IsEventCoordinator() then

				ply.NoclipPos = ply:GetPos()

			end

		end

	end

	return true
end

concommand.AddAdmin("rpa_setplayerscale", function(ply, targ, val, persist)
	if val > 10 or val < 0.1 then
		ply:SendChat("ERROR", "Scale must be between 0.1 and 10")

		return
	end

	targ:SetScale(val, true)

	if persist then
		local flag = targ:RunCharFlag("Scale")

		if flag then
			ply:SendChat("ERROR", "Target has a character flag overriding scale, cannot persist")

			return
		end

		targ:SetCharacterScale(val)
	end
end, false, {TYPE_ENTITY, TYPE_NUMBER, TYPE_BOOL})

concommand.AddAdmin("rpa_infiniteammo", function(ply, targ, bool)
	targ:SetInfiniteAmmo(bool)
end, false, {TYPE_ENTITY, TYPE_BOOL})

concommand.AddAdmin("rpa_setspawnoverride", function(ply)
	if GAMEMODE.EntryPortSpawns[1] and not GAMEMODE.SpawnBackup then
		GAMEMODE.SpawnBackup = GAMEMODE.EntryPortSpawns[1]
	end

	GAMEMODE.EntryPortSpawns[1] = {ply:GetPos()}
end)

concommand.AddAdmin("rpa_restorespawns", function(ply)
	GAMEMODE.EntryPortSpawns[1] = GAMEMODE.SpawnBackup or nil
end)

concommand.AddAdmin("rpa_setlight", function(ply, group, style)
	for _, v in ipairs(ents.FindByClass("cc_light*")) do
		if v:GetLightGroup() == group then
			local old = v:GetStyle()

			v:SetStyle(style)

			if style != old and v:IsReady() then
				v:Save()
			end
		end
	end
end, false, {TYPE_NUMBER, TYPE_NUMBER})

concommand.AddAdmin("rpa_radiostatic", function(ply, severity)
	GAMEMODE.RadioJammed = severity > 0 and severity or nil
end, false, {TYPE_NUMBER})

concommand.AddAdmin("rpa_givetempadmin", function(ply, targ)
	local tab = {}

	for _, v in player.Iterator() do
		if v:IsAdmin() then
			table.insert(tab, v)
		end
	end

	Chat.Send(tab, "NOTICE", string.format("%s has given admin to %s.", ply:Nick(), targ:Nick()))

	targ:SetUserGroup("admin")
end, true, {TYPE_ENTITY})

concommand.AddAdmin("rpa_taketempadmin", function(ply, targ)
	targ:SetUserGroup("user")

	local tab = {}

	for _, v in player.Iterator() do
		if v:IsAdmin() then
			table.insert(tab, v)
		end
	end

	Chat.Send(tab, "NOTICE", string.format("%s has taken admin from %s.", ply:Nick(), targ:Nick()))
end, true, {TYPE_ENTITY})
