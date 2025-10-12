module("console", package.seeall)

Commands = Commands or {}
ErrorColor = Color(255, 90, 90)

ClientOnly = 1 -- Only runs on the client, implicit NoConsole
Shared = 2 -- Runs on the client for clients, on the server for console
Server = 3 -- Runs on the server for everyone (Default)
ServerConsole = 4 -- Server console only

local COMMAND = CustomMetaTable("ConsoleCommand")
local logger = log.Create("console")

function AddCommand(name, callback)
	local command = setmetatable({
		Name = name,
		Callback = callback,
		Description = "No description specified",
		Arguments = {},
		Context = Server
	}, COMMAND)

	Commands[name] = command

	return command
end

function IsVisible(command)
	if CLIENT and command.Context == ServerConsole then
		return false
	elseif SERVER and (command.Context == ClientOnly or command.NoConsole) then
		return false
	end

	return true
end

function Rebuild()
	for command, commandObject in pairs(Commands) do
		if not IsVisible(commandObject) then
			continue
		end

		concommand.Add(command, function(ply, _, _, args)
			Parse(ply, command, args)
		end, AutoComplete, table.concat(commandObject:AutoComplete(), " | "))
	end
end

hook.Add("InitPostEntity", "cc2.ConsoleRebuild", Rebuild)
hook.Add("OnReloaded", "cc2.ConsoleRebuild", Rebuild)

function ReadArg(args, last)
	local str = last and table.concat(args, " ") or table.remove(args, 1)

	return str or ""
end

function Parser(name, callback)
	console[name] = function(options, argName)
		return {
			Callback = callback,
			Name = argName and string.lower(argName),
			Type = string.lower(name),
			Options = options or {}
		}
	end
end

function PlayerName(ply)
	return IsValid(ply) and ply:Nick() or "CONSOLE"
end

function FormatMessage(str, ...)
	local args = {...}

	for k, v in ipairs(args) do
		if isentity(v) and (v:IsPlayer() or v == NULL) then
			args[k] = PlayerName(v)
		end
	end

	return string.format(str, unpack(args))
end

function PrintMessage(ply, str, ...)
	str = FormatMessage(str, ...)

	if SERVER and IsValid(ply) then
		netstream.Send(ply, "console.PrintMessage", str)

		return
	end

	print(str)
end

function PrintError(ply, str, ...)
	str = FormatMessage(str, ...)

	if SERVER and IsValid(ply) then
		netstream.Send(ply, "console.PrintError", str)

		return
	end

	MsgC(ErrorColor, "ERROR: ", str, "\n")
end

if CLIENT then
	netstream.Hook("console.PrintMessage", function(str)
		PrintMessage(lp, str)
	end)

	netstream.Hook("console.PrintError", function(str)
		PrintError(lp, str)
	end)
end

function Trim(str)
	return string.match(str, "^()%s*$") and "" or string.match(str, "^%s*(.*%S)")
end

function Split(str)
	str = string.Trim(str)

	local args = {}
	local currentPos = 1
	local inQuote = false
	local len = #str

	while inQuote or currentPos <= len do
		local pos = string.find(str, "\"", currentPos, true)
		local prefix = string.sub(str, currentPos, (pos or 0) - 1)

		if not inQuote then
			local trim = Trim(prefix)

			if trim != "" then
				table.Add(args, string.Explode("%s+", trim, true))
			end
		else
			table.insert(args, prefix)
		end

		if pos != nil then
			currentPos = pos + 1
			inQuote = not inQuote
		else
			break
		end
	end

	return args
end

function Parse(ply, name, str)
	local logName = IsValid(ply) and ply or "CONSOLE"

	logger:Info("%s: %s %s", logName, name, str)

	local command = Commands[name]

	if not command then
		logger:Warning("Rejected '%s' command from %s: No such command exists", name, logName)
		PrintError(ply, "Unrecognized command")

		return
	end

	if CLIENT and command.Context == Server then
		logger:Debug("Redirecting '%s' command to server", name)

		netstream.Send("console.Parse", name, str)

		return
	elseif SERVER and IsValid(ply) and command.Context != Server and command.Context != ServerConsole then
		logger:Debug("Redirecting '%s' command to client", name)

		netstream.Send(ply, "console.Parse", ply, name, str)

		return
	end

	local args = Split(str)

	if IsValid(ply) then
		if command.Context == ServerConsole then
			logger:Info("Rejected '%s' command from %s: Server console only", name, logName)
			-- Quietly because we don't always want to acknowledge these commands' existence

			return
		end

		local ok, msg = command.CanAccess(ply)

		if not ok then
			logger:Info("Rejected '%s' command from %s: No access", name, logName)
			PrintError(ply, msg or "You do not have access to this command")

			return
		end

		async.Start(command.Invoke, command, ply, args)
	else
		if command.NoConsole then
			logger:Info("Rejected '%s' command from CONSOLE: In-game only", name)
			PrintError(ply, "You cannot run this command from the server console")

			return
		end

		async.Start(command.Invoke, command, ply, args)
	end
end

netstream.Hook("console.Parse", Parse)

function AutoComplete(name, args)
	local command = Commands[name]

	return table.Add({name .. args}, command:AutoComplete())
end

function COMMAND:Invoke(ply, args)
	local processedArgs = {}

	logger:Debug("Parsing %s argument(s): %s", #self.Arguments, self:GetUsage())

	for k, arg in ipairs(self.Arguments) do
		if #args < 1 then
			if arg.Optional then
				logger:Debug("Optional %s argument #%s using fallback value '%s'", arg.Type, k, arg.Fallback)

				processedArgs[k] = arg.Fallback

				continue
			elseif not arg.Options.Force then -- Forces the parser to run with a nil input value
				logger:Debug("Aborting because of missing argument #%s (%s)", k, arg.Name or arg.Type)

				PrintError(ply, "Missing argument #%s (%s)", k, arg.Name or arg.Type)

				return
			end
		end

		local ok, processed = arg.Callback(ply, args, k == #self.Arguments, arg.Options)

		if not ok then
			if arg.Options.Silent then
				logger:Debug("Silently failing %s parser for argument %s with error: %s", arg.Type, k, processed)
			else
				logger:Debug("Failing %s parser for argument %s with error: %s", arg.Type, k, processed)

				PrintError(ply, "Failed to parse argument #%s: %s", k, processed or "Unknown error")
			end

			return
		end

		logger:Debug("Parsed %s argument #%s into '%s'", arg.Type, k, processed)

		processedArgs[k] = processed
	end

	logger:Debug("Processed arguments into %s function arguments", #processedArgs)

	self.Callback(ply, unpack(processedArgs))
end

function COMMAND:AutoComplete()
	return {"Description: " .. self.Description, string.format("Usage: %s %s", self.Name, self:GetUsage())}
end

function COMMAND:CanAccess(ply)
	return true
end

function COMMAND:GetUsage()
	if #self.Arguments == 0 then
		return ""
	end

	local args = {}

	for k, arg in ipairs(self.Arguments) do
		local name = arg.Name and string.format("%s|%s", arg.Name, arg.Type) or arg.Type

		if arg.Optional then
			local fallback = ""

			if arg.Fallback or arg.FallbackText then
				fallback = " = " .. (arg.FallbackText or tostring(arg.Fallback))
			end

			table.insert(args, string.format("[%s%s]", name, fallback))
		else
			table.insert(args, string.format("(%s)", name))
		end
	end

	return table.concat(args, " ")
end

function COMMAND:AddParameter(arg)
	table.insert(self.Arguments, arg)
end

function COMMAND:AddOptional(arg, fallback, fallbackText)
	arg.Optional = true
	arg.Fallback = fallback
	arg.FallbackText = fallbackText

	table.insert(self.Arguments, arg)
end

function COMMAND:SetAccess(callback)
	self.CanAccess = callback
end

function COMMAND:SetDescription(new)
	self.Description = new
end

function COMMAND:SetExecutionContext(context)
	self.Context = context
end

function COMMAND:SetNoConsole()
	self.NoConsole = true
end

local color = Color(200, 200, 200)

local listCommand = AddCommand("commands", function(ply)
	MsgC(color_white, "Available commands:\n")

	local maxWidth = 0
	local commands = {}

	for name, command in SortedPairs(Commands) do
		if not IsVisible(command) then
			continue
		end

		maxWidth = math.max(maxWidth, #name + 1)

		table.insert(commands, {name, command.Description})
	end

	for _, command in ipairs(commands) do
		local name = command[1]

		MsgC(color_white, name, string.rep(" ", maxWidth - #name), "- ", color, command[2], "\n")
	end
end)

listCommand:SetDescription("Lists out all available console commands")
listCommand:SetExecutionContext(Shared)
