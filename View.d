/***********************************\
                VIEW
\***********************************/

//========================================
// Klassen für PermMem
//========================================

instance zCView@ (zCView);

//========================================
// View erzeugen
//========================================
func void _View_Create(var int ptr, var int x1, var int y1, var int x2, var int y2) {
    CALL_IntParam(2);
    CALL_IntParam(y2);
    CALL_IntParam(x2);
    CALL_IntParam(y1);
    CALL_IntParam(x1);
    CALL__thiscall(ptr, zCView__zCView);
    var zCView vw; vw = MEM_PtrToInst(ptr);
    vw.fxOpen = 0; // Das sieht einfach nur hässlich aus.
    vw.fxClose = 0;
};
func int View_Create(var int x1, var int y1, var int x2, var int y2) {
    var int hndl; hndl = new(zCView@);
    var zCView v; v = get(hndl);
    _View_Create(getPtr(hndl), x1, y1, x2, y2);

    v.fxOpen = 0;
    v.fxClose = 0;
    return hndl;
};

//========================================
// View erzeugen (Pixel)
//========================================
func int View_CreatePxl(var int x1, var int y1, var int x2, var int y2) {
    return View_Create(Print_ToVirtual(x1, PS_X), Print_ToVirtual(y1, PS_Y),
                       Print_ToVirtual(x2, PS_X), Print_ToVirtual(y2, PS_Y));
};

//========================================
// View erzeugen (Mittelpunkt)
//========================================
func int View_CreateCenter(var int x, var int y, var int w, var int h) {
    return View_Create(x-(w>>1), y-(h>>1), x+((w+1)>>1), y+((h+1)>>1));
};

//========================================
// View erzeugen (Mittelpunkt)(Pixel)
//========================================
func int View_CreateCenterPxl(var int x, var int y, var int w, var int h) {
    return View_CreateCenter(Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y),
                             Print_ToVirtual(w, PS_X), Print_ToVirtual(h, PS_Y));
};

//========================================
// View holen
//========================================
func zCView View_Get(var int hndl) {
    get(hndl);
};

//========================================
// View als Pointer holen
//========================================
func int View_GetPtr(var int hndl) {
    getPtr(hndl);
};

//========================================
// View rendern (sollte nicht benutzt werden!)
//========================================
func void View_Render(var int hndl) {
    CALL__thiscall(getPtr(hndl), zCView__Render);
};


//========================================
// View eine Textur zuweisen
//========================================
func void _View_SetTexture(var int ptr, var string tex) {
    CALL_zStringPtrParam(tex);
    CALL__thiscall(ptr, zCView__InsertBack);
};
func void View_SetTexture(var int hndl, var string tex) {
    tex = STR_Upper(tex);
    _View_SetTexture(getPtr(hndl), tex);
};

func string View_GetTexture(var int hndl) {
    var zCView v; v = get(hndl);
    var zCObject obj; obj = MEM_PtrToInst(v.backtex);
    return obj.objectName;
};


//========================================
// View einfärben
//========================================

func void View_SetColor(var int hndl, var int zColor) {
    var zCView v; v = get(hndl);
    v.color = zColor;
};

func int View_GetColor(var int hndl) {
    var zCView v; v = get(hndl);
    return v.color;
};


//========================================
// View anzeigen
//========================================
func void _View_Open(var int ptr) {
    CALL__thiscall(ptr, zCView__Open);
};
func void View_Open(var int hndl) {
    CALL__thiscall(getPtr(hndl), zCView__Open);
};

//========================================
// View schließen
//========================================
func void _View_Close(var int ptr) {
    CALL__thiscall(ptr, zCView__Close);
};
func void View_Close(var int hndl) {
    CALL__thiscall(getPtr(hndl), zCView__Close);
};

//========================================
// View löschen
//========================================
func void zCView_Delete(var zCView this) {
	if (this.textlines_next) {
		//free(this.textlines_next, zCList__zCViewText@);
		this.textlines_next = 0;
	};
	CALL__thiscall(MEM_InstToPtr(this), zCView__@zCView);
};

 func void View_Delete(var int hndl) {
	var zCView v; v = MEM_PtrToInst(getPtr(hndl));
	zCView_Delete(v);
	release(hndl);
};


//========================================
// Größe ändern
//========================================
func void View_Resize(var int hndl, var int x, var int y) {
    var zCView v; v = get(hndl);
    if(y < 0) {
        CALL_IntParam(v.vsizey);
    }
    else {
        CALL_IntParam(y);
    };
    if(x < 0) {
        CALL_IntParam(v.vsizex);
    }
    else {
        CALL_IntParam(x);
    };
    CALL__thiscall(getPtr(hndl), zCView__SetSize);
};

//========================================
// Größe ändern (pxl)
//========================================
func void View_ResizePxl(var int hndl, var int x, var int y) {
    View_Resize(hndl, Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y));
};

//========================================
// Bewegen
//========================================
func void View_Move(var int hndl, var int x, var int y) {
    if(!Hlp_IsValidHandle(hndl)) { return; };
    var zCView v; v = get(hndl);
    CALL_IntParam(y);
    CALL_IntParam(x);
    CALL__thiscall(getPtr(hndl), zCView__Move);
};

//========================================
// Bewegen (pxl)
//========================================
func void View_MovePxl(var int hndl, var int x, var int y) {
    View_Move(hndl, Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y));
};

//========================================
// Bewegen (absolut)
//========================================
func void View_MoveTo(var int hndl, var int x, var int y) {
    var zCView v; v = get(hndl);
    if(x == -1) { x = v.vposx; };
    if(y == -1) { y = v.vposy; };
    View_Move(hndl, -v.vposx, -v.vposy);
    View_Move(hndl, x,  y);
};

//========================================
// Bewegen (absolut)(pxl)
//========================================
func void View_MoveToPxl(var int hndl, var int x, var int y) {
    if(x != -1) { x = Print_ToVirtual(x, PS_X); };
    if(y != -1) { y = Print_ToVirtual(y, PS_Y); };
    View_MoveTo(hndl, x, y);
};

func void View_DeleteTextSub(var int listPtr) {
	var zCList l; l = MEM_PtrToInst(listPtr);
	MEM_Free(l.data);
};
func void View_DeleteText(var int hndl) {
	var zCView v; v = get(hndl);
	if (v.textLines_next) { 
		List_For(v.textLines_next, "View_DeleteTextSub");
		List_Destroy(v.textLines_next);
		v.textLines_next = 0;
	};
};

func void View_AddText(var int hndl, var int x, var int y, var string text, var string font) {
    if(!Hlp_IsValidHandle(hndl)) { return; };
    var zCView v; v = get(hndl);	
	var int ptr; ptr = Print_TextField(x, y, text, font, Print_ToVirtual(Print_GetFontHeight(font), v.pposy+v.psizey));
	if(v.textLines_next) {	
		List_Concat(v.textLines_next, ptr);
    }
    else {
        v.textLines_next = ptr;
    };
};

func void View_Top(var int hndl) {
    const int zCView_Top = 8021904; //007A6790
    Call__thiscall(getPtr(hndl), zCView_Top);
};


func void zCView_Archiver(var zCView this) {
    PM_SaveInt("_vtbl", this._vtbl);
    PM_SaveInt("_zCInputCallBack_vtbl", this._zCInputCallBack_vtbl);

    PM_SaveInt("m_bFillZ", this.m_bFillZ);
    PM_SaveInt("next", this.next);

    PM_SaveInt("ViewID", this.viewID);
    PM_SaveInt("flags", this.flags);
    PM_SaveInt("intflags", this.intflags);
    PM_SaveInt("onDesk", this.onDesk);

    PM_SaveInt("alphaFunc", this.alphaFunc);
    PM_SaveInt("color", this.color);
    PM_SaveInt("alpha", this.alpha);

    PM_SaveInt("childs_compare", this.childs_compare);
    PM_SaveInt("childs_count", this.childs_count);
    PM_SaveInt("childs_last", this.childs_last);
    PM_SaveInt("childs_wurzel", this.childs_wurzel);

    PM_SaveInt("owner", this.owner);

    PM_SaveString("backtex", zCTexture_GetName(this.backtex));

    PM_SaveInt("vposx", this.vposx);
    PM_SaveInt("vposy", this.vposy);
    PM_SaveInt("vsizex", this.vsizex);
    PM_SaveInt("vsizey", this.vsizey);

    PM_SaveInt("pposx", this.pposx);
    PM_SaveInt("pposy", this.pposy);
    PM_SaveInt("psizex", this.psizex);
    PM_SaveInt("psizey", this.psizey);
		
	PM_SaveString("font", Print_GetFontName(this.font));
    PM_SaveInt("fontColor", this.fontColor);

    PM_SaveInt("px1", this.px1);
    PM_SaveInt("py1", this.py1);
    PM_SaveInt("px2", this.px2);
    PM_SaveInt("py2", this.py2);

    PM_SaveInt("winx", this.winx);
    PM_SaveInt("winy", this.winy);

    PM_SaveClassPtr("textLines", this.textLines_next, "zCList__zCViewText");

    PM_SaveInt("scrollMaxTime", this.scrollMaxTime);
    PM_SaveInt("scrollTimer", this.scrollTimer);


    PM_SaveInt("fxOpen", this.fxOpen);
    PM_SaveInt("fxClose", this.fxClose);
    PM_SaveInt("timeDialog", this.timeDialog);
    PM_SaveInt("timeOpen", this.timeOpen);
    PM_SaveInt("timeClose", this.timeClose);
    PM_SaveInt("speedOpen", this.speedOpen);
    PM_SaveInt("speedClose", this.speedClose);
    PM_SaveInt("isOpen", this.isOpen);
    PM_SaveInt("isClosed", this.isClosed);
    PM_SaveInt("continueOpen", this.continueOpen);
    PM_SaveInt("continueClose", this.continueClose);
    PM_SaveInt("removeOnClose", this.removeOnClose);
    PM_SaveInt("resizeOnOpen", this.resizeOnOpen);
    PM_SaveInt("maxTextLength", this.maxTextLength);
    PM_SaveString("textMaxLength", this.textMaxLength);
    PM_SaveIntArray("posCurrent_0", _@(this.posCurrent_0), 2);
    PM_SaveIntArray("posCurrent_1", _@(this.posCurrent_1), 2);
    PM_SaveIntArray("posOpenClose_0", _@(this.posOpenClose_0), 2);
    PM_SaveIntArray("posOpenClose_1", _@(this.posOpenClose_1), 2);

};

func void zCView_Unarchiver(var zCView this) {
	var int vx1; vx1 = PM_Load("vposx");
	var int vy1; vy1 = PM_Load("vposy");
	var int vx2; vx2 = vx1 + PM_Load("vsizex");
	var int vy2; vy2 = vy1 + PM_Load("vsizey");
	
	_View_Create(MEM_InstToPtr(this), vx1, vy1, vx2, vy2);

	this._vtbl = PM_LoadInt("_vtbl");
	this._zCInputCallBack_vtbl = PM_LoadInt("_zCInputCallBack_vtbl");
	
	this.m_bFillZ = PM_LoadInt("m_bFillZ");
	// this.next = PM_LoadInt("next"); // Darf ich nicht überschreiben, habs der Übersicht halber aber hier gelassen
	
	this.viewID = PM_LoadInt("ViewID");
	this.flags = PM_LoadInt("flags");
	this.intflags = PM_LoadInt("intflags");

    // this.onDesk darf nicht geladen werden.

	
	this.alphaFunc = PM_LoadInt("alphaFunc");
	this.color = PM_LoadInt("color");
	this.alpha = PM_LoadInt("alpha");
	
	
	
	
	/*this.childs_compare = PM_LoadInt("childs_compare"); // Darf ich eventuell überschreiben, ist aber eh Schwachsinn da Pointer
	this.childs_count = PM_LoadInt("childs_count");
	this.childs_last = PM_LoadInt("childs_last");
	this.childs_wurzel = PM_LoadInt("childs_wurzel"); */ 
	
	// this.owner = PM_LoadInt("owner"); // Darf ich nicht überschreiben, habs der Übersicht halber aber hier gelassen
	
	_View_SetTexture(MEM_InstToPtr(this), PM_LoadString("backtex")); 
	
	this.vposx = PM_LoadInt("vposx");
	this.vposy = PM_LoadInt("vposy");
	this.vsizex = PM_LoadInt("vsizex");
	this.vsizey = PM_LoadInt("vsizey");
	
	this.pposx = PM_LoadInt("pposx");
	this.pposy = PM_LoadInt("pposy");
	this.psizex = PM_LoadInt("psizex");
	this.psizey = PM_LoadInt("psizey");

	
	this.font = Print_GetFontPtr(PM_LoadString("font"));
	
	this.fontColor = PM_LoadInt("fontColor");
	
	this.px1 = PM_LoadInt("px1");
	this.py1 = PM_LoadInt("py1");
	this.px2 = PM_LoadInt("px2");
	this.py2 = PM_LoadInt("py2");
	
	this.winx = PM_LoadInt("winx");
	this.winy = PM_LoadInt("winy");
	
	this.scrollMaxTime = PM_LoadInt("scrollMaxTime");
	this.scrollTimer = PM_LoadInt("scrollTimer");

    this.fxOpen = PM_LoadInt("fxOpen");
    this.fxClose = PM_LoadInt("fxClose");
    this.timeDialog =  PM_LoadInt("timeDialog");
    this.timeOpen = PM_LoadInt("timeOpen");
    this.timeClose = PM_LoadInt("timeClose");
    this.speedOpen = PM_LoadInt("speedOpen");
    this.speedClose = PM_LoadInt("speedClose");
    this.isOpen = PM_LoadInt("isOpen");
    this.isClosed = PM_LoadInt("isClosed");
    this.continueOpen = PM_LoadInt("continueOpen");
    this.continueClose = PM_LoadInt("continueClose");
    this.removeOnClose = PM_LoadInt("removeOnClose");
    this.resizeOnOpen = PM_LoadInt("resizeOnOpen");
    this.maxTextLength = PM_LoadInt("maxTextLength");
    this.textMaxLength = PM_LoadString("textMaxLength");
    PM_LoadArrayToPtr("posCurrent_0", _@(this.posCurrent_0));
    PM_LoadArrayToPtr("posCurrent_1", _@(this.posCurrent_1));
    PM_LoadArrayToPtr("posOpenClose_0", _@(this.posOpenClose_0));
    PM_LoadArrayToPtr("posOpenClose_1", _@(this.posOpenClose_1));
	
	
	if (this.intFlags) {
		_View_Open(MEM_InstToPtr(this));
	}; 
	
	this.textLines_next = PM_LoadClassPtr("textLines"); // Muss ich nach dem öffnen machen... >.>

};




