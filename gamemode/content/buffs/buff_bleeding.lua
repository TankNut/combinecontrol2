BUFF.RemoveOnDeath = true

BUFF.Duration = 5
BUFF.Interval = 1

BUFF.Damage = 2

function BUFF:Initialize()
	print("You start bleeding!")

	-- Force the first damage tick immediately
	self:OnTick()
end

function BUFF:OnTick()
	if SERVER then
		local dmginfo = DamageInfo()

		dmginfo:SetDamageType(DMG_FALL) -- So we don't get viewpunch and bypass things like shields
		dmginfo:SetDamage(data.Damage)
		dmginfo:SetAttacker(self.Player)

		self.Player:TakeDamageInfo(dmginfo)
	end
end

function BUFF:OnRemove()
	print("The bleeding has stopped!")
end
