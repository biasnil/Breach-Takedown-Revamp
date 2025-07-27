@replaceMethod(MinigameGenerationRuleScalingPrograms)
protected func OnProcessRule(size: Uint32, out grid: array<array<GridCell>>) -> Bool {
    let atStart: Bool;
    let combinedPowerLevel: Float;
    let extraDifficulty: Float;
    let i: Int32;
    let length: Int32;
    let miniGameActionRecord: wref<MinigameAction_Record>;
    let miniGameRecord: wref<Minigame_Def_Record>;
    let overlapInstance: Overlap;
    let overlapProbability: Float;
    let overlappingPrograms: array<Overlap>;
    let powerLevel: Float;
    let program: UnlockableProgram;
    let programComplexity: Float;
    let rand: Float;
    let tempPrograms: array<TweakDBID>;
    let x: Int32;

    let playerPrograms: array<MinigameProgramData> = this.minigameController.GetPlayerPrograms();

    this.m_bbNetwork = this.m_blackboardSystem.Get(GetAllBlackboardDefs().NetworkBlackboard);
    this.m_isOfficerBreach = this.m_bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.OfficerBreach);
    this.m_isRemoteBreach = this.m_bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.RemoteBreach);
    this.m_isFirstAttempt = this.m_bbNetwork.GetInt(GetAllBlackboardDefs().NetworkBlackboard.Attempt) == 1;
    let isItemBreach: Bool = this.m_bbNetwork.GetBool(GetAllBlackboardDefs().NetworkBlackboard.ItemBreach);

    this.FilterPlayerPrograms(playerPrograms);

    miniGameRecord = TweakDBInterface.GetMinigame_DefRecord(t"minigame_v2.DefaultMinigame");
    powerLevel = GameInstance.GetStatsSystem((this.m_entity as GameObject).GetGame()).GetStatValue(Cast<StatsObjectID>(this.m_entity.GetEntityID()), gamedataStatType.PowerLevel);
    extraDifficulty = miniGameRecord.ExtraDifficulty();
    overlapProbability = miniGameRecord.OverlapProbability();

    this.RandomMode(atStart);

    i = 0;
    while i < ArraySize(playerPrograms) + 1 {
        rand = RandRangeF(0.00, 1.00);
        if rand < overlapProbability {
            overlapInstance.instructionNumber = i;
            x = RandDifferent(i, ArraySize(playerPrograms) + 1);
            overlapInstance.otherInstruction = x;
            overlapInstance.atStart = atStart;
            overlapInstance.rarity = this.minigameController.GetRarity(RandRangeF(0.00, 1.00));
            ArrayPush(overlappingPrograms, overlapInstance);
            this.RandomMode(atStart);
        };
        i += 1;
    };

    ArrayClear(tempPrograms);

    let devSys: ref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer(this.m_player.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    let devData: ref<PlayerDevelopmentData> = devSys != null ? devSys.GetDevelopmentData(this.m_player) : null;
    let hasCopyPaste: Bool = devData != null && devData.IsNewPerkBought(gamedataNewPerkType.Intelligence_Left_Perk_2_3) > 0;

    i = 0;
    while i < ArraySize(playerPrograms) {
        miniGameActionRecord = TweakDBInterface.GetMinigameActionRecord(playerPrograms[i].actionID);
        programComplexity = miniGameActionRecord.Complexity();
        combinedPowerLevel = programComplexity + powerLevel + extraDifficulty;
        length = this.DefineLength(combinedPowerLevel, this.m_bufferSize, ArraySize(playerPrograms));

        program.name = StringToName(LocKeyToString(miniGameActionRecord.ObjectActionUI().Caption()));
        program.note = miniGameActionRecord.ObjectActionUI().Description();
        program.programTweakID = playerPrograms[i].actionID;
        program.iconTweakID = miniGameActionRecord.ObjectActionUI().CaptionIcon().TexturePartID().GetID();

        if !isItemBreach && i == 0 && hasCopyPaste {
            program.isFulfilled = true;
        } else {
            program.isFulfilled = false;
        };

        if !ArrayContains(tempPrograms, program.programTweakID) {
            ArrayPush(tempPrograms, program.programTweakID);
            this.minigameController.AddUnlockableProgram(program, this.GenerateRarities(length, overlappingPrograms, i + 1));
        };

        i += 1;
    };

    return true;
}


@replaceMethod(MinigameGenerationRuleOverridePrograms)
protected func OnProcessRule(size: Uint32, out grid: array<array<GridCell>>) -> Bool {
    let finalChain: array<Uint32>;
    let i: Int32;
    let j: Int32;
    let minigameRecord: ref<MinigameAction_Record>;
    let obj: ref<ObjectAction_Record>;
    let overrideProgramList: array<wref<Program_Record>>;
    let program: UnlockableProgram;
    let programChain: array<Int32>;
    let programRecord: ref<Program_Record>;
    let rand: Float;

    this.m_minigameRecord.OverrideProgramsList(overrideProgramList);

    let devSys: ref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer(this.m_player.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    let devData: ref<PlayerDevelopmentData> = devSys != null ? devSys.GetDevelopmentData(this.m_player) : null;
    let hasCopyPaste: Bool = devData != null && devData.IsNewPerkBought(gamedataNewPerkType.Intelligence_Left_Perk_2_3) > 0;

    i = 0;
    while i < ArraySize(overrideProgramList) {
        programRecord = overrideProgramList[i];
        obj = programRecord.Program();
        program.programTweakID = obj.GetID();
        minigameRecord = TweakDBInterface.GetMinigameActionRecord(program.programTweakID);
        program.name = StringToName(LocKeyToString(minigameRecord.ObjectActionUI().Caption()));
        program.note = minigameRecord.ObjectActionUI().Description();
        program.iconTweakID = minigameRecord.ObjectActionUI().CaptionIcon().TexturePartID().GetID();

        if !this.m_isItemBreach && i == 0 && hasCopyPaste {
            program.isFulfilled = true;
        } else {
            program.isFulfilled = false;
        };

        programChain = programRecord.CharactersChain();
        ArrayClear(finalChain);

        j = 0;
        while j < ArraySize(programChain) {
            if programChain[j] == -1 {
                rand = RandRangeF(0.00, 1.00);
                ArrayPush(finalChain, Cast<Uint32>(this.minigameController.GetRarity(rand)));
            } else {
                ArrayPush(finalChain, Cast<Uint32>(programChain[j]));
            };
            j += 1;
        };

        this.minigameController.AddUnlockableProgram(program, finalChain);
        i += 1;
    };

    return true;
}
