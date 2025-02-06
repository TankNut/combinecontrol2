module("Badge", package.seeall)

Lookup = Lookup or {}

local PLAYER = FindMetaTable("Player")

PlayerVar.Add("CustomBadges", {
	Default = {},
	Private = false,
	Persist = true,
	DataType = BLOB()}
)

function Load()
	List = GM.Badges

	for _, data in ipairs(List) do
		Lookup[data.ID] = data
	end
end

function Get(id)
	return Lookup[id]
end

function PLAYER:GetBadges()
	local custom = self:CustomBadges()
	local badges = {}

	for _, badge in pairs(Badge.List) do
		if (badge.Automated and badge.Callback(self)) or custom[badge.ID] then
			table.insert(badges, badge)
		end
	end

	return badges
end

function PLAYER:HasBadge(id)
	local badge = Badge.Get(id)

	if badge.Automated then
		return tobool(badge.Callback(self))
	else
		return tobool(self:CustomBadges()[badge.ID])
	end
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

		if table.IsEmpty(badges) then
			self:SetCustomBadges({})
		else
			self:SetCustomBadges(badges)
		end
	end
end
