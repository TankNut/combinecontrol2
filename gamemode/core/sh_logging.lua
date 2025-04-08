module("Log", package.seeall)

Types = Types or {}

function AddType(name, callback)
	Types[name] = callback
end

function GetFilePath()
	return string.format("%slogs/%s.txt", DataFolder, os.date("!%Y-%m-%d"))
end

function CreateNewHandle()
	if Handle then
		Handle.File:Close()
		timer.Remove("cc2.chatlogs")
	end

	local path = GetFilePath()
	local fileHandle = file.OpenSafe(path, "wb")

	Handle = {
		Path = path,
		File = fileHandle
	}

	timer.Create("cc2.chatlogs", 10, 0, function()
		fileHandle:Flush()
	end)

	return Handle.File
end

function GetHandle()
	if Handle then
		-- Check for date rollover
		if Handle.Path != GetFilePath() then
			return CreateNewHandle()
		end

		return Handle.File
	end

	return CreateNewHandle()
end

function WriteToFile(log)
	GetHandle():Write(log)
end

function WriteChatLog(log)
	WriteToFile(string.format("[%s] %s\n", os.date("!%X"), log))
end

function WriteHint(log)
	WriteToFile(string.format("-- [%s] --\n", string.upper(log)))
end

if CLIENT then
	netstream.Hook("WriteHint", function(log)
		WriteHint(log)
	end)
end
