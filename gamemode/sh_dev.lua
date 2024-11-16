concommand.AddAdmin("rp_dev_lootstats", function(ply)
	local pools = {}
	local entities = ents.FindByClass("cc_loot")
	local full = 0

	for _, v in pairs(entities) do
		local pool = v:GetLootPool()

		if not pools[pool] then
			pools[pool] = {
				total = 0,
				full = 0
			}
		end

		pool = pools[pool]

		pool.total = pool.total + 1

		if v.StoredItem then
			full = full + 1
			pool.full = pool.full + 1
		end
	end

	ply:PrintMessage(HUD_PRINTCONSOLE, string.format("%s loot points (%s/%.2f%% populated)", #entities, full, (full / #entities) * 100))

	local playerCount = player.GetCount()

	for k, v in pairs(pools) do
		if playerCount < GAMEMODE.Loot.Rates[k][1] then
			ply:PrintMessage(HUD_PRINTCONSOLE, string.format("%-20s | %s entities | Disabled (Not enough players)", k, v.total))

			continue
		end

		local time = GAMEMODE.LootData.Time[k]
		local rates = GAMEMODE.Loot.Rates[k]

		local cooldown = math.RemapC(playerCount, rates[1], game.MaxPlayers(), rates[2], rates[3])

		ply:PrintMessage(HUD_PRINTCONSOLE,
			string.format("%-20s | %s entities | Active | %s populated (%.2f%%) | %i seconds (%s until next item)", k, v.total, v.full, (v.full / v.total) * 100,
				cooldown, string.NiceTime(time + cooldown - CurTime())))
	end

	ply:PrintMessage(HUD_PRINTCONSOLE, "---")

	for k, v in SortedPairsByMemberValue(GAMEMODE.LootStats.Players, "Total", true) do
		local time = math.max(v.Last - v.Start, 1)
		ply:PrintMessage(HUD_PRINTCONSOLE, string.format("%-32s | %-19s | %i attempts (%i successful) (%i rate limited) | Average of %.2f per minute over %s", v.Nick, k, v.Total, v.Successful, v.RateLimit, (v.Total / time) * 60, string.NiceTime(time)))
	end
end, true)
