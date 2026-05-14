Action.Add("Patdown", {
	Name = "Pat Down",

	Target = ACTION_INTERACT,
	Filter = FILTER_PLAYER,

	Progress = function(target, ply)
		local endTime = CurTime() + 5

		if SERVER then
			ply:VisibleMessage("NOTICE", string.format("%s starts patting down %s", ply:VisibleRPName(), target:VisibleRPName()))

			netstream.Send(target, "InformPatdown", ply, endTime)
		end

		return {
			Name = "Patting Down...",
			EndTime = CurTime() + 5,
			Validate = {
				progress.Player(target, {Alive = true}),
				progress.Player(ply, {Alive = true})
			},
			Callback = CLIENT and stub or nil
		}
	end,
	Client = function(self, ply, ...)
		if Settings.Get("EquipTogglesMenu") then
			ui.Close("PlayerMenu")
		end

		return true, ...
	end,
	Callback = function(target, ply)
		local inventory = target:GetInventory()

		inventory:AddListener(ply, LISTENER_ENTITY)

		ply:OpenGUI("InventoryPopup", inventory.ID)
	end
})

if CLIENT then
	netstream.Hook("InformPatdown", function(ply, endTime)
		progress.Start(ply, {
			Name = "Being pat down...",
			EndTime = endTime,
			Validate = {
				progress.Player(ply, {Alive = true}),
				progress.Player(lp, {Alive = true})
			}
		})
	end)
end
