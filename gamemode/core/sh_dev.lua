GlobalVar.Add("GlobalLua", {
	Default = "",
	Persist = true
})

GlobalVar.Add("MapLua", {
	Default = "",
	Persist = true,
	Mode = GLOBALVAR_MAP_NO_OVERRIDE
})

function GM:OnGlobalLuaChanged(old, new, loaded)
	if new == "" then
		return
	end

	CompileString(new, "cc2.GlobalLua")()
end

function GM:OnMapLuaChanged(old, new, loaded)
	if new == "" then
		return
	end

	CompileString(new, "cc2.MapLua")()
end

if SERVER then
	netstream.Hook("DevEditorSubmit", function(ply, code, map)
		if Access.SecureDeveloper(ply, "DevEditor") then
			return
		end

		if map == nil then
			GAMEMODE:SetGlobalLua(code)
		elseif map == game.GetMap() then
			GAMEMODE:SetMapLua(code)
		else
			if code == "" then
				GAMEMODE.Database:Query("DELETE FROM `rp_globals` WHERE `Map` = :map AND `Key` = 'MapLua'", {
					map = map
				})
			else
				GAMEMODE.Database:Query("INSERT INTO `rp_globals` (`Map`, `Key`, `Value`) VALUES (:map, 'MapLua', :value) ON DUPLICATE KEY UPDATE `Value` = :value", {
					map = map,
					value = sfs.encode(code)
				})
			end
		end
	end)
end
