module("Database", package.seeall)

function Initialize(db)
	GAMEMODE.Database = db

	-- We've already ran the create_tables migration, so make sure vars are populated
	if #db:Query("SHOW TABLES LIKE 'rp_players'") > 0 then
		PopulateFromVars(db, "rp_players", PlayerVar.Vars)
		PopulateFromVars(db, "rp_characters", CharacterVar.Vars)
	end

	db:RunMigrations(engine.ActiveGamemode() .. "/gamemode/core/migrations/")

	db:Query("DELETE FROM rp_characters WHERE SteamID = 'BOT'")
end

function PopulateFromVars(db, tableName, vars)
	local columns = {}

	for _, column in pairs(db:Query(string.format("SHOW COLUMNS FROM `%s`", tableName))) do
		columns[column.Field] = string.upper(column.Type)
	end

	local fields = {}

	for name, data in pairs(vars) do
		local column = columns[data.Field]

		if not data.Persist or column == data.DataType then
			continue
		end

		if column == nil then
			table.insert(fields, string.format("ADD COLUMN `%s` %s", data.Field, data.DataType))
		else
			table.insert(fields, string.format("MODIFY COLUMN `%s` %s", data.Field, data.DataType))
		end
	end

	if #fields > 0 then
		db:Query(string.format("ALTER TABLE `%s` %s", tableName, table.concat(fields, ", ")))
	end
end

function GM:LoadDatabase()
	async.Start(function()
		local config = Config.Get("Database")

		Initialize(database.New(config.Host, config.Username, config.Password, config.Database, config.Port))

		Access.LoadBans()
		Item.LoadWorld()
		GlobalVar.Load()
		WorldEnts.LoadEntities()
	end)
end
