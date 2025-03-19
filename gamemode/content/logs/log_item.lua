Log.AddType("item_destroy", function(ply, item)
	return string.format("%s has destroyed a %s", ply:VisibleRPName(), item.ClassName), {
		Log.Character(ply),
		Log.Item(item)
	}
end)

Log.AddType("item_drop", function(ply, item)
	return string.format("%s has dropped a %s", ply:VisibleRPName(), item.ClassName), {
		Log.Character(ply),
		Log.Item(item)
	}
end)

Log.AddType("item_pickup", function(ply, item)
	return string.format("%s has picked up a %s", ply:VisibleRPName(), item.ClassName), {
		Log.Character(ply),
		Log.Item(item)
	}
end)
