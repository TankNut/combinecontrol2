CLASS.Name = "Admin"
CLASS.Description = "Speak with server administrators."

CLASS.Commands = {"a", "admin"}
CLASS.Aliases = {"@"}

CLASS.Tabs = TAB_ADMIN

CLASS.AdminNameColor = Color(255, 107, 218)
CLASS.AdminTextColor = Color(255, 156, 230)

CLASS.PlayerNameColor = Color(225, 51, 51)
CLASS.PlayerTextColor = Color(255, 83, 83)

CLASS.LogCategory = "admin"
CLASS.LogFiles = {"ooc", "admin"}

if CLIENT then
	function CLASS:OnReceive(data)
		local prefix = data.FromAdmin and "ADMIN" or "TO ADMINS"
		local nameColor = data.FromAdmin and self.AdminNameColor or self.PlayerNameColor
		local textColor = data.FromAdmin and self.AdminTextColor or self.PlayerTextColor

		return string.format("<c=%s>%s:</c> <c=%s>[%s] %s", nameColor, data.Name, textColor, prefix, data.Text)
	end
end

if SERVER then
	function CLASS:GetTargets(ply, data)
		return table.Add({ply}, player.GetAdmins())
	end

	function CLASS:Parse(ply, lang, cmd, text)
		return {
			Name = string.format("%s (%s)", ply:VisibleRPName(), ply:Nick()),
			Text = text,
			FromAdmin = ply:IsAdmin()
		}
	end

	function CLASS:WriteLog(data, ply)
		return string.format("[%sADMINS] %s: %s", ply:IsAdmin() and "" or "TO ", ply:VisibleRPName(), data.Text), {
			Log.Character(ply),
			ChatType = "admin"
		}
	end
end
