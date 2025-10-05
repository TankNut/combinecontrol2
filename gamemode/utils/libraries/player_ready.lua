local PLAYER = FindMetaTable("Player")

function PLAYER:IsClientReady()
	return CLIENT and tobool(net.Ready) or tobool(net.Ready[self])
end

if CLIENT then
	net.Receive("PlayerReady", function()
		net.Ready = true

		hook.Run("OnPlayerReady", lp)
	end)
else
	gameevent.Listen("OnRequestFullUpdate")

	util.AddNetworkString("PlayerReady")

	net.Ready = net.Ready or {}

	hook.Add("OnRequestFullUpdate", "player_ready", function(data)
		local ply = Player(data.userid)

		if net.Ready[ply] then
			return
		end

		net.Ready[ply] = true

		net.Start("PlayerReady")
		net.Send(ply)

		hook.Run("OnPlayerReady", ply)
	end)
end
