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
// const string _BUTTON_STRUCT = "auto|10";

func void _Button_Archiver(var _Button this) {
	if (this.userdata)     { PM_SaveInt("userdata",    this.userdata); };

	PM_SaveInt("posx",  this.posx);
	PM_SaveInt("posy",  this.posy);
	PM_SaveInt("posx2", this.posx2);
	PM_SaveInt("posy2", this.posy2);

	if (this.on_enter > 0) { PM_SaveFuncID("on_enter", this.on_enter); };
	if (this.on_leave > 0) { PM_SaveFuncID("on_leave", this.on_leave); };
	if (this.on_click > 0) { PM_SaveFuncID("on_click", this.on_click); };

	PM_SaveInt("view",  this.view); // Could also save it as classPtr to spare some handles?
	PM_SaveInt("state", this.state);
};

func void _Button_UnArchiver(var _Button this) {
	var int obj;
	if (PM_Exists("userdata")) { this.userdata = PM_Load("userdata"); };

	this.posx  = PM_Load("posx");
	this.posy  = PM_Load("posy");
	this.posx2 = PM_Load("posx2");
	this.posy2 = PM_Load("posy2");

	if (PM_Exists("on_enter")) {
		obj = _PM_SearchObj("on_enter");
		if (_PM_ObjectType(obj) == _PM_String) { // Compatibility
			this.on_enter = PM_LoadFuncID("on_enter");
		} else {
			this.on_enter = PM_Load("on_enter");
		};
	} else {
		this.on_enter = MEM_GetFuncID(Button_Null);
	};
	if (PM_Exists("on_leave")) {
		obj = _PM_SearchObj("on_leave");
		if (_PM_ObjectType(obj) == _PM_String) {
			this.on_leave = PM_LoadFuncID("on_leave");
		} else {
			this.on_leave = PM_Load("on_leave");
		};
	} else {
		this.on_leave = MEM_GetFuncID(Button_Null);
	};
	if (PM_Exists("on_click")) {
		obj = _PM_SearchObj("on_click");
		if (_PM_ObjectType(obj) == _PM_String) {
			this.on_click = PM_LoadFuncID("on_click");
		} else {
			this.on_click = PM_Load("on_click");
		};
	} else {
		this.on_click = MEM_GetFuncID(Button_Null);
	};

	this.view  = PM_Load("view");
	this.state = PM_Load("state");
};

func void _Button_Delete(var _Button btn) {
	// View might have been deleted already!
	if (Hlp_IsValidHandle(btn.view)) {
		View_Delete(btn.view);
	};
};

func void Button_Null(var int hndl) {};

instance _Button@(_Button);

//(posx|posy) refers to the upper left corner
func int Button_Create(var int posx, var int posy, var int width, var int height, var string tex, var func on_enter, var func on_leave, var func on_click) {
		
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
			
	return button+0;
};

func int Button_CreatePxl(var int posx, var int posy, var int width, var int height, var string tex, var func on_enter, var func on_leave, var func on_click) {
	return Button_Create(Print_ToVirtual(posx, PS_X), Print_ToVirtual(posy, PS_y), Print_ToVirtual(width, PS_X), Print_ToVirtual(height, PS_Y), tex, on_enter, on_leave, on_click);
};

func void Button_Delete(var int hndl) { 
	if (!Hlp_IsValidHandle(hndl)) {
		return;
	};
	
	delete(hndl);
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
		MEM_PushIntParam(hndl);
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
	var int width; width = btn.posx2 - btn.posx;
	var int height; height = btn.posy2 - btn.posy;
	View_MovePxl(btn.view, nposx, nposy);
	
	btn.posx += Print_ToVirtual(nposx, PS_X);
	btn.posx2 = btn.posx + width;
	
	btn.posy += Print_ToVirtual(nposy, PS_Y);
	btn.posy2 = btn.posy + height;
};

// Sadly I chose Pxl as the "default" Move. I regret that.
func void Button_MoveVrt(var int hndl, var int nvposx, var int nvposy) {
	Button_Move(hndl, Print_ToPixel(nvposx, PS_X), Print_ToPixel(nvposy, PS_Y));
};

func void Button_MoveTo(var int hndl, var int nposx, var int nposy) {
	var _Button btn; btn = get(hndl);
	var int width; width = btn.posx2 - btn.posx;
	var int height; height = btn.posy2 - btn.posy;
	View_MoveToPxl(btn.view, nposx, nposy);
	
	btn.posx = Print_ToVirtual(nposx, PS_X);
	btn.posx2 = btn.posx + width;
	
	btn.posy = Print_ToVirtual(nposy, PS_Y);
	btn.posy2 = btn.posy + height;
};

// Sadly I chose Pxl as the "default" MoveTo. I regret that.
func void Button_MoveToVrt(var int hndl, var int nvposx, var int nvposy) {
	Button_MoveTo(hndl, Print_ToPixel(nvposx, PS_X), Print_ToPixel(nvposy, PS_Y));
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

func int _Buttons_Do_Sub(var int btn_hndl) {
	var _Button btn; btn = get(btn_hndl);

	var int CY; CY = Print_ToVirtual(CURSOR_Y, PS_Y);
	var int CX; CX = Print_ToVirtual(CURSOR_X, PS_X);
	if (btn.state & BUTTON_ACTIVE) {
		if (btn.posx <= CX && btn.posx2 >= CX && btn.posy <= CY && btn.posy2 >= CY) {
			if (Cursor_Left==KEY_PRESSED) {
				MEM_PushIntParam(btn_hndl);
				MEM_CallByID(btn.on_click);
				// Might have been deleted just now
				if (!Hlp_IsValidHandle(btn_hndl)) {
					return rContinue;
				};
			};
			if ((btn.state & BUTTON_ENTERED)==0) {
				MEM_PushIntParam(btn_hndl);
				MEM_CallByID(btn.on_enter);
				// Might have been deleted just now
				if (!Hlp_IsValidHandle(btn_hndl)) {
					return rContinue;
				};
				btn.state = btn.state | BUTTON_ENTERED;
			};
		} else if (btn.state & BUTTON_ENTERED) {
			MEM_PushIntParam(btn_hndl);
			MEM_CallByID(btn.on_leave);
			// Might have been deleted just now
			if (!Hlp_IsValidHandle(btn_hndl)) {
				return rContinue;
			};
			btn.state = btn.state & ~BUTTON_ENTERED;
		}; 
	};

	return rContinue;
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
	
	foreachHndl(_Button@, _Buttons_Do_Sub);
};


