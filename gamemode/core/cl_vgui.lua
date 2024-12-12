vgui.AutoClosePanels = vgui.AutoClosePanels or {}

local meta = FindMetaTable("Panel")

function meta:GetAutoClose()
	return self.AutoClose
end

function meta:SetAutoClose(bool)
	self.AutoClose = bool

	if bool then
		vgui.AutoClosePanels[self] = true
	else
		vgui.AutoClosePanels[self] = nil
	end
end

function GM:OnPauseMenuShow()
	for panel in pairs(vgui.AutoClosePanels) do
		if not IsValid(panel) then
			vgui.AutoClosePanels[panel] = nil

			continue
		end

		if vgui.FocusedHasParent(panel) then
			panel:Remove()

			vgui.AutoClosePanels[panel] = nil

			return false
		end
	end

	return true
end
