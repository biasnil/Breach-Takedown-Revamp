registerForEvent("onTweak", function()

	-----------------------------------------------------------------------------
	-----------------------------PHYSICAL BREACHING---------------------------------
	-----------------------------------------------------------------------------
	
	--This is how many breach protocol hacks will get automatically uploaded when you do the breach takedown
	BreachCount = 9
	
	--Breach All Count
	TweakDB:SetFlat("TBL.BreachAllCount", BreachCount, 'Int32')
		
	--Create new status effect that will indicate in redscript if we should upload all daemons.
	TweakDB:CreateRecord("TBL.BreachTakedownSE", "gamedataStatusEffect_Record")
	TweakDB:SetFlatNoUpdate("TBL.BreachTakedownSE.duration", "TBL.BreachTakedownDuration")
	TweakDB:SetFlatNoUpdate("TBL.BreachTakedownSE.isAffectedByTimeDilationPlayer", true)
	TweakDB:SetFlat("TBL.BreachTakedownSE.statusEffectType", "BaseStatusEffectTypes.Misc")

	TweakDB:CreateRecord("TBL.BreachTakedownDuration", "gamedataStatModifierGroup_Record")
	TweakDB:SetFlatNoUpdate("TBL.BreachTakedownDuration.statModsLimit", -1)
	TweakDB:SetFlat("TBL.BreachTakedownDuration.statModifiers", {"TBL.BreachTakedownDurationStat"})
	createConstantStatModifier("TBL.BreachTakedownDurationStat", "Additive", "BaseStats.MaxDuration", 2)
	
	TweakDB:CreateRecord("TBL.BreachTakedownSE_inline0", "gamedataObjectActionEffect_Record")
	TweakDB:SetFlatNoUpdate("TBL.BreachTakedownSE_inline0.recipient", "ObjectActionReference.Instigator")
	TweakDB:SetFlat("TBL.BreachTakedownSE_inline0.statusEffect", "TBL.BreachTakedownSE")
		
	-----------------------------BREACH TAKEDOWN---------------------------------

	--Enable it to be used
	TweakDB:SetFlat("Takedown.NanoWireRemoteBreach.objectActionType", "ObjectActionType.Direct")

	--Adjust to be like remote breach + a takedown
	TweakDB:SetFlat("Takedown.NanoWireRemoteBreach.instigatorPrereqs", {"Takedown.Takedown_inline0", "QuickHack.RemoteBreach_inline0", "QuickHack.QuickHack_inline3"})
	TweakDB:SetFlat("Takedown.NanoWireRemoteBreach.targetPrereqs", {})
	TweakDB:SetFlat("Takedown.NanoWireRemoteBreach.targetActivePrereqs", {"Prereqs.QuickHackUploadingPrereq", "Prereqs.NetworkNotBreachedActive", "Prereqs.ConnectedToBackdoorActive"})
	
	TweakDB:SetFlat("Takedown.NanoWireRemoteBreach.startEffects", {"QuickHack.QuickHack_inline12", "QuickHack.QuickHack_inline13", "QuickHack.RemoteBreach_inline1", "TBL.BreachTakedownSE_inline0"})
	TweakDB:SetFlat("Takedown.NanoWireRemoteBreach.completionEffects", {"QuickHack.QuickHack_inline4", "QuickHack.QuickHack_inline8", "QuickHack.QuickHack_inline10", "QuickHack.QuickHack_inline11"})
	
	--It enables breach protocol
	TweakDB:SetFlat("Takedown.NanoWireRemoteBreach.actionName", "RemoteBreach")
	
	--Remove time, making breach protocol work
	TweakDB:SetFlat("Takedown.NanoWireRemoteBreach.activationTime", {})

	--Give breach and hacking reward
	TweakDB:SetFlat("Takedown.NanoWireRemoteBreach.rewards", {"RPGActionRewards.Stealth", "RPGActionRewards.Hacking"})
	--Set takedown icon
	TweakDB:SetFlat("Interactions.TakedownNetrunner.captionIcon", "ChoiceCaptionParts.JackInIcon")
	
	--Set our effect tag
	TweakDB:SetFlat("TBL.EffectTag", CName.new("kill"))
	
	-----------------------------------------KO BREACH------------------------------------------------------
	
	--Adjust to be like remote breach + a takedown
	TweakDB:SetFlat("Takedown.BreachUnconsciousOfficer.instigatorPrereqs", {"QuickHack.RemoteBreach_inline0", "QuickHack.QuickHack_inline3", "Takedown.GeneralStateChecks", "Takedown.IsPlayerInExploration", "Takedown.IsPlayerInAcceptableGroundLocomotionState", "Takedown.PlayerNotInSafeZone", "Takedown.GameplayRestrictions", "Takedown.BreachUnconsciousOfficer_inline0", "Takedown.BreachUnconsciousOfficer_inline1", "Takedown.BreachUnconsciousOfficer_inline2"})
	TweakDB:SetFlat("Takedown.BreachUnconsciousOfficer.targetPrereqs", {"Takedown.BreachUnconsciousOfficer_inline4", "Takedown.BreachUnconsciousOfficer_inline5"})
	TweakDB:SetFlat("Takedown.BreachUnconsciousOfficer.targetActivePrereqs", {"Prereqs.QuickHackUploadingPrereq", "Prereqs.NetworkNotBreachedActive", "Prereqs.ConnectedToBackdoorActive"})
	
	TweakDB:SetFlat("Takedown.BreachUnconsciousOfficer.startEffects", {"QuickHack.QuickHack_inline12", "QuickHack.QuickHack_inline13", "QuickHack.RemoteBreach_inline1", "TBL.BreachTakedownSE_inline0"})
	TweakDB:SetFlat("Takedown.BreachUnconsciousOfficer.completionEffects", {"QuickHack.QuickHack_inline4", "QuickHack.QuickHack_inline8", "QuickHack.QuickHack_inline10", "QuickHack.QuickHack_inline11"})
	
	--Remove time, making breach protocol work
	TweakDB:SetFlat("Takedown.BreachUnconsciousOfficer.activationTime", {})

	
	--It enables breach protocol
	TweakDB:SetFlat("Takedown.BreachUnconsciousOfficer.actionName", "RemoteBreach")
	
	--Set breach icon
	TweakDB:SetFlat("Interactions.BreachUnconsciousOfficer.captionIcon", "ChoiceCaptionParts.JackInIcon")
		
	--Move it to choice 3
	TweakDB:SetFlat("Interactions.BreachUnconsciousOfficer.action", "Choice3")
	
end)
function createConstantStatModifier(recordName, modifierType, statType, value)
	TweakDB:CreateRecord(recordName, "gamedataConstantStatModifier_Record")
	TweakDB:SetFlatNoUpdate(recordName..".modifierType", modifierType)
	TweakDB:SetFlatNoUpdate(recordName..".statType", statType)
	TweakDB:SetFlatNoUpdate(recordName..".value", value)
	TweakDB:Update(recordName)
end