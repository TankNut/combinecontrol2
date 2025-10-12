-- Database stuff
local createMigration = console.AddCommand("dev_database_migration", function(ply, str)
	local name = os.time() .. "_" .. str .. ".lua"

	console.PrintMessage(ply, name)

	if CLIENT then
		SetClipboardText(name)
	end
end)

createMigration:SetDescription("Gives you a path for a database migration file")
createMigration:SetExecutionContext(console.Shared)
createMigration:AddParameter(console.String({}, "name"))
