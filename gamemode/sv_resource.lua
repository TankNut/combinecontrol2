if Config.Get("WorkshopAddons") then
	for k, v in pairs(Config.Get("WorkshopAddons")) do
		resource.AddWorkshop(v)
	end
end
