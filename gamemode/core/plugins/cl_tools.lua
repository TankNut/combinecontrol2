local PANEL = vgui.GetControlTable("ToolPanel")

function PANEL:UpdateToolDisabledStatus()
	for cid, category in ipairs(self.List.pnlCanvas:GetChildren()) do
		for id, item in ipairs(category:GetChildren()) do
			if item == category.Header then
				continue
			end

			local enabled, err = hook.Run("CanUseTool", lp, item.Name)

			if enabled == item:IsEnabled() and (enabled or err == item:GetTooltip()) then
				continue
			end

			item:SetEnabled(enabled)

			if enabled then
				item:SetTooltip(nil)
			else
				item:SetTooltip(err)
			end
		end
	end
end
