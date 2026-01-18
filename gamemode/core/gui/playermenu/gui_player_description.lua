local PANEL = {}

function PANEL:Init()
	local h = ui.Scale(22)

	self.ModelPanel = self:Add("CC_CharacterModel")
	self.ModelPanel:SetWide(ui.Scale(200))
	self.ModelPanel:SetAllowManipulation(true)
	self.ModelPanel:SetPlayer(lp)
	self.ModelPanel:SetBaseYaw(20)

	self.ChangeName = self:Add("DButton")
	self.ChangeName:SetText("Change Name")
	self.ChangeName:SetDisabled(#lp:CharacterNameOverride() > 0)
	self.ChangeName:SetTall(h)

	self.ChangeName.DoClick = function()
		async.Start(function()
			netstream.Send("ChangeCharacterName",
				ui.Open("Input", "string", "Change Character Name", {
					Default = lp:CharacterName(),
					Validate = Config.Get("CharacterNameRules"),
					Name = "Your name"
				})
			)
		end)
	end

	self.ChangeDescription = self:Add("DButton")
	self.ChangeDescription:SetText("Change Description")
	self.ChangeDescription:SetTall(h)

	self.ChangeDescription.DoClick = function()
		async.Start(function()
			netstream.Send("ChangeCharacterDescription",
				ui.Open("Input", "multiline", "Change Character Description", {
					Default = lp:CharacterDescription():Unescape(),
					Validate = Config.Get("CharacterDescriptionRules"),
					Name = "Your description"
				})
			)
		end)
	end

	self.ChangeNotes = self:Add("DButton")
	self.ChangeNotes:SetText("Edit Notes")
	self.ChangeNotes:SetTall(h)

	self.ChangeNotes.DoClick = function()
		async.Start(function()
			netstream.Send("ChangeCharacterNotes",
				ui.Open("Input", "multiline", "Edit Character Notes", {
					Default = lp:CharacterNotes(),
					Validate = Config.Get("CharacterDescriptionRules"),
					Name = "Your personal notes"
				})
			)
		end)
	end

	self.MiscInfo = self:Add("ScribeLabel")

	self.CharacterName = self:Add("DLabel")
	self.CharacterName:SetFont("CombineControl.LabelGiant")
	self.CharacterName:SetText(lp:VisibleRPName())

	self.DescriptionScroll = self:Add("DScrollPanel")

	self.CharacterDescription = self.DescriptionScroll:Add("ScribeLabel")
	self.CharacterDescription:Dock(TOP)
	self.CharacterDescription:SetText(string.format("<small><c=cc_disabled>%s", lp:VisibleDescription()))
	self.CharacterDescription:SetAutoStretchVertical(true)

	self:UpdateMiscInfo()

	hook.Add("OnVisibleRPNameChanged", self, function(_, ply, old, new)
		if ply == lp then
			self.CharacterName:SetText(new)
		end
	end)

	hook.Add("OnVisibleDescriptionChanged", self, function(_, ply, old, new)
		if ply == lp then
			self.CharacterDescription:SetText(string.format("<small><c=cc_disabled>%s", new))
		end
	end)
end

function PANEL:AddLine(order, text)
	self.MiscLines[order] = text
end

function PANEL:PerformLayout(w, h)
	local x = ui.Scale(20)

	local spacing = ui.Scale(5)

	self.ChangeName:SizeToContentsX(x)
	self.ChangeDescription:SizeToContentsX(x)
	self.ChangeNotes:SizeToContentsX(x)

	self.ModelPanel:SetPos(0, 0)
	self.ModelPanel:StretchToParent(nil, nil, nil, 0)

	self.CharacterName:MoveRightOf(self.ModelPanel, ui.Scale(10))
	self.CharacterName:AlignTop()
	self.CharacterName:SizeToContentsY()
	self.CharacterName:StretchToParent(nil, nil, 0, nil)

	self.ChangeNotes:AlignRight()
	self.ChangeNotes:AlignBottom()
	self.ChangeDescription:MoveLeftOf(self.ChangeNotes, spacing)
	self.ChangeDescription:AlignBottom()
	self.ChangeName:MoveLeftOf(self.ChangeDescription, spacing)
	self.ChangeName:AlignBottom()

	self.MiscInfo:MoveRightOf(self.ModelPanel, ui.Scale(12))
	self.MiscInfo:AlignBottom()
	self.MiscInfo:StretchRightTo(self.ChangeName, spacing)
	self.MiscInfo:Rebuild()
	self.MiscInfo:SizeToContentsY()

	self.DescriptionScroll:MoveRightOf(self.ModelPanel, ui.Scale(12))
	self.DescriptionScroll:MoveBelow(self.CharacterName, spacing)
	self.DescriptionScroll:StretchToParent(nil, nil, 0)
	self.DescriptionScroll:StretchBottomTo(self.MiscInfo, spacing)
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

vgui.Register("CC_PlayerMenu_Description", PANEL, "Panel")

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
