GM:Include("sh_corpsefade.lua")
GM:Include("sh_money.lua")
GM:Include("sh_player_remover.lua")

GM:LoadFolder(ContentFolder .. "_defines/")

-- Load order determines category order (for now)
GM:Include("settings/settings_general.lua")
GM:Include("settings/settings_hud.lua")
GM:Include("settings/settings_admin.lua")

GM:LoadFolder(ContentFolder .. "commands/")

Badge.Load()
Language.Load()

CharacterCreate.RegisterFolder(ContentFolder .. "chartypes/")
CharacterFlag.RegisterFolder(ContentFolder .. "flags/")
Chat.RegisterFolder(ContentFolder .. "chat/")
Item.RegisterFolder(ContentFolder .. "items/")
Hud.RegisterFolder(ContentFolder .. "hud/")
buff.RegisterFolder(ContentFolder .. "buffs/")
