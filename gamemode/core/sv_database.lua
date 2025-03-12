module("Database", package.seeall)

function CreateTables(db)
	local query

	query = db:Create("rp_players")
		query:Create("SteamID", "VARCHAR(32) NOT NULL", true)
	query:Execute()

	query = db:Create("rp_characters")
		query:Create("id", "INT NOT NULL AUTO_INCREMENT", true)
		query:Create("SteamID", "VARCHAR(32) NOT NULL")
		query:Create("Created_At", "INT UNSIGNED NOT NULL")
		query:Create("Deleted_At", "INT UNSIGNED")

		query:Index("SteamID")
	query:Execute()

	query = db:Create("rp_items")
		query:Create("id", "INT NOT NULL AUTO_INCREMENT", true)
		query:Create("Class", "VARCHAR(64) NOT NULL")
		query:Create("StoreType", "INT")
		query:Create("StoreID", "VARCHAR(64)")
		query:Create("MapData", "BLOB")
		query:Create("CustomData", "BLOB")

		query:Index("StoreType", "StoreID")
	query:Execute()

	query = db:Create("rp_globals")
		query:Create("Map", "VARCHAR(32) NOT NULL", true)
		query:Create("Key", "VARCHAR(64) NOT NULL", true)
		query:Create("Value", "BLOB NOT NULL")
	query:Execute()

	query = db:Create("rp_bans")
		query:Create("SteamID", "VARCHAR(32) NOT NULL", true)
		query:Create("Admin", "VARCHAR(32) NOT NULL")
		query:Create("Timestamp", "INT UNSIGNED NOT NULL")
		query:Create("Length", "INT UNSIGNED NOT NULL")
		query:Create("Reason", "VARCHAR(256) NOT NULL")
	query:Execute()

	query = db:Create("rp_logs")
		query:Create("id", "INT NOT NULL AUTO_INCREMENT", true)
		query:Create("Name", "VARCHAR(64) NOT NULL")
		query:Create("Log", "TEXT NOT NULL")
		query:Create("Timestamp", "INT UNSIGNED NOT NULL")
		query:Create("Data", "BLOB")

		query:Index("Name")
		query:Index("Timestamp")
	query:Execute()

	query = db:Create("rp_log_data")
		query:Create("id", "INT NOT NULL")
		query:Create("Key", "VARCHAR(64) NOT NULL")
		query:Create("Value", "VARCHAR(512) NOT NULL")

		query:Index("Key", "Value")
	query:Execute()

	db:Suppress()
	db:Query("ALTER TABLE rp_log_data ADD CONSTRAINT fk_id FOREIGN KEY (id) REFERENCES rp_logs (id) ON DELETE CASCADE")

	query = db:Create("rp_worldents")
		query:Create("id", "INT NOT NULL AUTO_INCREMENT", true)
		query:Create("Class", "VARCHAR(64) NOT NULL")
		query:Create("Map", "VARCHAR(32) NOT NULL")
		query:Create("MapData", "BLOB")
		query:Create("CustomData", "BLOB")
	query:Execute()

	PopulateFromVars(db, "rp_players", PlayerVar.Vars)
	PopulateFromVars(db, "rp_characters", CharacterVar.Vars)
end

function PopulateFromVars(db, tableName, vars)
	local columns = {}

	for _, column in pairs(db:Query(string.format("SHOW COLUMNS FROM `%s`", tableName))) do
		columns[column.Field] = string.upper(column.Type)
	end

	local query

	for name, data in pairs(vars) do
		local column = columns[data.Field]

		if not data.Persist or column == data.DataType then
			continue
		end

		if not query then
			query = db:Alter(tableName)
		end

		if column == nil then
			query:Add(data.Field, data.DataType)
		else
			query:Modify(data.Field, data.DataType)
		end
	end

	if query then
		query:Execute()
	end

	for name, data in pairs(vars) do
		if data.DatabaseIndex then
			db:Query(string.format("CREATE INDEX IF NOT EXISTS cc_%s ON %s (%s)",
				data.Field, tableName, data.Field))
		end
	end
end

function GM:LoadDatabase()
	async.Start(function()
		local config = Config.Get("Database")

		self.Database = database.New(config.Host, config.Username, config.Password, config.Database, config.Port)

		CreateTables(self.Database)

		Access.LoadBans()
		Item.LoadWorld()
		GlobalVar.Load()
		WorldEnts.LoadEntities()
	end)
end
