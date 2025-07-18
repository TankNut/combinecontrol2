local BaseClass = inherit.Get("buff", "base")

BUFF.ShieldClass = "cc_shield"

if SERVER then
	function BUFF:Initialize(data)
		BaseClass.Initialize(self, data)

		shield.Enable(self.Player, self.ShieldClass)
	end

	function BUFF:OnRemove()
		BaseClass.OnRemove(self)

		shield.Disable(self.Player)
	end

	function BUFF:OnSpawn()
		shield.Enable(self.Player, self.ShieldClass)
	end
end
