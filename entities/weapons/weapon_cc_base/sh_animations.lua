AddCSLuaFile()

function SWEP:GetAnimation(name)
	local owner = self:GetOwner()

	if not IsValid(owner) or not owner:IsPlayer() then
		return
	end

	local vm = owner:GetViewModel()
	local func = self["Get" .. name .. "Animation"]
	local animation = func and func(self) or self.Animations[name]

	if not animation then
		return
	end

	return isnumber(animation) and vm:SelectWeightedSequence(animation) or vm:LookupSequence(animation), vm
end

function SWEP:PlayAnimation(name)
	local index, vm = self:GetAnimation(name)

	if not index then
		return
	end

	local duration = vm:SequenceDuration(index)

	vm:SendViewModelMatchingSequence(index)

	self:SetNextIdle(CurTime() + duration)

	return duration
end

function SWEP:GetHolsterAnimation()
	if not self.Settings.UseHolsterAnimations then
		return
	end

	return self:GetHolstered() and ACT_VM_HOLSTER or ACT_VM_DRAW
end
