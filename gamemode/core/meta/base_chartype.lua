local CLASS = CharCreate.Class

CLASS.SortOrder = 0

-- All fields use the character var 'name', e.g. CharacterModel which will be translated by ply:CreateCharacter into db fields
CLASS.Fields = {} -- Pre-set fields that will be used as a baseline
CLASS.Pages = {} -- The GUI layout, contains tables for pages which contain options
CLASS.Options = {} -- The actual options used to build the GUI
CLASS.Validate = {} -- Validation rules for options

local PLAYER = FindMetaTable("Player")

function CLASS:GetName()
	return self.Name or self.ID
end

if CLIENT then
	function CLASS:GetAppearance(options, key)
		return {
			_base = {
				Model = Model("models/player/skeleton.mdl")
			}
		}
	end
else
	function CLASS:GiveItem(ply, ...)
		local func = ply:IsTemporaryCharacter() and PLAYER.GiveTempItem or PLAYER.GiveItem

		func(ply, ...)
	end

	function CLASS:PreCreateCharacter(ply, fields, options)
	end

	function CLASS:PostCreateCharacter(ply, options)
	end
end
