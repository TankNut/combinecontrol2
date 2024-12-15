vgui.PauseClosePanels = vgui.PauseClosePanels or {}

local meta = FindMetaTable("Panel")

function meta:GetCloseOnPause()
	return self.m_bCloseOnPause
end

function meta:SetCloseOnPause(bool)
	self.m_bCloseOnPause = bool

	if bool then
		vgui.PauseClosePanels[self] = true
	else
		vgui.PauseClosePanels[self] = nil
	end
end

function GM:OnPauseMenuShow()
	for panel in pairs(vgui.PauseClosePanels) do
		if not IsValid(panel) then
			vgui.PauseClosePanels[panel] = nil

			continue
		end

		if vgui.FocusedHasParent(panel) then
			panel:Remove()

			vgui.PauseClosePanels[panel] = nil

			return false
		end
	end

	return true
end
