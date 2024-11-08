function GM:LoadDatabase()
	async.Start(function()
		local config = self.DatabaseConfig

		self.Database = database.New(config.Host, config.Username, config.Password, config.Database, config.Port)

		hook.Run("LoadDatabaseTables", self.Database)
		hook.Run("PostLoadDatabase", self.Database)
	end)
end

function GM:LoadDatabaseTables(db)
	local query

	query = db:Create("rp_player_data")
		query:Create("steamid", "VARCHAR(32) NOT NULL", true)
		query:Create("key", "VARCHAR(255) NOT NULL", true)
		query:Create("value", "TEXT NOT NULL")
	query:Execute()

	query = db:Create("rp_characters")
		query:Create("id", "INT NOT NULL AUTO_INCREMENT", true)
		query:Create("steamid", "VARCHAR(32) NOT NULL", true)
	query:Execute()

	query = db:Create("rp_character_data")
		query:Create("id", "INT NOT NULL", true)
		query:Create("key", "VARCHAR(255) NOT NULL", true)
		query:Create("value", "TEXT NOT NULL")
	query:Execute()

	db:Suppress()
	db:Query("ALTER TABLE rp_character_data ADD CONSTRAINT fk_rp_characters_id FOREIGN KEY (id) REFERENCES rp_characters(id) ON DELETE CASCADE")
end
