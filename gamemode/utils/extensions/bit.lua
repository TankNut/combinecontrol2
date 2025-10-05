function bit.Check(val, flag)
	return bit.band(val, flag) == flag
end

function bit.Set(val, flag)
	return bit.bor(val, flag)
end

function bit.Unset(val, flag)
	return bit.band(val, bit.bnot(flag))
end

function bit.Pack(bitCount, ...)
	local args = {...}

	assert(#args * bitCount <= 32, "bitCount exceeds possible limit")

	local limit = 2 ^ bitCount - 1
	local num = 0

	for k, v in ipairs(args) do
		num = num + bit.lshift(math.Clamp(v, 0, limit), (k - 1) * bitCount)
	end

	return num
end

function bit.Unpack(bitCount, num)
	assert(bitCount <= 32, "bitCount exceeds possible limit")

	local count = math.floor(32 / bitCount)
	local returns = {}
	local limit = 2 ^ bitCount - 1

	for i = 1, count do
		returns[i] = bit.band(bit.rshift(num, bitCount * (i - 1)), limit)
	end

	return unpack(returns)
end
