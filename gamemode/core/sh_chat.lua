module("Chat", package.seeall)

List = List or {}
Commands = Commands or {}
Aliases = Aliases or {}

ConsoleCommands = ConsoleCommands or {}

Class = Class or {}
Class.__index = Class

local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

PlayerVar.Add("Typing", {})

function Register(data)
	data = inherit.Register("chat", data.Name, data, data.Base or "base")

	List[data.Name] = data

	if data.Commands then
		for _, name in ipairs(data.Commands) do
			Commands[name] = data
		end
	end

	if data.Aliases then
		for _, alias in ipairs(data.Aliases) do
			Aliases[alias] = data.Commands[1]
		end
	end
end

function RegisterFolder(dir)
	file.Iterate(dir, "shared.lua", "LUA", function(path, folder)
		_G.CLASS = {}

		GM:IncludeShared(path)

		Register(CLASS)

		CLASS = nil
	end)
end

function AddConsoleCommand(names, command)
	if not istable(names) then
		names = {names}
	end

	for _, name in ipairs(names) do
		ConsoleCommands[name] = command
	end
end

function Process(ply, str)
	for alias, command in pairs(Aliases) do
		if string.Left(str, #alias) == alias then
			str = string.format("/%s %s", command, string.sub(str, #alias + 1))

			break
		end
	end

	local lang, command, args = string.match(str, "^[/!](%w+)%.(%w+)%s*(.-)%s*$")

	if not Language.Lookup[lang] then
		lang = ply:ActiveLanguage()
		command, args = string.match(str, "^[/!](%w+)%s*(.-)%s*$")

		if not command then
			command, args = "say", string.Trim(str)
		end
	else
		lang = string.lower(lang)
	end

	return lang, string.lower(command), args
end

function GetTargets(pos, range, muffledRange, withEntities)
	local maxRange = math.max(range, muffledRange)
	local targets = {}

	for _, ent in pairs(ents.FindInSphere(pos, maxRange)) do
		if not ent:IsPlayer() and (not withEntities or not ent.OnHear) then
			continue
		end

		local dist = ent:GetPos():DistToSqr(pos)

		if ent:CanHear(pos) then
			if dist < maxRange * maxRange then
				table.insert(targets, ent)
			end
		elseif dist <= muffledRange then
			table.insert(targets, ent)
		end
	end
end

function Parse(ply, str)
	local lang, cmd, args = Process(ply, str)

	if CLIENT then
		if ConsoleCommands[cmd] then
			console.Parse(lp, ConsoleCommands[cmd], args)
		else
			netstream.Send("ParseChat", str)
		end
	else
		local command = Commands[cmd]

		if not command then
			ply:SendChat("ERROR", string.format("Unknown command: '%s'", cmd))

			return
		end

		command:Handle(ply, lang, cmd, args)
	end
end

if CLIENT then
	function Create()
		local panel = GUI.Get("Chat")

		if IsValid(panel) then
			local buffer = panel:ExportBuffer()

			GUI.Open("Chat"):ImportBuffer(buffer)
		else
			GUI.Open("Chat")
		end
	end

	function Bind(bind, down)
		if down and string.find(bind, "messagemode") then
			Show()

			return true
		end
	end

	function Show()
		GUI.Get("Chat"):Show()
	end

	function Hide()
		GUI.Get("Chat"):Hide()

		if lp:Typing() != nil then
			lp:SetTyping(nil)

			netstream.Send("Typing", nil)
		end
	end

	function Receive(name, data)
		if isstring(data) then
			data = {Text = data}
		end

		local command = List[name]
		local message, consoleMessage = command:OnReceive(data)

		if isstring(message) then
			GUI.Get("Chat"):AddMessage(message, consoleMessage, command.Tabs)
		end
	end

	netstream.Hook("SendChat", function(payload)
		Receive(payload.__Type, payload)
	end)
else
	netstream.Hook("ParseChat", Parse)

	netstream.Hook("Typing", function(ply, cmd)
		if cmd and Commands[cmd] then
			ply:SetTyping(cmd)
		else
			ply:SetTyping(nil)
		end
	end)

	function Send(name, data, targets)
		if isstring(data) then
			data = {Text = data}
		end

		data.__Type = name

		netstream.Send(targets, "SendChat", data)
	end

	function GM:PlayerSay(ply, text, t)
		Parse(ply, text)

		return ""
	end
end

function ENTITY:CanHear(pos)
	return util.TraceLine({
		start = self:IsPlayer() and self:EyePos() or self:WorldSpaceCenter(),
		endpos = pos,
		filter = self,
		mask = MASK_SOLID_BRUSHONLY
	}).Fraction == 1
end

function PLAYER:SendChat(name, data)
	if CLIENT then
		assert(self == lp, "Attempt to SendChat to a non-local player")

		Receive(name, data)
	else
		Send(name, data, self)
	end
end

function PLAYER:GetTypingString()
	return Commands[self:Typing()].Typing
end
