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
	var int data;
	var int hasData;
	var int gametime;
};
instance FFItem@(FFItem);

func void FFItem_Archiver(var FFItem this) {
    PM_SaveFuncPtr("loop", this.fncID);
    if(this.next)  { PM_SaveInt("next",  this.next); };
    if(this.delay) { PM_SaveInt("delay", this.delay); };
    if(this.cycles != -1) {
        PM_SaveInt("cycles", this.cycles);
    };
	if (this.hasData) { PM_SaveInt("data", this.data); };
	if (this.gametime) { PM_SaveInt("gametime", this.gametime); };
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
	if (PM_Exists("data")) {
		this.data = PM_Load("data");
		this.hasData = 1;
	};

	if (PM_Exists("gametime")) {
		this.gametime = PM_Load("gametime");
	};

    // Fix function signature of invalid functions
    if (this.fncID == MEM_GetFuncPtr(_PM_EmptyFunc_int)) && (!this.hasData) {
        this.fncID = MEM_GetFuncPtr(_PM_EmptyFunc_void);
    };
};

var int _FF_Symbol;

//========================================
// Funktion hinzuf�gen
//========================================

func void _FF_Create(var func function, var int delay, var int cycles, var int hasData, var int data, var int gametime) {
	var int hndl; hndl = new(FFItem@);
    var FFItem itm; itm = get(hndl);
    itm.fncID = MEM_GetFuncPtr(function);
    itm.cycles = cycles;
    itm.delay = delay;
	itm.data = data;
	itm.hasData = hasData;
	itm.gametime = gametime;
	if (gametime) {
		itm.next = TimerGT() + itm.delay;
	} else {
		itm.next = Timer() + itm.delay;
	};
};

func void FF_ApplyExtData(var func function, var int delay, var int cycles, var int data) {
	_FF_Create(function, delay, cycles, true, data, false);
};

func void FF_ApplyExt(var func function, var int delay, var int cycles) {
	_FF_Create(function, delay, cycles, false, 0, false);
};

func void FF_ApplyExtDataGT(var func function, var int delay, var int cycles, var int data) {
	_FF_Create(function, delay, cycles, true, data, true);
};

func void FF_ApplyExtGT(var func function, var int delay, var int cycles) {
	_FF_Create(function, delay, cycles, false, 0, true);
};

//========================================
// Funktion pr�fen
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
// Funktion hinzuf�gen (vereinfacht)
//========================================
func void FF_Apply(var func function) {
    FF_ApplyExt(function, 0, -1);
};

func void FF_ApplyGT(var func function) {
	FF_ApplyExtGT(function, 0, -1);
};

//========================================
// Funktion einmalig hinzuf�gen
//========================================
func void FF_ApplyOnceExt(var func function, var int delay, var int cycles) {
    if(FF_Active(function)) {
        return;
    };
    FF_ApplyExt(function, delay, cycles);
};

func void FF_ApplyOnceExtGT(var func function, var int delay, var int cycles) {
    if(FF_Active(function)) {
        return;
    };
    FF_ApplyExtGT(function, delay, cycles);
};

//========================================
// Funktion einmalig hinzuf�gen (vereinfacht)
//========================================
func void FF_ApplyOnce(var func function) {
    FF_ApplyOnceExt(function, 0, -1);
};

func void FF_ApplyOnceGT(var func function) {
    FF_ApplyOnceExtGT(function, 0, -1);
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

func void FF_RemoveAll(var func function) {
    _FF_Symbol = MEM_GetFuncPtr(function);
    foreachHndl(FFItem@, _FF_RemoveAllL);
};

func int _FF_RemoveAllL(var int hndl) {
    if(MEM_ReadInt(getPtr(hndl)) != _FF_Symbol) {
        return continue;
    };
    delete(hndl);
    return continue;
};

//========================================
// [intern] Enginehook
//========================================
func void _FF_Hook() {
	if(!Hlp_IsValidNpc(hero)) { return; };

    foreachHndl(FFItem@, FrameFunctions);
};


func int FrameFunctions(var int hndl) {
    var FFItem itm; itm = get(hndl);

	var int timer;
    var int t; t = Timer();
	var int tgt; tgt = TimerGT();

	if (itm.gametime) {
		timer = tgt;
	} else {
		timer = t;
	};

    MEM_Label(0);
    if(timer >= itm.next) {
        // Backup data stack pointer
        var int sptr; sptr = MEM_Parser.datastack_sptr;

        // Call function
		if (itm.hasData) {
			itm.data;
		};
        MEM_CallByPtr(itm.fncID);

        // Restore data stack pointer
        MEM_Parser.datastack_sptr = sptr;

        // If a FrameFunction removes itself while its delay is small enough s.t. MEM_Goto(0) is called below,
        // the game crashes, because MEM_CallByPtr moves the stack pointer to an invalid position.
        if (!Hlp_IsValidHandle(hndl)) {
            return rContinue;
        };

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
        } else {
            // Minimally increase to prevent running during menu if PiM or GT, i.e. while timer will not increase, the
            // above condition (timer >= itm.next) will always be satisfied.
            itm.next = timer + 1;
        };
    };


    return rContinue;
};



/***********************************\
	The following code has been supplied by
	Frank-95 (https://forum.worldofplayers.de/forum/members/148085-Frank-95)
\***********************************/

//========================================
// Remove FF with the specified data
//========================================

var int _FF_Data;

func int _FF_RemoveLData(var int hndl)
{
    if(MEM_ReadInt(getPtr(hndl)) != _FF_Symbol)
    {
        return continue;
    };

    var FFItem itm; itm = get(hndl);
    if(itm.data != _FF_Data)
    {
        return continue;
    }
    else
    {
        delete(hndl);
        return break;
    };
};

func void FF_RemoveData(var func function, var int data)
{
    _FF_Data = data;
    _FF_Symbol = MEM_GetFuncPtr(function);
    foreachHndl(FFItem@, _FF_RemoveLData);
};

//=======================================================
// Check whether FF with the specified data is active
//=======================================================


func int _FF_ActiveData(var int hndl)
{
    if(MEM_ReadInt(getPtr(hndl)) != _FF_Symbol)
    {
        return continue;
    };

    var FFItem itm; itm = get(hndl);
    if(itm.data != _FF_Data)
    {
        return continue;
    }
    else
    {
        _FF_Symbol = 0;
        return break;
    };
};

func int FF_ActiveData(var func function, var int data)
{
    _FF_Data = data;
    _FF_Symbol = MEM_GetFuncPtr(function);
    foreachHndl(FFItem@, _FF_ActiveData);
    return !_FF_Symbol;
};

//========================================
// More FFdata functions
//========================================

func void FF_ApplyData(var func function, var int data)
{
    FF_ApplyExtData(function, 0, -1, data);
};

func void FF_ApplyOnceExtData(var func function, var int delay, var int cycles, var int data)
{
    if(FF_ActiveData(function,data))
    {
        return;
    };

    FF_ApplyExtData(function, delay, cycles, data);
};

func void FF_ApplyOnceData(var func function, var int data)
{
    FF_ApplyOnceExtData(function, 0, -1, data);
};


