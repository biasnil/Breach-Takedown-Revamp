@wrapMethod(ScriptedPuppetPS)
public final const func GetValidChoices(
  const actions: script_ref<[wref<ObjectAction_Record>]>,
  const context: script_ref<GetActionsContext>,
  objectActionsCallbackController: wref<gameObjectActionsCallbackController>,
  checkPlayerQuickHackList: Bool,
  choices: script_ref<[InteractionChoice]>
) -> Void {
  let remoteBreach: wref<ObjectAction_Record> = TweakDBInterface.GetObjectActionRecord(t"Takedown.NanoWireRemoteBreach");
  if IsDefined(remoteBreach) {
    ArrayPush(Deref(actions), remoteBreach);
  };

  let breachOfficer: wref<ObjectAction_Record> = TweakDBInterface.GetObjectActionRecord(t"Takedown.BreachUnconsciousOfficer");
  if IsDefined(breachOfficer) {
    ArrayPush(Deref(actions), breachOfficer);
  };

  wrappedMethod(actions, context, objectActionsCallbackController, checkPlayerQuickHackList, choices);
}
