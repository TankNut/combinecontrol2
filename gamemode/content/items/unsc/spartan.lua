local BaseClass = inherit.Get("item", "base")

ITEM.Name           = "MJOLNIR Powered Assault Armor"

ITEM.Rarity         = RARITY_LEGENDARY
ITEM.Category       = "Spartan"

ITEM.Model       	= Model("models/rena_haloreach/crate_packing.mdl")

ITEM.IconAngle   	= Angle(30, 27, 0)
ITEM.IconFOV     	= 35

ITEM.Weight         = 12

ITEM.EquipmentSlots = {"spartan"}

ITEM.Buffs          = {"halo_shield"}

ITEM.Actions = {}

local colorOptions = {
	{Name = "Steel", Value = Color(74, 74, 74)},
	{Name = "Silver", Value = Color(136, 136, 136)},
	{Name = "White", Value = Color(207, 207, 207)},

	{Name = "Brown", Value = Color(90, 63, 45)},
	{Name = "Tan", Value = Color(138, 101, 79)},
	{Name = "Khaki", Value = Color(192, 150, 127)},

	{Name = "Sage", Value = Color(91, 100, 63)},
	{Name = "Olive", Value = Color(130, 146, 85)},
	{Name = "Drab", Value = Color(166, 188, 118)},

	{Name = "Forest", Value = Color(31, 96, 43)},
	{Name = "Green", Value = Color(62, 153, 87)},
	{Name = "Sea Foam", Value = Color(113, 192, 122)},

	{Name = "Teal", Value = Color(24, 112, 109)},
	{Name = "Aqua", Value = Color(48, 159, 157)},
	{Name = "Cyan", Value = Color(102, 211, 207)},

	{Name = "Blue", Value = Color(36, 68, 105)},
	{Name = "Cobalt", Value = Color(74, 103, 145)},
	{Name = "Ice", Value = Color(119, 157, 208)},

	{Name = "Violet", Value = Color(67, 66, 117)},
	{Name = "Orchid", Value = Color(100, 97, 165)},
	{Name = "Lavender", Value = Color(146, 143, 213)},

	{Name = "Maroon", Value = Color(138, 39, 38)},
	{Name = "Brick", Value = Color(198, 43, 43)},
	{Name = "Rose", Value = Color(225, 124, 124)},

	{Name = "Rust", Value = Color(152, 56, 19)},
	{Name = "Coral", Value = Color(217, 94, 37)},
	{Name = "Peach", Value = Color(215, 145, 106)},

	{Name = "Gold", Value = Color(141, 95, 19)},
	{Name = "Yellow", Value = Color(190, 161, 45)},
	{Name = "Pale", Value = Color(209, 203, 87)}
}

local modelOptions = {
	{Name = "Mark V [B]", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_vb.mdl")},
	{Name = "CQC", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_cqc.mdl")},
	{Name = "ODST", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_odst.mdl")},
	{Name = "HAZOP", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_hazop.mdl")},
	{Name = "EOD", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_eod.mdl")},
	{Name = "Operator", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_operator.mdl")},
	{Name = "Grenadier", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_jorge.mdl")},
	{Name = "Air Assault", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_kat.mdl")},
	{Name = "Scout", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_scout.mdl")},
	{Name = "EVA", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_eva.mdl")},
	{Name = "JFO", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_jfo.mdl")},
	{Name = "Commando", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_carter.mdl")},
	{Name = "Mark V", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_v.mdl")},
	{Name = "Pilot", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_pilot.mdl")},
	{Name = "Recon", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_recon.mdl")},
	{Name = "Mark VI", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_vi.mdl")},
	{Name = "GUNGNIR", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_gungnir.mdl")},
	{Name = "Security", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_security.mdl")},
	{Name = "Military Police", Value = Model("models/models/valk/haloreach/unsc/spartan/spartan_mp.mdl")}
}

local attachmentOptions = {
	{Name = "Default", Value = 0},
	{Name = "Variant #1", Value = 1},
	{Name = "Variant #2", Value = 2}
}

local visorOptions = {
	{Name = "Default", Value = 0},
	{Name = "Silver", Value = 1},
	{Name = "Blue", Value = 2},
	{Name = "Black", Value = 3},
	{Name = "Gold", Value = 4}
}

local shoulderOptions = {
	{Name = "Default", Value = 0},
	{Name = "FJ/PARA", Value = 1},
	{Name = "HAZOP/PARA", Value = 2},
	{Name = "JFO", Value = 3},
	{Name = "Recon", Value = 4},
	{Name = "UA/Multi-Threat", Value = 5},
	{Name = "Jump Jet", Value = 6},
	{Name = "EVA", Value = 7},
	{Name = "ODST", Value = 8},
	{Name = "CQC", Value = 9},
	{Name = "Operator", Value = 10},
	{Name = "Commando", Value = 11},
	{Name = "Grenadier", Value = 12},
	{Name = "Sniper", Value = 13},
	{Name = "MJOLNIR Mk. V", Value = 14},
	{Name = "Security", Value = 15}
}

local chestOptions = {
	{Name = "Default", Value = 0},
	{Name = "HP/HALO", Value = 1},
	{Name = "UA/Counterassault", Value = 2},
	{Name = "Tactical/LRP", Value = 3},
	{Name = "UA/ODST", Value = 4},
	{Name = "Tactical/Recon", Value = 5},
	{Name = "Collar/Grenadier", Value = 6},
	{Name = "Tactical/Patrol", Value = 7},
	{Name = "Collar/Breacher", Value = 8},
	{Name = "Assault/Sapper", Value = 9},
	{Name = "Assault/Commando", Value = 10},
	{Name = "HP/Parafoil", Value = 11},
	{Name = "Collar/Grenadier [UA]", Value = 12},
	{Name = "UA/Multi-Threat", Value = 13},
	{Name = "UA/Base Security", Value = 14}
}

local wristOptions = {
	{Name = "Default", Value = 0},
	{Name = "UA/Buckler", Value = 1},
	{Name = "UA/Bracer", Value = 2},
	{Name = "Tactical/TACPAD", Value = 3},
	{Name = "Tactical/UGPS", Value = 4},
	{Name = "Assault/Breacher", Value = 5}
}

local utilityOptions = {
	{Name = "Default", Value = 0},
	{Name = "UA/CHOBHAM", Value = 1},
	{Name = "Tactical/Hard Case", Value = 2},
	{Name = "UA/NxRA", Value = 3},
	{Name = "Tactical/Trauma Kit", Value = 4},
	{Name = "Tactical/Soft Case", Value = 5}
}

local kneeOptions = {
	{Name = "Default", Value = 0},
	{Name = "FJ/PARA", Value = 1},
	{Name = "GUNGNIR", Value = 2},
	{Name = "Grenadier", Value = 3}
}

ITEM.Actions.Randomize = {
	Name = "Customize\tRandomize",
	Priority = ITEM_ACTION_CUSTOMIZE - 11,

	Context = table.Lookup({"RightClick", "Examine"}),

	CanRun = function(self, ply)
		return self:IsEquipped() and hook.Run("CanInteractWithItem", ply, self)
	end,
	Callback = function(self, ply)
		self:Randomize()
		ply:UpdateAppearance()
	end
}

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 1, "Set Armor Color", "ArmorColor", colorOptions)
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 2, "Set Helmet", "PlayerModel", modelOptions)
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 3, "Set Helmet Attachments", "Attachment", attachmentOptions)
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 4, "Set Visor", "Visor", visorOptions)
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 5, "Set Left Shoulder", "LeftShoulder", shoulderOptions)
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 6, "Set Right Shoulder", "RightShoulder", shoulderOptions)
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 7, "Set Chest", "Chest", chestOptions)
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 8, "Set Wrist", "Wrist", wristOptions)
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 9, "Set Utility", "Utility", utilityOptions)
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 10, "Set Knees", "Knees", kneeOptions)

function ITEM:Randomize()
	self:SetData("ArmorColor", table.Random(colorOptions).Value)
	self:SetData("PlayerModel", table.Random(modelOptions).Value)
	self:SetData("Attachment", table.Random(attachmentOptions).Value)
	self:SetData("Visor", table.Random(visorOptions).Value)
	self:SetData("LeftShoulder", table.Random(shoulderOptions).Value)
	self:SetData("RightShoulder", table.Random(shoulderOptions).Value)
	self:SetData("Chest", table.Random(chestOptions).Value)
	self:SetData("Wrist", table.Random(wristOptions).Value)
	self:SetData("Utility", table.Random(utilityOptions).Value)
	self:SetData("Knees", table.Random(kneeOptions).Value)
end

if SERVER then
	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Model = self:GetPlayerModel(),
				Skin = self:GetVisor(),
				Color = self:GetArmorColor(),
				Bodygroups = {
					["Helmet Attachment"] = self:GetAttachment(),
					["Shoulder Left"] = self:GetLeftShoulder(),
					["Shoulder Right"] = self:GetRightShoulder(),
					Chestplate = self:GetChest(),
					Wrist = self:GetWrist(),
					Utility = self:GetUtility(),
					Knees = self:GetKnees()
				}
			}
		}
	end
end
