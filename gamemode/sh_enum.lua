IRON_HOLSTERED 		= 0
IRON_HOLSTERED2IDLE = 1
IRON_IDLE 			= 2
IRON_IDLE2AIM 		= 3
IRON_AIM 			= 4

RELOADTYPE_NONE		= 0
RELOADTYPE_NORMAL	= 1
RELOADTYPE_SHOTGUN	= 2

SONG_IDLE 		= 0
SONG_ALERT 		= 1
SONG_ACTION 	= 2
SONG_STINGER 	= 3

DOOR_UNBUYABLE			= 0
DOOR_BUYABLE 			= 1
DOOR_COMBINEOPEN 		= 2
DOOR_COMBINELOCK 		= 3
DOOR_BUYABLE_ASSIGNABLE = 4

NEWBIE_STATUS_NEW = 0
NEWBIE_STATUS_OLD = 1

TRAIT_NONE 		= 2^0

--teams need reorganising for tekka
TEAM_CITIZEN		= 1
TEAM_SKYNET			= 2
TEAM_REPROG 		= 3
TEAM_GREY 			= 4
TEAM_AOF 			= 5

MICROPHONE_BIG 		= 50
MICROPHONE_SMALL 	= 56

LOCATION_CITY = 1
LOCATION_CANAL = 2
LOCATION_OUTLANDS = 3
LOCATION_COAST = 4
LOCATION_NEXUS = 5

EQUIPMENT_TO_TEXT = {}

local function AddEquipment(index, enum, name)
	_G["EQUIPMENT_" .. enum] = index
	EQUIPMENT_TO_TEXT[index] = name
end

AddEquipment(1, "HEAD", "Headgear")
AddEquipment(2, "EYES", "Eyewear")
AddEquipment(3, "MASK", "Mask")
AddEquipment(4, "BODY", "Clothing")
AddEquipment(5, "EXO", "Exosuit")
AddEquipment(6, "BACK", "Backpack")
AddEquipment(7, "ARM_L", "Left Armband")
AddEquipment(8, "ARM_R", "Right Armband")
AddEquipment(9, "PRIMARY", "Primary Weapon")
AddEquipment(10, "SECONDARY", "Secondary Weapon")
AddEquipment(11, "MELEE", "Melee Weapon")
AddEquipment(12, "GRENADE", "Grenade")
AddEquipment(13, "EQUIP1", "Main Equipment")
AddEquipment(14, "EQUIP2", "Backup Equipment")
AddEquipment(15, "RADIO", "Radio")
AddEquipment(16, "LIGHT", "Light")
AddEquipment(17, "ARMOR", "Armor")

SPEC_NONE 			= 0
SPEC_PENETRATE 		= 1 -- Allows the hitscan projectile to penetrate certain materials
SPEC_TRANQ 			= 2 -- Applies the damage as 'consiousness' damage
SPEC_BURN 			= 3 -- Sets entities on fire
SPEC_DOORBREACH		= 4 -- Allows the weapon to breach doors
SPEC_CUSTOM 		= 5 -- Calls a custom function on firing

MAT_MULTIPLIERS 	= { -- Material based multipliers for weapon penetration
	[MAT_FOLIAGE]		= 5,
	[MAT_SLOSH]			= 3,
	[MAT_ALIENFLESH]	= 2,
	[MAT_ANTLION]		= 2,
	[MAT_BLOODYFLESH]	= 2,
	[MAT_FLESH]			= 2,
	[45]				= 2,	-- Metrocop heads don't have enumerations
	[MAT_DIRT]			= 2,
	[MAT_GRASS]			= 2,
	[MAT_WOOD]			= 1.5,
	[MAT_SAND]			= 1.3,
	[MAT_GLASS]			= 1.2,
	[MAT_CLIP]			= 1,
	[MAT_COMPUTER]		= 1,
	[MAT_PLASTIC]		= 1,
	[MAT_TILE]			= 1,
	[MAT_CONCRETE]		= 1,
	[MAT_GRATE]			= 0.8,
	[MAT_VENT]			= 0.8,
	[MAT_METAL]			= 0.3
}

LOG_NONE 		= 0
LOG_SECURITY 	= 1
LOG_SANDBOX 	= 2
LOG_ITEMS 		= 3
LOG_CHARACTER 	= 4
LOG_CHAT 		= 5
LOG_ADMIN 		= 6
LOG_DEVELOPER 	= 7

META_CHAR 	= 1
META_ITEM 	= 2
META_PLY 	= 3

THROW_NORMAL 	= 1
THROW_ROLL 		= 2
THROW_LOB 		= 3

OVERLAY_NONE 		= 0
OVERLAY_NVG 		= 1
OVERLAY_TARGET 		= 2
OVERLAY_THERMAL 	= 3
