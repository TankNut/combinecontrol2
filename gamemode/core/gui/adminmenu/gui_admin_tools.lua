local PANEL = {}

function PANEL:CreateLabel(text, wide)
	local label = self:Add("DLabel")

	label:SetFont("CombineControl.LabelMedium")
	label:SetSize(wide or 190, 20)
	label:SetText(text)

	return label
end

function PANEL:Init()
	self.Restart = self:Add("DButton")
	self.Restart:SetText("Restart Server")
	self.Restart:SetWide(100)
	self.Restart.DoClick = function()
		RunConsoleCommand("rpa_restart")
	end

	self.DisableAILabel = self:CreateLabel("Disable AI")
	self.DisableAI = self:Add("DCheckBox")
	self.DisableAI:SetChecked(GAMEMODE:AIDisabled())
	self.DisableAI.OnChange = function(_, val)
		RunConsoleCommand("rpa_ai_disable", val and "1" or "0")
	end

	hook.Add("OnAIDisabledChanged", self, function(_, old, new, loaded)
		self.DisableAI:SetChecked(new)
	end)

	self.IgnoreAILabel = self:CreateLabel("NPC's Ignore Players")
	self.IgnoreAI = self:Add("DCheckBox")
	self.IgnoreAI:SetChecked(GAMEMODE:AINoTarget())
	self.IgnoreAI.OnChange = function(_, val)
		RunConsoleCommand("rpa_ai_notarget", val and "1" or "0")
	end

	hook.Add("OnAINoTargetChanged", self, function(_, old, new, loaded)
		self.IgnoreAI:SetChecked(new)
	end)

	local initial = GAMEMODE:OOCDelay()

	self.OOCDelayLabel = self:CreateLabel("OOC Delay")
	self.OOCDelay = self:Add("DTextEntry")
	self.OOCDelay:SetTall(20)
	self.OOCDelay:SetFont("CombineControl.LabelMedium")
	self.OOCDelay:SetValue(initial == -1 and 0 or initial)
	self.OOCDelay.OnEnter = function()
		self.ApplyOOCDelay:DoClick()
	end

	self.ApplyOOCDelay = self:Add("DButton")
	self.ApplyOOCDelay:SetText("Apply")
	self.ApplyOOCDelay:SetSize(50, 20)
	self.ApplyOOCDelay.DoClick = function()
		local delay = util.Duration(self.OOCDelay:GetValue()) or 0

		RunConsoleCommand("rpa_oocdelay", delay)
	end

	self.DisableOOC = self:Add("DButton")
	self.DisableOOC:SetText("Disable")
	self.DisableOOC:SetSize(80, 20)
	self.DisableOOC:SetDisabled(initial == -1)
	self.DisableOOC.DoClick = function()
		RunConsoleCommand("rpa_oocdisable")
	end

	hook.Add("OnOOCDelayChanged", self, function(_, old, new, loaded)
		self.OOCDelay:SetValue(new == -1 and 0 or new)
		self.DisableOOC:SetDisabled(new == -1)
	end)
end

function PANEL:Think()
end

function PANEL:PerformLayout(w, h)
	self.Restart:AlignRight()
	self.Restart:AlignBottom()

	self.DisableAI:MoveRightOf(self.DisableAILabel)
	self.DisableAI:SetY(self.DisableAILabel:GetY() + 3)

	self.IgnoreAILabel:MoveBelow(self.DisableAILabel, 10)
	self.IgnoreAI:MoveRightOf(self.IgnoreAILabel)
	self.IgnoreAI:SetY(self.IgnoreAILabel:GetY() + 3)

	self.OOCDelayLabel:MoveBelow(self.IgnoreAILabel, 10)
	self.OOCDelay:MoveRightOf(self.OOCDelayLabel)
	self.OOCDelay:SetY(self.OOCDelayLabel:GetY() - 1)

	self.ApplyOOCDelay:MoveRightOf(self.OOCDelay, 5)
	self.ApplyOOCDelay:SetY(self.OOCDelay:GetY())

	self.DisableOOC:MoveRightOf(self.ApplyOOCDelay, 5)
	self.DisableOOC:SetY(self.OOCDelay:GetY())
end

derma.DefineControl("CC_AdminMenu_Tools", "", PANEL, "Panel")
