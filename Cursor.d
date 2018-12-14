/***********************************\
               CURSOR
\***********************************/

//========================================
// Uservariablen
//========================================
var int Cursor_X;
var int Cursor_Y;
var int Cursor_RelX; // float
var int Cursor_RelY; // float
var int Cursor_Wheel;
var int Cursor_Left;
var int Cursor_Mid;
var int Cursor_Right;
var int Cursor_NoEngine;

var int Cursor_Event; // gCEvent(h)

//========================================
// [intern] Variablen
//========================================
var int Cursor_fX;
var int Cursor_fY;

//========================================
// Cursor verstecken
//========================================
var int Cursor_Hndl;
func void Cursor_Hide() {
    if(!Hlp_IsValidHandle(Cursor_Hndl)) { return; };
	
    View_Close(Cursor_Hndl);
};

//========================================
// Cursor anzeigen
//========================================
func void Cursor_Show() {
    if(Hlp_IsValidHandle(Cursor_Hndl)) { View_Open(Cursor_Hndl); return; };
    Print_GetScreenSize();
    Cursor_X = Print_Screen[PS_X] / 2;
    Cursor_Y = Print_Screen[PS_Y] / 2;
    Cursor_fX = mkf(Cursor_X);
    Cursor_fY = mkf(Cursor_Y);
    Cursor_Hndl = View_CreatePxl(Cursor_X, Cursor_Y, Cursor_X+64, Cursor_Y+64);
    View_SetTexture(Cursor_Hndl, Cursor_Texture);
    View_Open(Cursor_Hndl);
};

//========================================
// Maussteuerung An-/Ausschalten
//========================================
func void SetMouseEnabled(var int bEnabled) {
    CALL_IntParam(!!bEnabled /*Nur zur Sicherheit*/);
    CALL_IntParam(2);
    CALL__thiscall(MEM_ReadInt(zCInput_zinput), zCInput_Win32__SetDeviceEnabled);
};

//========================================
// [intern] Klasse (von Engine genutzt)
//========================================
class _Cursor {
    var int relX;
    var int relY;
    var int wheel;
    var int keyLeft;
    var int keyMid;
    var int keyRight;
};

//========================================
// [intern] Tasten
//========================================
func void Cursor_KeyState(var int ptr, var int pressed) {
    var int keyState; keyState = MEM_ReadInt(ptr);
    // Kopiert aus der Ikarus.d
    if (keyState == KEY_UP) {
        if (pressed) {
            keyState = KEY_PRESSED;
        };
    } else if (keyState == KEY_PRESSED) {
        if (pressed) {
            keyState = KEY_HOLD;
        } else {
            keyState = KEY_RELEASED;
        };
    } else if (keyState == KEY_HOLD) {
        if (!pressed) {
            keyState = KEY_RELEASED;
        };
    } else {
        if (pressed) {
            keyState = KEY_PRESSED;
        } else {
            keyState = KEY_UP;
        };
    };
    MEM_WriteInt(ptr, keyState);
    return;
};

//========================================
// [intern] Enginehook
//========================================

func void Cursor_Update() {
    View_Top(Cursor_Hndl);
};

func void _Cursor_GetVal() {
    var _Cursor c; c = _^(Cursor_Ptr);

    Cursor_RelX = c.relX;
    Cursor_RelY = c.relY;
    Cursor_fX = addf(mulf(mkf(Cursor_RelX), mulf(MEM_ReadInt(Cursor_sX), mkf(2))), Cursor_fX);
    Cursor_fY = addf(mulf(mkf(Cursor_RelY), mulf(MEM_ReadInt(Cursor_sY), mkf(2))), Cursor_fY);

    Cursor_X = roundf(Cursor_fX);
    Cursor_Y = roundf(Cursor_fY);
    Cursor_Wheel = c.wheel;

    Cursor_KeyState(_@(Cursor_Left),  c.keyLeft);
    Cursor_KeyState(_@(Cursor_Right), c.keyRight);
    Cursor_KeyState(_@(Cursor_Mid),   c.keyMid);
	
	if(Cursor_Left == KEY_PRESSED) {
		Event_Execute(Cursor_Event, CUR_LeftClick);
	};
	if(Cursor_Right == KEY_PRESSED) {
		Event_Execute(Cursor_Event, CUR_RightClick);
	};
	if(Cursor_Mid == KEY_PRESSED) {
		Event_Execute(Cursor_Event, CUR_MidClick);
	};
	if(Cursor_Wheel != 0) {
		if(Cursor_Wheel > 0) {
			Event_Execute(Cursor_Event, CUR_WheelUp);
		}
		else {
			Event_Execute(Cursor_Event, CUR_WheelDown);
		};
	};

    Print_GetScreenSize();
    if(Cursor_X > Print_Screen[PS_X]) {
        Cursor_X = Print_Screen[PS_X];
        Cursor_fX = mkf(Cursor_X);
    }
    else if(Cursor_X < 0) {
        Cursor_X = 0;
        Cursor_fX = mkf(Cursor_X);
    };
    if(Cursor_Y > Print_Screen[PS_Y]) {
        Cursor_Y = Print_Screen[PS_Y];
        Cursor_fY = mkf(Cursor_Y);
    }
    else if(Cursor_Y < 0) {
        Cursor_Y = 0;
        Cursor_fY = mkf(Cursor_Y);
    };

    if(Cursor_NoEngine) {
        c.relX = 0;
        c.relY = 0;
        c.keyLeft = 0;
        c.keyMid = 0;
        c.keyRight = 0;
        c.wheel = 0;
    };

    if(!Hlp_IsValidHandle(Cursor_Hndl)) { return; };

    View_MoveToPxl(Cursor_Hndl, Cursor_X, Cursor_Y);
    Cursor_Update();
};


