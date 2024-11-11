function GM:OnPlayerReady(ply)
	async.Start(function()
		PlayerVars.Load(ply)
	end)
end
