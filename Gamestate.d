/***********************************\
              GAMESTATE
\***********************************/

//========================================
// Globals Gamestate-Variable
//========================================
// Konstanten in Userconst.d
var int Gamestate;

//========================================
// [intern] Variablen
//========================================
var int _Gamestate_Event;

//========================================
// Listener für Gamestate hinzufügen
//========================================
func void Gamestate_AddListener(var func f) {
    Event_AddOnce(_Gamestate_Event, f);
};

//========================================
// Listener für Gamestate entfernen
//========================================
func void Gamestate_RemoveListener(var func f) {
    Event_Remove(_Gamestate_Event, f);
};

//========================================
// [intern] Initialisierung
//========================================
func void _Gamestate_InitLate() {
    Event_Execute(_Gamestate_Event, Gamestate);
};

func void _Gamestate_Init(var int state) {
    if(!_Gamestate_Event) {
        _Gamestate_Event = Event_Create();
    };
    Gamestate = state;
    if(state == Gamestate_NewGame) {
        FF_ApplyExt(_Gamestate_InitLate, 1, 1);
    }
    else {
        _Gamestate_InitLate();
    };
};