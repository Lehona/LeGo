/*************************************************************************\
|*                                                                       *|
|*           $$\                 $$$$$$\              $$$$$$\            *|
|*           $$ |               $$  __$$\            $$  __$$\           *|
|*           $$ |      $$$$$$\  $$ /  \__| $$$$$$\   \__/  $$ |          *|
|*           $$ |     $$  __$$\ $$ |$$$$\ $$  __$$\   $$$$$$  |          *|
|*           $$ |     $$$$$$$$ |$$ |\_$$ |$$ /  $$ | $$  ____/           *|
|*           $$ |     $$   ____|$$ |  $$ |$$ |  $$ | $$ |                *|
|*           $$$$$$$$\\$$$$$$$\ \$$$$$$  |\$$$$$$  | $$$$$$$$\           *|
|*           \________|\_______| \______/  \______/  \________|          *|
|*                                                                       *|
|*                  Erweitertes Scriptpaket, aufbauend                   *|
|*                              auf Ikarus                               *|
|*                                                                       *|
\*************************************************************************/
const string LeGo_Version = "LeGo 2.5.1";

const int LeGo_PrintS          = 1<<0;  // Interface.d
const int LeGo_HookEngine      = 1<<1;  // HookEngine.d
const int LeGo_AI_Function     = 1<<2;  // AI_Function.d
const int LeGo_Trialoge        = 1<<3;  // Trialoge.d
const int LeGo_Dialoggestures  = 1<<4;  // Dialoggestures.d
const int LeGo_FrameFunctions  = 1<<5;  // FrameFunctions.d
const int LeGo_Cursor          = 1<<6;  // Cursor.d
const int LeGo_Focusnames      = 1<<7;  // Focusnames.d
const int LeGo_Random          = 1<<8;  // Random.d
const int LeGo_Bloodsplats     = 1<<9;  // Bloodsplats.d
const int LeGo_Saves           = 1<<10; // Saves.d
const int LeGo_PermMem         = 1<<11; // PermMemory.d
const int LeGo_Anim8           = 1<<12; // Anim8.d
const int LeGo_View            = 1<<13; // View.d
const int LeGo_Interface       = 1<<14; // Interface.d
const int LeGo_Bars            = 1<<15; // Bars.d
const int LeGo_Buttons         = 1<<16; // Buttons.d
const int LeGo_Timer           = 1<<17; // Timer.d
const int LeGo_EventHandler    = 1<<18; // EventHandler.d
const int LeGo_Gamestate       = 1<<19; // Gamestate.d
const int LeGo_Sprite          = 1<<20; // Sprite.d
const int LeGo_Names           = 1<<21; // Names.d
const int LeGo_ConsoleCommands = 1<<22; // ConsoleCommands.d
const int LeGo_Buffs           = 1<<23; // Buffs.d
const int LeGo_Render          = 1<<24; // Render.d
const int LeGo_Draw3D          = 1<<25; // Draw3D.d


const int LeGo_All            = (1<<23)-1; // Sämtliche Bibliotheken // No Experimental

//========================================
// [intern] Variablen
//========================================
const int _LeGo_Init = 0;
var int _LeGo_Loaded;


//========================================
// [intern] Abhängigkeiten bestimmen
//========================================
func void LeGo_InitFlags(var int f) {
    if(f & LeGo_Bloodsplats)    { f = f | LeGo_FrameFunctions | LeGo_HookEngine | LeGo_Random | LeGo_Anim8; };
    if(f & LeGo_Buffs)          { f = f | LeGo_FrameFunctions | LeGo_PermMem | LeGo_View; };
    if(f & LeGo_Gamestate)      { f = f | LeGo_EventHandler | LeGo_Saves; };
    if(f & LeGo_Cursor)         { f = f | LeGo_Interface | LeGo_View; };
    if(f & LeGo_PrintS)         { f = f | LeGo_AI_Function | LeGo_Anim8 | LeGo_Interface; };
    if(f & LeGo_Anim8)          { f = f | LeGo_PermMem | LeGo_FrameFunctions | LeGo_Timer; };
    if(f & LeGo_Buttons)        { f = f | LeGo_PermMem | LeGo_View | LeGo_FrameFunctions; };
    if(f & LeGo_ConsoleCommands){ f = f | LeGo_HookEngine; };
    if(f & LeGo_FrameFunctions) { f = f | LeGo_PermMem | LeGo_HookEngine | LeGo_Timer; };
    if(f & LeGo_Draw3D)         { f = f | LeGo_PermMem | LeGo_HookEngine; };
    if(f & LeGo_Bars)           { f = f | LeGo_PermMem | LeGo_View; };
    if(f & LeGo_EventHandler)   { f = f | LeGo_PermMem; };
    if(f & LeGo_View)           { f = f | LeGo_PermMem; };
    if(f & LeGo_Interface)      { f = f | LeGo_PermMem | LeGo_AI_Function; };
	if(f & LeGo_AI_Function)	{ f = f | LeGo_HookEngine; };
    if(f & LeGo_Sprite)         { f = f | LeGo_PermMem; };
	if(f & LeGo_Names)			{ f = f | LeGo_PermMem; };
    if(f & LeGo_PermMem)        { f = f | LeGo_Saves; };
    if(f & LeGo_Saves)          { f = f | LeGo_HookEngine; };
    _LeGo_Flags = f;
};

//========================================
// LeGo flags in human-readable format
//========================================
func string LeGo_FlagsHR(var int flags) {
    var int symbOnset; symbOnset = MEM_GetSymbolIndex("LEGO_VERSION") + 1;
    if ((!symbOnset) || (!(flags & (LeGo_Draw3D * 2 - 1)))) {
        return "";
    };

    var string ret; ret = "";
    repeat(i, 32); var int i;
        if (flags & (1 << i)) {
            var string name; name = MEM_ReadString(MEM_GetSymbolByIndex(symbOnset + i));
            name = STR_SubStr(name, 5, STR_Len(name)-5); // Cut off 'LEGO_'
            ret = ConcatStrings(ConcatStrings(ret, name), " ");
        };
    end;
    return STR_Prefix(ret, STR_Len(ret)-1);
};

//========================================
// [intern] Immer
//========================================
func void LeGo_InitAlways(var int f) {
    if (!_LeGo_Loaded) {
		// Nur beim ersten Spielstart, sonst wird es sowieso aus dem Savegame geladen
		if (f & LeGo_PermMem) {
			_PM_Reset();
			HandlesPointer = _HT_Create();
			HandlesInstance = _HT_Create();
			_PM_CreateForeachTable();
		};
	};
    if (f & LeGo_Saves) {
        if(_LeGo_IsLevelChange()) {

            // During level change, LeGo_InitAlways is called twice on very first transistion!
            _LeGo_LevelChangeCounter += 1;

            // update gamestate status at the first call of _LeGo_IsLevelChange
            // because it is only called once for consecutive level changes
            if((f & LeGo_Gamestate) && (_LeGo_LevelChangeCounter == 1)) {
                _Gamestate_Init(Gamestate_WorldChange);
            };
        };
    };

    if(f & LeGo_Timer) {
        _Timer_Init();
		_TimerGT_Init();
    };

    if(_LeGo_Loaded && !_LeGo_IsLevelChange()) {
        // Wenn ein Spielstand geladen wird
        if(f & LeGo_Saves) {
            _BR_LoadGame();
        };
    };

    if(!_LeGo_Loaded) {


        if(f & LeGo_Gamestate) {
            _Gamestate_Init(Gamestate_NewGame);
        };

        if(f & LeGo_Buttons) {
            FF_Apply(Buttons_Do);
        };

        if(f & LeGo_Bloodsplats) {
            FF_Apply(_Bloodsplats_Loop);
        };

        if(f & LeGo_Anim8) {
            FF_ApplyGT(_Anim8_FFLoop);
        };

        if(f & LeGo_Cursor) {
            Cursor_Event = Event_Create();
        };

        if (f & LeGo_Render) {
            _render_list = new(zCList@);
        };
        if (f & LeGo_Buffs) {
                Bufflist_Init();
        };

        if (f & LeGo_Names) {
			Talent_Names = TAL_CreateTalent();
		};

    };

    if (f & LeGo_Render) {
        _Render_RestorePointer();
        GameState_AddListener(_Render_RestorePointer_Listener);
    };
};

//========================================
// [intern] Nur bei Spielstart
//========================================
func void LeGo_InitGamestart(var int f) {

	/* ACHTUNG: Es steht kein new() zur Verfügung (aber create()) */

    // Fix bug in Ikarus for displaying error boxes (Ikarus 1.2 line 4660 is missing writing permission)
    if(GOTHIC_BASE_VERSION == 1) {
        MemoryProtectionOverride(/*0x4F55C2*/ 5199298, 1);
    };

    if(f & LeGo_Cursor) {
        HookEngineF(sub_4D3D90_X, 5, _CURSOR_GETVAL);
    };

    if(f & LeGo_Random) {
        r_DefaultInit();
    };

    if(f & LeGo_Focusnames) {
        HookEngineF(oCGame__UpdateStatus, 8, _Focusnames);
    };

    if(f & LeGo_AI_Function) {
        HookEngineF(oCNPC__EV_PlayAni, 5, _AI_FUNCTION_EVENT);
    };

    if(f & LeGo_FrameFunctions) {
        HookEngineF(oCGame__Render, 7, _FF_HOOK);
    };

    if(f & LeGo_ConsoleCommands) {
        HookEngineF(zCConsoleOutputOverwriteAddr, 9, _CC_HOOK);
        CC_Register(CC_LeGo, "LeGo", "Show information about LeGo");
    };

    if(f & LeGo_Saves) {
        HookEngineF(oCGame__changeLevel, 7, _LeGo_ChangeLevelHookBegin);
        HookEngineF(oCGame__changeLevelEnd, 7, _LeGo_ChangeLevelHookEnd);
        HookEngineF(oCSavegameManager__SetAndWriteSavegame, 5, _BW_SAVEGAME);
        HookEngineF(CGameManager__Read_Savegame, 7, _BR_SetSelectedSlot);
    };

    if(f & LeGo_Draw3D) {
        HookEngineF(zCWorld__AdvanceClock, 10, _DrawHook);
    };

    if(f & LeGo_Sprite) {
        HookEngineF(zRND_D3D__EndFrame, 6, _Sprite_DoRender);
    };

    if (f & LeGo_Render) {
        _Render_Init();
    };

    if(f & LeGo_Interface) {
        Print_fixPS();
    };
};

//========================================
// LeGo initialisieren
//========================================
func void LeGo_Init(var int flags) {
    if(!MEM_CheckVersion(1,2,0)) {
        MEM_Error("LeGo benötigt mindestens Ikarus 1.2!");
        return;
    };

    MEM_InitAll();

    // In Gothic 1 LeGo_Init is called twice on new game: prevent calling LeGo_InitAlways a second time
    if (_LeGo_Loaded == -1) {
        _LeGo_Loaded = 1;
        return;
    };

    MEM_Info(ConcatStrings(LeGo_Version, " wird initialisiert."));

    LeGo_InitFlags(flags);
    MEM_Info(ConcatStrings("Flags: ", LeGo_FlagsHR(_LeGo_Flags)));
    if(!_LeGo_Init) {
        LeGo_InitGamestart(_LeGo_Flags);
    };
    LeGo_InitAlways(_LeGo_Flags);
    _LeGo_Init = 1;

    // For Gothic 1 mark _LeGo_Loaded with -1 to prevent second call during new game
    if (GOTHIC_BASE_VERSION == 1) && (!_LeGo_Loaded) && (!Hlp_IsValidNpc(hero)) {
        _LeGo_Loaded = -1;
    } else {
        _LeGo_Loaded = 1;
    };

    MEM_Info(ConcatStrings(LeGo_Version, " wurde erfolgreich initialisiert."));
};
