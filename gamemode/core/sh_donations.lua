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
