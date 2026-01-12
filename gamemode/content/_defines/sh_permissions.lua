Permissions.Add("donator_basic", {Description = "This person is a basic donator", Callback = function(ply) return ply:IsDonator() end})
Permissions.Add("donator_advanced", {Description = "This person is an advanced donator", Callback = function(ply) return ply:IsDonator(true) end})

Permissions.Add("character_spartan", {Description = "Gives access to SPARTAN character creation"})
