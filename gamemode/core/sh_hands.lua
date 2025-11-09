module("Hands", package.seeall)

List = List or {}

function AddModel(mdl, hands)
	List[mdl] = hands
end

function Get(mdl)
	for pattern, hands in pairs(List) do
		if string.find(mdl, pattern) then
			return table.Copy(hands)
		end
	end

	return {
		Model = Model("models/weapons/c_arms_hev.mdl")
	}
end
