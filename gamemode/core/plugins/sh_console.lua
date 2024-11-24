function console.PrintMessage(ply, str, ...)
	str = console.FormatMessage(str, ...)

	if not IsValid(ply) then
		print(str)

		return
	end

	if CLIENT then
		-- Maybe we should add a backport of eternity/afterglow chat to the list, this is horrid
		local message = table.Merge(table.Copy(GAMEMODE.MessageTypes.WARNING), {
			Class = GAMEMODE.MessageTypes.WARNING,
			Text = str,
		})

		message.Name = nil

		if hook.Run("OnChatReceived", message) then
			return
		end

		GAMEMODE:AddChatMessage(message)
	else
		ply:SendChat(nil, "WARNING", str)
	end
end

function console.PrintError(ply, str, ...)
	str = console.FormatMessage(str, ...)

	if not IsValid(ply) then
		MsgC(console.ErrorColor, "ERROR: ", str, "\n")

		return
	end

	if CLIENT then
		local message = table.Merge(table.Copy(GAMEMODE.MessageTypes.ERROR), {
			Class = GAMEMODE.MessageTypes.ERROR,
			Text = str,
		})

		if hook.Run("OnChatReceived", message) then
			return
		end

		GAMEMODE:AddChatMessage(message)
	else
		ply:SendChat(nil, "ERROR", str)
	end
end

hook.Add("LoadContent", "console", function()
	local path = string.format("%s/gamemode/content/commands/", engine.ActiveGamemode())
	local files = file.Find(path .. "*.lua", "LUA")

	for _, v in ipairs(files) do
		GM:Include(path .. v)
	end
end)
