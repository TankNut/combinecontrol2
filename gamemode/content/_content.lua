GM:Include("sh_corpsefade.lua")
GM:Include("sh_player_remover.lua")
GM:Include("sh_radio.lua")
GM:Include("sh_shield.lua")
GM:Include("sh_visr.lua")

GM:IncludeFolder(ContentFolder .. "_defines/")
GM:IncludeFolder(ContentFolder .. "settings/")
GM:IncludeFolder(ContentFolder .. "commands/")
GM:IncludeFolder(ContentFolder .. "logs/")
GM:IncludeFolder(ContentFolder .. "actions/")
GM:IncludeFolder(ContentFolder .. "gui/")

GM:IncludeFolder(ContentFolder .. "patches/")

Language.Load()

hook.Call("RegisterContent", GM, ContentFolder)
