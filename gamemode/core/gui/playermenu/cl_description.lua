local PANEL = {}

function PANEL:Init()
	self:SetPaintBackground(false)

	self.ModelPanel = self:Add("CC_CharacterModel")
	self.ModelPanel:SetWide(200)
	self.ModelPanel:SetAllowManipulation(true)
	self.ModelPanel:SetPlayer(lp)
	self.ModelPanel:SetBaseYaw(20)

	self.ChangeName = self:Add("DButton")
	self.ChangeName:SetText("Change Name")

	self.ChangeDescription = self:Add("DButton")
	self.ChangeDescription:SetText("Change Description")

	self.MiscInfo = self:Add("ScribeLabel")

	self.CharacterName = self:Add("DLabel")
	self.CharacterName:SetFont("CombineControl.LabelGiant")
	self.CharacterName:SetText(lp:VisibleRPName())

	self.CharacterDescription = self:Add("ScribeLabel")
	self.CharacterDescription:SetText(lp:VisibleDescription())

	self:UpdateMiscInfo()

	hook.Add("OnVisibleRPNameChanged", self, function(ply, old, new)
		if ply == lp then
			self.CharacterName:SetText(new)
		end
	end)

	hook.Add("OnVisibleDescriptionChanged", self, function(ply, old, new)
		if ply == lp then
			self.CharacterDescription:SetText(new)
		end
	end)
end

function PANEL:AddLine(order, text)
	self.MiscLines[order] = text
end

function PANEL:PerformLayout(w, h)
	self.ChangeName:SizeToContentsX(20)
	self.ChangeDescription:SizeToContentsX(20)

	self.ModelPanel:SetPos(0, 0)
	self.ModelPanel:StretchToParent(nil, nil, nil, 0)

	self.CharacterName:MoveRightOf(self.ModelPanel, 10)
	self.CharacterName:AlignTop()
	self.CharacterName:SizeToContentsY()
	self.CharacterName:StretchToParent(nil, nil, 0, nil)

	self.ChangeDescription:AlignRight()
	self.ChangeDescription:AlignBottom()
	self.ChangeName:MoveLeftOf(self.ChangeDescription, 5)
	self.ChangeName:AlignBottom()

	self.MiscInfo:MoveRightOf(self.ModelPanel, 12)
	self.MiscInfo:AlignBottom()
	self.MiscInfo:StretchRightTo(self.ChangeName, 5)
	self.MiscInfo:Rebuild()
	self.MiscInfo:SizeToContentsY()

	self.CharacterDescription:MoveRightOf(self.ModelPanel, 12)
	self.CharacterDescription:StretchBottomTo(self.MiscInfo, 5)
end

function PANEL:UpdateMiscInfo()
	self.MiscLines = {}

	hook.Run("GetMiscCharacterInfo", self)

	local lines = {}

	for _, line in SortedPairs(self.MiscLines) do
		table.insert(lines, line)
	end

	self.MiscInfo:SetText("<c=cc_disabled>" .. table.concat(lines, "\n") .. "")
end

derma.DefineControl("CC_PlayerMenu_Description", "", PANEL, "DPanel")

function GM:GetMiscCharacterInfo(panel)
	local spoken = {}
	local understood = {}

	local languages = lp:Languages()

	for lang, state in pairs(languages) do
		local name = Language.Get(lang).Name
		if state then
			table.insert(spoken, name)
		end

		table.insert(understood, name)
	end

	panel:AddLine(1, "Spoken Languages: " .. (#spoken > 0 and table.concat(spoken, ", ") or "None"))
	panel:AddLine(2, "Understood Languages: " .. (#understood > 0 and table.concat(understood, ", ") or "None"))
end
