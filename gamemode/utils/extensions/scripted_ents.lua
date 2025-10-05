function scripted_ents.IsType(name, base)
	return name == base or scripted_ents.IsBasedOn(name, base)
end
