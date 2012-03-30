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
const string LeGo_Version = "LeGo 2.x.x_b";

const int LeGo_PrintS         = 1<<0;  // Interface.d
const int LeGo_HookEngine     = 1<<1;  // HookEngine.d
const int LeGo_AI_Function    = 1<<2;  // AI_Function.d
const int LeGo_Trialoge       = 1<<2;  // Trialoge.d
const int LeGo_Dialoggestures = 1<<2;  // Dialoggestures.d
const int LeGo_FrameFunctions = 1<<3;  // FrameFunctions.d
const int LeGo_Cursor         = 1<<3;  // Cursor.d
const int LeGo_Focusnames     = 1<<4;  // Focusnames.d
const int LeGo_Random         = 1<<5;  // Random.d
const int LeGo_Bloodsplats    = 1<<6;  // Bloodsplats.d
const int LeGo_Saves          = 1<<7;  // Saves.d
const int LeGo_Shields        = 1<<8;  // Shields.d
const int LeGo_PermMem        = 1<<9;  // PermMemory.d
const int LeGo_Anim8          = 1<<10; // Anim8.d
const int LeGo_View           = 1<<11; // View.d
const int LeGo_Interface      = 1<<12; // Interface.d
const int LeGo_Bars           = 1<<13; // Bars.d
const int LeGo_Quickslots     = 1<<14; // Quickslots.d
const int LeGo_Buttons        = 1<<15; // Buttons.d
const int LeGo_Timer          = 1<<16; // Timer.d
const int LeGo_EventHandler   = 1<<17; // EventHandler.d
const int LeGo_Gamestate      = 1<<18; // Gamestate.d

const int LeGo_All            = (1<<19)-1; // Sämtliche Bibliotheken

//========================================
// [intern] Variablen
//========================================
const int _LeGo_Init = 0;
var int _LeGo_Loaded;

//========================================
// [intern] Abhängigkeiten bestimmen
//========================================
func void LeGo_InitFlags(var int f) {
    if(f & LeGo_Bloodsplats)    { f = f | LeGo_FrameFunctions | LeGo_HookEngine | LeGo_Random; };
    if(f & LeGo_Gamestate)      { f = f | LeGo_EventHandler | LeGo_Saves; };
    if(f & LeGo_EventHandler)   { f = f | LeGo_PermMem; };
    if(f & LeGo_PrintS)         { f = f | LeGo_AI_Function | LeGo_Anim8 | LeGo_Interface; };
    if(f & LeGo_Anim8)          { f = f | LeGo_PermMem | LeGo_FrameFunctions; };
    if(f & LeGo_FrameFunctions) { f = f | LeGo_PermMem | LeGo_HookEngine | LeGo_Timer; };
    if(f & LeGo_Cursor)         { f = f | LeGo_Interface | LeGo_View; };
    if(f & LeGo_Buttons)        { f = f | LeGo_PermMem | LeGo_View; };
    if(f & LeGo_Bars)           { f = f | LeGo_PermMem | LeGo_View; };
    if(f & LeGo_Quickslots)     { f = f | LeGo_PermMem | LeGo_Interface | LeGo_View | LeGo_HookEngine; };
    if(f & LeGo_View)           { f = f | LeGo_PermMem; };
    if(f & LeGo_Interface)      { f = f | LeGo_PermMem; };
    if(f & LeGo_PermMem)        { f = f | LeGo_Saves; };
    if(f & LeGo_Saves)          { f = f | LeGo_HookEngine; };
    _LeGo_Flags = f;
};

//========================================
// [intern] Immer
//========================================
func void LeGo_InitAlways(var int f) {
    if(f & LeGo_PermMem) {
        if(Handles) {
            // Weltenwechsel
            HandlesObj = MEM_PtrToInst(Handles);
        };
        if((Handles)&&(!_LeGo_Loaded)) {
            // Passiert bei 'Neues Spiel' -> 'Neues Spiel'
            _PM_Reset();
        };
    };

    if(_LeGo_Loaded) {
        // Wenn ein Spielstand geladen wird
        if(f & LeGo_Saves) {
            _BR_LoadGame();
        };
    };

    if(!_LeGo_Loaded) {
        // Nur beim ersten Spielstart
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
            FF_Apply(_Anim8_FFLoop);
        };
    };

    if(f & LeGo_Quickslots) {
        _QS_Init();
    };
};

//========================================
// [intern] Nur bei Spielstart
//========================================
func void LeGo_InitGamestart(var int f) {
    if(f & LeGo_Cursor) {
        HookEngineF(5062907, 5, _CURSOR_GETVAL);
    };

    if(f & LeGo_Shields) {
        HookEngineF(oCNpc__EV_DrawWeapon,    6, _EVT_SHIELD_DRAW);
        HookEngineF(oCNpc__EV_DrawWeapon1,   5, _EVT_SHIELD_DRAW);
        HookEngineF(oCNpc__EV_RemoveWeapon,  7, _EVT_SHIELD_REMOVE);
        HookEngineF(oCNpc__EV_RemoveWeapon1, 7, _EVT_SHIELD_REMOVE);
        HookEngineF(oCNpc__EquipItem,        7, _EVT_SHIELD_EQUIP);
        HookEngineF(oCNpc__UnequipItem,      6, _EVT_SHIELD_UNEQUIP);
        HookEngineF(oCNpc__DropUnconscious,  7, _EVT_SHIELD_DROP);
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

    if(f & LeGo_Saves) {
        HookEngineF(oCSavegameManager__SetAndWriteSavegame, 5, _BW_SAVEGAME);
    };

    if(f & LeGo_Timer) {
        _Timer_Init();
    };
	
	if (f & LeGo_Interface) {	
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

    MEM_Info(ConcatStrings(LeGo_Version, " wird initialisiert."));

    LeGo_InitFlags(flags);

    if(!_LeGo_Init) {
        LeGo_InitGamestart(_LeGo_Flags);
    };

    LeGo_InitAlways(_LeGo_Flags);

    _LeGo_Init = 1;
    _LeGo_Loaded = 1;
	
	
};



