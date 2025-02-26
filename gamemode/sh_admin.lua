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

concommand.AddAdmin("rpa_invisible", function(ply, targ, bool)
	GAMEMODE:WriteLog("admin_invisible", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ), Bool = bool})
	targ:SetNoDraw(bool)
end, false, {TYPE_ENTITY, TYPE_BOOL})

concommand.AddAdmin("rpa_namewarn", function(ply, targ)
	GAMEMODE:WriteLog("admin_namewarn", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(targ), Char = GAMEMODE:LogCharacter(targ)})

	net.Start("nWarnName")
	net.Send(targ)
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
	if not util.IsValidSteamID(steamid) then
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
	if not util.IsValidSteamID(steamid) then
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

concommand.AddAdmin("rpa_unowndoor", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) and ent:IsDoor() then
		ent:ResetDoor()
	end
end, false)

concommand.AddAdmin("rpa_hidebadge", function(ply, bool)
	ply:SetHideAdmin(not ply:HideAdmin())
end, false)

concommand.AddAdmin("rpa_playernotes", function(ply, targ)
	GAMEMODE:PlayerNotes(ply, targ)
end, false, {TYPE_ENTITY})

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
