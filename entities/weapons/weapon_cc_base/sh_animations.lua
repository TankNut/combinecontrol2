AddCSLuaFile()

function SWEP:GetAnimation(name)
	if not self:GetOwner():IsPlayer() then
		return
	end

	local vm = self:GetViewModel()
	local func = self["Get" .. name .. "Animation"]
	local animation = func and func(self) or self.Animations[name]

	if not animation then
		return
	end

	local index

	if istable(animation) then
		animation = table.Random(animation)
	end

	if isnumber(animation) then
		index = vm:SelectWeightedSequence(animation)
	else
		index = vm:LookupSequence(animation)
	end

	return index
end

function SWEP:PlayAnimation(name, rate)
	local index = self:GetAnimation(name)

	if not index then
		return
	end

	rate = rate or 1

	local vm = self:GetViewModel()
	local duration = vm:SequenceDuration(index) / rate

	vm:SendViewModelMatchingSequence(index)
	vm:SetPlaybackRate(rate)

	self:SetNextIdle(CurTime() + duration)

	return duration
end

function SWEP:PlayerAnimation(index)
	self:GetOwner():SetAnimation(index)
end
