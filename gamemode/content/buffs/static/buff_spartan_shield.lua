BUFF.ShieldClass = "cc_shield"

if SERVER then
	function BUFF:Initialize()
		shield.Enable(self.Player, self.ShieldClass)
	end

	function BUFF:OnRemove()
		shield.Disable(self.Player)
	end
end
