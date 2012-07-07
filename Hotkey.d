
const int HK_Key = 1;
const int HK_Alt = 2;
const int HK_Ctrl = 4;
const int HK_Shift = 8;

class gCHotkey {
	var int hotkey;
	var int altMod;
	var int shiftMod;
	var int ctrlMod;
	var int state;
	var int function; 
	var int data;
};

instance gCHotkey@(gCHotkey);
var int Hotkey_Curr; // gCHotkey@


var int _Hotkey_Array; // zCArray@

func int Hotkey_AddExtData(var int key, var int altM, var int shiftM, var int ctrlM, var func f, var int data) {
	var int h; h = new(gCHotkey@);
	var gCHotkey hk; hk = get(h);
	hk.hotkey = key;
	hk.altMod = altM;
	hk.shiftMod = shiftM;
	hk.ctrlMod = ctrlM;
	hk.function = MEM_GetFuncID(f);
	hk.data = data;
	if (MEM_ArrayIndexOf(getPtr(_Hotkey_Array), key != -1)) {
		MEM_ArrayInsert(getPtr(_Hotkey_Array), key);
	};
	return h;
};

func int Hotkey_AddExt(var int key, var int altM, var int shiftM, var int ctrlM, var func f) {
	return Hotkey_AddExtData(key, altM, shiftM, ctrlM, f, 0);
};

func int Hotkey_Add(var int key, var func f) {
	return Hotkey_AddExtData(key, 0, 0, 0, f, 0);
};
	
func int _Hotkey_State(var int key) {
	return MEM_ReadStatArr(MEMINT_KeyState, key);
};

func int __Hotkey_Do(var int hndl) {
	var gCHotkey h; h = get(hndl);
	if (_Hotkey_State(h.hotkey) == KEY_PRESSED) {
        h.state = h.state | HK_Key;
    } else if (_Hotkey_State(h.hotkey) == KEY_RELEASED) {
        h.state = h.state &~ HK_Key;
    };
	if (_Hotkey_State(KEY_LMENU) == KEY_PRESSED) {
		h.state = h.state | HK_Alt;
	} else if (_Hotkey_State(KEY_LMENU) == KEY_RELEASED) {
		h.state = h.state &~ HK_Alt;
	};
	if (_Hotkey_State(KEY_LSHIFT) == KEY_PRESSED) {
		h.state = h.state | HK_Shift;
	} else if (_Hotkey_State(KEY_LSHIFT) == KEY_RELEASED) {
		h.state = h.state &~ HK_Shift;
	};
	if (_Hotkey_State(KEY_LCONTROL) == KEY_PRESSED) {
		h.state = h.state | HK_Ctrl;
	} else if (_Hotkey_State(KEY_LCONTROL) == KEY_RELEASED) {
		h.state = h.state &~ HK_Ctrl;
	};
	var int isPressed; isPressed = h.state & HK_Key;
	if (h.altMod) 	{ isPressed = isPressed && (h.state & HK_Alt); };
	if (h.shiftMod) { isPressed = isPressed && (h.state & HK_Shift); };
	if (h.ctrlMod) 	{ isPressed = isPressed && (h.state & HK_Ctrl); };
	if (isPressed) {
		Hotkey_Curr = hndl;
		MEM_CallById(h.function);
		h.state = 0;
	};
	return rContinue;
};
	

	
func void _Hotkey_Do() {
	var int i; i = 0;
	var int k; // Purge
	var zCArray arr; arr = get(_Hotkey_Array);
	var int len; len = arr.numInArray;
	repeat(i, len);
		k = MEM_KeyState(MEM_ReadIntArray(arr.array, i));
	end;
	k = MEM_KeyState(KEY_LMENU);
	k = MEM_KeyState(KEY_LSHIFT);
	k = MEM_KeyState(KEY_LCONTROL);
	ForEachHndl(gCHotkey@, __Hotkey_Do);
};







