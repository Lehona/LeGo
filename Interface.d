/***********************************\
              INTERFACE
\***********************************/

var int Print_List; //zCList_zCViewText@

//========================================
// Vergangene Zeit seit Systemstart
//========================================
// Danke an Sektenspinner
func int sysGetTime() {
    CALL__cdecl(sysGetTimePtr);
    return CALL_RetValAsInt();
};

//========================================
// Farbhandling
//========================================
func int RGBA(var int r, var int g, var int b, var int a) {
    if(!a){if(!b){if(!g){if(!r){return 1;};};};};
    return ((r&zCOLOR_CHANNEL)<<zCOLOR_SHIFT_RED)
          |((g&zCOLOR_CHANNEL)<<zCOLOR_SHIFT_GREEN)
          |((b&zCOLOR_CHANNEL)<<zCOLOR_SHIFT_BLUE)
          |((a&zCOLOR_CHANNEL)<<zCOLOR_SHIFT_ALPHA);
};

func int ChangeAlpha(var int zCol, var int a) {
    return ((zCol & ~(zCOLOR_CHANNEL<<zCOLOR_SHIFT_ALPHA)) | ((a&zCOLOR_CHANNEL)<<zCOLOR_SHIFT_ALPHA));
};

func int GetAlpha(var int zCol) {
    return (zCol&(zCOLOR_CHANNEL<<zCOLOR_SHIFT_ALPHA))>>zCOLOR_SHIFT_ALPHA;
};


//========================================
// Text generieren
//========================================

func int Print_CreateText(var string text, var string font) {
    var int hndl; hndl = new(zCViewText@);
    var zCViewText txt; txt = get(hndl);
    txt.timed = 0;
    txt.font = Print_GetFontPtr(font);
    txt.color = -1;
    txt.text = text;
    return hndl;
};

func int Print_CreateTextPtr(var string text, var string font) {
    var int ptr; ptr = create(zCViewText@);
    var zCViewText txt; txt = _^(ptr);
    txt.timed = 0;
    txt.font = Print_GetFontPtr(font);
    txt.text = text;
    txt.color = -1;
    return ptr;
};

func int Print_CreateTextPtrColored(var string text, var string font, var int color) {
    var int ptr; ptr = create(zCViewText@);
    var zCViewText txt; txt = _^(ptr);
    txt.timed = 0;
    txt.font = Print_GetFontPtr(font);
    txt.text = text;
    txt.color = color;
	if (!color == -1) {
		txt.colored = 1;
	};
    return ptr;
};

//========================================
// Text als zCViewText erhalten
//========================================
func zCViewText Print_GetText(var int hndl) {
    get(hndl);
};

func int Print_GetTextPtr(var int hndl) {
    return getPtr(hndl);
};

//========================================
// Text löschen
//========================================
func void Print_DeleteText(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) { return; };
    var zCViewText txt; txt = Print_GetText(hndl);
    zCViewText_Delete(txt);
    delete(hndl);
};

//========================================
// Mark: Print set alpha
//========================================
// pointer
func void PrintPtr_SetAlpha(var int ptr, var int a) {
	if (!ptr) { return; };
	var zCViewText txt; txt = MEM_PtrToInst(ptr);
	txt.colored = 1;
	txt.color = ChangeAlpha(txt.color, a);
};
// handle
func void Print_SetAlpha(var int hndl, var int a) {
	if (!Hlp_IsValidHandle(hndl)) { return; };
	PrintPtr_SetAlpha(getPtr(hndl), a);
};

//========================================
// Screengröße (in Pixeln)
//========================================
var int Print_Ratio; //float
func void _Print_Ratio() {
    Print_Ratio = mkf(Print_Screen[PS_X]);
    Print_Ratio = divf(Print_Ratio, mkf(Print_Screen[PS_Y]));
};


var int Print_Screen[2];
func void Print_GetScreenSize() {
    if (!_@(MEM_Game)) {
        // Initialize if called during level change (e.g. by PrintScreen_Ext(), caused by log entry)
        MEM_InitGlobalInst();
    };
    var zCView screen; screen = _^(MEM_Game._zCSession_viewport);
    Print_Screen[PS_X] = screen.psizex;
    Print_Screen[PS_Y] = screen.psizey;
    _Print_Ratio();
};

//========================================
// Pixel in Virtuelle Koordinaten
//========================================
func int Print_ToVirtual(var int pxl, var int dim) {
    Print_GetScreenSize();
    pxl *= 8192;
    if(dim == PS_X) {
        return pxl / Print_Screen[PS_X];
    }
    else if(dim == PS_Y) {
        return pxl / Print_Screen[PS_Y];
    };
    return pxl / dim;
};
func int Print_ToPixel(var int vrt, var int dim) {
    Print_GetScreenSize();
    if(dim == PS_X) {
        vrt *= Print_Screen[PS_X];
    }
    else if(dim == PS_Y) {
        vrt *= Print_Screen[PS_Y];
    }
    else {
        vrt *= dim;
    };
    return vrt / 8192;
};

func int Print_ToPixelF(var int vrt, var int dim) {
    Print_GetScreenSize();
    if(dim == PS_X) {
        vrt *= Print_Screen[PS_X];
    }
    else if(dim == PS_Y) {
        vrt *= Print_Screen[PS_Y];
    }
    else {
        vrt *= dim;
    };
    return fracf(vrt, PS_VMax);
};

func int Print_ToRatio(var int size, var int dim) {
    if (dim == PS_Y) {
        return roundf(mulf(mkf(size), Print_Ratio));
    } else if (dim == PS_X) {
        return roundf(divf(mkf(size), Print_Ratio));
    };
    return -1;
};

func int Print_ToRadian(var int angle) {
    const int toRadian = 1016003125; // 0.017453292
    mulf(angle, toRadian);
};
func int Print_ToDegree(var int angle) {
    const int toDegree = 1113927393; // 57.29578
    mulf(angle, toDegree);
};

//========================================
// Erweitertes PrintScreen
//========================================

instance zCViewTextPrint(zCViewText) {
    _vtbl = zCViewText_vtbl;
    inPrintWin = 0;
    timer = 0;
    timed = 0;
    colored = 0;
    color = 0;
};

func void zCViewTextPrint_UnArchiver(var zCViewText this) {
    this._vtbl = PM_LoadInt("vtbl");
    this.posx = PM_LoadInt("posx");
    this.posy = PM_LoadInt("posy");
    this.text = PM_LoadString("text");
    this.font = Print_GetFontPtr(PM_LoadString("fontname"));
    this.timer = PM_LoadInt("timer");
    this.inPrintWin = PM_LoadInt("inPrintWin");
    this.color = PM_LoadInt("color");
    this.timed = PM_LoadInt("timed");
    this.colored = PM_LoadInt("colored");

    var zCView v; v = _^(MEM_Game.array_view[0]);
    if (v.textlines_next) {
        List_Add(v.textlines_next, MEM_InstToPtr(this));
    } else {
        v.textlines_next = List_Create(MEM_InstToPtr(this));
    };
};


func int Print_Ext(var int x, var int y, var string text, var string font, var int color, var int time) {
    if (!_@(MEM_Game)) || (!_@(MEM_StackPos)) {
        // Initialize if called during level change (e.g. by PrintScreen_Ext(), caused by log entry)
        MEM_InitLabels();
        MEM_InitGlobalInst();
    };

    if (time == -1) {
        var int h; h = new(zCViewTextPrint);
        var zCViewText txt; txt = get(h);
    } else {
        h = -1;
        txt = _^(create(zCViewTextPrint));
    };

    if(!color) { color = 1; };

    txt.timed = (time != -1);
    if (time != -1) { txt.timer = mkf(time); };

    txt.font = Print_GetFontPtr(font);
    txt.color = color;
    txt.text = text;
    txt.colored = 1;

    txt.posx = x;
    if (x == -1) {
        txt.posx = (PS_VMax - Print_ToVirtual(Print_GetStringWidth(text, font), PS_X)) / 2;
    };
    txt.posy = y;
    if (y == -1) {
        txt.posy = (PS_VMax - Print_ToVirtual(Print_GetFontHeight(font), PS_Y)) / 2;
    };

    var zCView v; v = _^(MEM_Game.array_view[0]);
    if (v.textlines_next) {
        List_Add(v.textlines_next, MEM_InstToPtr(txt));
    } else {
        v.textlines_next = List_Create(MEM_InstToPtr(txt));
    };
    return h;
};

//========================================
// Erweitertes PrintScreen (pixel)
//========================================
func int Print_ExtPxl(var int x, var int y, var string text, var string font, var int color, var int time) {
    Print_Ext(Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y), text, font, color, time);
};

//========================================
// Textfeld
//========================================

func string Print_LongestLineExt(var string text, var string font, var string separator) {
    var int cnt; cnt = STR_SplitCount(text, separator);
    var int i; i = 0;
    var int max; max = 0;
    var int tmp; tmp = 0;

    var int pos; pos = MEM_StackPos.position;
        if (i >= cnt) {
            return STR_Split(text, separator, i-1);
        };
        tmp = Print_GetStringWidth(STR_Split(text, separator, i), font);
        if (tmp > max) {
            max = tmp;
        };
    i+=1;
    MEM_StackPos.position = pos;
};

func string Print_LongestLine(var string text, var string font) {
	Print_LongestLineExt(text, font, Print_LineSeperator);
};

func int Print_LongestLineLengthExt(var string text, var string font, var string separator) {
    return Print_GetStringWidth(Print_LongestLineExt(text, font, separator), font);
};

func int Print_LongestLineLength(var string text, var string font) {
    return Print_LongestLineLengthExt(text, font, Print_LineSeperator);
};

func int Print_TextFieldColored(var int x, var int y, var string text, var string font, var int height, var int color) {
    var int cnt; cnt = STR_SplitCount(text, Print_LineSeperator);
    var int i; i = 1;
    var int ptr; ptr = Print_CreateTextPtrColored(STR_Split(text, Print_LineSeperator, 0), font, color);
    var zCViewText txt; txt = _^(ptr);
    txt.posx = x;
    txt.posy = y;

    var int list; list = List_Create(Ptr);
    var int pos; pos = MEM_StackPos.position;
    if (i >= cnt) {
        return list;
    };
        ptr = Print_CreateTextPtrColored(STR_Split(text, Print_LineSeperator, i), font, color);
        txt = _^(ptr);
        txt.posx = x;
        txt.posy = y+(height*i);

        List_Add(list, ptr);
        i+=1;

    MEM_StackPos.position = pos;
};

func int Print_TextField(var int x, var int y, var string text, var string font, var int height) {
	return Print_TextFieldColored(x, y, text, font, height, -1);
};

func int Print_TextFieldPxl(var int x, var int y, var string text, var string font) {
    return Print_TextField(Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y), text, font, Print_ToVirtual(Print_GetFontHeight(font), PS_Y));
};



//========================================
// Klasse für PermMem
//========================================
class gCPrintS {
    var int a8_Alpha;    // Anim8(h)
    var int a8_Movement; // Anim8(h)
    var int tv_Text;     // Print(h)
    var int vr_Pos;
    var int vr_Offs;
};
instance gCPrintS@(gCPrintS);

var int gCPrintS_Act;
var int gCPrintS_COff;

func void gCPrintS_Delete(var gCPrintS this) {
    Anim8_Delete(this.a8_Movement);
    Print_DeleteText(this.tv_Text);
};

func void gCPrintS_Alpha(var int h, var int value) {
    var gCPrintS p; p = get(h);
    var zCViewText t; t = get(p.tv_Text);
    t.color = ChangeAlpha(t.color, value);
    if(gCPrintS_COff > p.vr_Offs) {
        p.vr_Pos -= (gCPrintS_COff - p.vr_Offs) * PF_TextHeight;
        Anim8(p.a8_Movement, p.vr_Pos, PF_MoveYTime, A8_SlowEnd);
        p.vr_Offs = gCPrintS_COff;
    };
};

func void gCPrintS_Position(var int h, var int value) {
    var gCPrintS p; p = get(h);
    var zCViewText t; t = get(p.tv_Text);
    t.posY = value;
};

//========================================
// Softprint
//========================================
func void PrintS_Ext(var string txt, var int color) {
    var int h; h = new(gCPrintS@);
    var gCPrintS p; p = get(h);
    var int v;

    v = Anim8_NewExt(1, gCPrintS_Alpha, h, false);
    Anim8_RemoveIfEmpty(v, true);
    Anim8_RemoveDataIfEmpty(v, true);
    Anim8 (v, 255, PF_FadeInTime,  A8_Constant);
    Anim8q(v, 0,   PF_WaitTime,    A8_Wait);
    Anim8q(v, 0,   PF_FadeOutTime, A8_SlowStart);
    p.a8_Alpha = v;

    v = Anim8_NewExt(PF_PrintY, gCPrintS_Position, h, false);
    Anim8 (v, PF_PrintY - PF_TextHeight, PF_MoveYTime, A8_SlowEnd);
    p.a8_Movement = v;

    p.tv_Text = Print_Ext(PF_PrintX, PF_PrintY, txt, PF_Font, color, -1);
    p.vr_Pos = PF_PrintY - PF_TextHeight;
    gCPrintS_COff += 1;
    if(!gCPrintS_Act) {
        gCPrintS_COff = 0;
    };
    gCPrintS_Act += 1;
    p.vr_Offs = gCPrintS_COff;
};
func void AI_PrintS_Ext(var c_npc slf, var string txt, var int color) {
    AI_Function_SI(slf, PrintS_Ext, txt, color);
};

//========================================
// vereinfachter Softprint
//========================================
func void PrintS(var string txt) {
    PrintS_Ext(txt, RGBA(255,255,255,0));
};
func void AI_PrintS(var c_npc slf, var string txt) {
    AI_Function_S(slf, PrintS, txt);
};

//========================================
// PrintScreen fixen
//========================================
func void PrintScreen_Ext(var string txt, var int x, var int y, var string font, var int timeSec) {
    if(x == -1) {
        x = (PS_VMax - Print_ToVirtual(Print_GetStringWidth(txt, font), PS_X)) / 2;
    }
    else {
        x = Print_ToVirtual(x, 100);
    };
    if(y == -1) {
        y = (PS_VMax - Print_ToVirtual(Print_GetFontHeight(font), PS_Y)) / 2;
    }
    else {
        y = Print_ToVirtual(y, 100);
    };
    Print_Ext(x, y, txt, font, COL_White, timeSec * 1000);
};

class PS_Param {
    var string txt;
    var int x;
    var int y;
    var string font;
    var int timesec;
}; instance PS_Param@(PS_Param);

func void AI_PrintScreen_Execute(var int h) {
    var PS_Param p; p = get(h);
    PrintScreen_Ext(p.txt, p.x, p.y, p.font, p.timeSec);
    delete(h);
};

func void AI_PrintScreen_Ext(var string txt, var int x, var int y, var string font, var int timeSec) {
    var int h; h = New(PS_Param@);
	PS_Param@ = get(h);
    PS_Param@.txt = txt;
    PS_Param@.x = x;
    PS_Param@.y = y;
    PS_Param@.font = font;
    PS_Param@.timeSec = timeSec;

    AI_Function_I(hero, AI_PrintScreen_Execute, h);
};
func void Print_FixPS() {
    var int PS_Ext; PS_Ext = MEM_GetFuncOffset(PrintScreen_Ext);
    var zCPar_Symbol PS; PS = _^(MEM_ReadIntArray(contentSymbolTableAddress, MEM_GetFuncID(PrintScreen)));

    Call_Begin(0);
        Call_IntParam(_@(PS_Ext));
        Call__thiscall(_@(ContentParserAddress), zCParser__DoStack);

    PS.content = Call_Close();

	if (MEMINT_SwitchG1G2(false, true)) {
		var int AI_PS_Ext; AI_PS_Ext = MEM_GetFuncOffset(AI_PrintScreen_Ext);
		PS = _^(MEM_GetParserSymbol ("AI_PRINTSCREEN"));

		Call_Begin(0);
			Call_IntParam(_@(AI_PS_Ext));
			Call__thiscall(_@(ContentParserAddress), zCParser__DoStack);

		PS.content = Call_Close();
	};
};

