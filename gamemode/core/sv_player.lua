function GM:OnPlayerReady(ply)
	async.Start(function()
		PlayerVars.Load(ply)
		print("Player vars loaded")
	end)
end
