@replaceMethod(ScriptedPuppet)
protected func OnIncapacitated() -> Void {
  let link: ref<PuppetDeviceLinkPS>;

  // Prevent duplicate incapacitation handling
  if this.IsIncapacitated() {
    return;
  };

  // Reset security and interaction states
  this.m_securitySupportListener = null;
  this.EnableLootInteractionWithDelay(this);
  this.EnableInteraction(n"Grapple", false);
  this.EnableInteraction(n"TakedownLayer", false);
  this.EnableInteraction(n"AerialTakedown", false);
  StatusEffectHelper.RemoveAllStatusEffectsByType(this, gamedataStatusEffectType.Cloaked);

  // Special takedown interaction disabling
  if this.IsBoss() {
    this.EnableInteraction(n"BossTakedownLayer", false);
  } else if this.IsMassive() {
    this.EnableInteraction(n"MassiveTargetTakedownLayer", false);
  };

  // Disable awareness and hacking
  this.RevokeAllTickets();
  this.GetSensesComponent().ToggleComponent(false);
  this.GetBumpComponent().Toggle(false);
  this.UpdateQuickHackableState(false);

  // Cancel active reinforcement calls
  if this.IsPerformingCallReinforcements() {
    this.HidePhoneCallDuration(gamedataStatPoolType.CallReinforcementProgress);
  };

  // Set persistent incapacitated state and clear loadouts
  this.GetPuppetPS().SetWasIncapacitated(true);

  // Keep NPC network-visible — no unlinking
  link = this.GetDeviceLink() as PuppetDeviceLinkPS;
  if IsDefined(link) {
    link.NotifyAboutSpottingPlayer(false);
    // NOTE: we intentionally do NOT call any function like UnregisterNetworkLink...
  };

  // Update cached state
  CachedBoolValue.SetDirty(this.m_isActiveCached);
}
