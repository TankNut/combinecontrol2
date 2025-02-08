if SERVER then
	net.Receive("nSetPropDesc", function(len, ply)
		local MAX_CHARS = 140

		local ent = net.ReadEntity()
		local description = string.Trim(net.ReadString())

		if #description > MAX_CHARS then
			net.Start("nPropDescTooLong")
				net.WriteFloat(MAX_CHARS)
			net.Send(ply)
		else
			if IsValid(ent) then
				GAMEMODE:WriteLog("sandbox_propdesc", {Char = GAMEMODE:LogCharacter(ply), Ply = GAMEMODE:LogPlayer(ply), Ent = tostring(ent), Before = ent:PropDescription(), After = description})
				ent:SetPropDescription(description)
			end
		end
	end)
end

net.Receive("nPropDescTooLong", function (len)
	if SERVER then return end

	local maxChars = net.ReadFloat()
	lp:SendChat("ERROR", "Prop descriptions are limited to " .. maxChars)
end)

function GM:ContextMenuOpen()
	return LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool" and not CCP.ContextMenu
end
