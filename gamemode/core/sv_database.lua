module("Database", package.seeall)

function Load(db)
	CreateTables(db)
end

function CreateTables(db)
	local query

	query = db:Create("rp_players")
		query:Create("SteamID", "VARCHAR(32) NOT NULL", true)
	query:Execute()

	query = db:Create("rp_characters")
		query:Create("id", "INT NOT NULL AUTO_INCREMENT", true)
		query:Create("SteamID", "VARCHAR(32) NOT NULL", true)
		query:Create("Created_At", "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
		query:Create("Deleted_At", "TIMESTAMP")
	query:Execute()

	PopulateFromVars(db, "rp_players", PlayerVar.Vars)
	PopulateFromVars(db, "rp_characters", CharacterVar.Vars)
end

function PopulateFromVars(db, tableName, vars)
	local columns = {}

	for _, col in pairs(db:Query(string.format("SHOW COLUMNS FROM `%s`", tableName))) do
		columns[col.Field] = true
	end

	local query

	for name, data in pairs(vars) do
		if not data.Persist or columns[data.Field] then
			continue
		end

		if not query then
			query = db:Alter(tableName)
		end

		query:Add(data.Field, data.DataType)
	end

	if query then
		query:Execute()
	end
end

function GM:LoadDatabase()
	async.Start(function()
		local config = self.DatabaseConfig

		self.Database = database.New(config.Host, config.Username, config.Password, config.Database, config.Port)

		Load(self.Database)
	end)
end
