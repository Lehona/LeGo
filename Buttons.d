// Interne Klasse

var int _Button_MO; // One Mouseover at a time
var int _Button_MO_Len;
var int _Button_Mo_Hi;

class _Button {
	var int userdata;
	
	var int posx;
	var int posy;
	var int posx2;
	var int posy2;
	
	var int on_enter;
	var int on_leave;
	var int on_click;

	// intern
	var int view; 	// zCView@
	var int state; 	

};
const string _BUTTON_STRUCT = "auto|10";
func void _Button_Delete(var _Button btn) {
	View_Delete(btn.view);
};

func void Button_Null(var int hndl) {};

const int MAX_BUTTONS = 256;
var int _Buttons[MAX_BUTTONS]; // Wer mehr Buttons hat, hat doch 'nen Rad ab :) Kann aber auch gerne erweitert werden.
var int _Buttons_NextSlot;
instance _Button@(_Button);

//(posx|posy) refers to the upper left corner
func int Button_Create(var int posx, var int posy, var int width, var int height, var string tex, var func on_enter, var func on_leave, var func on_click) {
	if (_Buttons_NextSlot == MAX_BUTTONS) {
		return 0;
	};
	
	var int button; button = new(_Button@);
	var _Button btn; btn = get(button);
	
	btn.posx = posx;
	btn.posy = posy;
	btn.posx2 = posx+width;
	btn.posy2 = posy+height;
	
	btn.on_enter = MEM_GetFuncID(on_enter);
	btn.on_leave = MEM_GetFuncID(on_leave);
	btn.on_click = MEM_GetFuncID(on_click);
	


	// intern
	btn.view = View_Create(posx, posy, posx+width, posy+height); // posy+height or posy-height???
	btn.state = 0; //off
	
	View_SetTexture(btn.view, tex);
			
				
	MEM_WriteStatArr(_Buttons, _Buttons_NextSlot, button);
	_Buttons_NextSlot += 1;
	return button+0;
};

func int Button_CreatePxl(var int posx, var int posy, var int width, var int height, var string tex, var func on_enter, var func on_leave, var func on_click) {
	return Button_Create(Print_ToVirtual(posx, PS_X), Print_ToVirtual(posy, PS_y), Print_ToVirtual(width, PS_X), Print_ToVirtual(height, PS_Y), tex, on_enter, on_leave, on_click);
};

func void Button_Delete(var int hndl) { 
	if (!Hlp_IsValidHandle(hndl)) {
		return;
	};
	var int i; i = 0;
	var int pos; pos = MEM_StackPos.position;
	if (i >= _Buttons_NextSlot) {
		return;
	};
	if (MEM_ReadStatArr(_Buttons, i) == hndl) {
		delete(hndl);
		var int tmp; tmp = MEM_ReadStatArr(_Buttons, _Buttons_NextSlot-1); // Letztes Element
		MEM_WriteStatArr(_Buttons, i, tmp);
		MEM_WriteStatArr(_Buttons, _Buttons_NextSlot-1, 0);
		_Buttons_NextSlot -= 1; // Array verkleinern
	};
	i += 1;
	MEM_StackPos.position = pos;
};
	

func void Button_Show(var int hndl) {
	var _Button btn; btn = get(hndl);
	if (btn.state & BUTTON_ACTIVE) { // It's already activated
		return;
	};
	
	View_Open(btn.view);
	
	btn.state = BUTTON_ACTIVE;
};

func void Button_Hide(var int hndl) {
	var _Button btn; btn = get(hndl);
	if (!(btn.state&BUTTON_ACTIVE)) { // It's already deactivated
		return;
	};
	
	View_Close(btn.view);
	
	btn.state = 0;
};

func void Button_SetTexture(var int hndl, var string tex) {
	var _Button btn; btn = get(hndl);
	
	View_SetTexture(btn.view, tex);
};

func void Button_SetCaption(var int hndl, var string caption, var string font) { 
	var _Button btn; btn = get(hndl);
	
	View_DeleteText(btn.view);
	
	var int len; len = Print_GetStringWidth(STR_Split(caption, Print_LineSeperator, 0), font);
	var int hi; hi = Print_GetFontHeight(font);
	
	var int lines; lines = STR_SplitCount(caption, Print_LineSeperator);
	var int xPos; xPos = (1<<13>>1)-(Print_ToVirtual(len, Print_ToPixel(btn.posx2-btn.posx, PS_X))/2);
	var int yPos; yPos = (1<<13>>1)-(Print_ToVirtual((hi*lines)/2, Print_ToPixel(btn.posy2-btn.posy, PS_Y))/2);
		
	View_AddText(btn.view, xPos, yPos, caption, font);
};


func void Button_DeleteMouseover() {
	if (!Hlp_IsValidHandle(_BUTTON_MO)) {
		return;
	};
	
	View_Close(_BUTTON_MO);
};
func void Button_CreateMouseover(var string text, var string font) {
	var int len; var int max; max = 0; var int i; i = 0; var int pos; pos = MEM_StackPos.position; 
	
	len = Print_GetStringWidth(STR_Split(text, Print_LineSeperator, i), font);
		if (len > max) { max = len; };
		i += 1;
		
		if (i < STR_SplitCount(text, Print_LineSeperator)) {
	MEM_StackPos.position = pos;
	};
	len = max; 
	_Button_MO_Len = len;
	
	var int hi; hi = Print_GetFontHeight(font);
	if (!_BUTTON_MO) {
		_BUTTON_MO = View_CreatePxl(CURSOR_X-2, CURSOR_Y-2, CURSOR_X+len+14, CURSOR_Y+(hi*STR_SplitCount(text, Print_LineSeperator)+2));
	} else {
		View_ResizePxl(_BUTTON_MO, len+14, hi*STR_SplitCount(text, Print_LineSeperator)+2);
	};
	_Button_MO_Hi = hi*STR_SplitCount(text, Print_LineSeperator)+2;
	
	View_SetTexture(_BUTTON_MO, "MO_BG.TGA");
	View_Open(_BUTTON_MO);

	
	
	var int txt; txt = Print_TextField(100, 100, text, font, Print_ToVirtual(hi, (hi*STR_SplitCount(text, Print_LineSeperator)+2))); //Print_CreateTextView(0, 0, text, font); 
	var zCView view; view = View_Get(_BUTTON_MO);
	
	view.fxopen = 0;
	view.fxclose = 0;
	
	if (view.textLines_next) {
		View_DeleteText(_BUTTON_MO);
	};
	view.textLines_next = txt; 
};	

func void Button_Activate(var int hndl) {
	var _Button btn; btn = get(hndl);
	btn.state = btn.state | BUTTON_ACTIVE;
};

func void Button_Deactivate(var int hndl) {
	var _Button btn; btn = get(hndl);
	if (btn.state & BUTTON_ENTERED) {
		MEM_CallByID(btn.on_leave);
	};
	btn.state = 0; // Purge all data
};

func void Button_SetUserData(var int hndl, var int data) {
	var _button btn; btn = get(hndl);
	btn.userdata = data;
};

func int Button_GetUserData(var int hndl) {
	var _Button btn; btn = get(hndl);
	return btn.userdata+0;
};
func int Button_GetState(var int hndl) {
	var _Button btn; btn = get(hndl);
	return btn.state+0; // Verschachteln
};
func void Button_Move(var int hndl, var int nposx, var int nposy) {
	var _Button btn; btn = get(hndl);
	
	View_MovePxl(btn.view, nposx, nposy);
};

func int Button_GetViewHandle(var int hndl) {
	var _Button btn; btn = get(hndl);
	return btn.view+0;
};

func int Button_GetViewPtr(var int hndl) {
	var _Button btn; btn = get(hndl);
	return View_GetPtr(btn.view)+0;
};

func zCView Button_GetView(var int hndl) {
	Button_GetViewPtr(hndl);
};

func int Button_GetCaptionPtr(var int hndl) {
	var _Button btn; btn = get(hndl);
	var zCView v; v = get(btn.view);
	return v.textLines_next;
};

	
func void Buttons_Do() {
	var _Button btn;
	
	var int y; y = CURSOR_Y+27;
	var int x; x = CURSOR_X+15;
	if (_BUTTON_MO) {
		if (CURSOR_Y+27+_Button_MO_Hi > Print_Screen[PS_Y]) {
			y = Print_Screen[PS_Y]-_Button_MO_Hi;
		};
		if (CURSOR_X+15+_Button_MO_Len > Print_Screen[PS_X]) {
			x = Print_Screen[PS_X]-_Button_Mo_Len;
		};
		View_MoveToPxl(_BUTTON_MO, x, y);
	};
	var int i; i = 0;
	var int pos; pos = MEM_StackPos.position;
		if (i >= _Buttons_NextSlot) {
			return;
		};
		
		btn = get(MEM_ReadStatArr(_Buttons, i));
		var int CY; CY = Print_ToVirtual(CURSOR_Y, PS_Y);
		var int CX; CX = Print_ToVirtual(CURSOR_X, PS_X);
		if (btn.state & BUTTON_ACTIVE) {
			if (btn.posx <= CX && btn.posx2 >= CX && btn.posy <= CY && btn.posy2 >= CY) {
				if (Cursor_Left==KEY_PRESSED) {
					MEM_PushIntParam(MEM_ReadStatArr(_Buttons, i));
					MEM_CallByID(btn.on_click);
				};
				if ((btn.state & BUTTON_ENTERED)==0) {
					MEM_PushIntParam(MEM_ReadStatArr(_Buttons, i));
					MEM_CallByID(btn.on_enter);
					btn.state = btn.state | BUTTON_ENTERED;
				};
			} else if (btn.state & BUTTON_ENTERED) {
				MEM_PushIntParam(MEM_ReadStatArr(_Buttons, i));
				MEM_CallByID(btn.on_leave);
				btn.state = btn.state & ~BUTTON_ENTERED;
			}; 
		};
				
		i += 1;
		MEM_StackPos.position = pos;
};


