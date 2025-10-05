-- 08/11/2024: First cc2-core commit
-- 21/03/2025: Last remaining CC code stripped out
AddCSLuaFile()
DeriveGamemode("sandbox")

GM.Name = "CombineControl 2"
GM.Author = "Taco N Banana"
GM.Website = "http://taconbanana.com"
GM.Email = "gangleider@taconbanana.com"

gameevent.Listen("player_disconnect")
gameevent.Listen("player_changename")

function client(path) if CLIENT then return include(path) else AddCSLuaFile(path) end end
function server(path) if SERVER then return include(path) end end
function shared(path) AddCSLuaFile(path) return include(path) end

hook.Remove("PlayerTick", "TickWidgets")
hook.Remove("PostDrawEffects", "RenderWidgets")

GM.Config = {}

shared("utils/_utils.lua")

shared("core/enums.lua")
shared("core/sh_config.lua")

shared("config/sh_config.lua")
server("config/sv_config.lua")
client("config/cl_motd.lua")

client("cl_skin.lua")

shared("core/_core.lua")
