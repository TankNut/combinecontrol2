module("log", package.seeall)

TextColor = Color(200, 200, 200)
CategoryColor = CLIENT and Color(255, 221, 102) or Color(136, 221, 255)
Levels = {
	{Name = "WARNING", Color = Color(255, 195, 3)},
	{Name = "INFO", Color = Color(0, 171, 0)},
	{Name = "DEBUG", Color = Color(0, 178, 253)}
}

ConVars = ConVars or {}
MaxLength = 0

for _, v in ipairs(Levels) do
	MaxLength = math.max(MaxLength, #v.Name + 1)
end

local LOG = {}
LOG.__index = LOG

function LOG:Warning(...) Write(self, 1, ...) end
function LOG:Info(...) Write(self, 2, ...) end
function LOG:Debug(...) Write(self, 3, ...) end

function Create(name)
	name = string.lower(name)

	local logger = setmetatable({
		ConVar = CreateConVar("log_" .. name, 1, FCVAR_ARCHIVE, "The level at which to log this specific category to console. [0 = don't log, 1 = warning, 2 = info, 3 = debug]", 0, 3),
		Name = name,
	}, LOG)

	ConVars[name] = logger.ConVar

	return logger
end

function Write(category, level, str, ...)
	if category.ConVar:GetInt() < level then
		return
	end

	str = string.format(str, ...)
	level = Levels[level]

	MsgC(TextColor, os.date("!%Y-%m-%dT%H:%M:%SZ "), level.Color, level.Name, TextColor, string.rep(" ", MaxLength - #level.Name), "[", CategoryColor, category.Name, TextColor, "] ", str, "\n")
end

concommand.Add("log_all", function(ply, _, _, level)
	if SERVER and IsValid(ply) then
		return
	end

	level = tonumber(level) or 1

	for _, convar in pairs(ConVars) do
		convar:SetInt(level)
	end
end)
