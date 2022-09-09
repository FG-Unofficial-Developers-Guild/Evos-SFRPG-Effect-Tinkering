
local originalapplyOngoingDamageAdjustment;

function onInit()
	originalapplyOngoingDamageAdjustment = EffectManagerSFRPG.applyOngoingDamageAdjustment;
	EffectManagerSFRPG.applyOngoingDamageAdjustment = BetterRegen.applyOngoingDamageAdjustment;
end

function applyOngoingDamageAdjustment(nodeActor, nodeEffect, rEffectComp)
	local aResults = {};
  	if rEffectComp.type == "REGEN" then
  		for _, tag in ipairs(rEffectComp.remainder) do
			if tag:lower() == "temp" then
				table.insert(aResults, "[HEAL] [TEMP] Regeneration");
			elseif tag:lower() == "sp" then
				if DB.getValue(nodeActor, "fatique", 0) == 0 then
					return;
				end
				table.insert(aResults, "[RESTORE] Regeneration");
			end
		end
		
		if #aResults == 0 then
			if DB.getValue(nodeActor, "wounds", 0) == 0 and DB.getValue(nodeActor, "nonlethal", 0) == 0 then
				return;
			end
			table.insert(aResults, "[REGEN] Regeneration");
		end

		local rTarget = ActorManager.resolveActor(nodeActor);
		local rRoll = { sType = "damage", sDesc = table.concat(aResults, " "), aDice = rEffectComp.dice, nMod = rEffectComp.mod };
		if EffectManager.isGMEffect(nodeActor, nodeEffect) then
			rRoll.bSecret = true;
		end
		ActionsManager.roll(nil, rTarget, rRoll);
	else
    	originalapplyOngoingDamageAdjustment(nodeActor, nodeEffect, rEffectComp)
	end
end
