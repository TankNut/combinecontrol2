Log.AddType("sandbox_spawn_prop", function(ply, model)
	return string.format("%s has spawned a prop: %s", ply:Nick(), model), {
		Log.Player(ply)
	}
end)

Log.AddType("sandbox_spawn_entity", function(ply, class)
	return string.format("%s has spawned an entity: %s", ply:Nick(), class), {
		Log.Player(ply)
	}
end)

Log.AddType("sandbox_spawn_vehicle", function(ply, class)
	return string.format("%s has spawned a vehicle: %s", ply:Nick(), class), {
		Log.Player(ply)
	}
end)

Log.AddType("sandbox_spawn_npc", function(ply, class)
	return string.format("%s has spawned a NPC: %s", ply:Nick(), class), {
		Log.Player(ply)
	}
end)

Log.AddType("sandbox_spawn_weapon", function(ply, class)
	return string.format("%s has spawned a weapon: %s", ply:Nick(), class), {
		Log.Player(ply)
	}
end)

Log.AddType("sandbox_tool", function(ply, tool, class)
	return string.format("%s used %s on %s", ply:Nick(), tool, class), {
		Log.Player(ply)
	}
end)

Log.AddType("sandbox_kill", function(ply, victim, weapon)
	return string.format("%s killed %s using %s", ply:Nick(), victim:Nick(), weapon), {
		Log.Player(ply),
		Log.Player(victim)
	}
end)
