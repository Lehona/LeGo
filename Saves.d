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

/* Some magic made by Chicken
 * Not used anymore by LeGo, but kept for compatibility */
func string GetParmValue(var string str) {
    CALL_zStringPtrParam(str);
    CALl_RetValIszString();
    CALL__thisCall(MEM_ReadInt(zoptions_Pointer_Address), zCOption__ParmValue);

    return CALL_RetValAszString();
};

//========================================
// [intern] Gibt Pfad zur Speicherdatei zurück
//========================================
func string _BIN_GetSavefilePath(var int slot) {
    // Game save path. The class zCOption is defined incorrectly in Ikarus for Gothic1, hence the use of an offset here
    var int zOpt; zOpt = MEM_ReadInt(zoptions_Pointer_Address);
    var string path; path = MEM_ReadStringArray(zOpt+zCOptions_dir_string_offset, /*zTOptionPaths_SaveDir*/ 2);

    // Cut off initial and trailing backslashes
    path = STR_SubStr(path, 1, STR_Len(path)-2);

    // Slot sub directory
    if (slot) {
        path = ConcatStrings(path, "/savegame");
        path = ConcatStrings(path, IntToString(slot));
    } else {
        path = ConcatStrings(path, "/quicksave");
    };

    path = ConcatStrings(path, "/SCRPTSAVE.SAV");

    return path;
};

//========================================
// [intern] Speicherslot herausfinden
//========================================
func int _BR_GetSelectedSlot() {
    var CGameManager man; man = _^(MEM_ReadInt(MEMINT_gameMan_Pointer_address));
    var int slot; slot = MEM_ReadInt(man.menu_load_savegame + menu_savegame_slot_offset);
    return slot;
};

//========================================
// [intern] Fix slot on quick load (F9)
//========================================
func void _BR_SetSelectedSlot() {
    var int slot; slot = MEM_ReadInt(ESP+4);
    var CGameManager man; man = _^(MEM_ReadInt(MEMINT_gameMan_Pointer_address));
    MEM_WriteInt(man.menu_load_savegame + menu_savegame_slot_offset, slot);
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
        // Quicksave
        slot = 0;
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
