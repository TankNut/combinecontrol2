local workshopMapResources = GM.WorkshopMaps[game.GetMap()]

if workshopMapResources then
	for _, id in pairs(workshopMapResources) do
		resource.AddWorkshop(id)
	end
end

if GM.WorkshopAddons then
	for k, v in pairs(GM.WorkshopAddons) do
		resource.AddWorkshop(v)
	end
end
