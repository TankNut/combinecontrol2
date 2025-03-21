AddCSLuaFile()

function SWEP:PlayAnimation(name)
	local owner = self:GetOwner()

	if not IsValid(owner) or not owner:IsPlayer() then
		return
	end

	local vm = owner:GetViewModel()
	local func = self["Get" .. name .. "Animation"]
	local animation = func and func(self) or self.Animations[name]

	local index = isnumber(animation) and vm:SelectWeightedSequence(animation) or vm:LookupSequence(animation)

	vm:SendViewModelMatchingSequence(index)

	return vm:SequenceDuration(index)
end

function SWEP:GetHolsterAnimation()
	return self:GetHolstered() and ACT_VM_HOLSTER or ACT_VM_DRAW
end
