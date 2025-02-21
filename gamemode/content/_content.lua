GM:Include("sh_corpsefade.lua")
GM:Include("sh_money.lua")
GM:Include("sh_player_remover.lua")

GM:LoadFolder(ContentFolder .. "_defines/")
GM:LoadFolder(ContentFolder .. "settings/")

GM:LoadFolder(ContentFolder .. "commands/")

Badge.Load()
Language.Load()

CharacterCreate.RegisterFolder(ContentFolder .. "chartypes/")
CharacterFlag.RegisterFolder(ContentFolder .. "flags/")
CharacterGen.RegisterFolder(ContentFolder .. "chargens/")
Chat.RegisterFolder(ContentFolder .. "chat/")
Item.RegisterFolder(ContentFolder .. "items/")
Hud.RegisterFolder(ContentFolder .. "hud/")
buff.RegisterFolder(ContentFolder .. "buffs/")
