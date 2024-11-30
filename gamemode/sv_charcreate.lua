net.Receive("nDeleteCharacter", function(len, ply)
	local id = net.ReadFloat()

	if ply:SQLCharExists(id) then

		if ply:CharID() == id then return end

		local char = ply:GetCharFromID(id)

		ply:DeleteCharacter(id, char.RPName)

	end
end)

net.Receive("nChangeRPName", function(len, ply)
	local name = net.ReadString()

	name = string.Trim(name)

	if #name <= GAMEMODE.MaxNameLength and #name >= GAMEMODE.MinNameLength and GAMEMODE:CheckNameValidity(name) then
		GAMEMODE:WriteLog("character_setname", {Char = GAMEMODE:LogCharacter(ply), Ply = GAMEMODE:LogPlayer(ply), Name = name})

		ply:SetCharacterName(name)
		ply:UpdateVisibleName()
	end
end)

net.Receive("nChangeTitle", function(len, ply)
	local desc = net.ReadString()

	desc = string.Trim(desc)

	if #desc <= GAMEMODE.MaxDescLength then
		GAMEMODE:WriteLog("character_setdesc", {Char = GAMEMODE:LogCharacter(ply), Ply = GAMEMODE:LogPlayer(ply), New = desc})

		ply:SetDescription(desc)
		ply:UpdateCharacterField("Title", desc)
	end
end)

net.Receive("nSetNewbieStatus", function(len, ply)
	local status = 1 - net.ReadBit()

	ply:SetNewbieStatus(status)
	ply:UpdatePlayerField("NewbieStatus", status)
end)
