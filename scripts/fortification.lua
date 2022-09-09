
local originalonAttackResolve;

function onInit()
	originalonAttackResolve = ActionAttack.onAttackResolve;
	ActionAttack.onAttackResolve = Fortification.onAttackResolve;
	ActionsManager.registerResultHandler("fortification", onFortification);
end

function onAttackResolve(rSource, rTarget, rRoll, rMessage)
	originalonAttackResolve(rSource, rTarget, rRoll, rMessage);

	if rRoll.sResult == "crit" then
		local rEffectComp = EffectManagerSFRPG.getEffectsByType(rTarget, "FORT");
		local nHighestMod = 0;
		for i,effect in ipairs(rEffectComp) do
			rEffectComp.type = effect.type;
			if effect.mod > nHighestMod then
				nHighestMod = effect.mod
			end
		end

		if rEffectComp.type == "FORT" then
			rRoll.nFortificationChance = nHighestMod;
			
			table.insert(rRoll.aMessages, "[FORTIFICATION " .. rRoll.nFortificationChance .. "%]");
			
			local aFortificationChanceDice = { "d100" };
			local rFortificationChanceRoll = { sType = "fortification", sDesc = rRoll.sDesc .. "[FORTIFICATION CHANCE " .. rRoll.nFortificationChance .. "%]", aDice = aFortificationChanceDice, nMod = 0 };
			
			ActionsManager.roll(rSource, rTarget, rFortificationChanceRoll);
		end
	end
end

function onFortification(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local nFortificationResult = ActionsManager.total(rRoll);
	local nFortificationChance = tonumber(string.match(rMessage.text, "%[FORTIFICATION CHANCE (%d+)%%%]"));
	if nFortificationResult <= nFortificationChance then
		rMessage.text = rMessage.text .. " [FORTIFIED]";
		if rTarget then
			rMessage.icon = "roll_attack_hit";
			ActionAttack.clearCritState(rSource, rTarget);
		else
			rMessage.icon = "roll_attack";
		end
	else
		rMessage.text = rMessage.text .. " [NOT FORTIFIED]";
		if rTarget then
			rMessage.icon = "roll_attack_crit";
		else
			rMessage.icon = "roll_attack";
		end
	end
	
	Comm.deliverChatMessage(rMessage);
end
