Action.Add("Patdown", {
	Name = "Pat Down",

	Target = ACTION_INTERACT,
	Filter = FILTER_PLAYER,

	Progress = function(target, ply)
		local endTime = CurTime() + 5

		if SERVER then
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
	Client = closeMenu,
	Callback = function(target, ply)
		local inventory = target:GetInventory()

		inventory:AddListener(ply, LISTENER_ENTITY)

		ply:OpenGUI("InventoryPopup", inventory.ID)
	end
})

if CLIENT then
	netstream.Hook("InformPatdown", function(ply, endTime)
		progress.Start({
			Name = "Being pat down...",
			EndTime = endTime,
			Validate = {
				progress.Player(ply, {Alive = true}),
				progress.Player(lp, {Alive = true})
			}
		})
	end)
end
