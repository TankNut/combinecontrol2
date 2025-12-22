local PLAYER = FindMetaTable("Player")

-- This might change later but for now I'm just stuffing all the generic 'recalculate this' functions into one file to ease my suffering

function PLAYER:UpdateArmor()
	local armor = self:RunCharFlag("Armor")

	for _, item in pairs(self:GetItems()) do
		armor = armor + item:GetArmor()
	end

	-- Internally rescales current armor because of the armor plugin
	self:SetMaxArmor(armor)
end

function PLAYER:UpdateVisibleName()
	local name

	if #self:CharacterNameOverride() > 0 then
		name = self:CharacterNameOverride()
	end

	self:SetVisibleRPName(name or self:RunCharFlag("VisibleRPName"))
end

function PLAYER:UpdateVisibleDescription()
	local description = self:RunCharFlag("VisibleDescription")

	self:SetVisibleDescription(description)

	local short = string.match(description, "^[^\r\n]*")
	local config = Config.Get("ShortDescLength")

	if #short > 0 and #short > config then
		short = string.Trim(string.sub(short, 1, config - 3)) .. "..."
	end

	self:SetShortDescription(short)
	self.ExamineCache = nil
end

function PLAYER:UpdateMovementSpeed()
	local slow, walk, run, jump, crouch = self:RunCharFlag("GetSpeeds")

	self:SetSlowWalkSpeed(slow)
	self:SetWalkSpeed(walk)
	self:SetRunSpeed(run)
	self:SetJumpPower(jump)
	self:SetCrouchedWalkSpeed(crouch / walk)
end

function PLAYER:UpdateMaxWeight()
	self:SetMaxInventoryWeight(30)
end

function PLAYER:UpdateClassification(force)
	Npc.ApplyClassification(self, hook.Run("GetPlayerClassification", self), force)
end
