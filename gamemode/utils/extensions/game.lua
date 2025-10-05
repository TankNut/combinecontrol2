function game.GetMapList()
	local tab = {}

	for _, map in ipairs(file.Find("maps/*.bsp", "GAME")) do
		table.insert(tab, string.FileName(map))
	end

	return tab
end

function game.GetIP()
	local hostip = tonumber(GetConVar("hostip"):GetString())

	local ip = {}
	ip[1] = bit.rshift(bit.band(hostip, 0xFF000000), 24)
	ip[2] = bit.rshift(bit.band(hostip, 0x00FF0000), 16)
	ip[3] = bit.rshift(bit.band(hostip, 0x0000FF00), 8)
	ip[4] = bit.band(hostip, 0x000000FF)

	return table.concat(ip, ".")
end

function game.GetPort()
	return tonumber(GetConVar("hostport"):GetString())
end
