surface.GetFontSize = Memoize(function(font, str)
	surface.SetFont(font)

	return surface.GetTextSize(str)
end)

surface.GetFontHeight = function(font)
	local _, h = surface.GetFontSize(font, " ")

	return h
end
