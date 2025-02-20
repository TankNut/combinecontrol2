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

local allowedChars = "!?#abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 .-'áàâäçéèêëíìîïóòôöúùûüÿÁÀÂÄßÇÉÈÊËÍÌÎÏÓÒÔÖÚÙÛÜŸ"

function GM:CheckNameValidity(name)
	for _, char in pairs(string.Explode("", name)) do
		if not string.find(allowedChars, char, 1, true) then
			return false
		end
	end
	return true
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

function util.TimeSinceDate(d)
	if not d or d == "" then return 0 end

	local c = os.date("!*t")

	local sides = string.Explode(" ", d)
	local d2 = string.Explode("/", sides[1])
	local t2 = string.Explode(":", sides[2])

	local cmonth = tonumber(d2[1])
	local cday = tonumber(d2[2])
	local cyear = tonumber(d2[3])
	local chour = tonumber(t2[1])
	local cmin = tonumber(t2[2])
	local csec = tonumber(t2[3])

	c.year = c.year - 2000

	local count = (c.year - cyear) * 525600
	count = count + (c.month - cmonth) * 43200
	count = count + (c.day - cday) * 1440
	count = count + (c.hour - chour) * 60
	count = count + (c.min - cmin)
	count = count + math.ceil((c.sec - csec) / 60)

	return count
end

GM.Music = {
	{"music/hl1_song3.mp3", 131, SONG_IDLE, "Black Mesa Inbound"},
}

GM.TRPMusic = {
	{"terminator/t1title.mp3",			137,	SONG_IDLE,	"T1 - Future War Theme"},
	{"terminator/t1theme.mp3",			256,	SONG_IDLE,	"T1 - Future Classic Theme"},
	{"terminator/bunker.mp3",			66,		SONG_IDLE,	"T1 - Future Flashback"},
	{"terminator/lovescene.mp3",		225,	SONG_IDLE,	"T1 - Love Scene"},
	{"terminator/destiny.mp3",			184,	SONG_IDLE,	"T1 - Sarah's Destiny"},
	{"terminator/surgery.mp3",			95,		SONG_IDLE,	"T1 - T800 Surgery"},
	{"terminator/wade.mp3",				136,	SONG_IDLE,	"T1 - T800 Arrival"},
	{"terminator/chase.mp3",			85,		SONG_IDLE,	"T1 - Chase Scene"},
	{"terminator/t2maintheme.mp3",		118,	SONG_IDLE,	"T2 - Main Theme"},
	{"terminator/desert.mp3",			208,	SONG_IDLE,	"T2 - Desert"},
	{"terminator/dysonattack.mp3",		249,	SONG_IDLE,	"T2 - Attack on Dyson"},
	{"terminator/goodbye.mp3",			276,	SONG_IDLE,	"T2 - Goodbye"},
	{"terminator/heavy.mp3",			99,		SONG_IDLE,	"T2 - Trust Me"},
	{"terminator/freeze.mp3",			183,	SONG_IDLE,	"T2 - T1000 Frozen"},
	{"terminator/impaled.mp3",			126,	SONG_IDLE,	"T2 - T800 Impaled"},
	{"terminator/illbeback.mp3",		240,	SONG_IDLE,	"T2 - I'll Be Back"},
	{"terminator/nucleardream.mp3",		111,	SONG_IDLE,	"T2 - Nuclear Nightmare"},
	{"terminator/revives.mp3",			135,	SONG_IDLE,	"T2 - T800 Revives"},
	{"terminator/swat.mp3",				205,	SONG_IDLE,	"T2 - SWAT Team Attack"},
	{"terminator/t1000.mp3",			109,	SONG_IDLE,	"T2 - Hospital Escape"},
	{"terminator/t4title.mp3",			100,	SONG_IDLE,	"Salvation - Opening Theme"},
	{"terminator/broadcast.mp3",		199,	SONG_IDLE,	"Salvation - Broadcast"},
	{"terminator/escape.mp3",			81,		SONG_IDLE,	"Salvation - Escape"},
	{"terminator/farewell.mp3",			100,	SONG_IDLE,	"Salvation - Farewell"},
	{"terminator/freeside.mp3",			91,		SONG_IDLE,	"Salvation - Fireside"},
	{"terminator/plan.mp3",				103,	SONG_IDLE,	"Salvation - No Plan"},
	{"terminator/salvation.mp3",		187,	SONG_IDLE,	"Salvation - Salvation"},
	{"terminator/serena.mp3",			148,	SONG_IDLE,	"Salvation - Serena"},
	{"terminator/solution.mp3",			104,	SONG_IDLE,	"Salvation - Solution"},
	{"terminator/shortopen.mp3",		141,	SONG_IDLE,	"Salvation - Short Open Theme"},
	{"terminator/marcusenters.mp3",		49,		SONG_IDLE,	"Salvation - Marcus Enters Skynet"},
	{"terminator/skynetlab.mp3",		27,		SONG_IDLE,	"Salvation - Skynet Lab"},
	{"terminator/reveal.mp3",			46,		SONG_IDLE,	"Salvation - Reveal"},
	{"terminator/arrivaltoearth.mp3",	186,	SONG_IDLE,	"Transformers - Arrival to Earth"},
	{"terminator/autobots.mp3",			152,	SONG_IDLE,	"Transformers - Autobots"},
	{"terminator/flight.mp3",			85,		SONG_IDLE,	"Transformers - Scorponok"},
	{"terminator/soldier.mp3",			67,		SONG_IDLE,	"Transformers - You're A Soldier Now"},
	{"terminator/weweregods.mp3",		197,	SONG_IDLE,	"Transformers - We Were Gods Once"},
	{"terminator/shockwave.mp3",		117,	SONG_IDLE,	"Transformers - Shockwave"},
	{"terminator/frenzy.mp3",			102,	SONG_IDLE,	"Transformers - Frenzy"},
	{"terminator/farcrycommando.mp3",	133,	SONG_IDLE,	"Far Cry - Cyber Commando"},
	{"terminator/farcryhelo.mp3",		78,		SONG_IDLE,	"Far Cry - Helo-73"},
	{"terminator/farcryrex.mp3",		109,	SONG_IDLE,	"Far Cry - Rex Colt"},
	{"terminator/farcrytheme.mp3",		117,	SONG_IDLE,	"Far Cry - Blood Dragon theme"},
	{"terminator/farcrywarcry.mp3",		145,	SONG_IDLE,	"Far Cry - Warcry"},
	{"terminator/farcrywarzone.mp3",	158,	SONG_IDLE,	"Far Cry - Warzone"},
	{"terminator/farcrycalm.mp3",		207,	SONG_IDLE,	"Far Cry - Moment Of Calm"},
	{"terminator/rock.mp3",				140,	SONG_IDLE,	"The Rock - Rock House Jail"},
	{"terminator/rock2.mp3",			48,		SONG_IDLE,	"The Rock - Navy Seals"},
	{"terminator/edgewakeup.mp3",		105,	SONG_IDLE,	"Edge of Tomorrow - Find me when you Wake Up"},
	{"terminator/edgebeach.mp3",		120,	SONG_IDLE,	"Edge of Tomorrow - The Beach"},
	{"terminator/elysiumkruger.mp3",	96,		SONG_IDLE,	"Elysium - Kruger Suits Up"},
	{"terminator/elysiumfire.mp3",		26,		SONG_IDLE,	"Elysium - Fire and Water - part1"},
	{"terminator/elysiumwater.mp3",		41,		SONG_IDLE,	"Elysium - Fire and Water - part2"},
	{"terminator/prepare.mp3",			283,	SONG_IDLE,	"Predator - Prepare"},
	{"terminator/trumpet1.mp3",			87,		SONG_IDLE,	"Predator - Blaine's Burial"},
	{"terminator/trumpet2.mp3",			71,		SONG_IDLE,	"Predator - Night Watch"},
	{"terminator/darkknight.mp3",		115,	SONG_IDLE,	"Dark Knight - End Theme"},
	{"terminator/dogstart.mp3",			112,	SONG_IDLE,	"Dark Knight - Dog Chasing Cars"},
	{"terminator/dog.mp3",				116,	SONG_IDLE,	"Dark Knight - Dog Chasing Cars (part 2)"},
	{"terminator/electro.mp3",			38,		SONG_IDLE,	"Black Hawk Down - Wounded"},
	{"terminator/starship.mp3",			133,	SONG_IDLE,	"Starship Troopers - Main Theme"},
	{"terminator/runningman.mp3",		120,	SONG_IDLE,	"The Running Man - Main Theme"},
	{"terminator/factory.mp3",			71,		SONG_IDLE,	"Fear Factory - Metallic Division"},
	{"terminator/signal.mp3",			69,		SONG_IDLE,	"Fear Factory - Terminator Slams"},
	{"terminator/reptile.mp3",			61,		SONG_IDLE,	"Nine Inch Nails - Reptile"},
	{"terminator/gnr.mp3",				240,	SONG_IDLE,	"Guns N' Roses - You Could Be Mine"},
	{"terminator/lovesexmoney.mp3",		62,		SONG_IDLE,	"Gravity Kills - Love, Sex & Money"},
	{"terminator/watchtower.mp3",		125,	SONG_IDLE,	"Jimi Hendrix - All Along The Watchtower"},
	{"terminator/instinct.mp3",			53,		SONG_IDLE,	"Killer Instinct - The Instinct"},
}

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

function game.GetIP()
	local hostip = tonumber(GetConVarString("hostip"))

	local ip = {}
	ip[1] = bit.rshift(bit.band(hostip, 0xFF000000), 24)
	ip[2] = bit.rshift(bit.band(hostip, 0x00FF0000), 16)
	ip[3] = bit.rshift(bit.band(hostip, 0x0000FF00), 8)
	ip[4] = bit.band(hostip, 0x000000FF)

	return table.concat(ip, ".")
end

function game.GetPort()
	return tonumber(GetConVarString("hostport"))
end

function ParseChatLog(data)
	local format = ""
	local args = {}

	local function add(str, arg)
		format = format .. str
		table.insert(args, arg)
	end

	add("[%s", data.Class)

	if data.Lang then
		add(".%s] ", data.Lang)
	else
		add("] ")
	end

	if data.Freq then
		add("[%s MHz] ", data.Freq)
	end

	add("%s", data.Char.CharName)

	if data.RecChar then
		add(" -> %s", data.RecChar.CharName)
	end

	add(": %s", data.Text)

	return string.format(format, unpack(args))
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
