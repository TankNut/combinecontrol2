hook.Add("PrePlayerDraw", "noclip", function(ply, flags)
	if ply:IsAdmin() and ply:IsEFlagSet(EFL_NOCLIP_ACTIVE) then
		return true
	end
end)

hook.Add("PostDrawTranslucentRenderables", "flag", function(depth, skybox)
	for _, v in player.Iterator() do
		if v:IsDormant() or v:GetNoDraw() then
			continue
		end

		if v == LocalPlayer() and not v:ShouldDrawLocalPlayer() then
			continue
		end

		local func = v:RunCharFlag("PostDrawTranslucentRenderables")

		if not func then
			continue
		end

		func(v, depth, skybox)
	end
end)
