-- The length required to go from corner to corner on a max-sized map
MAX_LENGTH = 56756

-- The length required to go from corner to corner on a max-sized map on a single axis
MAX_LENGTH_AXIS = 32768

-- Default use distance in source
MAX_USE_DISTANCE = 82

-- Yes
SHARED = true

DOOR_SF_TOGGLE = 32
DOOR_SF_USABLE = 256
DOOR_SF_TOUCHABLE = 1024
DOOR_SF_LOCKED = 2048
DOOR_SF_TOGGLE_PROP = 8192

APPLYMODEL_FIELDS = {
	Model = true,
	Skin = true,
	Bodygroups = true,
	Materials = true,
	Color = true
}

-- env_explosion spawnflags
SF_EXPLOSION_MUTE = 64
SF_EXPLOSION_NO_EFFECTS = bit.bor(4, 8, 32, 512)
SF_EXPLOSION_NO_DECALS = 16

SF_EXPLOSION_INVISIBLE = bit.bor(SF_EXPLOSION_MUTE, SF_EXPLOSION_NO_EFFECTS, SF_EXPLOSION_NO_DECALS)
