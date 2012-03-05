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
    var zCViewText txt; txt = MEM_PtrToInst(ptr);
    txt.timed = 0;
    txt.font = Print_GetFontPtr(font);
    txt.text = text;
    txt.color = -1;
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
    delete(hndl);
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
    Print_Screen[PS_X] = STR_ToInt(MEM_GetGothOpt("VIDEO", "zVidResFullscreenX"));
    Print_Screen[PS_Y] = STR_ToInt(MEM_GetGothOpt("VIDEO", "zVidResFullscreenY"));
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

func int Print_ToRatio(var int size, var int dim) {
    if (dim == PS_Y) {
        return roundf(mulf(mkf(size), Print_Ratio));
    } else if (dim == PS_X) {
        return roundf(divf(mkf(size), Print_Ratio));
    };
    return -1;
};

//========================================
// Erweitertes PrintScreen
//========================================

instance zCViewTextPrint(zCViewText) {
    _vtbl = 8643396; //0x83E344
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

    var zCView v; v = MEM_PtrToInst(MEM_Game.array_view[0]);
    if (v.textlines_next) {
        List_Add(v.textlines_next, MEM_InstToPtr(this));
    } else {
        v.textlines_next = List_Create(MEM_InstToPtr(this));
    };
};


func int Print_Ext(var int x, var int y, var string text, var string font, var int color, var int time) {
    if (time == -1) {
        var int h; h = new(zCViewTextPrint);
        var zCViewText txt; txt = get(h);
    } else {
        h = -1;
        txt = MEM_PtrToInst(create(zCViewTextPrint));
    };

    if(!color) { color = 1; };

    txt.timed = 0;
    txt.font = Print_GetFontPtr(font);
    txt.color = color;
    txt.text = text;
    txt.colored = 1;

    txt.posx = x;
    if (x == -1) {
        txt.posx = ((1<<13)>>1)-(Print_GetStringWidth(text, font)/2);
    };
    txt.posy = y;
    if (y == -1) {
        txt.posy = ((1<<13)>>1)-(Print_GetFontHeight(font)/2);
    };

    var zCView v; v = MEM_PtrToInst(MEM_Game.array_view[0]);
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

func string Print_LongestLine(var string text, var string font) {
	var int cnt; cnt = STR_SplitCount(text, Print_LineSeperator);
    var int i; i = 0;
	var int max; max = 0;
	var int tmp; tmp = 0;
	
	var int pos; pos = MEM_StackPos.position;
		if (i >= cnt) {
			return STR_Split(text, Print_LineSeperator, i-1);
		};
		tmp = Print_GetStringWidth(STR_Split(text, Print_LineSeperator, i), font);
		if (tmp > max) {
			max = tmp;
		};
	i+=1;
	MEM_StackPos.position = pos;
};

func int Print_LongestLineLength(var string text, var string font) {
	return Print_GetStringWidth(Print_LongestLine(text, font), font);
};	
		
		
func int Print_TextField(var int x, var int y, var string text, var string font, var int height) {
    var int cnt; cnt = STR_SplitCount(text, Print_LineSeperator);
    var int i; i = 1;
    var int ptr; ptr = Print_CreateTextPtr(STR_Split(text, Print_LineSeperator, 0), font);
    var zCViewText txt; txt = MEM_PtrToInst(ptr);
    txt.posx = x;
    txt.posy = y;

    var int list; list = List_Create(Ptr);
    var int pos; pos = MEM_StackPos.position;
    if (i >= cnt) {
        return list;
    };
        ptr = Print_CreateTextPtr(STR_Split(text, Print_LineSeperator, i), font);
        txt = MEM_PtrToInst(ptr);
        txt.posx = x;
        txt.posy = y+(height*i);

        List_Add(list, ptr);
        i+=1;

    MEM_StackPos.position = pos;
};

func int Print_TextFieldPxl(var int x, var int y, var string text, var string font) {
    return Print_TextField(Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y), text, font, Print_ToVirtual(Print_GetFontHeight(font), PS_Y));
};

func void Print_TextFieldDelete(var int txtfield) { // Geht noch nicht.
    var zCList__zCViewText v; v = _^(txtfield);
	//zCList__zCViewText_Delete(v);
};



//========================================
// Klasse für PermMem
//========================================
class gCPrintS {
    var int alpha;
    var int y;
    var int hndl; // zCViewText@
    var int opos;
    var int gpos;
};

func void gCPrintS_Delete(var gCPrintS g) {
    if(Hlp_IsValidHandle(g.hndl)) {
        Print_DeleteText(g.hndl);
    };
    if(Hlp_IsValidHandle(g.alpha)) {
        Anim8_Delete(g.alpha);
    };
    if(Hlp_IsValidHandle(g.y)) {
        Anim8_Delete(g.y);
    };
};

instance gCPrintS@(gCPrintS);

var int PF_List; // zCList<gCPrintS(h)>(h)
const int PF_ListPtr = 0;
var int PF_CPos;
var int PF_Loop;

//========================================
// Softprint
//========================================
func void PrintS_Ext(var string txt, var int color) {
    // Die geballte Macht von PermMem und Anim8!
    if(!PF_List) {
        PF_List = new(zCList@);
        PF_ListPtr = getPtr(PF_List);
    };

    var int alpha; alpha = Anim8_New(1, false);
    Anim8 (alpha, 255, PF_FadeTime,   A8_Constant);
    Anim8q(alpha, 0,   PF_WaitTime,   A8_Wait);
    Anim8q(alpha, 0,   PF_FadeTime*3, A8_SlowStart);

    var int y; y = Anim8_New(PF_PrintY + PF_TextHeight, false);
    Anim8(y, PF_PrintY, PF_MoveYTime, A8_SlowEnd);

    var int h; h = new(gCPrintS@);
    var gCPrintS p; p = get(h);
    p.alpha = alpha;
    p.y = y;
    p.opos = PF_CPos;
    p.gpos = PF_CPos;
    p.hndl = Print_Ext(PF_PrintX, PF_PrintY + PF_TextHeight, txt, PF_Font, color, -1);
    List_Add(PF_ListPtr, h);
    PF_CPos += 1;
    if(!PF_Loop) {
        PF_Loop = 1;
        FF_Apply(_PrintS_Loop);
    };
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
// [intern] Softprint-Loop
//========================================
func void _PrintS_Loop() {
    PF_ListPtr = getPtr(PF_List);
    var int i; i = 2;
    var int l; l = PF_ListPtr;
    var int p; p = MEM_StackPos.position;
    l = MEM_ReadInt(l+4); // l = (zCList*)l->next
    var int p0; p0 = MEM_StackPos.position;
    if(l) {
        var int c; c = MEM_ReadInt(l);
        if(c) {
            if(!Hlp_IsValidHandle(c)) {
                List_Delete(l, i);
            }
            else {
                var gCPrintS g; g = get(c);
                var zCViewText t; t = Print_GetText(g.hndl);
                t.color = ChangeAlpha(t.color, Anim8_Get(g.alpha));
                if(PF_CPos > g.opos) {
                    g.opos = PF_Cpos;
                    Anim8(g.y, PF_PrintY - PF_TextHeight * (PF_Cpos - g.gpos), PF_MoveYTime, A8_SlowEnd);
                };
                t.posY = Anim8_Get(g.y);
                if(Anim8_Empty(g.alpha)) {
                    delete(c);
                    l = MEM_ReadInt(l+4);
                    List_Delete(PF_ListPtr, i);
                    MEM_StackPos.position = p0;
                };
            };
        };
        i += 1;
        MEM_StackPos.position = p;
    };
    if(List_Length(PF_ListPtr) <= 1) {
        PF_Loop = 0;
        PF_CPos = 0;
        FF_Remove(_PrintS_Loop);
    };
};
