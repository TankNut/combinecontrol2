function string.Filename(path)
	if string.Right(path, 1) == "/" then
		path = string.sub(path, 1, -2)
	end

	return string.StripExtension(string.GetFileFromFilename(path))
end

function string.FirstToUpper(str)
	return string.gsub(str, "^%l", string.upper)
end

function string.LastSpace(str)
	for i = #str, 1, -1 do
		if str[i] == " " then
			return i
		end
	end
end

local escapeEntities = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;"
}

local unescapeEntities = {
	["&amp;"] = "&",
	["&lt;"] = "<",
	["&gt;"] = ">"
}

function string.Escape(str)
	return string.gsub(tostring(str), "[&<>]", escapeEntities)
end

function string.Unescape(str)
	return string.gsub(tostring(str), "(&.-;)", unescapeEntities)
end

function string.Gibberish(str, prob)
	local ret = ""

	for _, v in ipairs(string.Explode("", str)) do
		if math.random(1, 100) < prob then
			v = ""

			for i = 1, math.random(0, 2) do
				ret = ret .. table.Random({"#", "@", "&", "%", "$", "/", "^", "-", ";", "*", "*", "*", "*", "*", "*", "*", "*"})
			end
		end

		ret = ret .. v
	end

	return ret
end
