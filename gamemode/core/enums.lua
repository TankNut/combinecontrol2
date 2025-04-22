INV_WORLD     = 0
INV_PLAYER    = 1
INV_STASH     = 2
INV_ITEM      = 3
INV_ENTITY    = 4

RARITY_COMMON    = 1
RARITY_UNCOMMON  = 2
RARITY_RARE      = 3
RARITY_EPIC      = 4
RARITY_LEGENDARY = 5
RARITY_ARTIFACT  = 6
RARITY_DEVELOPER = 7

TAB_LOOC  = 2^1
TAB_OOC   = 2^2
TAB_IC    = 2^3
TAB_ADMIN = 2^4
TAB_PM    = 2^5
TAB_RADIO = 2^6

TOOLTRUST_BANNED    = 0 -- Scoreboard badge
TOOLTRUST_UNTRUSTED = 1
TOOLTRUST_TRUSTED   = 2
TOOLTRUST_ADVANCED  = 3 -- Scoreboard badge
TOOLTRUST_ADMIN     = 4 -- Auto-assigned to admins
TOOLTRUST_DEVELOPER = 5 -- Blanket access

SLOT_BASIC   = 1
SLOT_WEAPONS = 2
SLOT_MISC    = 3

CONTEXT_TOP       = 0 -- Unused
CONTEXT_ENTITY    = 10 -- Interacting with other players/entities
CONTEXT_IMPORTANT = 20 -- Important stuff like patching up armor
CONTEXT_EQUIPMENT = 30 -- Equipped item actions
CONTEXT_INVENTORY = 40 -- Inventory item actions
CONTEXT_SELF      = 50 -- Self actions e.g. gestures, animations
CONTEXT_MISC      = 60 -- Default
CONTEXT_ADMIN     = 70 -- Admin-only stuff

ITEM_ACTION_EXAMINE   = 100
ITEM_ACTION_EQUIP     = 90
ITEM_ACTION_OPEN      = 80
ITEM_ACTION_CUSTOMIZE = 70
ITEM_ACTION_DROP      = 2
ITEM_ACTION_DESTROY   = 1

PROP_CLASSES = table.Lookup({
	"prop_physics",
	"prop_effect"
})

WEAPONS_TOOLS = table.Lookup({
	"weapon_physgun",
	"gmod_tool"
})

ACTION_ADMIN    = 1
ACTION_EDITMODE = 2

ACTION_SELF     = 1
ACTION_LOOK     = 2
ACTION_INTERACT = 3

KEYMODE_HOLD   = 1
KEYMODE_TOGGLE = 2
KEYMODE_SMART  = 3

SCOREBOARD_SHOW   = 0 -- Normal display on the scoreboard
SCOREBOARD_HIDDEN = 1 -- Red background on the scoreboard
SCOREBOARD_SKIP   = 2 -- Skip display on the scoreboard

CLOTHING_NONE    = 0 -- We don't support any type of clothing e.g. antlions and zombies
CLOTHING_PARTIAL = 1 -- We support _some_ clothing, weapons/exos for combine soldiers
CLOTHING_FULL    = 2 -- The whole nine yards

FIREMODE_AUTO  = -1
FIREMODE_SEMI  = 0
FIREMODE_SAFE  = 1
FIREMODE_BURST = 3

CLASSIFY_NEUTRAL  = "neutral"
CLASSIFY_ARMED    = "armed"
CLASSIFY_LONEWOLF = "lonewolf"
CLASSIFY_COMBINE  = "combine"
CLASSIFY_ZOMBIE   = "zombie"
CLASSIFY_ANTLION  = "antlion"

CHAT_FONT_DEFAULT    = 1
CHAT_FONT_LEGACY     = 2
CHAT_FONT_TACOSCRIPT = 3

DOOR_SEPARATE = 1 -- Each door can be separately configured
DOOR_MASTER   = 2 -- Only the master door gets configured
DOOR_BOTH     = 3 -- Both doors get configured together

GLOBALVAR_ALWAYS          = 1 -- Always load
GLOBALVAR_MAP             = 2 -- Load based on game.GetMapOverride()
GLOBALVAR_MAP_NO_OVERRIDE = 3 -- Load based on game.GetMap()

AMBIENCE_PREVIEW = 0
AMBIENCE_GLOBAL  = 1
AMBIENCE_LOCAL   = 2

SONG_IDLE    = 0
SONG_ALERT   = 1
SONG_ACTION  = 2
SONG_STINGER = 3

LISTENER_ADMIN  = 1
LISTENER_ENTITY = 2

SPAWN_FALLBACK = 0
SPAWN_TEAM     = 1
SPAWN_GROUP    = 2
SPAWN_OVERRIDE = 3

CONTAINER_PUBLIC = 0
CONTAINER_KEY    = 1
CONTAINER_ADMIN  = 2

KEY_BOTH      = 0
KEY_DOOR      = 1
KEY_CONTAINER = 2

VOICELINE_DELAY = 2
