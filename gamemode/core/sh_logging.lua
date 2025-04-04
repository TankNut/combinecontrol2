module("Log", package.seeall)

Types = Types or {}
Directory = DataFolder .. "logs/"

function AddType(name, callback)
	Types[name] = callback
end

function WriteToFile(message, logFiles)
	local dir = Directory .. os.date("!%Y-%m-%d") .. "/"
	local log = string.format("[%s] %s\n", os.date("!%H:%M:%S"), message)

	for _, logFile in pairs(logFiles) do
		file.AppendSafe(dir .. logFile .. ".txt", log)
	end
end
