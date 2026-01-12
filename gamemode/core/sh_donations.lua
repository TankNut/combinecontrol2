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
	function PLAYER:SetDonation(level, expire)
		self:SetDonationLevel(level)
		self:SetDonationExpire(os.time() + expire)
	end

	function PLAYER:CheckDonation()
		if self:DonationLevel() == DONATOR_NONE then
			return
		end

		-- Might want some kind of reminder if there's less than X days left
		if self:DonationExpire() <= os.time() then
			self:SetDonationLevel(DONATOR_NONE)

			self:SendChat("NOTICE", "Your contributor status has ran out.")
		end
	end
end
