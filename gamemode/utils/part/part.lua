module("part", package.seeall)

Outfits = Outfits or {}

function Add(ent, name, data)
	Remove(ent, name)

	local outfit = inherit.Instance("part", "outfit")
	outfit:Initialize(ent, name, table.Copy(data))

	Outfits[outfit] = ent
end

function Get(ent)
	local tab = {}

	for outfit, owner in pairs(Outfits) do
		if owner == ent then
			tab[outfit.Name] = outfit
		end
	end

	return tab
end

function Remove(ent, name)
	for outfit, owner in pairs(Outfits) do
		if owner == ent and outfit.Name == name then
			Outfits[outfit] = nil
			outfit:Remove()
		end
	end
end

function Clear(ent)
	for outfit, owner in pairs(Outfits) do
		if owner == ent then
			Outfits[outfit] = nil
			outfit:Remove()
		end
	end
end

function Copy(from, to)
	for outfit, owner in pairs(Outfits) do
		if owner == from then
			Add(to, outfit.Name, outfit.Data)
		end
	end
end

function Move(from, to)
	for outfit, owner in pairs(Outfits) do
		if owner == from then
			Add(to, outfit.Name, outfit.Data)
			outfit:Remove()
		end
	end
end

function Draw(ent, renderMode)
	for outfit, owner in pairs(Outfits) do
		if owner == ent then
			outfit:Draw(renderMode)
		end
	end
end

function Call(name, ...)
	for outfit, owner in pairs(Outfits) do
		if not IsValid(owner) and owner != game.GetWorld() then
			outfit:Remove()
			Outfits[outfit] = nil

			continue
		end

		outfit[name](outfit, ...)
	end
end

hook.Add("Think", "tacolib.part", function()
	Call("Think")
end)

hook.Add("EntityRemoved", "tacolib.part", function(ent)
	jank(function()
		if not IsValid(ent) then
			Clear(ent)
		end
	end)
end)

hook.Add("CreateClientsideRagdoll", "tacolib.part", Copy)

hook.Add("PostDrawTranslucentRenderables", "tacolib.part", function()
	Call("Draw", "translucent")
end)
