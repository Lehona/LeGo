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
|*************************************************************************|
|                                                                         |
| ----------------------------------------------------------------------- |
| Information                                                             |
| ----------------------------------------------------------------------- |
| Dieses Scriptpaket benötigt IKARUS und das FLOATPAKET von Sektenspinner |
| Alle Funktionen die ein '_' vor dem eigentlichen Namen tragen sind      |
| interne Funktionen, sprich: Sie sind entweder unzureichend abgesichert  |
| oder funktionieren unter Umständen nur in einem bestimmten Kontext. Sie |
| sollten möglichst nicht verwendet werden. (Im Normalfall gibt es eine   |
| abgesicherte "Verpackung" dazu.)                                        |
|                                                                         |
| ----------------------------------------------------------------------- |
| Table of Contents                                                       |
| ----------------------------------------------------------------------- |
|                                                                         |
| === 1. Werkzeuge ===                                                    |
| 1.1  PermMem                                                            |
|       Sehr mächtiges Paket um mit Klassen/Pointern vollständig arbeiten |
|       zu können. (Normalerweise verfliegen diese spätestens nach einem  |
|       Neustart)                                                         |
| 1.2  HookEngine                                                         |
|       Scriptfunktionen an beliebigen Punkten von Enginefunktionen       |
|       aufrufen                                                          |
| 1.3  AI_Function                                                        |
|       Scriptfunktionen in die AI-Queue von Npcs einreihen               |
| 1.4  FrameFunctions                                                     |
|       Scriptschleifen ohne Trigger                                      |
| 1.5  Interface                                                          |
|       Pixelgenaues Printen von Texten, ua. mit einstellbarer Textfarbe  |
| 1.6  View                                                               |
|       Arbeiten mit Texturen auf dem Bildschirm                          |
| 1.7  Random                                                             |
|       Eine verbesserte Zufallsfunktion                                  |
| 1.8  BinaryMachines                                                     |
|       Lesen und schreiben von Dateien                                   |
| 1.9  Locals                                                             |
|       Daedalus bietet keine lokalen Variablen. Bei rekursiven           |
|       Funktionen kann das zu Problemen führen. Locals erlaubt Variablen |
|       temporär auf einem Pseudo-Stack zu sichern.                       |
| 1.10 List                                                               |
|       Vereinfachter Umgang mit zCList und zCListSort                    |
| 1.11 Int64                                                              |
|       Grundlegende Arithmetik für 64bit Integer                         |
|                                                                         |
| === 2. Anwendungen ===                                                  |
| 2.1  Anim8                                                              |
|       "Animieren" von Werten (Mover ohne Scripte zB.)                   |
| 2.2  Names                                                              |
|       Den Namen eines Npcs erst anzeigen wenn er bekannt ist            |
| 2.3  Dialoggestures                                                     |
|       Emotionen in Dialogen                                             |
| 2.4  Cursor                                                             |
|       Ingame mit der Maus arbeiten                                      |
| 2.5  Bloodsplats                                                        |
|       Blutspritzer auf den Bildschirm                                   |
| 2.6  Trialoge                                                           |
|       Dialoge mit beliebig vielen Npcs und Kamerafahrten                |
| 2.7  Saves                                                              |
|       Eigene Speicherdateien um zB. Strings zu sichern                  |
|       (Ziemlich hinfällig da PermMem Saves vereinfacht verwendet)       |
| 2.8  Shields                                                            |
|       Scriptseitige Methode um Schilde zu verwenden (ALPHA)             |
| 2.9  Focusnames                                                         |
|       Farbige Fokusnamen nach Attitüde des Npcs                         |
| 2.10 Bars                                                               |
|       Eigene Balken auf dem Bildschirm anzeigen                         |
| 2.11 Quickslots                                                         |
|       Quickslot-Leiste wie in Gothic 3                                  |
|                                                                         |
\*************************************************************************/

/***********************************\
                LEGO
\***********************************/

/* Info:
 *  Ist einfach nur genial :>
 *
 * Inhalt:
 *  void LeGo_Init(int flags)
 *     Initialisiert LeGo mit den angegebenen Bibliotheken
 *     flags   : Die Bibliotheken die zu aktivieren sind. (Benutzung über die folgenden Konstanten)
 *     Beispiel: LeGo_Init(LeGo_HookEngine | LeGo_FrameFunctions); // HookEngine und FrameFunctions
 *               LeGo_Init(LeGo_All & ~LeGo_Focusnames);           // Alle außer Focusnames
 */

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

const int LeGo_All            = (1<<17)-1; // Sämtliche Bibliotheken

//========================================
// [intern] Variablen
//========================================
const int _LeGo_Init = 0;
var int _LeGo_Loaded;

//========================================
// LeGo initialisieren
//========================================

// Alle Abhängigkeiten bestimmen
func void LeGo_InitFlags(var int f) {
    if(f & LeGo_Bloodsplats)    { f = f | LeGo_FrameFunctions | LeGo_HookEngine | LeGo_Random; };
    if(f & LeGo_PrintS)         { f = f | LeGo_AI_Function | LeGo_Anim8 | LeGo_Interface; };
    if(f & LeGo_Anim8)          { f = f | LeGo_PermMem | LeGo_FrameFunctions; };
    if(f & LeGo_FrameFunctions) { f = f | LeGo_PermMem | LeGo_HookEngine | LeGo_Timer; };
    if(f & LeGo_Cursor)         { f = f | LeGo_Interface; };
    if(f & LeGo_Buttons)        { f = f | LeGo_PermMem | LeGo_View; };
    if(f & LeGo_Bars)           { f = f | LeGo_PermMem | LeGo_View; };
    if(f & LeGo_Quickslots)     { f = f | LeGo_PermMem | LeGo_Interface | LeGo_View | LeGo_HookEngine; };
    if(f & LeGo_View)           { f = f | LeGo_PermMem; };
    if(f & LeGo_Interface)      { f = f | LeGo_PermMem; };
    if(f & LeGo_PermMem)        { f = f | LeGo_Saves; };
    if(f & LeGo_Saves)          { f = f | LeGo_HookEngine; };
    _LeGo_Flags = f;
};

// Wird bei jedem Init aufgerufen
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
        if(f & LeGo_Buttons) {
            FF_Apply(Buttons_Do);
        };

        if(f & LeGo_Bloodsplats) {
            FF_Apply(_Bloodsplats_Loop);
        };

        if(f & LeGo_Anim8) {
            FF_Apply(_Anim8_Loop);
        };
    };
	
	if(f & LeGo_Timer) {
		_Timer_Init();
	};

    if(f & LeGo_Quickslots) {
        _QS_Init();
    };
};

// Wird bei jedem SPIELSTART aufgerufen
func void LeGo_InitGamestart(var int f) {
    if(f & LeGo_Cursor) {
        HookEngine(5062907, 5, "_CURSOR_GETVAL");
    };

    if(f & LeGo_Shields) {
        HookEngine(oCNpc__EV_DrawWeapon,    6, "_EVT_SHIELD_DRAW");
        HookEngine(oCNpc__EV_DrawWeapon1,   5, "_EVT_SHIELD_DRAW");
        HookEngine(oCNpc__EV_RemoveWeapon,  7, "_EVT_SHIELD_REMOVE");
        HookEngine(oCNpc__EV_RemoveWeapon1, 7, "_EVT_SHIELD_REMOVE");
        HookEngine(oCNpc__EquipItem,        7, "_EVT_SHIELD_EQUIP");
        HookEngine(oCNpc__UnequipItem,      6, "_EVT_SHIELD_UNEQUIP");
        HookEngine(oCNpc__DropUnconscious,  7, "_EVT_SHIELD_DROP");
    };

    if(f & LeGo_Random) {
        r_DefaultInit();
    };

    if(f & LeGo_Focusnames) {
        HookEngine(oCGame__UpdateStatus, 8, "_FOCUSNAMES");
    };

    if(f & LeGo_AI_Function) {
        HookEngine(oCNPC__EV_PlayAni, 5, "_AI_FUNCTION_EVENT");
    };

    if(f & LeGo_FrameFunctions) {
        HookEngine(oCGame__Render, 7, "_FF_LOOP");
    };

    if(f & LeGo_Saves) {
        HookEngine(oCSavegameManager__SetAndWriteSavegame, 5, "_BW_SAVEGAME");
    };
};

func void LeGo_Init(var int flags) {
    if(!MEM_CheckVersion(1,2,0)) {
        MEM_Error("LeGo benötigt mindestens Ikarus 1.2!");
		return;
    };

    MEM_InitAll();

    LeGo_InitFlags(flags);

    if(!_LeGo_Init) {
        LeGo_InitGamestart(_LeGo_Flags);
    };

    LeGo_InitAlways(_LeGo_Flags);

    _LeGo_Init = 1;
    _LeGo_Loaded = 1;
};



