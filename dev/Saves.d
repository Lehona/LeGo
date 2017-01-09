/***********************************\
                SAVES
\***********************************/

var int _LeGo_LevelChangeIsExecuted;
var int _LeGo_LevelChangeCounter;

func void BW_Savegame() {

};

func void BR_Savegame() {

};


func void _LeGo_ChangeLevelHookBegin() {
    _LeGo_LevelChangeIsExecuted = TRUE;
};

func void _LeGo_ChangeLevelHookEnd() {
    _LeGo_LevelChangeIsExecuted = FALSE;
    _LeGo_LevelChangeCounter = 0;
};

func int _LeGo_IsLevelChange() {
    return _LeGo_LevelChangeIsExecuted;
};

/* Some magic made by Chicken */
func string GetParmValue(var string str) {
	CALL_zStringPtrParam(str);
	CALl_RetValIszString();
	CALL__thisCall(MEM_ReadInt(zoptions_Pointer_Address), 4586784);
	
	return CALL_RetValAszString();
};

//========================================
// [intern] Gibt Pfad zur Speicherdatei zurück
//========================================
func string _BIN_GetSavefilePath(var int slot) {
    var string path;
	var string cmd;
	if (MEMINT_SwitchG1G2(false, true)) {
		/* G2 */
        cmd = MEM_GetCommandLine();
    };
    var string _BIN_ini;
	
    if(!STR_len(_BIN_ini)) {
		if (MEMINT_SwitchG1G2(false, true)) {
			/* G2 */
			var int start; start = STR_IndexOf(cmd, "-GAME:");
        	_BIN_ini = STR_SubStr(cmd, start+6, STR_Len(cmd)-start-6);
		} else {
			/* G1 */
			_BIN_ini = GetParmValue("GAME"); // Yea, I've lost a lot of time and patience to resolve crash during saving the game. 
		};
        _BIN_ini = STR_Split(_BIN_ini, ".", 0);
    };

	MEM_Info(ConcatStrings(":_Bin_ini:",_BIN_ini));
	
    if(Hlp_StrCmp(_BIN_ini, "GOTHICGAME") || (Hlp_StrCmp(_BIN_ini, ""))) {
        path = "saves";
    }
    else {
        path = ConcatStrings("saves_", _BIN_ini);
    };
    if(slot) {
        path = ConcatStrings(path, "/savegame");
        path = ConcatStrings(path, IntToString(slot));
    }
    else {
        path = ConcatStrings(path, "/quicksave");
    };
    path = ConcatStrings(path, "/SCRPTSAVE.SAV");

	MEM_Info(ConcatStrings(":path:",path));
    return path;
};

//========================================
// [intern] Speicherslot herausfinden
//========================================
func int _BR_GetSelectedSlot() {
    var CGameManager man; man = _^(MEM_ReadInt(MEMINT_gameMan_Pointer_address));
	var int slot; slot = MEM_ReadInt(man.menu_load_savegame + menu_savegame_slot_offset);
	MEM_Info(ConcatStrings(":slot:",IntToString(slot)));
    return slot;
};

//========================================
// [intern] Ruft BW_Savegame auf
//========================================
func void _BW_SaveGame() {
    var int ext; ext = MEM_ReadInt(EBP+oCSavegameManager__SetAndWriteSavegame_bp_offset);
    if(_LeGo_Flags & LeGo_Gamestate) {
        _Gamestate_Init(Gamestate_Saving);
    };
    if(BW_NewFile(_BIN_GetSavefilePath(ext))) {
        if(_LeGo_Flags & LeGo_PermMem) {
            _PM_Archive();
        };
        BW_Savegame();
        BW_Close();
    };
};

//========================================
// [intern] Ruft BR_Savegame auf
//========================================
func void _BR_LoadGame() {
    var int slot; slot = _BR_GetSelectedSlot();
    if(slot == -1) {
        if(_LeGo_Flags & LeGo_Gamestate) {
            _Gamestate_Init(Gamestate_WorldChange);
        };
        return;
    };
    if(BR_OpenFile(_BIN_GetSavefilePath(slot))) {
        if(_LeGo_Flags & LeGo_PermMem) {
            _PM_UnArchive();
        };
        BR_Savegame();
        BR_Close();
    };
    if(_LeGo_Flags & LeGo_Gamestate) {
        _Gamestate_Init(Gamestate_Loaded);
    };
};