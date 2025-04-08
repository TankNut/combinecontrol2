module("Log", package.seeall)

Types = Types or {}
Handles = Handles or {}

function AddType(name, callback)
	Types[name] = callback
end

function GetFilePath(name)
	return string.format("%slogs/%s/%s.txt", DataFolder, os.date("!%Y-%m-%d"), name)
end

function CreateNewHandle(name)
	local handle = Handles[name]

	if handle then
		handle.File:Close()
		timer.Remove("cc2.logging." .. name)
	end

	local path = GetFilePath(name)
	local fileHandle = file.OpenSafe(path, "wb")

	Handles[name] = {
		Path = path,
		File = fileHandle
	}

	timer.Create("cc2.logging." .. name, 10, 0, function()
		fileHandle:Flush()
	end)

	return Handles[name]
end

function GetHandle(name)
	local handle = Handles[name]

	if handle then
		-- Check for date rollover
		if handle.Path != GetFilePath(name) then
			handle = CreateNewHandle(name)
		end

		return handle.File
	end

	return CreateNewHandle(name).File
end

function WriteToFile(log, files)
	for _, logFile in ipairs(files) do
		-- We already write to all down below, don't do double writes kids
		if logFile == "_all" then
			continue
		end

		GetHandle(logFile):Write(log)
	end

	GetHandle("_all"):Write(log)
end

function WriteChatLog(log, files)
	WriteToFile(string.format("[%s] %s\n", os.date("!%X"), log), files)
end

function WriteHint(log)
	WriteToFile(string.format("-- [%s] --\n", string.upper(log)), LOG_ALL_FILES)
end

if CLIENT then
	netstream.Hook("WriteHint", function(log)
		WriteHint(log)
	end)
end
