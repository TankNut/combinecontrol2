module("netstream", package.seeall)

Hooks = Hooks or {}
Cache = Cache or {}

MessageLimit = 60000 -- 60 KB
RateLimit = 180000 -- 0.18 MB/s

local logger = log.Create("netstream")

function Hook(name, callback)
	Hooks[name] = callback
	Cache[name] = {}
end

function Split(name, data)
	local encoded = sfs.encode(data)
	local length = #encoded

	if length < MessageLimit then
		return {{
			Data = encoded,
			Length = length
		}}, length
	end

	local payload = {}
	local count = math.ceil(length / MessageLimit)

	for i = 1, count do
		local buffer = string.sub(encoded, MessageLimit * (i - 1) + 1, MessageLimit * i)

		payload[i] = {
			Data = buffer,
			Length = #buffer
		}
	end

	return payload, length
end

if CLIENT then
	function Send(name, ...)
		local data = {...}

		if #data == 0 then
			logger:Info("[%s] Sending notify to server", name)

			net.Start("NetstreamNotify")
				net.WriteString(name)
			net.SendToServer()

			return
		end

		local payload, size = Split(name, data)

		logger:Info("[%s] Sending %s to server", name, string.NiceSize(size))

		for k, v in ipairs(payload) do
			net.Start("Netstream")
				net.WriteString(name)
				net.WriteBool(k == #payload)
				net.WriteUInt(v.Length, 16)
				net.WriteData(v.Data, v.Length)
			net.SendToServer()
		end
	end

	function Read(name)
		local final = net.ReadBool()
		local payload = net.ReadData(net.ReadUInt(16))

		local cache = Cache[name]

		table.insert(cache, payload)

		logger:Debug("[%s] Received %s partial from server", name, string.NiceSize(#payload))

		if final then
			local raw = table.concat(cache)

			Cache[name] = {}

			return sfs.decode(raw), #raw
		end
	end

	net.Receive("Netstream", function()
		local name = net.ReadString()
		local callback = Hooks[name]

		if not callback then
			net.ReadBool() -- Discard
			logger:Warning("[%s] Discarding %s from server, no callback to run", name, string.NiceSize(net.ReadUInt(16)))

			return
		end

		local data, dataLen = Read(name)

		if data then
			logger:Info("[%s] Received %s from server", name, string.NiceSize(dataLen))

			async.Start(callback, unpack(data))
		end
	end)

	net.Receive("NetstreamNotify", function()
		local name = net.ReadString()
		local callback = Hooks[name]

		if not callback then
			logger:Warning("[%s] Discarding notify from server, no callback to run", name)

			return
		end

		logger.Info("[%s] Received notify from server", name)

		async.Start(callback)
	end)
else
	util.AddNetworkString("Netstream")
	util.AddNetworkString("NetstreamNotify")

	Queue = Queue or {}
	Rate = Rate or {}
	Ready = Ready or {}
	Limited = Limited or {}

	function GetTargets(targets)
		if not targets then
			return player.GetAll()
		elseif TypeID(targets) == TYPE_RECIPIENTFILTER then
			return targets:GetPlayers()
		elseif istable(targets) then
			local ply = next(targets)

			-- So we don't have to table.GetKeys ourselves constantly
			if isentity(ply) and ply:IsPlayer() then
				targets = table.GetKeys(targets)
			end

			return table.Unique(targets)
		else
			return {targets}
		end
	end

	function AddToQueue(name, final, payload, targets)
		local data = {
			Name = name,
			Final = final,
			Length = 4 + #name,
			Data = payload.Data
		}

		if payload then
			data.Length = data.Length + 3 + payload.Length
		end

		for _, ply in ipairs(targets) do
			if not IsValid(ply) or ply:IsBot() then
				continue
			end

			if not Queue[ply] then
				Queue[ply] = util.Queue()
			end

			Queue[ply]:Push(data)
		end
	end

	function Broadcast(name, ...)
		Send(nil, name, ...)
	end

	function Send(targets, name, ...)
		local data = {...}

		targets = GetTargets(targets)

		if #targets < 1 then
			logger:Info("[%s] Discarding message, no targets", name)

			return
		end

		local targetLog = #targets > 1 and #targets .. " targets" or targets[1]

		if not data then
			logger:Info("[%s] Adding notify to queue for %s", name, targetLog)

			AddToQueue(name, nil, nil, targets)
		end

		local payload, size = Split(name, data)

		logger:Info("[%s] Adding %s to queue for %s", name, string.NiceSize(size), targetLog)

		for k, v in ipairs(payload) do
			AddToQueue(name, k == #payload, v, targets)
		end
	end

	function Read(name, ply)
		local final = net.ReadBool()
		local payload = net.ReadData(net.ReadUInt(16))

		local cache = Cache[name]

		if not cache[ply] then
			cache[ply] = {}
		end

		table.insert(cache[ply], payload)

		logger:Debug("[%s] Received %s partial from %s", name, string.NiceSize(#payload), ply)

		if final then
			local raw = table.concat(cache[ply])

			cache[ply] = {}

			return sfs.decode(raw), #raw
		end
	end

	net.Receive("Netstream", function(_, ply)
		local name = net.ReadString()
		local callback = Hooks[name]

		if not callback then
			net.ReadBool() -- Discard
			logger:Warning("[%s] Discarding %s from %s, no callback to run", name, string.NiceSize(net.ReadUInt(16)), ply)

			return
		end

		local data, dataLen = Read(name, ply)

		if data then
			logger:Info("[%s] Received %s from %s", name, string.NiceSize(dataLen), ply)

			async.Start(callback, ply, unpack(data))
		end
	end)

	net.Receive("NetstreamNotify", function(_, ply)
		local name = net.ReadString()
		local callback = Hooks[name]

		if not callback then
			logger:Warning("[%s] Discarding notify from %s, no callback to run", name, ply)

			return
		end

		logger:Info("[%s] Received notify from %s", name, ply)

		async.Start(callback, ply)
	end)

	hook.Add("OnPlayerReady", "netstream", function(ply)
		Ready[ply] = true

		if Queue[ply] then
			local size = 0

			for _, v in pairs(netstream.Queue[ply].Items) do
				size = size + v.Length
			end

			logger:Info("%s is ready and has %s queued", ply, string.NiceSize(size))
		else
			logger:Info("%s is ready", ply)
		end
	end)

	hook.Add("Think", "netstream", function()
		for ply, queue in pairs(Queue) do
			if not IsValid(ply) then
				Queue[ply] = nil
				Rate[ply] = nil
				Ready[ply] = nil
				Limited[ply] = nil

				continue
			end

			if not Ready[ply] then
				continue
			end

			local rate = Rate[ply] or RateLimit

			if rate < RateLimit then
				rate = math.min(rate + (RateLimit * FrameTime()), RateLimit)
			end

			while queue:Count() > 0 do
				local peek = queue:Peek()

				if rate - peek.Length <= 0 then
					if not Limited[ply] then
						logger:Warning("[%s] Rate limit exceeded for %s", peek.Name, ply)

						Limited[ply] = true
					end

					break
				end

				local payload = queue:Pop()

				if payload.Data then
					net.Start("Netstream")
						net.WriteString(payload.Name)
						net.WriteBool(payload.Final)
						net.WriteUInt(#payload.Data, 16)
						net.WriteData(payload.Data, #payload.Data)

						rate = rate - net.BytesWritten()
					net.Send(ply)

					if payload.Final then
						Limited[ply] = nil
					end
				else
					net.Start("NetstreamNotify")
						net.WriteString(payload.Name)

						rate = rate - net.BytesWritten()
					net.Send(ply)

					Limited[ply] = nil
				end
			end

			Rate[ply] = rate
		end
	end)
end
