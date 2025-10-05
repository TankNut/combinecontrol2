local PANEL = FindMetaTable("Panel")

function PANEL:SetCloseOnPause()
	self.m_bCloseOnPause = true

	hook.Add("OnPauseMenuShow", self, function()
		if vgui.FocusedHasParent(self) then
			self:Close()

			return false
		end
	end)
end
