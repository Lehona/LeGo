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
const string LeGo_Version = "LeGo 2.3.2";

const int LeGo_PrintS         = 1<<0;  // Interface.d
const int LeGo_HookEngine     = 1<<1;  // HookEngine.d
const int LeGo_AI_Function    = 1<<2;  // AI_Function.d
const int LeGo_Trialoge       = 1<<3;  // Trialoge.d
const int LeGo_Dialoggestures = 1<<4;  // Dialoggestures.d
const int LeGo_FrameFunctions = 1<<5;  // FrameFunctions.d
const int LeGo_Cursor         = 1<<6;  // Cursor.d
const int LeGo_Focusnames     = 1<<7;  // Focusnames.d
const int LeGo_Random         = 1<<8;  // Random.d
const int LeGo_Bloodsplats    = 1<<9;  // Bloodsplats.d
const int LeGo_Saves          = 1<<10;  // Saves.d
const int LeGo_PermMem        = 1<<11;  // PermMemory.d
const int LeGo_Anim8          = 1<<12;  // Anim8.d
const int LeGo_View           = 1<<13; // View.d
const int LeGo_Interface      = 1<<14; // Interface.d
const int LeGo_Bars           = 1<<15; // Bars.d
const int LeGo_Buttons        = 1<<16; // Buttons.d
const int LeGo_Timer          = 1<<17; // Timer.d
const int LeGo_EventHandler   = 1<<18; // EventHandler.d
const int LeGo_Gamestate      = 1<<19; // Gamestate.d
const int LeGo_Sprite         = 1<<20; // Sprite.d
const int LeGo_Render          = 1<<21; // Render.d

const int LeGo_All            = (1<<22)-1; // Sämtliche Bibliotheken

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
    if(f & LeGo_Gamestate)      { f = f | LeGo_EventHandler | LeGo_Saves; };
    if(f & LeGo_Cursor)         { f = f | LeGo_Interface | LeGo_View; };
    if(f & LeGo_PrintS)         { f = f | LeGo_AI_Function | LeGo_Anim8 | LeGo_Interface; };
    if(f & LeGo_Anim8)          { f = f | LeGo_PermMem | LeGo_FrameFunctions | LeGo_Timer; };
    if(f & LeGo_Buttons)        { f = f | LeGo_PermMem | LeGo_View | LeGo_FrameFunctions; };
    if(f & LeGo_FrameFunctions) { f = f | LeGo_PermMem | LeGo_HookEngine | LeGo_Timer; };
    if(f & LeGo_Bars)           { f = f | LeGo_PermMem | LeGo_View; };
    if(f & LeGo_EventHandler)   { f = f | LeGo_PermMem; };
    if(f & LeGo_View)           { f = f | LeGo_PermMem; };
    if(f & LeGo_Interface)      { f = f | LeGo_PermMem; };
    if(f & LeGo_Sprite)         { f = f | LeGo_PermMem; };
    if(f & LeGo_PermMem)        { f = f | LeGo_Saves; };
    if(f & LeGo_Saves)          { f = f | LeGo_HookEngine; };
    _LeGo_Flags = f;
};

//========================================
// [intern] Immer
//========================================
func void LeGo_InitAlways(var int f) {
    if(f & LeGo_PermMem) {
        if(HandlesPointer) {
            // Weltenwechsel
        };
        if((_LeGo_Init)&&(!_LeGo_Loaded)) { // Aus einem Spiel heraus -> Neues Spiel
            _PM_Reset();
        };
    };

    if(f & LeGo_Timer) {
        _Timer_Init();
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

        if(f & LeGo_Cursor) {
            Cursor_Event = Event_Create();
        };

        if (f & LeGo_Render) {
            _render_list = new(zCList@);
        };

    };

    if (f & LeGo_Render) {
        _Render_RestorePointer();
        GameState_AddListener(_Render_RestorePointer_Listener);
    };

    if(f & LeGo_Interface) {
        // TODO: Check whether this is working!
        // TODO: Check whether log entries are invisible sometimes
        Print_fixPS();
    };
};

//========================================
// [intern] Nur bei Spielstart
//========================================
func void LeGo_InitGamestart(var int f) {
    if(f & LeGo_Cursor) {
        HookEngineF(5062907, 5, _CURSOR_GETVAL);
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

    if(f & LeGo_Sprite) {
        HookEngineF(zRND_D3D__EndFrame, 6, _Sprite_DoRender);
    };

    if (f & LeGo_Render) {
        _Render_Init();
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

    MEM_Info(ConcatStrings(LeGo_Version, " wurde erfolgreich initialisiert."));
};



