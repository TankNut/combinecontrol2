Log.AddType("item_destroy", function(ply, item)
	return string.format("%s has destroyed %s", ply:VisibleRPName(), item), {
		Log.Player(ply),
		Log.Item(item)
	}
end)

Log.AddType("item_drop", function(ply, item)
	return string.format("%s has dropped %s", ply:VisibleRPName(), item), {
		Log.Player(ply),
		Log.Item(item)
	}
end)

Log.AddType("item_pickup", function(ply, item)
	return string.format("%s has picked up %s", ply:VisibleRPName(), item), {
		Log.Player(ply),
		Log.Item(item)
	}
end)

Log.AddType("item_equip", function(ply, item)
	return string.format("%s has equipped %s", ply:VisibleRPName(), item), {
		Log.Player(ply),
		Log.Item(item)
	}
end)

Log.AddType("item_unequip", function(ply, item)
	return string.format("%s has unequipped %s", ply:VisibleRPName(), item), {
		Log.Player(ply),
		Log.Item(item)
	}
end)

Log.AddType("item_set_name", function(ply, item, name)
	return string.format("%s has renamed %s to %s", ply:VisibleRPName(), item, name), {
		Log.Player(ply),
		Log.Item(item)
	}
end)

Log.AddType("item_set_description", function(ply, item, description)
	return string.format("%s has described %s as '%s'", ply:VisibleRPName(), item, description), {
		Log.Player(ply),
		Log.Item(item)
	}
end)
