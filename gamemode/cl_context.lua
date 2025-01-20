net.Receive("nCReceiveCredits", function(len)
	local amt = net.ReadFloat()
	local ply = net.ReadEntity()

	lp:SendChat("GENERIC", ply:VisibleRPName() .. " gave you " .. util.FormatCurrency(amt) .. ".")
end)

function GM:GetCCOptions(ent, dist)
	local tab = {}

	if IsValid(ent) and ent:GetClass() == "prop_ragdoll" then
		for _, v in player.Iterator() do
			if IsValid(v:Ragdoll()) and v:Ragdoll() == ent then
				ent = v
				CCSelectedEnt = ent
			end
		end
	end

	if IsValid(ent) then
		if ent:IsDoor() then
			if LocalPlayer():TiedUp() then return tab end
			if LocalPlayer():PassedOut() then return tab end

			if (ent:DoorType() == DOOR_BUYABLE or ent:DoorType() == DOOR_BUYABLE_ASSIGNABLE) and #ent:DoorOwners() == 0 and #ent:DoorAssignedOwners() == 0 then

				local option = {"Buy", function()
					if lp:HasMoney(ent:DoorPrice()) then
						net.Start("nCBuyDoor")
							net.WriteEntity(ent)
						net.SendToServer()
					else
						lp:SendChat("ERROR", "You need more money to do that!")
					end
				end, nil, 100}

				table.insert(tab, option)
			elseif (ent:DoorType() == DOOR_BUYABLE or ent:DoorType() == DOOR_BUYABLE_ASSIGNABLE) and table.HasValue(ent:DoorOwners(), lp:CharID()) then
				local option = {"Sell", function()
					net.Start("nCSellDoor")
						net.WriteEntity(ent)
					net.SendToServer()

					lp:SendChat("NOTICE", "You sold the door for 80% of its original value (" .. util.FormatCurrency(ent:DoorPrice() * 0.8) .. ").")
				end, nil, 100}

				table.insert(tab, option)
			end

			if table.HasValue(ent:DoorOwners(), lp:CharID()) then
				local option = {"Rename", function()
					self:CCCreateDoorNameEdit()
				end, nil, 100}

				table.insert(tab, option)

				local option = {"Manage Owners", function()
					self:CCCreateDoorOwnersEdit()
				end, nil, 100}

				table.insert(tab, option)
			end

			if lp:CanLock(ent) then
				local option = {"Lock/Unlock", function()
					net.Start("nCLockUnlock")
						net.WriteEntity(ent)
					net.SendToServer()
				end, nil, 100}

				table.insert(tab, option)
			end
		elseif ent:IsPlayer() then
			local option = {"Examine", function()
				self:CCCreatePlayerViewer(CCSelectedEnt)
			end, nil, self:GetPlayerSight()}

			table.insert(tab, option)

			if lp:TiedUp() then return tab end
			if lp:PassedOut() then return tab end

			local option = {"Give Money", function()
				self:CCCreateGiveCredits()
			end, nil, 100}

			table.insert(tab, option)

			if ent:PassedOut() and lp:HasItem("weapon_cc_knife") and ent:GetVelocity():Length2D() <= 5 then
				local option = {"Slit Throat", function()
					net.Start("nCSlitThroat")
						net.WriteEntity(ent)
					net.SendToServer()
				end, nil, 100}

				table.insert(tab, option)
			end
		elseif ent:GetClass() == "cc_item" then
			if ent.Item and #ent.Item.Description > 0 then
				local option = {"Examine", function()
					lp:SendChat("GENERIC", ent.Item.Description)

					if #ent.Item:GetProperty("UserDescription") > 0 then
						lp:SendChat("GENERIC", ent.Item:GetProperty("UserDescription"))
					end
				end, nil, 100}

				table.insert(tab, option)
			end
		elseif ent:GetClass() == "cc_vendingmachine" then
			local option = {"Examine", function()
				lp:SendChat("GENERIC", "Only Breen Water is in stock. The machine says they costs " .. util.FormatCurrency(7) .. " each.")
			end, nil, 100}

			table.insert(tab, option)
		elseif ent:GetClass() == "cc_paper" then
			local option = {"Read", function()
				local paper = vgui.Create("DFrame")
				paper:SetSize(400, 600)
				paper:Center()
				paper:SetTitle("")
				paper:MakePopup()
				paper.PerformLayout = CCFramePerformLayout
				paper:PerformLayout()
				paper.Paint = function(panel, w, h)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawRect(0, 0, w, h)
				end

				paper:SetCloseOnPause(true)

				local entry = vgui.Create("DTextEntry", paper)
				entry:SetFont("CombineControl.Written")
				entry:SetPos(10, 34)
				entry:SetSize(380, 526)
				entry:SetMultiline(true)
				entry:PerformLayout()
				entry:SetTextColor(Color(0, 0, 0, 255))
				entry:SetDrawBackground(false)
				entry:SetValue(ent:GetText())
				entry:SetEditable(false)
			end, nil, 100}

			table.insert(tab, option)
		elseif ent:GetClass() == "prop_physics" and ent:PropSaved() == 0 and (lp:IsAdmin() or lp:ToolTrust() == 2) then
			local hasPermission = lp:SteamID() == ent:PropSteamID() or lp:IsAdmin()

			if not hasPermission then
				local pp = {}

				for _, v in player.Iterator() do
					if v:SteamID() == ent:PropSteamID() then
						pp = v:PropProtection()
					end
				end
				if table.HasValue(pp, LocalPlayer()) then
					hasPermission = true
				end
			end

			if hasPermission then
				local option = {"Describe", function ()
					local frame = vgui.Create( "DFrame" )
					frame:SetSize( 400, 50 )
					frame:SetTitle("Describe")
					frame:SetDraggable(false)
					frame:ShowCloseButton(false)
					frame:Center()
					frame:MakePopup()

					local TextEntry = vgui.Create( "DTextEntry", frame )
					TextEntry:SetPos(3,26)
					TextEntry:SetSize(394,20)
					TextEntry:SetText(ent:PropDescription())
					TextEntry.OnEnter = function(self)
						net.Start("nSetPropDesc")
							net.WriteEntity(ent)
							net.WriteString(self:GetValue())
						net.SendToServer()
						frame:Close()
					end
				end, nil, 100}

				table.insert(tab, option)
			end
		elseif ent.IsWorldEnt then
			for _, v in pairs(ent:GetContextOptions(LocalPlayer())) do
				table.insert(tab, {v.Name, function()
					if v.Client then
						v.Client()
					end

					if v.Callback then
						net.Start("nWorldEnt")
							net.WriteEntity(ent)
							net.WriteString(v.Name)
						net.SendToServer()
					end
				end, nil, 100})
			end
		end
	end

	for k, v in pairs(self:GetValidGestures(LocalPlayer())) do
		local option = {k, function()
			LocalPlayer():PlaySignal(v)
		end, true}

		table.insert(tab, option)
	end

	return tab
end

function GM:CCCreateDoorNameEdit()
	CCP.DoorNameEdit = vgui.Create("DFrame")
	CCP.DoorNameEdit:SetSize(300, 114)
	CCP.DoorNameEdit:Center()
	CCP.DoorNameEdit:SetTitle("Change Door Name")
	CCP.DoorNameEdit.lblTitle:SetFont("CombineControl.Window")
	CCP.DoorNameEdit:MakePopup()
	CCP.DoorNameEdit.PerformLayout = CCFramePerformLayout
	CCP.DoorNameEdit:PerformLayout()

	CCP.DoorNameEdit:SetCloseOnPause(true)

	CCP.DoorNameEdit.Label = vgui.Create("DLabel", CCP.DoorNameEdit)
	CCP.DoorNameEdit.Label:SetText(#CCSelectedEnt:DoorName() .. "/50")
	CCP.DoorNameEdit.Label:SetPos(10, 74)
	CCP.DoorNameEdit.Label:SetSize(280, 22)
	CCP.DoorNameEdit.Label:SetFont("CombineControl.LabelGiant")
	CCP.DoorNameEdit.Label:PerformLayout()

	CCP.DoorNameEdit.Entry = vgui.Create("DTextEntry", CCP.DoorNameEdit)
	CCP.DoorNameEdit.Entry:SetFont("CombineControl.LabelBig")
	CCP.DoorNameEdit.Entry:SetPos(10, 34)
	CCP.DoorNameEdit.Entry:SetSize(280, 30)
	CCP.DoorNameEdit.Entry:PerformLayout()
	CCP.DoorNameEdit.Entry:SetValue(CCSelectedEnt:DoorName())
	CCP.DoorNameEdit.Entry:RequestFocus()
	CCP.DoorNameEdit.Entry:SetCaretPos(#CCP.DoorNameEdit.Entry:GetValue())
	function CCP.DoorNameEdit.Entry:OnChange()

		if CCP.DoorNameEdit.Label then

			local val = self:GetValue()

			local col = Color(200, 200, 200, 255)

			if #string.Trim(val) > 50 or #string.Trim(val) < 1 then

				col = Color(200, 0, 0, 255)

			end

			CCP.DoorNameEdit.Label:SetText(#string.Trim(val) .. "/50")
			CCP.DoorNameEdit.Label:SetTextColor(col)

		end

	end

	CCP.DoorNameEdit.OK = vgui.Create("DButton", CCP.DoorNameEdit)
	CCP.DoorNameEdit.OK:SetFont("CombineControl.LabelSmall")
	CCP.DoorNameEdit.OK:SetText("OK")
	CCP.DoorNameEdit.OK:SetPos(240, 74)
	CCP.DoorNameEdit.OK:SetSize(50, 30)
	function CCP.DoorNameEdit.OK:DoClick()

		local val = string.Trim(CCP.DoorNameEdit.Entry:GetValue())

		if #val <= 50 and #val >= 1 then

			CCP.DoorNameEdit:Remove()

			net.Start("nCNameDoor")
				net.WriteEntity(CCSelectedEnt)
				net.WriteString(val)
			net.SendToServer()

		else

			lp:SendChat("ERROR", "Name must be between 1 and 50 characters.")

		end

	end
	CCP.DoorNameEdit.OK:PerformLayout()

	CCP.DoorNameEdit.Entry.OnEnter = CCP.DoorNameEdit.OK.DoClick
end

function GM:CCCreateDoorOwnersEdit()
	CCP.DoorOwnersEdit = vgui.Create("DFrame")
	CCP.DoorOwnersEdit:SetSize(400, 504)
	CCP.DoorOwnersEdit:Center()
	CCP.DoorOwnersEdit:SetTitle("Manage Door Owners")
	CCP.DoorOwnersEdit.lblTitle:SetFont("CombineControl.Window")
	CCP.DoorOwnersEdit:MakePopup()
	CCP.DoorOwnersEdit.PerformLayout = CCFramePerformLayout
	CCP.DoorOwnersEdit:PerformLayout()

	CCP.DoorOwnersEdit:SetCloseOnPause(true)

	CCP.DoorOwnersEdit.AllPlayers = vgui.Create("DListView", CCP.DoorOwnersEdit)
	CCP.DoorOwnersEdit.AllPlayers:SetPos(10, 34)
	CCP.DoorOwnersEdit.AllPlayers:SetSize(185, 430)
	CCP.DoorOwnersEdit.AllPlayers:AddColumn("Characters")
	function CCP.DoorOwnersEdit.AllPlayers:DoDoubleClick(id, line)

		local ply = CCP.DoorOwnersEdit.AllPlayers:GetLine(id).Player

		net.Start("nCMakeOwner")
			net.WriteEntity(CCSelectedEnt)
			net.WriteEntity(ply)
		net.SendToServer()

		CCP.DoorOwnersEdit.AllPlayers:RemoveLine(id)
		CCP.DoorOwnersEdit.Owners:AddLine(ply:VisibleRPName()).Player = ply

	end

	for k, v in player.Iterator() do

		if not table.HasValue(CCSelectedEnt:DoorOwners(), v:CharID()) and not table.HasValue(CCSelectedEnt:DoorAssignedOwners(), v:CharID()) then

			CCP.DoorOwnersEdit.AllPlayers:AddLine(v:VisibleRPName()).Player = v

		end

	end

	CCP.DoorOwnersEdit.Owners = vgui.Create("DListView", CCP.DoorOwnersEdit)
	CCP.DoorOwnersEdit.Owners:SetPos(205, 34)
	CCP.DoorOwnersEdit.Owners:SetSize(185, 430)
	CCP.DoorOwnersEdit.Owners:AddColumn("Owners")
	function CCP.DoorOwnersEdit.Owners:DoDoubleClick(id, line)

		local ply = CCP.DoorOwnersEdit.Owners:GetLine(id).Player

		net.Start("nCRemoveOwner")
			net.WriteEntity(CCSelectedEnt)
			net.WriteEntity(ply)
		net.SendToServer()

		CCP.DoorOwnersEdit.Owners:RemoveLine(id)
		CCP.DoorOwnersEdit.AllPlayers:AddLine(ply:VisibleRPName()).Player = ply

	end

	for k, v in pairs(CCSelectedEnt:DoorOwners()) do

		if v != LocalPlayer():CharID() then

			if player.GetByCharID(v) and player.GetByCharID(v):IsValid() then

				CCP.DoorOwnersEdit.Owners:AddLine(player.GetByCharID(v):VisibleRPName()).Player = player.GetByCharID(v)

			end

		end

	end

	CCP.DoorOwnersEdit.MakeOwner = vgui.Create("DButton", CCP.DoorOwnersEdit)
	CCP.DoorOwnersEdit.MakeOwner:SetFont("CombineControl.LabelSmall")
	CCP.DoorOwnersEdit.MakeOwner:SetText(">")
	CCP.DoorOwnersEdit.MakeOwner:SetPos(10, 474)
	CCP.DoorOwnersEdit.MakeOwner:SetSize(185, 20)
	function CCP.DoorOwnersEdit.MakeOwner:DoClick()

		if not CCP.DoorOwnersEdit.AllPlayers:GetSelected()[1] then return end

		local ply = CCP.DoorOwnersEdit.AllPlayers:GetSelected()[1].Player

		net.Start("nCMakeOwner")
			net.WriteEntity(CCSelectedEnt)
			net.WriteEntity(ply)
		net.SendToServer()

		CCP.DoorOwnersEdit.AllPlayers:RemoveLine(CCP.DoorOwnersEdit.AllPlayers:GetSelected()[1]:GetID())
		CCP.DoorOwnersEdit.Owners:AddLine(ply:VisibleRPName()).Player = ply

	end
	CCP.DoorOwnersEdit.MakeOwner:PerformLayout()

	CCP.DoorOwnersEdit.RemoveOwner = vgui.Create("DButton", CCP.DoorOwnersEdit)
	CCP.DoorOwnersEdit.RemoveOwner:SetFont("CombineControl.LabelSmall")
	CCP.DoorOwnersEdit.RemoveOwner:SetText("<")
	CCP.DoorOwnersEdit.RemoveOwner:SetPos(205, 474)
	CCP.DoorOwnersEdit.RemoveOwner:SetSize(185, 20)
	function CCP.DoorOwnersEdit.RemoveOwner:DoClick()

		if not CCP.DoorOwnersEdit.Owners:GetSelected()[1] then return end

		local ply = CCP.DoorOwnersEdit.Owners:GetSelected()[1].Player

		net.Start("nCRemoveOwner")
			net.WriteEntity(CCSelectedEnt)
			net.WriteEntity(ply)
		net.SendToServer()

		CCP.DoorOwnersEdit.Owners:RemoveLine(CCP.DoorOwnersEdit.Owners:GetSelected()[1]:GetID())
		CCP.DoorOwnersEdit.AllPlayers:AddLine(ply:VisibleRPName()).Player = ply

	end
	CCP.DoorOwnersEdit.RemoveOwner:PerformLayout()
end

function GM:CCCreateGiveCredits()
	CCP.GiveCredits = vgui.Create("DFrame")
	CCP.GiveCredits:SetSize(180, 80)
	CCP.GiveCredits:Center()
	CCP.GiveCredits:SetTitle("Give Money")
	CCP.GiveCredits.lblTitle:SetFont("CombineControl.Window")
	CCP.GiveCredits:MakePopup()
	CCP.GiveCredits.PerformLayout = CCFramePerformLayout
	CCP.GiveCredits:PerformLayout()

	CCP.GiveCredits:SetCloseOnPause(true)

	CCP.GiveCredits.Entry = vgui.Create("DTextEntry", CCP.GiveCredits)
	CCP.GiveCredits.Entry:SetFont("CombineControl.LabelBig")
	CCP.GiveCredits.Entry:SetPos(10, 34)
	CCP.GiveCredits.Entry:SetSize(100, 30)
	CCP.GiveCredits.Entry:PerformLayout()
	CCP.GiveCredits.Entry:RequestFocus()
	CCP.GiveCredits.Entry:SetNumeric(true)
	CCP.GiveCredits.Entry:SetCaretPos(#CCP.GiveCredits.Entry:GetValue())

	CCP.GiveCredits.OK = vgui.Create("DButton", CCP.GiveCredits)
	CCP.GiveCredits.OK:SetFont("CombineControl.LabelSmall")
	CCP.GiveCredits.OK:SetText("OK")
	CCP.GiveCredits.OK:SetPos(120, 34)
	CCP.GiveCredits.OK:SetSize(50, 30)
	function CCP.GiveCredits.OK:DoClick()

		if not CCSelectedEnt or not CCSelectedEnt:IsValid() then return end

		local val = tonumber(CCP.GiveCredits.Entry:GetValue())

		if not val or math.floor(val) < 1 then

			CCP.GiveCredits:Remove()
			return

		end

		if LocalPlayer():GetPos():Distance(CCSelectedEnt:GetPos()) > 100 then

			lp:SendChat("GENERIC", "They're too far away.")
			return

		end

		val = math.floor(val)

		if lp:HasMoney(val) then

			CCP.GiveCredits:Remove()

			net.Start("nCGiveCredits")
				net.WriteFloat(val)
				net.WriteEntity(CCSelectedEnt)
			net.SendToServer()

			lp:SendChat("GENERIC", "You gave " .. CCSelectedEnt:VisibleRPName() .. " " .. util.FormatCurrency(val) .. ".")

		else

			lp:SendChat("ERROR", "You don't have this much money!")

		end

	end
	CCP.GiveCredits.OK:PerformLayout()

	CCP.GiveCredits.Entry.OnEnter = CCP.GiveCredits.OK.DoClick
end

function GM:CCCreatePlayerViewer(ent)
	if not ent or not ent:IsValid() then return end

	local title = string.format("%s %s", ent:VisibleRPName(), LocalPlayer():IsAdmin() and string.format("- %s (%s)", ent:Nick(), ent:SteamID()) or "")
	CCP.PlayerViewer = vgui.Create("DFrame")
	CCP.PlayerViewer:SetSize(800, 426)
	CCP.PlayerViewer:Center()
	CCP.PlayerViewer:SetTitle(title)
	CCP.PlayerViewer.lblTitle:SetFont("CombineControl.Window")
	CCP.PlayerViewer:MakePopup()
	CCP.PlayerViewer.PerformLayout = CCFramePerformLayout
	CCP.PlayerViewer:PerformLayout()

	CCP.PlayerViewer:SetCloseOnPause(true)

	CCP.PlayerViewer.CharacterModel = vgui.Create("DModelPanel", CCP.PlayerViewer)
	CCP.PlayerViewer.CharacterModel:SetPos(10, 34)
	CCP.PlayerViewer.CharacterModel:SetModel(ent:GetModel())
	CCP.PlayerViewer.CharacterModel.Entity:SetSkin(ent:GetSkin())
	CCP.PlayerViewer.CharacterModel.Entity:SetMaterial(ent:GetMaterial())
	CCP.PlayerViewer.CharacterModel.Entity:CopyBodygroups(ent)
	CCP.PlayerViewer.CharacterModel:SetSize(200, 382)
	CCP.PlayerViewer.CharacterModel:SetFOV(20)
	CCP.PlayerViewer.CharacterModel:SetCamPos(Vector(50, 0, 56))
	CCP.PlayerViewer.CharacterModel:SetLookAt(Vector(0, 0, 56))

	function CCP.PlayerViewer.CharacterModel:DoClick()
		self:StartScene("scenes/expressions/citizen_angry_idle_01.vcd")
	end

	function CCP.PlayerViewer.CharacterModel.Entity:GetPlayerColor()
		if not IsValid(ent) then
			return Vector(1, 1, 1)
		end

		return ent:GetPlayerColor()
	end

	part.Copy(ent, CCP.PlayerViewer.CharacterModel.Entity)

	CCP.PlayerViewer.CharacterName = vgui.Create("DLabel", CCP.PlayerViewer)
	CCP.PlayerViewer.CharacterName:SetText(ent:VisibleRPName())
	CCP.PlayerViewer.CharacterName:SetPos(220, 34)
	CCP.PlayerViewer.CharacterName:SetSize(540, 22)
	CCP.PlayerViewer.CharacterName:SetFont("CombineControl.LabelGiant")
	CCP.PlayerViewer.CharacterName:PerformLayout()

	CCP.PlayerViewer.CharacterDescScroll = vgui.Create("DScrollPanel", CCP.PlayerViewer)
	CCP.PlayerViewer.CharacterDescScroll:SetPos(220, 64)
	CCP.PlayerViewer.CharacterDescScroll:SetSize(540, 352)
	function CCP.PlayerViewer.CharacterDescScroll:Paint(w, h) end

	CCP.PlayerViewer.CharacterDesc = vgui.Create("CCLabel")
	CCP.PlayerViewer.CharacterDesc:SetPos(0, 0)
	CCP.PlayerViewer.CharacterDesc:SetSize(530, 10)
	CCP.PlayerViewer.CharacterDesc:SetFont("CombineControl.LabelSmall")
	CCP.PlayerViewer.CharacterDesc:SetText(ent:Description())
	CCP.PlayerViewer.CharacterDesc:PerformLayout()

	CCP.PlayerViewer.CharacterDescScroll:AddItem(CCP.PlayerViewer.CharacterDesc)
end

function GM:CreateCCContext(ent)
	CloseDermaMenus()
end

function GM:RemoveCCContext(d)
	gui.EnableScreenClicker(false)
	CloseDermaMenus()
end

function GM:CCCreateMiniAdminMenu(ply)
	CloseDermaMenus()

	local options = {
		{"Kick", "rpa_kick"},
		{"Name Warn", "rpa_namewarn"},
		{"Slap", "rpa_slap"},
		{"Knockout", "rpa_ko"},
		{"Wake up", "rpa_wakeup"},
		{"Kill", "rpa_kill"},
		{"Goto", "rpa_goto"},
		{"Bring", "rpa_bring"},
		{"Player Notes", "rpa_playernotes"},
		{"Edit Inventory", "rpa_editinventory"},
		{"OOC Mute", "rpa_oocmute"},
		{"Character list", "rpa_charlist"}}

	gui.EnableScreenClicker(true)

	local menu = DermaMenu()
	menu:SetPos(gui.MousePos())

	for _, v in pairs(options) do

		menu:AddOption(v[1], function()
			gui.EnableScreenClicker(false)

			if not IsValid(ply) then
				return
			end

			RunConsoleCommand(v[2], ply:IsBot() and ply:VisibleRPName() or ply:SteamID())
		end)

	end

	menu:Open()
end
