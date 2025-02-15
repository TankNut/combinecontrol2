DEFINE_BASECLASS("buff_base")

BUFF.RemoveOnDeath = true

BUFF.Duration = 5

BUFF.Interval = 1
BUFF.Damage = 2

function BUFF:Initialize(data)
	BaseClass.Initialize(self, data)

	self:AddBleedStack(data)
	print("You start bleeding!")
end

function BUFF:OnDuplicate(data)
	self:AddBleedStack(data)
end

function BUFF:AddBleedStack(data)
	self:AddStacks(1)
	self:AddTimer(nil, data.CurTime,
		data.Duration or self.Duration,
		data.Interval or self.Interval, {
			Damage = data.Damage or self.Damage
		})
end

function BUFF:OnTick(index, data)
	if SERVER then
		local info = DamageInfo()

		info:SetDamageType(DMG_FALL) -- So we don't get viewpunch
		info:SetDamage(data.Damage)
		info:SetAttacker(self.Player)

		self.Player:TakeDamageInfo(info)
	end
end

function BUFF:OnTimer(index, data)
	self:RemoveStacks(1)
end

function BUFF:OnExpire()
	print("The bleeding has stopped!")
end
