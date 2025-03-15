module("Team", package.seeall)

List = {}

function Add(name, color, hidden)
	return table.insert(List, {
		Name = name,
		Color = color,
		Hidden = tobool(hidden)
	})
end

function Team.IsHidden(id)
	return List[id] and List[id].Hidden or false
end

function GM:CreateTeams()
	for id, data in ipairs(List) do
		team.SetUp(id, data.Name, data.Color, false)
	end
end
