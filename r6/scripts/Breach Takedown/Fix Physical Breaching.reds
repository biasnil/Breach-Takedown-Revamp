@addField(ScriptedPuppetPS)
public let wasIncapacitatedViaBreach: Bool;

@wrapMethod(ScriptedPuppetPS)
public final func SetWasIncapacitated(wasIncapacitated: Bool) -> Void {
  wrappedMethod(wasIncapacitated); // preserve original behavior

  let owner: wref<GameObject> = this.GetOwnerEntity();
  if !IsDefined(owner) || !wasIncapacitated {
    return;
  }

  // Check if the incapacitation was caused by our custom Breach Takedown status effect
  if StatusEffectSystem.ObjectHasStatusEffect(owner, t"TBL.BreachTakedownSE") {
    this.wasIncapacitatedViaBreach = true;

    // Optional: trigger additional effect logic
    let effectName: CName = n"physicalBreach";
    let effectTag: CName = TweakDBInterface.GetCName(t"TBL.EffectTag", n"kill");

    TakedownGameEffectHelper.FillTakedownData(
      GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject(),
      GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject(),
      owner,
      effectName,
      effectTag,
      "TBL.BreachTakedownSE"
    );
  } else {
    this.wasIncapacitatedViaBreach = false;
  }
}
