GM:Include("sh_corpsefade.lua")
GM:Include("sh_money.lua")
GM:Include("sh_player_remover.lua")

GM:LoadFolder(ContentFolder .. "defines/")

-- Load order determines category order (for now)
GM:Include("settings/settings_general.lua")
GM:Include("settings/settings_hud.lua")
GM:Include("settings/settings_admin.lua")

GM:LoadFolder(ContentFolder .. "commands/")

Badge.Load()
Language.Load()

CharacterFlag.RegisterFolder(ContentFolder .. "flags/")
CharCreate.RegisterFolder(ContentFolder .. "charcreate/")
Chat.RegisterFolder(ContentFolder .. "chat/")
Item.RegisterFolder(ContentFolder .. "items/")
Hud.RegisterFolder(ContentFolder .. "hud/")
buff.RegisterFolder(ContentFolder .. "buffs/")
