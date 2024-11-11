function GM:InitPostEntity()
	-- Legacy code
	hook.Run("CC.SH.InitEnts")

	if CLIENT then
		net.Start("nRequestPData")
		net.SendToServer()

		return
	end
	-- Legacy code ends

	hook.Run("LoadDatabase")
end
