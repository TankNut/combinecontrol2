DONATOR_NONE     = 0
DONATOR_BASIC    = 1
DONATOR_ADVANCED = 2

local PLAYER = FindMetaTable("Player")

PlayerVar.Add("DonationLevel", {
	Default = DONATOR_NONE,
	Persist = true,
	DataType = TINYINT()
})

PlayerVar.Add("DonationExpire", {
	Default = 0,
	Persist = true,
	ServerOnly = true,
	DataType = UINT()
})

function PLAYER:IsDonator(advanced)
	return advanced and self:DonationLevel() == DONATOR_ADVANCED or self:DonationLevel() > DONATOR_NONE
end

if SERVER then
	function PLAYER:CheckDonation()
		if self:DonationLevel() == DONATOR_NONE then
			return
		end

		local expire = self:DonationExpire()

		-- Might want some kind of reminder if there's less than X days left
		if expire > 0 and expire <= os.time() then
			self:SetDonationLevel(DONATOR_NONE)

			Log.Write("donator_expire", self)

			self:SendChat("NOTICE", "Your contributor status has ran out.")
		end
	end
end

hook.Add("GetSandboxLimit", "plugin.Donator", function(ply, name)
	if not ply:IsDonator() then
		return
	end

	return Config.Get("DonatorLimits")[name] or limit
end)

if CLIENT then
	hook.Add("GetPhysgunColor", "plugin.Donator", function(ply)
		if not ply:IsDonator() and not ply:IsSuperAdmin() then
			return
		end

		return ply:GetSetting("PhysgunColor")
	end)

	hook.Add("GetScoreboardTitle", "plugin.Donator", function(ply)
		if not ply:IsDonator() and not ply:IsSuperAdmin() then
			return
		end

		return ply:GetSetting("ScoreboardTitle"), ply:GetSetting("ScoreboardTitleColor")
	end)
else
	local donatorNames = {
		[DONATOR_NONE] = "No",
		[DONATOR_BASIC] = "<c=dodgerblue>Basic</c>",
		[DONATOR_ADVANCED] = "<c=gold>Advanced</c>"
	}

	hook.Add("ParsePlayerRecord", "plugin.Donator", function(addLine, steamID, record)
		local donator = (record.DonationLevel > 0 and os.time() <= record.DonationExpire) and record.DonationLevel or DONATOR_NONE

		addLine("Contributor", donatorNames[donator])

		if donator > DONATOR_NONE then
			addLine("Until", "%s (%s remaining)", os.date("%Y-%m-%d %H:%M:%S", record.DonationExpire), string.NiceTime(record.DonationExpire - os.time()))
		end
	end)
end
