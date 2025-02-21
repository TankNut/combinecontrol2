net.Receive("nAFlagsRoster", function(len)
	local tab = net.ReadTable()

	MsgC(Color(128, 128, 128, 255), "FLAG ROSTER:\n")

	for _, v in pairs(tab) do

		MsgC(Color(128, 128, 128, 255), v.RPName, "\t", Color(229, 201, 98, 255), v.CharFlags, "\t", GAMEMODE:CharFlagPrintName(v.CharFlags), "\n")

	end
end)

net.Receive("nAPlayMusic", function(len)
	local song = net.ReadString()

	GAMEMODE:PlayMusic(song)
end)

net.Receive("nAStopMusic", function(len)
	GAMEMODE:FadeOutMusic()
end)

net.Receive("nAPlayOverwatch", function(len)
	local id = net.ReadFloat()

	surface.PlaySound(GAMEMODE.OverwatchLines[id][1])
end)

net.Receive("nAListCharacters", function(len)
	local steamID = net.ReadString()
	local tab = net.ReadTable()

	if #tab < 1 then
		MsgC(Color(200, 0, 0, 255), "No characters found for " .. steamID .. ".\n")

		return
	else
		MsgC(Color(200, 200, 200, 255), "Character list for: " .. steamID .. " (" .. #tab .. " characters)\n")
	end

	local fieldsLen = {}

	for _, char in pairs(tab) do
		for index, field in pairs(char) do
			fieldsLen[index] = math.max(fieldsLen[index] or 0, #tostring(field))
		end
	end

	for _, v in pairs(tab) do
		-- Using %-*s wouldn't work for some reason, so we'll do it the ugly way
		MsgC(Color(200, 200, 200, 255), string.format("CharID: %-" .. fieldsLen.id ..
			"s | Name: %-" .. fieldsLen.RPName ..
			"s | Flags: %-" .. fieldsLen.CharFlags ..
			"s\n",v.id, v.RPName, v.CharFlags))
	end
end)

net.Receive("nACharacterData", function(len)
	local id = net.ReadInt(32)
	local tab = net.ReadTable()

	if #tab < 1 then
		MsgC(Color(200, 0, 0, 255), "No data found for charid " .. id .. "\n")

		return
	end

	tab = tab[1]

	MsgC(Color(200, 200, 200, 255), "Character data for charid: " .. id .. "\n")

	local keyLen = 0

	for index, _ in pairs(tab) do
		keyLen = math.max(keyLen, #tostring(index))
	end

	for k, v in pairs(tab) do
		MsgC(Color(200, 200, 200, 255), string.format("%-" .. keyLen .. "s: " .. v .. "\n", k))
	end
end)

net.Receive("nACharacterInventory", function(len)
	local id = net.ReadInt(32)
	local tab = net.ReadTable()

	if #tab < 1 then
		MsgC(Color(200, 0, 0, 255), "No data found for charid " .. id .. ".\n")

		return
	end

	local inv = string.Explode("|", tab[1].Inventory)

	local function printItems(data)
		local itemTab = {}
		local keyLen = 0

		for _, v in pairs(data) do
			if #v < 1 then
				continue
			end

			local arr = string.Explode(":", v)

			itemTab[arr[1]] = arr[2]
			keyLen = math.max(keyLen, #arr[1])
		end

		if table.Count(itemTab) < 1 then
			MsgC(Color(200, 0, 0, 255), "No items found\n")

			return
		end

		for k, v in SortedPairs(itemTab) do
			MsgC(Color(200, 200, 200, 255), string.format("%-" .. keyLen .. "s: " .. v .. "\n", k))
		end
	end

	MsgC(Color(200, 200, 200, 255), "Inventory for charid " .. id .. " (" .. tab[1].RPName .. ")\n")

	if #inv > 0 then
		printItems(inv)
	else
		MsgC(Color(200, 0, 0, 255), "No items found\n")
	end
end)

net.Receive("nACharacterLookup", function(len)
	local name = net.ReadString()
	local tab = net.ReadTable()

	if #tab < 1 then
		MsgC(Color(200, 0, 0, 255), "No matches found for " .. name .. "\n")

		return
	else
		MsgC(Color(200, 200, 200, 255), "Character matches for " .. name .. ": (" .. #tab .. " matches)\n")
	end

	local fieldsLen = {}

	for _, char in pairs(tab) do
		for index, field in pairs(char) do
			fieldsLen[index] = math.max(fieldsLen[index] or 0, #tostring(field))
		end
	end

	for _, v in pairs(tab) do
		-- Using %-*s wouldn't work for some reason, so we'll do it the ugly way
		MsgC(Color(200, 200, 200, 255), string.format("CharID: %-" .. fieldsLen.id ..
			"s | Name: %-" .. fieldsLen.RPName ..
			"s | SteamID: %-" .. fieldsLen.SteamID ..
			"s | Flags: %-" .. fieldsLen.CharFlags ..
			"s\n",v.id, v.RPName, v.SteamID, v.CharFlags))
	end
end)
