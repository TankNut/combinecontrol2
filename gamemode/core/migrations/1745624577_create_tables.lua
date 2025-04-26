return function(db)
	db:Query([[CREATE TABLE `rp_players` (
		`SteamID` VARCHAR(32) NOT NULL,
		PRIMARY KEY (`SteamID`)
	)]])

	db:Query([[CREATE TABLE `rp_characters` (
		`id` INT NOT NULL AUTO_INCREMENT,
		`SteamID` VARCHAR(32) NOT NULL,
		`Created_At` INT UNSIGNED NOT NULL,
		`Deleted_At` INT UNSIGNED,
		PRIMARY KEY(`id`),
		INDEX(`SteamID`),
		INDEX(`Deleted_At`)
	)]])

	db:Query([[CREATE TABLE `rp_items` (
		`id` INT NOT NULL AUTO_INCREMENT,
		`Class` VARCHAR(64) NOT NULL,
		`StoreType` INT,
		`StoreID` VARCHAR(64),
		`MapData` BLOB,
		`CustomData` BLOB,
		`Created_At` INT UNSIGNED NOT NULL,
		`Deleted_At` INT UNSIGNED,
		PRIMARY KEY(`id`),
		INDEX(`StoreType`, `StoreID`),
		INDEX(`Deleted_At`)
	)]])

	db:Query([[CREATE TABLE `rp_globals` (
		`Map` VARCHAR(32) NOT NULL,
		`Key` VARCHAR(64) NOT NULL,
		`Value` BLOB NOT NULL,
		`StoreID` VARCHAR(64),
		`MapData` BLOB,
		`CustomData` BLOB,
		`Created_At` INT UNSIGNED NOT NULL,
		`Deleted_At` INT UNSIGNED,
		PRIMARY KEY(`Map`, `Key`)
	)]])

	db:Query([[CREATE TABLE `rp_bans` (
		`SteamID` VARCHAR(32) NOT NULL,
		`Admin` VARCHAR(32) NOT NULL,
		`Timestamp` INT UNSIGNED NOT NULL,
		`Length` INT UNSIGNED NOT NULL,
		`Reason` VARCHAR(256) NOT NULL,
		PRIMARY KEY(`SteamID`)
	)]])

	db:Query([[CREATE TABLE `rp_logs` (
		`id` INT NOT NULL AUTO_INCREMENT,
		`Name` VARCHAR(64) NOT NULL,
		`Log` TEXT NOT NULL,
		`Timestamp` INT UNSIGNED NOT NULL,
		`Data` BLOB,
		PRIMARY KEY(`id`),
		INDEX(`Name`),
		INDEX(`Timestamp`)
	)]])

	db:Query([[CREATE TABLE `rp_log_data` (
		`id` INT NOT NULL,
		`Key` VARCHAR(64) NOT NULL,
		`Value` VARCHAR(512) NOT NULL,
		INDEX(`Key`, `Value`)
	)]])

	db:Query("ALTER TABLE `rp_log_data` ADD CONSTRAINT FOREIGN KEY (`id`) REFERENCES `rp_logs` (`id`) ON DELETE CASCADE")

	db:Query([[CREATE TABLE `rp_worldents` (
		`id` INT NOT NULL AUTO_INCREMENT,
		`Class` VARCHAR(64) NOT NULL,
		`Map` VARCHAR(32) NOT NULL,
		`MapData` BLOB,
		`CustomData` BLOB,
		PRIMARY KEY(`id`),
		INDEX(`Map`)
	)]])

	Database.PopulateFromVars(db, "rp_players", PlayerVar.Vars)
	Database.PopulateFromVars(db, "rp_characters", CharacterVar.Vars)
end
