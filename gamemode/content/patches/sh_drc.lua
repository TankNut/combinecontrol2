local function filterDRC(ent, class)
	if string.Left(class, 4) == "drc_" then
		return false
	end
end

hook.Add("PreRegisterSENT", "cc2.DRCPatch", filterDRC)
hook.Add("PreRegisterSWEP", "cc2.DRCPatch", filterDRC)
