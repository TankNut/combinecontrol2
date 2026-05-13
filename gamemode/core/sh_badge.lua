module("Badge", package.seeall)

List = List or {}

local PLAYER = FindMetaTable("Player")

PlayerVar.Add("CustomBadges", {
	Default = {},
	Private = false,
	Persist = true,
	DataType = BLOB()
})

function Add(id, name, order, material, callback)
	List[id] = {
		ID = id,
		Name = name,
		Order = order or 0,
		Material = Material(material),
		Callback = callback,
		Automated = tobool(callback)
	}
end

function Get(id)
	return List[id]
end

function PLAYER:GetBadges()
	local custom = self:CustomBadges()
	local badges = {}

	for id, badge in pairs(Badge.List) do
		if (badge.Automated and badge.Callback(self)) or custom[id] then
			table.insert(badges, badge)
		end
	end

	table.sort(badges, function(a, b)
		if a.Order == b.Order then
			-- Sort alphabetically
			return a.ID < b.ID
		end

		-- Left to right, high to low
		return a.Order > b.Order
	end)

	return badges
end

function PLAYER:HasBadge(id)
	local badge = Badge.Get(id)

	if not badge then
		return false
	end

	return badge.Automated and tobool(badge.Callback(self)) or tobool(self:CustomBadges()[id])
end

if SERVER then
	function PLAYER:GiveBadge(id)
		local badge = Badge.Get(id)

		if badge.Automated then
			return
		end

		local badges = self:CustomBadges()

		badges[id] = true

		self:SetCustomBadges(badges)
	end

	function PLAYER:TakeBadge(id)
		local badge = Badge.Get(id)

		if badge.Automated then
			return
		end

		local badges = self:CustomBadges()

		badges[id] = nil

		self:SetCustomBadges(badges)
	end
end
