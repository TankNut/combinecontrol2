function string.FileName(path)
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
