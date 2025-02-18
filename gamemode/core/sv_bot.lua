local deadRemarks = {
	"gordead_ques01",
	"gordead_ques02",
	"gordead_ques06",
	"gordead_ques07",
	"gordead_ques10",
	"gordead_ques11",
	"gordead_ques14",
	"gordead_ans01",
	"gordead_ans02",
	"gordead_ans03",
	"gordead_ans04",
	"gordead_ans05",
	"gordead_ans07",
	"gordead_ans10",
	"gordead_ans14",
	"gordead_ans19",
}

local targetedSounds = {
	"excuseme01",
	"excuseme02",
	"pardonme01",
	"pardonme02",
}

local idleSounds = {
	"doingsomething",
	"getgoingsoon",
	"question02",
	"question04",
	"question05",
	"question06",
	"question07",
	"question09",
	"question11",
	"question12",
	"question13",
	"question15",
	"question16",
	"question17",
	"question18",
	"question19",
	"question20",
	"question22",
	"question23",
	"question25",
	"question27",
	"question28",
	"question29",
	"question30",
}

hook.Add("StartCommand", "bot", function(bot, cmd)
	if not bot:IsBot() then
		return
	end

	if not bot.AI then
		bot.AI = {}
	end

	if not bot.AI.Next then
		bot.AI.Next = CurTime()
	end

	cmd:ClearButtons()
	cmd:ClearMovement()
	cmd:SetViewAngles(bot:EyeAngles())

	if not bot:Alive() then
		cmd:SetButtons(IN_JUMP)

		bot.AI.Next = CurTime() + 3
		bot.AI.Target = nil

		return
	end

	if IsValid(bot.AI.Target) then
		if not bot.AI.Target:Alive() then
			bot.AI.Target = nil
			bot.AI.Next = CurTime() + 4

			local remark = table.Random(deadRemarks)

			bot:EmitSound(Sound("*vo/npc/" .. bot:Gender() .. "01/" .. remark .. ".wav"), 80)

			return
		end

		if bot.AI.Target:InVehicle() or bot.AI.Target:GetNoDraw() then
			bot.AI.Target = nil

			return
		end
	end

	if not IsValid(bot.AI.Target) then
		local dist = 400
		local closest = nil

		for _, v in player.Iterator() do
			if v != bot and v:Alive() and not v:InVehicle() and not v:GetNoDraw() and bot:CanSee(v) then
				local d = v:GetPos():Distance(bot:GetPos())

				if d < dist then
					dist = d
					closest = v
				end
			end
		end

		if IsValid(closest) then
			bot.AI.Target = closest

			local remark = table.Random(targetedSounds)

			bot:EmitSound(Sound("*vo/npc/" .. bot:Gender() .. "01/" .. remark .. ".wav"), 80)

			return
		end
	end

	if not IsValid(bot.AI.Target) then
		return
	end

	local eyeang = (bot.AI.Target:EyePos() - bot:EyePos()):GetNormal():Angle()

	eyeang.p = math.NormalizeAngle(eyeang.p)
	eyeang.y = math.NormalizeAngle(eyeang.y)
	eyeang.r = math.NormalizeAngle(eyeang.r)

	local dist = bot:GetPos():Distance(bot.AI.Target:GetPos())

	if dist > 200 then
		cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_SPEED))
	end

	if not bot:IsFemale() and bot.AI.Target:IsFemale() then
		cmd:SetForwardMove(bot:GetMaxSpeed())
	elseif dist > 50 then
		cmd:SetForwardMove(bot:GetMaxSpeed())
	end

	if CurTime() >= bot.AI.Next then
		if dist <= 50 then
			if not bot:IsFemale() and bot.AI.Target:IsFemale() then
				bot:EmitSound(Sound("vo/npc/male01/hi0" .. math.random(1, 2) .. ".wav"), 80)
				bot.AI.Next = CurTime() + 0.2
			else
				if math.random(1, 3) == 1 then
					local remark = table.Random(idleSounds)

					bot:EmitSound(Sound("*vo/npc/" .. bot:Gender() .. "01/" .. remark .. ".wav"), 80)
				end

				bot.AI.Next = CurTime() + math.random(20, 30)
			end

			return
		end

		bot.AI.Next = CurTime() + 0.1
	end

	cmd:SetViewAngles(eyeang)
	bot:SetEyeAngles(eyeang)
end)

