--[[ Unbreakable STool
     Date   : 28 janvier 2007    Date   : 04 December 2013
     Auteur : Chaussette™        Author : XxWestKillzXx
]]

TOOL.Category = "Construction"
TOOL.Name     = "#tool.unbreakable.name"

if CLIENT then
	TOOL.Information = {
		{ name = "left" },
		{ name = "right" }
	}

	language.Add("tool.unbreakable.name", "Unbreakable")
	language.Add("tool.unbreakable.desc", "Make a prop unbreakable")
	language.Add("tool.unbreakable.panel", "Make a prop unbreakable")
	language.Add("tool.unbreakable.left", "Select an object to make unbreakable")
	language.Add("tool.unbreakable.right", "Restore the previous settings of an object")
else
	hook.Add("InitPostEntity", "unbreakable", function()
		local filter = ents.Create("filter_activator_name")

		filter:SetKeyValue("TargetName", "CCFilterDamage")
		filter:SetKeyValue("negated", "1")
		filter:Spawn()

		GAMEMODE.UnbreakableFilter = filter
	end)
end

local function SetUnbreakable(ent, unbreakable)
	local filter = unbreakable and "CCFilterDamage" or ""

	ent:SetVar("Unbreakable", unbreakable)
	ent:Fire("SetDamageFilter", filter, 0)
end

function TOOL:LeftClick(tr)
	local ent = tr.Entity

	if not IsValid(ent) then
		return false
	end

	if SERVER then
		SetUnbreakable(ent, true)
	end

	return true
end

function TOOL:RightClick(tr)
	local ent = tr.Entity

	if not IsValid(ent) then
		return false
	end

	if SERVER then
		SetUnbreakable(ent, false)
	end

	return true
end

function TOOL:Reload(tr)
	return false
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", {
		Text = "#tool.unbreakable.name",
		Description = "#tool.unbreakable.panel"
	})
end
