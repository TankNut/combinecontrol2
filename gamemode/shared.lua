-- 08/11/2024: First combinecontrol-tnb commit
-- 21/03/2025: Last remaining CC code stripped out
AddCSLuaFile()
DeriveGamemode("sandbox")

GM.Name = "CombineControl: TnB"
GM.Author = "Taco N Banana"
GM.Website = "http://taconbanana.com"
GM.Email = "gangleider@taconbanana.com"

function GM:GetGameDescription()
	return self.Name
end

local function client(path) if CLIENT then return include(path) else AddCSLuaFile(path) end end
local function server(path) if SERVER then return include(path) end end
local function shared(path) AddCSLuaFile(path) return include(path) end

GM.Config = {}

shared("core/enums.lua")
shared("core/sh_config.lua")

shared("config/sh_config.lua")
server("config/sv_config.lua")
client("config/cl_motd.lua")

client("cl_skin.lua")

shared("core/_core.lua")
