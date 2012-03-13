const int _Timer_Diff = 0;

func void _Timer_Init() {
	_Timer_Diff = MEM_GetSystemTime() - _Timer;
};

var int _Timer;
var int _Timer_Paused;
var int _Timer_PiM;
func int Timer() {
	if(!MEM_Game.timeStep) {
		if(_Timer_PiM) {
			return _Timer;
		};
	};
	if(_Timer_Paused) { return _Timer; };
	_Timer = MEM_GetSystemTime() - _Timer_Diff;
	return _Timer;
};

func int TimerF() {
	return mkf(Timer());
};

func void Timer_SetPause(var int on) {
	if(on) {
		_Timer_Paused = 1;
		return;
	};
	_Timer_Paused = 0;
	_Timer_Init();
};

func void Timer_SetPauseInMenu(var int on) {
	_Timer_PiM = on;
};