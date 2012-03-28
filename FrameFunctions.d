/***********************************\
            FRAMEFUNCTIONS
\***********************************/

//========================================
// [intern] PM-Klasse
//========================================
class FFItem {
    var int fncID;
    var int next;
    var int delay;
    var int cycles;
};
instance FFItem@(FFItem);

func void FFItem_Archiver(var FFItem this) {
    PM_SaveFuncPtr("loop", this.fncID);
    if(this.next)  { PM_SaveInt("next",  this.next); };
    if(this.delay) { PM_SaveInt("delay", this.delay); };
    if(this.cycles != -1) {
        PM_SaveInt("cycles", this.cycles);
    };
};

func void FFItem_Unarchiver(var FFItem this) {
    this.fncID = PM_LoadFuncPtr("loop");
    if(PM_Exists("next"))  { this.next = PM_Load("next"); };
    if(PM_Exists("delay")) { this.delay = PM_Load("delay"); };
    if(PM_Exists("cycles")) {
        this.cycles = PM_Load("cycles");
    }
    else {
        this.cycles = -1;
    };
};

var int _FF_Symbol;

//========================================
// Funktion hinzufügen
//========================================
func void FF_ApplyExt(var func function, var int delay, var int cycles) {
    var int hndl; hndl = new(FFItem@);
    var FFItem itm; itm = get(hndl);
    itm.fncID = MEM_GetFuncPtr(function);
    itm.cycles = cycles;
    itm.delay = delay;
    itm.next = MEM_Timer.totalTime + itm.delay;
};

//========================================
// Funktion prüfen
//========================================
func int FF_Active(var func function) {
	_FF_Symbol = MEM_GetFuncPtr(function);
	foreachHndl(FFItem@, _FF_Active);
	return !_FF_Symbol;
};

func int _FF_Active(var int hndl) {
	if(MEM_ReadInt(getPtr(hndl)) != _FF_Symbol) {
		return continue;
	};
	_FF_Symbol = 0;
	return break;
};

//========================================
// Funktion hinzufügen (vereinfacht)
//========================================
func void FF_Apply(var func function) {
    FF_ApplyExt(function, 0, -1);
};

//========================================
// Funktion einmalig hinzufügen
//========================================
func void FF_ApplyOnceExt(var func function, var int delay, var int cycles) {
	if(FF_Active(function)) {
		return;
	};
	FF_ApplyExt(function, delay, cycles);
};

//========================================
// Funktion einmalig hinzufügen (vereinfacht)
//========================================
func void FF_ApplyOnce(var func function) {
	FF_ApplyOnceExt(function, 0, -1);
};

//========================================
// Funktion entfernen
//========================================
func void FF_Remove(var func function) {
	_FF_Symbol = MEM_GetFuncPtr(function);
	foreachHndl(FFItem@, _FF_RemoveL);
};

func int _FF_RemoveL(var int hndl) {
	if(MEM_ReadInt(getPtr(hndl)) != _FF_Symbol) {
		return continue;
	};
	delete(hndl);
	return break;
};

//========================================
// [intern] Enginehook
//========================================
func void _FF_Hook() {
	MEM_PushIntParam(FFItem@);
	MEM_GetFuncID(FrameFunctions);
	MEM_StackPos.position = foreachHndl_ptr;
};
func int FrameFunctions(var int hndl) {
    var FFItem itm; itm = get(hndl);

	MEM_Label(0);
    if(MEM_Timer.totalTime >= itm.next) {
        MEM_CallByPtr(itm.fncID);
        if(itm.cycles != -1) {
            itm.cycles -= 1;
            if(itm.cycles <= 0) {
                delete(hndl);
				return rContinue;
            };
        };
        if(itm.delay) {
            itm.next += itm.delay;
			MEM_Goto(0);
        };
    };
	
	return rContinue;
};


