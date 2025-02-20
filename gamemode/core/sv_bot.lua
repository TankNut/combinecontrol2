hook.Add("StartCommand", "bot", function(bot, cmd)
	if not bot:IsBot() then
		return
	end

	cmd:ClearButtons()
	cmd:ClearMovement()

	if not bot:Alive() then
		cmd:SetButtons(IN_JUMP)
	end
end)

hook.Add("PlayerSpawn", "bot", function(_, ply)
	if ply:IsBot() and not ply:HasCharacter() then
		CharacterGen.Run(ply, Config.Get("BotGenerator"), true)
	end
end, POST_HOOK)

hook.Add("PlayerDisconnected", "bot", function(ply)
	if ply:IsBot() and ply:IsTemporaryCharacter() then
		-- Otherwise they'll keep piling up
		Character.DeleteTemp(ply:CharID())
	end
end)
