function GM:CreateMOTD()
	if not self.MOTDText then return end

	CCP.MOTD = vgui.Create("DFrame")
	CCP.MOTD:SetSize(400, 600)
	CCP.MOTD:Center()
	CCP.MOTD:SetTitle("MOTD")
	CCP.MOTD.lblTitle:SetFont("CombineControl.Window")
	CCP.MOTD:MakePopup()
	CCP.MOTD.PerformLayout = CCFramePerformLayout
	CCP.MOTD:PerformLayout()

	CCP.MOTD:SetCloseOnPause(true)

	CCP.MOTD.ContentPane = vgui.Create("DScrollPanel", CCP.MOTD)
	CCP.MOTD.ContentPane:SetPos(10, 34)
	CCP.MOTD.ContentPane:SetSize(400 - 20, 556)

	CCP.MOTD.Content = vgui.Create("CCLabel")
	CCP.MOTD.Content:SetPos(10, 0)
	CCP.MOTD.Content:SetSize(400 - 50, 14)
	CCP.MOTD.Content:SetFont("CombineControl.LabelSmall")
	CCP.MOTD.Content:SetText(self.MOTDText)
	CCP.MOTD.Content:PerformLayout()

	CCP.MOTD.ContentPane:AddItem(CCP.MOTD.Content)
end
