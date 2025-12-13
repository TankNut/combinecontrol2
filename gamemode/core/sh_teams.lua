module("Team", package.seeall)

List = {}

GlobalVar.Add("HiddenTeams", {
	Default = {},
	Persist = true
})

function Add(id, name, color)
	color:Register("team_" .. id)

	return table.insert(List, {
		ID = id,
		Name = name,
		Color = color
	})
end

function Get(enum)
	return List[enum]
end

function IsHidden(enum)
	return GAMEMODE:HiddenTeams()[enum] or false
end

function GM:CreateTeams()
	for enum, data in ipairs(List) do
		team.SetUp(enum, data.Name, data.Color, false)
	end
end

if SERVER then
	function SetHidden(enum, shouldHide)
		local hidden = GAMEMODE:HiddenTeams()

		if shouldHide then
			hidden[enum] = true
		else
			hidden[enum] = nil
		end

		GAMEMODE:SetHiddenTeams(hidden)
	end
end
