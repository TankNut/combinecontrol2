local COLOR = FindMetaTable("Color")

COLOR.colors = COLOR.colors or {
	aliceblue = {240, 248, 255},
	antiquewhite = {250, 235, 215},
	aqua = {0, 255, 255},
	aquamarine = {127, 255, 212},
	azure = {240, 255, 255},
	beige = {245, 245, 220},
	bisque = {255, 228, 196},
	black = {0, 0, 0},
	blanchedalmond = {255, 235, 205},
	blue = {0, 0, 255},
	blueviolet = {138, 43, 226},
	brown = {165, 42, 42},
	burlywood = {222, 184, 135},
	cadetblue = {95, 158, 160},
	chartreuse = {127, 255, 0},
	chocolate = {210, 105, 30},
	coral = {255, 127, 80},
	cornflowerblue = {100, 149, 237},
	cornsilk = {255, 248, 220},
	crimson = {220, 20, 60},
	cyan = {0, 255, 255},
	darkblue = {0, 0, 139},
	darkcyan = {0, 139, 139},
	darkgoldenrod = {184, 134, 11},
	darkgray = {169, 169, 169},
	darkgrey = {169, 169, 169},
	darkgreen = {0, 100, 0},
	darkkhaki = {189, 183, 107},
	darkmagenta = {139, 0, 139},
	darkolivegreen = {85, 107, 47},
	darkorange = {255, 140, 0},
	darkorchid = {153, 50, 204},
	darkred = {139, 0, 0},
	darksalmon = {233, 150, 122},
	darkseagreen = {143, 188, 143},
	darkslateblue = {72, 61, 139},
	darkslategray = {47, 79, 79},
	darkslategrey = {47, 79, 79},
	darkturquoise = {0, 206, 209},
	darkviolet = {148, 0, 211},
	deeppink = {255, 20, 147},
	deepskyblue = {0, 191, 255},
	dimgray = {105, 105, 105},
	dimgrey = {105, 105, 105},
	dodgerblue = {30, 144, 255},
	firebrick = {178, 34, 34},
	floralwhite = {255, 250, 240},
	forestgreen = {34, 139, 34},
	fuchsia = {255, 0, 255},
	gainsboro = {220, 220, 220},
	ghostwhite = {248, 248, 255},
	gold = {255, 215, 0},
	goldenrod = {218, 165, 32},
	gray = {128, 128, 128},
	grey = {128, 128, 128},
	green = {0, 128, 0},
	greenyellow = {173, 255, 47},
	honeydew = {240, 255, 240},
	hotpink = {255, 105, 180},
	indianred = {205, 92, 92},
	indigo = {75, 0, 130},
	ivory = {255, 255, 240},
	khaki = {240, 230, 140},
	lavender = {230, 230, 250},
	lavenderblush = {255, 240, 245},
	lawngreen = {124, 252, 0},
	lemonchiffon = {255, 250, 205},
	lightblue = {173, 216, 230},
	lightcoral = {240, 128, 128},
	lightcyan = {224, 255, 255},
	lightgoldenrodyellow = {250, 250, 210},
	lightgray = {211, 211, 211},
	lightgrey = {211, 211, 211},
	lightgreen = {144, 238, 144},
	lightpink = {255, 182, 193},
	lightsalmon = {255, 160, 122},
	lightseagreen = {32, 178, 170},
	lightskyblue = {135, 206, 250},
	lightslategray = {119, 136, 153},
	lightslategrey = {119, 136, 153},
	lightsteelblue = {176, 196, 222},
	lightyellow = {255, 255, 224},
	lime = {0, 255, 0},
	limegreen = {50, 205, 50},
	linen = {250, 240, 230},
	magenta = {255, 0, 255},
	maroon = {128, 0, 0},
	mediumaquamarine = {102, 205, 170},
	mediumblue = {0, 0, 205},
	mediumorchid = {186, 85, 211},
	mediumpurple = {147, 112, 219},
	mediumseagreen = {60, 179, 113},
	mediumslateblue = {123, 104, 238},
	mediumspringgreen = {0, 250, 154},
	mediumturquoise = {72, 209, 204},
	mediumvioletred = {199, 21, 133},
	midnightblue = {25, 25, 112},
	mintcream = {245, 255, 250},
	mistyrose = {255, 228, 225},
	moccasin = {255, 228, 181},
	navajowhite = {255, 222, 173},
	navy = {0, 0, 128},
	oldlace = {253, 245, 230},
	olive = {128, 128, 0},
	olivedrab = {107, 142, 35},
	orange = {255, 165, 0},
	orangered = {255, 69, 0},
	orchid = {218, 112, 214},
	palegoldenrod = {238, 232, 170},
	palegreen = {152, 251, 152},
	paleturquoise = {175, 238, 238},
	palevioletred = {219, 112, 147},
	papayawhip = {255, 239, 213},
	peachpuff = {255, 218, 185},
	peru = {205, 133, 63},
	pink = {255, 192, 203},
	plum = {221, 160, 221},
	powderblue = {176, 224, 230},
	purple = {128, 0, 128},
	rebeccapurple = {102, 51, 153},
	red = {255, 0, 0},
	rosybrown = {188, 143, 143},
	royalblue = {65, 105, 225},
	saddlebrown = {139, 69, 19},
	salmon = {250, 128, 114},
	sandybrown = {244, 164, 96},
	seagreen = {46, 139, 87},
	seashell = {255, 245, 238},
	sienna = {160, 82, 45},
	silver = {192, 192, 192},
	skyblue = {135, 206, 235},
	slateblue = {106, 90, 205},
	slategray = {112, 128, 144},
	slategrey = {112, 128, 144},
	snow = {255, 250, 250},
	springgreen = {0, 255, 127},
	steelblue = {70, 130, 180},
	tan = {210, 180, 140},
	teal = {0, 128, 128},
	thistle = {216, 191, 216},
	tomato = {255, 99, 71},
	turquoise = {64, 224, 208},
	violet = {238, 130, 238},
	wheat = {245, 222, 179},
	white = {255, 255, 255},
	whitesmoke = {245, 245, 245},
	yellow = {255, 255, 0},
	yellowgreen = {154, 205, 50},
	transparent = {255, 255, 255, 0}
}

function util.GetColorTable()
	return COLOR.colors
end

local function component(val)
	return math.Clamp(tonumber(val) or 255, 0, 255)
end

function Color(r, g, b, a)
	if istable(r) then -- Allow copying like vectors
		return setmetatable({
			r = component(r.r),
			g = component(r.g),
			b = component(r.b),
			a = component(g != nil and g or r.a)
		}, COLOR)
	end

	if isstring(r) and not tonumber(r) then
		if r[1] == "#" then
			return HexToColor(r) or setmetatable({
				r = 255,
				g = 255,
				b = 255,
				a = 255
			}, COLOR)
		end

		local match = COLOR.colors[string.lower(r)]

		if match then
			return setmetatable({
				r = match[1],
				g = match[2],
				b = match[3],
				a = match[4] != nil and match[4] or component(g)
			}, COLOR)
		end

		local explode = string.Explode("[,%s]+", r, true)

		r, g, b, a = explode[1], explode[2], explode[3], explode[4]
	end

	return setmetatable({
		r = component(r),
		g = component(g),
		b = component(b),
		a = component(a)
	}, COLOR)
end

function COLOR:Register(name)
	if not istable(name) then
		name = {name}
	end

	for _, v in pairs(name) do
		COLOR.colors[v] = {self.r, self.g, self.b, self.a < 255 and self.a or nil}
	end

	return self
end

function COLOR:GetInverted()
	return Color(255, - self.r, 255 - self.g, 255 - self.b, self.a)
end

function COLOR:GetTriadic()
	local h, s, v = ColorToHSV(self)

	return self, HSVToColor((h - 120) % 360, s, v), HSVToColor((h + 120) % 360, s, v)
end

function COLOR:GetMonochrome(steps, full)
	local h, s = ColorToHSL(self)
	local ret = {}

	if full then
		steps = steps - 1

		for i = 0, steps do
			table.insert(ret, HSLToColor(h, s, i / steps))
		end
	else
		steps = steps + 1

		for i = 1, steps - 1 do
			table.insert(ret, HSLToColor(h, s, i / steps))
		end
	end

	return ret
end

function COLOR:UnpackToVector()
	return self.r / 255, self.g / 255, self.b / 255, self.a / 255
end

function COLOR:Set(color)
	self.r = color.r
	self.g = color.g
	self.b = color.b
	self.a = color.a
end
