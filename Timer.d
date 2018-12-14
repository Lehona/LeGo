/***********************************\
                TIMER
\***********************************/

//========================================
// [intern] Variablen
//========================================
const int _Timer_Diff = 0;
var int _Timer;
var int _Timer_Paused;
var int _Timer_PiM;

//========================================
// [intern] Initialisierung
//========================================
func void _Timer_Init() {
	_Timer_Diff = MEM_GetSystemTime() - _Timer;
};

//========================================
// Aktuelle Zeit holen
//========================================
func int Timer() {
	if(!MEM_Game.timeStep) {
		if(_Timer_PiM) {
			_Timer_Paused = 2;
			return _Timer;
		};
	};
	if(_Timer_Paused) {
		if(_Timer_Paused == 2) {
			_Timer_Paused = 0;
			_Timer_Init();
		}
		else {
			return _Timer;
		};
	};
	_Timer = MEM_GetSystemTime() - _Timer_Diff;
	return _Timer;
};

//========================================
// Aktuelle Zeit als float holen
//========================================
func int TimerF() {
	return mkf(Timer());
};

//========================================
// Timer pausieren
//========================================
func void Timer_SetPause(var int on) {
	if(on) {
		_Timer_Paused = 1;
		return;
	};
	_Timer_Paused = 0;
	_Timer_Init();
};

//========================================
// In Menüs automatisch pausieren?
//========================================
func void Timer_SetPauseInMenu(var int on) {
	_Timer_PiM = on;
};

//========================================
// Abfragen ob der Timer pausiert ist
//========================================
func int Timer_IsPaused() {
	return _Timer_Paused > 0;
};