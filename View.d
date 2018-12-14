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
func void _ViewPtr_CreateIntoPtr(var int ptr, var int x1, var int y1, var int x2, var int y2) {
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
func int ViewPtr_Create(var int x1, var int y1, var int x2, var int y2) {
    var int ptr; ptr = create(zCView@);
    _ViewPtr_CreateIntoPtr(ptr, x1, y1, x2, y2);
    return ptr;
};
func int View_Create(var int x1, var int y1, var int x2, var int y2) {
    var int hndl; hndl = new(zCView@);
    var zCView v; v = get(hndl);
    _ViewPtr_CreateIntoPtr(getPtr(hndl), x1, y1, x2, y2);
    return hndl;
};

func int ViewPtr_New() {
    return ViewPtr_Create(0, 0, 0, 0);
};
func int View_New() {
    return View_Create(0, 0, 0, 0);
};

//========================================
// View erzeugen (Pixel)
//========================================
func int ViewPtr_CreatePxl(var int x1, var int y1, var int x2, var int y2) {
    return ViewPtr_Create(Print_ToVirtual(x1, PS_X), Print_ToVirtual(y1, PS_Y),
                          Print_ToVirtual(x2, PS_X), Print_ToVirtual(y2, PS_Y));
};
func int View_CreatePxl(var int x1, var int y1, var int x2, var int y2) {
    return View_Create(Print_ToVirtual(x1, PS_X), Print_ToVirtual(y1, PS_Y),
                       Print_ToVirtual(x2, PS_X), Print_ToVirtual(y2, PS_Y));
};

//========================================
// View erzeugen (Mittelpunkt)
//========================================
func int ViewPtr_CreateCenter(var int x, var int y, var int w, var int h) {
    return ViewPtr_Create(x-(w>>1), y-(h>>1), x+((w+1)>>1), y+((h+1)>>1));
};
func int View_CreateCenter(var int x, var int y, var int w, var int h) {
    return View_Create(x-(w>>1), y-(h>>1), x+((w+1)>>1), y+((h+1)>>1));
};

//========================================
// View erzeugen (Mittelpunkt)(Pixel)
//========================================
func int ViewPtr_CreateCenterPxl(var int x, var int y, var int w, var int h) {
    return ViewPtr_CreateCenter(Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y),
                                Print_ToVirtual(w, PS_X), Print_ToVirtual(h, PS_Y));
};
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
func void ViewPtr_Render(var int ptr) {
    CALL__thiscall(ptr, zCView__Render);
};
func void View_Render(var int hndl) {
    ViewPtr_Render(getPtr(hndl));
};

//========================================
// View eine Textur zuweisen
//========================================
func void ViewPtr_SetTexture(var int ptr, var string tex) {
    tex = STR_Upper(tex);
    CALL_zStringPtrParam(tex);
    CALL__thiscall(ptr, zCView__InsertBack);
};
func void View_SetTexture(var int hndl, var string tex) {
    ViewPtr_SetTexture(getPtr(hndl), tex);
};

func string ViewPtr_GetTexture(var int ptr) {
    var zCView v; v = _^(ptr);
    var zCObject obj; obj = MEM_PtrToInst(v.backtex);
    return obj.objectName;
};
func string View_GetTexture(var int hndl) {
    return ViewPtr_GetTexture(getPtr(hndl));
};

//========================================
// Mark:
// View set alpha
//========================================
func void ViewPtr_SetAlpha(var int ptr, var int val) {
	var zCView v; v = _^(ptr);
	v.alpha = val;
	if((v.alpha != 255) && (v.alphafunc == 1)) {
        v.alphafunc = 2;
    };
};

func void View_SetAlpha(var int hndl,var int val) {
	ViewPtr_SetAlpha(getPtr(hndl), val);
};
//========================================
// Mark: View set alpha 
// (including all text within the view)
//========================================
func void ViewPtr_SetAlphaAll(var int ptr, var int val) {
	var zCView v; v = _^(ptr);
	v.alpha = val;
	if((v.alpha != 255) && (v.alphafunc == 1)) {
        v.alphafunc = 2;
    };
	if (v.textLines_next) { 
		var int list; list = v.textLines_next;
		var zCList l;
		while(list);
			l = _^(list);
			PrintPtr_SetAlpha(l.data,val);
			list = l.next;
		end;
	};
};

func void View_SetAlphaAll(var int hndl, var int val) {
	ViewPtr_SetAlphaAll(getPtr(hndl), val);
};

//========================================
// View einfärben
//========================================
func void ViewPtr_SetColor(var int ptr, var int zColor) {
    var zCView v; v = _^(ptr);
    v.color = zColor;
    ViewPtr_SetAlpha(ptr, (zColor >> zCOLOR_SHIFT_ALPHA) & zCOLOR_CHANNEL);
};
func void View_SetColor(var int hndl, var int zColor) {
	ViewPtr_SetColor(getPtr(hndl), zColor);
};

func int ViewPtr_GetColor(var int ptr) {
    var zCView v; v = _^(ptr);
    return v.color;
};
func int View_GetColor(var int hndl) {
    return ViewPtr_GetColor(getPtr(hndl));
};


//========================================
// View anzeigen
//========================================
func void ViewPtr_Open(var int ptr) {
    var zCView v; v = _^(ptr);
    var int textlinesBak; textlinesBak = v.textLines_next;
    v.textLines_next = 0;

    // zCView::Open destroys all textlines (why??)
    CALL__thiscall(ptr, zCView__Open);

    v.textLines_next = textlinesBak;
};
func void View_Open(var int hndl) {
    ViewPtr_Open(getPtr(hndl));
};

//========================================
// View schließen
//========================================
func void ViewPtr_Close(var int ptr) {
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

func void ViewPtr_Delete(var int ptr) {
    var zCView v; v = _^(ptr);
    zCView_Delete(v);
    MEM_Free(ptr);
};
func void View_Delete(var int hndl) {
    var zCView v; v = get(hndl);
    zCView_Delete(v);
    release(hndl);
};


//========================================
// Größe ändern
//========================================
func void ViewPtr_Resize(var int ptr, var int x, var int y) {
    var zCView v; v = _^(ptr);
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
    CALL__thiscall(ptr, zCView__SetSize);

    v.psizex = Print_ToPixel(v.vsizex, PS_X);
    v.psizey = Print_ToPixel(v.vsizey, PS_Y);
};
func void View_Resize(var int hndl, var int x, var int y) {
    ViewPtr_Resize(getPtr(hndl), x, y);
};

//========================================
// Größe ändern (pxl)
//========================================
func void ViewPtr_ResizePxl(var int ptr, var int x, var int y) {
    ViewPtr_Resize(ptr, Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y));
};
func void View_ResizePxl(var int hndl, var int x, var int y) {
    ViewPtr_ResizePxl(getPtr(hndl), x, y);
};

//========================================
// Bewegen
//========================================
func void ViewPtr_Move(var int ptr, var int x, var int y) {
    var zCView v; v = _^(ptr);
    CALL_IntParam(y);
    CALL_IntParam(x);
    CALL__thiscall(ptr, zCView__Move);

    v.pposx = Print_ToPixel(v.vposx, PS_X);
    v.pposy = Print_ToPixel(v.vposy, PS_Y);
};
func void View_Move(var int hndl, var int x, var int y) {
    ViewPtr_Move(getPtr(hndl), x, y);
};

//========================================
// Bewegen (pxl)
//========================================
func void ViewPtr_MovePxl(var int ptr, var int x, var int y) {
    ViewPtr_Move(ptr, Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y));
};
func void View_MovePxl(var int hndl, var int x, var int y) {
    ViewPtr_MovePxl(getPtr(hndl), x, y);
};

//========================================
// Bewegen (absolut)
//========================================
func void ViewPtr_MoveTo(var int ptr, var int x, var int y) {
    var zCView v; v = _^(ptr);
    if(x == -1) { x = v.vposx; };
    if(y == -1) { y = v.vposy; };
    ViewPtr_Move(ptr, -v.vposx, -v.vposy);
    ViewPtr_Move(ptr, x,  y);
};
func void View_MoveTo(var int hndl, var int x, var int y) {
    ViewPtr_MoveTo(getPtr(hndl), x, y);
};

//========================================
// Bewegen (absolut)(pxl)
//========================================
func void ViewPtr_MoveToPxl(var int ptr, var int x, var int y) {
    if(x != -1) { x = Print_ToVirtual(x, PS_X); };
    if(y != -1) { y = Print_ToVirtual(y, PS_Y); };
    ViewPtr_MoveTo(ptr, x, y);
};
func void View_MoveToPxl(var int hndl, var int x, var int y) {
    ViewPtr_MoveToPxl(getPtr(hndl), x, y);
};

//========================================
// Text entfernen
//========================================
func void View_DeleteTextSub(var int listPtr) {
    var zCList l; l = MEM_PtrToInst(listPtr);
    MEM_Free(l.data);
};
func void ViewPtr_DeleteText(var int ptr) {
    var zCView v; v = _^(ptr);
    if (v.textLines_next) {
        List_ForF(v.textLines_next, View_DeleteTextSub);
        List_Destroy(v.textLines_next);
        v.textLines_next = 0;
    };
};
func void View_DeleteText(var int hndl) {
    ViewPtr_DeleteText(getPtr(hndl));
};

//========================================
// Text hinzufügen
//========================================
func void ViewPtr_AddText(var int ptr, var int x, var int y, var string text, var string font, var int color) {
    var zCView v; v = _^(ptr);
    var int field; field = Print_TextFieldColored(x, y, text, font, Print_ToVirtual(Print_GetFontHeight(font), v.psizey), color);
    if(v.textLines_next) {
        List_Concat(v.textLines_next, field);
    }
    else {
        v.textLines_next = field;
    };
};
func void View_AddText(var int hndl, var int x, var int y, var string text, var string font) {
    ViewPtr_AddText(getPtr(hndl), x, y, text, font, -1);
};

func void View_AddTextColored(var int hndl, var int x, var int y, var string text, var string font, var int color) {
    ViewPtr_AddText(getPtr(hndl), x, y, text, font, color);
};

//========================================
// Textview hinzufügen
//========================================
func void ViewPtr_AddTextView(var int ptr, var int view) {
    var zCView v; v = _^(ptr);
    if(v.textLines_next) {
        List_Concat(v.textLines_next, view);
    }
    else {
        v.textLines_next = List_Create(view);
    };
};
func void View_AddTextView(var int hndl, var int view) {
    ViewPtr_AddTextView(getPtr(hndl), view);
};

//========================================
// Views ausrichten
//========================================
func void ViewPtr_SetMargin(var int ptr, var int parent, var int align, var int mT, var int mR, var int mB, var int mL) {
    var zCView v;
    if(!parent) {
        // using screen if no parent is given
        v = _^(MEM_ReadInt(screen));
    }
    else {
        v = _^(parent);
    };

    if(align == ALIGN_LEFT) {
        ViewPtr_MoveTo(ptr, v.vposx + mL, v.vposy + mT);
        ViewPtr_Resize(ptr, mR, v.vsizey - mT - mB);
    }
    else if(align == ALIGN_RIGHT) {
        ViewPtr_MoveTo(ptr, v.vposx + v.vsizex - mR - mL, v.vposy + mT);
        ViewPtr_Resize(ptr, mL, v.vsizey - mT - mB);
    }
    else if(align == ALIGN_TOP) {
        ViewPtr_MoveTo(ptr, v.vposx + mL, v.vposy + mT);
        ViewPtr_Resize(ptr, v.vsizex - mL - mR, mB);
    }
    else if(align == ALIGN_BOTTOM) {
        ViewPtr_MoveTo(ptr, v.vposx + mL, v.vposy + v.vsizey - mT - mB);
        ViewPtr_Resize(ptr, v.vsizex - mL - mR, mT);
    }
    else {
        ViewPtr_MoveTo(ptr, v.vposx + mL, v.vposy + mT);
        ViewPtr_Resize(ptr, v.vsizex - mL - mR, v.vsizey - mT - mB);
    };
};
func void ViewPtr_SetMarginPxl(var int ptr, var int parent, var int align, var int mT, var int mR, var int mB, var int mL) {
    ViewPtr_SetMargin(ptr, parent, align, Print_ToVirtual(mT, PS_Y), Print_ToVirtual(mR, PS_X), Print_ToVirtual(mB, PS_Y), Print_ToVirtual(mL, PS_X));
};

//========================================
// Eine Viewliste an einen parent kleben
//========================================
func void ViewList_GlueToAxis(var int list, var int parent, var int axis, var int mT, var int mR, var int mB, var int mL) {
    var zCView v;
    if(!parent) {
        // using screen if no parent is given
        v = _^(MEM_ReadInt(screen));
    }
    else {
        v = _^(parent);
    };

    var int i; i = 0;
    var int itemSize;
    var int items; items = List_Length(list);
    var zCList l;

    if(axis == PS_X) {
        l = _^(list);

        itemSize = v.vsizex / items;

        repeat(i, items);
            ViewPtr_SetMargin(l.data, parent, ALIGN_LEFT, mT, itemSize - mL - mR, mB, i * itemSize + mL);
            if(l.next) {
                l = _^(l.next);
            };
        end;
    }
    else {
        l = _^(list);

        itemSize = v.vsizey / items;

        repeat(i, items);
            ViewPtr_SetMargin(l.data, parent, ALIGN_TOP, i * itemSize + mT, mL, itemSize - mT - mB, mR);
            if(l.next) {
                l = _^(l.next);
            };
        end;
    };
};
func void ViewList_GlueToAxisPxl(var int list, var int parent, var int axis, var int mT, var int mR, var int mB, var int mL) {
    ViewList_GlueToAxis(list, parent, axis, Print_ToVirtual(mT, PS_Y), Print_ToVirtual(mR, PS_X), Print_ToVirtual(mB, PS_Y), Print_ToVirtual(mL, PS_X));
};

//========================================
// Text ausrichten
//========================================
func void ViewPtr_AlignText(var int ptr, var int margin) {
    var zCView v;  v = _^(ptr);
    var int    lp; lp = v.textLines_next;
    var zCList l;
    var zCViewText vt;

    var int width;

    if(margin == 0) {
        while(lp);
            l = _^(lp);
            vt = _^(l.data);
            width = Print_ToVirtual(Print_GetStringWidthPtr(vt.text, vt.font), PS_X) * PS_VMAX / v.vsizex;
            vt.posx = PS_VMAX / 2 - width / 2;
            lp = l.next;
        end;
    }
    else if(margin > 0) {
        while(lp);
            l = _^(lp);
            vt = _^(l.data);
            vt.posx = margin;
            lp = l.next;
        end;
    }
    else {
        while(lp);
            l = _^(lp);
            vt = _^(l.data);
            width = Print_ToVirtual(Print_GetStringWidthPtr(vt.text, vt.font), PS_X) * PS_VMAX / v.vsizex;
            vt.posx = PS_VMAX - width - margin;
            lp = l.next;
        end;
    };
};



//========================================
// View nach oben bewegen
//========================================
func void ViewPtr_Top(var int ptr) {
    Call__thiscall(ptr, zCView_Top);
};
func void View_Top(var int hndl) {
    ViewPtr_Top(getPtr(hndl));
};


func void zCView_Archiver(var zCView this) {
    PM_SaveInt("_vtbl", this._vtbl);
    PM_SaveInt("_zCInputCallBack_vtbl", this._zCInputCallBack_vtbl);

    if (MEMINT_SwitchG1G2(false, true)) {
        /* Gothic 1 kennt die Eigenschaft m_bFillZ nicht, daher die Pointerarithmetik hier */
        PM_SaveInt("m_bFillZ", MEM_ReadInt(_@(this)+8));
    };
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

    _ViewPtr_CreateIntoPtr(_@(this), vx1, vy1, vx2, vy2);

    this._vtbl = PM_LoadInt("_vtbl");
    this._zCInputCallBack_vtbl = PM_LoadInt("_zCInputCallBack_vtbl");

    if (MEMINT_SwitchG1G2(false, true)) {
        /* Gothic 1 kennt die Eigenschaft m_bFillZ nicht, daher die Pointerarithmetik hier */
        MEM_WriteInt(_@(this)+8, PM_LoadInt("m_bFillZ"));
    };
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

    ViewPtr_SetTexture(_@(this), PM_LoadString("backtex"));

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


    if (PM_Load("ondesk")) {
        ViewPtr_Open(_@(this));
    };

    this.textLines_next = PM_LoadClassPtr("textLines"); // Muss ich nach dem öffnen machen... >.>

};




