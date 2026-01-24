-- How much damage is left over per 1000 source units, caps out at 20% of the original damage
DMG_FALLOFF_SHOTGUN = 0.8
DMG_FALLOFF_SMG     = 0.9
DMG_FALLOFF_RIFLE   = 0.94
DMG_FALLOFF_SNIPER  = 0.98
DMG_FALLOFF_NONE    = 1

-- See this as the mechanical accuracy of a weapon, it's combined with SWEP.Settings.Range to get the final spread values
-- Values are for hip and aimed shots respectively
ACCURACY_POOR    = {16, 5}
ACCURACY_AVERAGE = {14, 4}
ACCURACY_GOOD    = {12, 3}
ACCURACY_GREAT   = {10, 2}
ACCURACY_PERFECT = {8, 1}

-- The distance at which a weapon hits the accuracy values listed above, set per-class
RANGE_SHOTGUN  = 1000

RANGE_SMG      = {400, 1500}
RANGE_PISTOL   = {600, 2400}

RANGE_RIFLE    = {600, 2400}
RANGE_SNIPER   = {300, 7200}

RANGE_LAUNCHER = {1000, 4000}

--[[
	Accuracy = {a, b} -- Normal and scoped accuracy, set on a quality basis
	Range = {a, b} -- Normal and aimed range, set on a weapon class basis
]]
