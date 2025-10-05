module("request", package.seeall)

Pending = Pending or {}

local logger = log.Create("request")

if CLIENT then
	function Hook(name, callback)
		netstream.Hook(name, function(payload)
			logger:Info("[%s] Incoming request from server with payload ID: %s", name, payload.ID)

			netstream.Send("Request", {
				ID = payload.ID,
				Data = {callback(unpack(payload.Data))}
			})
		end)
	end

	function Send(name, ...)
		local cr = async.Assert()
		local id = table.insert(Pending, cr)

		logger:Info("[%s] Outgoing request to server with payload ID: %s", name, id)

		netstream.Send(name, {
			ID = id,
			Data = {...}
		})

		return coroutine.yield()
	end

	netstream.Hook("Request", function(payload)
		logger:Info("Incoming response from server with payload ID: %s", payload.ID)

		local cr = Pending[payload.ID]

		if not cr then
			logger:Warning("Received invalid request response from server with payload ID: %s", payload.Index)

			return
		end

		Pending[payload.ID] = nil

		async.Handle(cr, unpack(payload.Data))
	end)
else
	function Hook(name, callback)
		netstream.Hook(name, function(ply, payload)
			logger:Info("[%s] Incoming request from %s with payload ID: %s", name, ply, payload.ID)

			netstream.Send(ply, "Request", {
				ID = payload.ID,
				Data = {callback(ply, unpack(payload.Data))}
			})
		end)
	end

	function Send(ply, name, ...)
		local cr = async.Assert()

		if not Pending[ply] then
			Pending[ply] = {}
		end

		local id = table.insert(Pending[ply], cr)

		logger:Info("[%s] Outgoing request to %s with payload ID: %s", name, ply, id)

		netstream.Send(ply, name, {
			ID = id,
			Data = {...}
		})

		return coroutine.yield()
	end

	netstream.Hook("Request", function(ply, payload)
		local pending = Pending[ply]

		if not pending then
			logger:Warning("Received invalid request response from %s with payload ID: %s", ply, payload.ID)

			return
		end

		local cr = pending[payload.ID]

		if not cr then
			logger:Warning("Received invalid request response from %s with payload ID: %s", ply, payload.ID)

			return
		end

		pending[payload.ID] = nil

		async.Handle(cr, unpack(payload.Data))
	end)

	hook.Add("PlayerDisconnected", "request", function(ply)
		Pending[ply] = nil
	end)
end
