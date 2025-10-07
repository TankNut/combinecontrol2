hook.Add("StartCommand", "cc2.Bots", function(bot, cmd)
	if bot:IsBot() and not bot:Alive() then
		cmd:SetButtons(IN_JUMP)
	end
end)

hook.Add("PlayerSpawn", "cc2.Bots", function(_, ply)
	if ply:IsBot() and not ply:HasCharacter() then
		async.Start(CharacterGen.Run, ply, Config.Get("BotGenerator"), true)
	end
end, POST_HOOK)
