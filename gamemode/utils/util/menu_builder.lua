function util.BuildMenu(data)
	local tree = {
		Lookup = {}
	}

	for _, def in ipairs(data) do
		local nodes = string.Explode("\t", def.Name)
		local node = tree

		for k, path in ipairs(nodes) do
			local name = string.match(path, "(.+)\a.+$") or path

			if #name > 0 and not node.Lookup[path] then
				local id = table.insert(node, {
					Name = name,
					Lookup = {}
				})

				node.Lookup[path] = id
			end

			if (def.Spacer == true and k == #nodes) or def.Spacer == k then
				table.insert(node, true)
			end

			if #name > 0 then
				node = node[node.Lookup[path]]
			end
		end

		node.Callback = def.Callback
	end

	local function recurse(node, dmenu)
		for _, child in ipairs(node) do
			if child == true then
				if dmenu:ChildCount() > 0 then
					dmenu:AddSpacer()
				end

				continue
			end

			if #child > 0 then
				local subMenu = dmenu:AddSubMenu(child.Name, child.Callback)

				recurse(child, subMenu)
			else
				dmenu:AddOption(child.Name, child.Callback)
			end
		end
	end

	local baseMenu = DermaMenu()

	recurse(tree, baseMenu)

	return baseMenu
end
