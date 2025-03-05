-- 5/25/2013

DeriveGamemode("sandbox")

GM.Name = "CombineControl: TnB"
GM.Author = "Taco N Banana"
GM.Website = "http://taconbanana.com"
GM.Email = "gangleider@taconbanana.com"

function GM:GetGameDescription()
	return self.Name
end

local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

stub = function() end -- Used in several places, might as well make it global

function PLAYER:IsFemale(mdl)
	return self:Gender(mdl) == "female"
end

function PLAYER:Gender(mdl)
	return util.GetModelGender(mdl or self:GetModel())
end

function GM:FindPlayer(name, caller)
	if not name then
		return
	end

	name = string.lower(name)

	if name == "^" and IsValid(caller) then
		return caller
	end

	if name == "-" and IsValid(caller) then
		local ent = caller:GetEyeTrace().Entity

		if IsValid(ent) and (ent:IsPlayer()) then
			return ent
		end

		return
	end

	for k, v in player.Iterator() do
		if string.find(string.lower(v:VisibleRPName()), name, nil, true) then
			return v
		end

		if (not IsValid(caller) or caller:IsAdmin()) and string.find(string.lower(v:Nick()), name, nil, true) then
			return v
		end

		if (not IsValid(caller) or caller:IsAdmin()) and string.lower(v:SteamID()) == name then
			return v
		end
	end
end

local fontCache = {}
local function getCharWidth(char, fc)
	if not fc[char] then
		fc[char] = surface.GetTextSize(char)
	end
	return fc[char]
end

function GM:FormatText(str, font, maxWidth, indent)
	str = string.gsub(str:Trim(), "\r", "")
	if #str <= 1 then return {str} end

	surface.SetFont(font)
	if not fontCache[font] then
		fontCache[font] = {}
	end
	local fc = fontCache[font]
	indent = indent and getCharWidth("  ", fc)

	local t = string.ToTable(str)
	local i, len, start, lastSpace = 1, #str, 1
	local curWidth = indent or 0
	local res = {}

	local indentNextLine = false
	while i <= len do
		local c = t[i]
		local isBreak = c == "\n"
		local width = getCharWidth(c, fc)

		if isBreak or curWidth + width + (#res > 0 and indent or 0) > maxWidth then
			local stop = isBreak and i or lastSpace or i - 1

			local line = string.Trim(str:sub(start, stop))
			res[#res + 1] = (indentNextLine and "  " or "") .. line

			start = str:find("[%S\r\n]", stop + 1)
			if not start then
				return res
			end
			lastSpace = nil
			i = start
			curWidth = 0

			indentNextLine = indent and not isBreak
		else
			curWidth = curWidth + width
			if i == len then
				local line = string.Trim(str:sub(start))
				res[#res + 1] = (indentNextLine and " " or "") .. line
			elseif c:match("[^%w_\"'%.]") then
				lastSpace = i
			end
			i = i + 1
		end
	end

	return res
end

function GM:FormatLine(str, font, maxWidth)
	local t = self:FormatText(str, font, maxWidth)
	return table.concat(t, "\n"), #t
end

function ENTITY:IsDoor()
	if self:GetClass() == "prop_door_rotating" then return true end
	if self:GetClass() == "func_door_rotating" then return true end
	if self:GetClass() == "func_door" then return true end

	return false
end

function GM:ShouldCollide(e1, e2)
	return true
end

function GM:GetHandTrace(ply, len)
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * (len or 50)
	trace.filter = ply

	return util.TraceLine(trace)
end

GM.Music = {
	{"music/hl1_song3.mp3", 131, SONG_IDLE, "Black Mesa Inbound"},
}

GM.TRPMusic = {}

GM.EP2Music = {
	{"music/vlvx_song26.mp3", 110, SONG_IDLE, "Inhuman Frequency"},
}

function GM:GetSongList(e)
	local tab = {}

	for _, v in pairs(self.Music) do

		if v[3] == e then

			table.insert(tab, v[1])

		end

	end

	return tab
end

-- Maps a yaw to 0 -> 360
function math.AngleToHeading(yaw)
	return (-yaw % 360) + 360 % 360
end

-- Takes a heading and returns the compass direction
function GM:GetHeading(heading)
	local northSouth = (heading < 67.5 or heading > 292.5) and "N" or
		(heading > 112.5 and heading < 247.5) and "S" or ""

	local eastWest = (heading > 22.5 and heading < 157.5) and "E" or
		(heading > 202.5 and heading < 337.5) and "W" or ""

	return northSouth .. eastWest
end
