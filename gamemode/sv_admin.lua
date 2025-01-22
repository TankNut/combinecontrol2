local GM = GM or GAMEMODE
net.Receive("nGetBansList", function(len, ply)
	if not ply:IsAdmin() then return end

	net.Start("nBansList")
		net.WriteTable(GAMEMODE.BanTable or {})
	net.Send(ply)
end)
