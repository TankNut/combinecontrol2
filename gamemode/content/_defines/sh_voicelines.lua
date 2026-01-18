-- Really just to show how these work...

Voicelines.Add("MaleCitizenAmmo", {
	Name = "Ammo",
	CanAccess = function(ply)
		return util.GetModelGender(ply:GetModel()) == "male"
	end,
	Options = {
		{
			Name = "Freeman, ammo!",
			Sound = "vo/npc/male01/ammo01.wav"
		},
		{
			Name = "Here, ammo!",
			Sound = "vo/npc/male01/ammo03.wav"
		},
		{
			Name = "Take some ammo!",
			Chat = true,
			Sound = "vo/npc/male01/ammo05.wav"
		}
	}
})

Voicelines.Add("MaleCitizenAngry", {
	Name = "Angry",
	CanAccess = function(ply)
		return util.GetModelGender(ply:GetModel()) == "male"
	end,
	Options = {
		{
			Name = "Spray 'em!",
			Sound = "vo/npc/male02/reb2_antlions05.wav"
		},
		{
			Name = "I hate bugs!",
			Sound = "vo/npc/male02/reb2_antlions07.wav"
		},
		{
			Name = "Damn these things!",
			Chat = "/y Damn these things!",
			Sound = "vo/npc/male02/reb2_antlions12.wav"
		}
	}
})

Voicelines.Add("FemaleCitizenAmmo", {
	Name = "Ammo",
	CanAccess = function(ply)
		return util.GetModelGender(ply:GetModel()) == "female"
	end,
	Options = {
		{
			Name = "Freeman, ammo!",
			Sound = "vo/npc/female01/ammo01.wav"
		},
		{
			Name = "Here, ammo!",
			Sound = "vo/npc/female01/ammo03.wav"
		},
		{
			Name = "Take some ammo!",
			Sound = "vo/npc/female01/ammo05.wav"
		}
	}
})
