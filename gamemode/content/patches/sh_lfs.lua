if SERVER then
	hook.Add("PreRegisterSENT", "cc2.lfs", function(ent, class)
		if class == "lunasflightschool_basescript" then
			ent.TakePrimaryAmmo = stub
			ent.TakeSecondaryAmmo = stub
		end
	end)
end
