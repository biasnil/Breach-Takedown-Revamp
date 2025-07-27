@wrapMethod(ScriptedPuppetPS)
public final const func GetValidChoices(const actions: script_ref<array<wref<ObjectAction_Record>>>, const context: script_ref<GetActionsContext>, objectActionsCallbackController: wref<gameObjectActionsCallbackController>, checkPlayerQuickHackList: Bool, choices: script_ref<array<InteractionChoice>>) -> Void {
  // Inject custom takedown actions
  ArrayPush(Deref(actions), TweakDBInterface.GetObjectActionRecord(t"Takedown.NanoWireRemoteBreach"));
  ArrayPush(Deref(actions), TweakDBInterface.GetObjectActionRecord(t"Takedown.BreachUnconsciousOfficer"));

  // Call original logic
  wrappedMethod(actions, context, objectActionsCallbackController, checkPlayerQuickHackList, choices);
}
