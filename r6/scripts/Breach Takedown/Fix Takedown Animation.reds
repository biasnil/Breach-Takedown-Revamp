@replaceMethod(LocomotionTakedownEvents)
protected final func SelectSyncedAnimationAndExecuteAction(
  stateContext: ref<StateContext>,
  scriptInterface: ref<StateGameScriptInterface>,
  owner: ref<GameObject>,
  target: ref<GameObject>,
  action: CName
) -> Void {
  let effectTag: CName;
  let syncedAnimName: CName;
  let dataTrackingEvent: ref<TakedownActionDataTrackingRequest> = new TakedownActionDataTrackingRequest();
  let gameEffectName: CName = n"takedowns";
  let takedownType: ETakedownActionType = this.GetTakedownAction(stateContext);

  // Handle modded action names
  if Equals(action, n"RemoteBreach") || Equals(action, n"NanoWireRemoteBreach") {
    takedownType = ETakedownActionType.TakedownNetrunner;
  };

  switch takedownType {
    case ETakedownActionType.GrappleFailed:
      TakedownGameEffectHelper.FillTakedownData(scriptInterface.executionOwner, owner, target, gameEffectName, action, "");
      break;

    case ETakedownActionType.TargetDead:
      syncedAnimName = n"grapple_sync_death";
      effectTag = n"kill";
      break;

    case ETakedownActionType.BreakFree:
      syncedAnimName = n"grapple_sync_recover";
      break;

    case ETakedownActionType.Takedown:
      syncedAnimName = this.SelectRandomSyncedAnimation(stateContext);
      effectTag = n"kill";
      (target as NPCPuppet).SetMyKiller(owner);
      break;

    case ETakedownActionType.TakedownNonLethal:
      if stateContext.GetConditionBool(n"CrouchToggled") {
        syncedAnimName = n"grapple_sync_nonlethal_crouch";
      } else {
        syncedAnimName = this.SelectRandomSyncedAnimation(stateContext);
      };
      effectTag = n"setUnconscious";
      break;

    case ETakedownActionType.TakedownNetrunner:
      // ✅ Gender-aware version for female rig
      if Equals((target as ScriptedPuppet).GetGender(), gamedataGender.Female) {
        syncedAnimName = n"personal_link_takedown_01_female";
      } else {
        syncedAnimName = n"personal_link_takedown_01";
      };
      effectTag = TweakDBInterface.GetCName(t"TBL.EffectTag", n"setUnconsciousTakedownNetrunner");
      (target as NPCPuppet).SetMyKiller(owner);
      break;

    case ETakedownActionType.TakedownMassiveTarget:
      TakedownGameEffectHelper.FillTakedownData(scriptInterface.executionOwner, owner, target, gameEffectName, action, "");
      effectTag = n"setUnconsciousTakedownMassiveTarget";
      break;

    case ETakedownActionType.AerialTakedown:
      TakedownGameEffectHelper.FillTakedownData(scriptInterface.executionOwner, owner, target, gameEffectName,
        this.SelectAerialTakedownWorkspot(scriptInterface, owner, target, true, true, false, false, action));
      effectTag = n"setUnconsciousAerialTakedown";
      break;

    case ETakedownActionType.BossTakedown:
      TakedownGameEffectHelper.FillTakedownData(scriptInterface.executionOwner, owner, target, gameEffectName,
        this.SelectSyncedAnimationBasedOnPhase(stateContext, target), "");
      effectTag = this.SetEffectorBasedOnPhase(stateContext);
      syncedAnimName = this.GetSyncedAnimationBasedOnPhase(stateContext);
      StatusEffectHelper.ApplyStatusEffect(target, t"BaseStatusEffect.BossTakedownCooldown");
      target.GetTargetTrackerComponent().AddThreat(owner, true, owner.GetWorldPosition(), 1.00, 10.00, false);
      break;

    case ETakedownActionType.ForceShove:
      syncedAnimName = n"grapple_sync_shove";
      break;

    default:
      syncedAnimName = n"grapple_sync_kill";
      effectTag = n"kill";
  };

  if IsNameValid(syncedAnimName) && IsDefined(owner) && IsDefined(target) {
    if this.IsTakedownWeapon(stateContext, scriptInterface) {
      this.FillAnimWrapperInfoBasedOnEquippedItem(scriptInterface, false);
    };
    this.PlayExitAnimation(scriptInterface, owner, target, syncedAnimName);
  };

  dataTrackingEvent.eventType = takedownType;
  scriptInterface.GetScriptableSystem(n"DataTrackingSystem").QueueRequest(dataTrackingEvent);
  this.DefeatTarget(stateContext, scriptInterface, owner, target, gameEffectName, effectTag);
}
