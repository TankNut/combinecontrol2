vgui.PauseClosePanels = vgui.PauseClosePanels or {}

local PANEL = FindMetaTable("Panel")

function PANEL:GetCloseOnPause()
	return self.m_bCloseOnPause
end

function PANEL:SetCloseOnPause(bool)
	self.m_bCloseOnPause = bool

	if bool then
		vgui.PauseClosePanels[self] = true
	else
		vgui.PauseClosePanels[self] = nil
	end
end

function PANEL:OnPauseMenu()
	self:Remove()

	return true
end

function GM:OnPauseMenuShow()
	for panel in pairs(vgui.PauseClosePanels) do
		if not IsValid(panel) then
			vgui.PauseClosePanels[panel] = nil

			continue
		end

		if vgui.FocusedHasParent(panel) then
			panel:Close()

			if not IsValid(panel) then
				vgui.PauseClosePanels[panel] = nil
			end

			return false
		end
	end

	return true
end
