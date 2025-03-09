INV_WORLD     = 0
INV_PLAYER    = 1
INV_STASH     = 2
INV_ITEM      = 3
INV_CONTAINER = 4

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

CONTEXT_TOP = 0 -- Unused
CONTEXT_ENTITY = 10 -- Interacting with other players/entities
CONTEXT_IMPORTANT = 20 -- Important stuff like patching up armor
CONTEXT_EQUIPMENT = 30 -- Equipped item actions
CONTEXT_INVENTORY = 40 -- Inventory item actions
CONTEXT_SELF = 50 -- Self actions e.g. gestures, animations
CONTEXT_MISC = 60 -- Default
CONTEXT_ADMIN = 70 -- Admin-only stuff

PROP_CLASSES = table.Lookup({
	"prop_physics", "prop_effect"
})

WEAPONS_TOOLS = table.Lookup({
	"weapon_physgun",
	"gmod_tool"
})
