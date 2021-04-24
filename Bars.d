/***********************************\
                BARS
\***********************************/

//========================================
// [intern] Bar update status
//========================================
const int _Bar_Update_Status = -1;

//========================================
// Klasse für den Nutzer
//========================================
class Bar {
    var int x;
    var int y;
    var int barTop;
    var int barLeft;
    var int width;
    var int height;
    var string backTex;
    var string barTex;
    var int value;
    var int valueMax;
};

//========================================
// Prototyp für Konstruktor-Instanz
//========================================
prototype GothicBar(Bar) {
    x = Print_Screen[PS_X] / 2;
    y = Print_Screen[PS_Y] - 20;
    barTop = MEMINT_SwitchG1G2(2, 3);
    barLeft = 7;
    width = 180;
    height = 20;
    backTex = "Bar_Back.tga";
    barTex = "Bar_Misc.tga";
    value = 100;
    valueMax = 100;
};

//========================================
// Beispiel für Konstruktor-Instanz
//========================================
instance GothicBar@(GothicBar);

//========================================
// [intern] Klasse für PermMem
//========================================
class _bar {
    var int valMax;
    var int barW;
    var int v0; // zCView(h)
    var int v1; // zCView(h)
    var int hidden;
};

instance _bar@(_bar);

func void _bar_Archiver(var _bar this) {
    PM_SaveInt("valMax", this.valMax);
    PM_SaveInt("barW",   this.barW);
    PM_SaveInt("v0",     this.v0);
    PM_SaveInt("v1",     this.v1);
    PM_SaveInt("hidden", this.hidden);
};

func void _bar_Unarchiver(var _bar this) {
    this.valMax = PM_Load("valMax");
    this.barW   = PM_Load("barW");
    this.v0     = PM_Load("v0");
    this.v1     = PM_Load("v1");
    if (PM_Exists("hidden")) {
        this.hidden = PM_Load("hidden");
    } else {
        this.hidden = -1; // Obtained from view (see _Bar_UpdateShow)
    };
};


func void _bar_Delete(var _bar b) {
    if(Hlp_IsValidHandle(b.v0)) {
        delete(b.v0);
    };
    if(Hlp_IsValidHandle(b.v1)) {
        delete(b.v1);
    };
};

//========================================
// Höchstwert setzen
//========================================
func void Bar_SetMax(var int bar, var int max) {
    if(!Hlp_IsValidHandle(bar)) { return; };
    var _bar b; b = get(bar);
    b.valMax = max;
};

//========================================
// Wert in 1/1000
//========================================
func void Bar_SetPromille(var int bar, var int pro) {
    if(!Hlp_IsValidHandle(bar)) { return; };
    var _bar b; b = get(bar);
    if(pro > 1000) { pro = 1000; };
    View_Resize(b.v1, (pro * b.barW) / 1000, -1);
};

//========================================
// Wert in 1/100
//========================================
func void Bar_SetPercent(var int bar, var int perc) {
    Bar_SetPromille(bar, perc*10);
};

//========================================
// Wert der Bar
//========================================
func void Bar_SetValue(var int bar, var int val) {
    if(!Hlp_IsValidHandle(bar)) { return; };
    var _bar b; b = get(bar);
    if(val) {
        Bar_SetPromille(bar, (val * 1000) / b.valMax);
    }
    else {
        Bar_SetPromille(bar, 0);
    };
};

//========================================
// Bar löschen
//========================================
func void Bar_Delete(var int bar) {
    if(Hlp_IsValidHandle(bar)) {
        delete(bar);
    };
};

//========================================
// Bar verstecken
//========================================
func void Bar_Hide(var int bar) {
	if(!Hlp_IsValidHandle(bar)) { return; };
	var _bar b; b = get(bar);
	View_Close(b.v0);
	View_Close(b.v1);
	b.hidden = TRUE;
};

//========================================
// Bar zeigen
//========================================
func void Bar_Show(var int bar) {
	if(!Hlp_IsValidHandle(bar)) { return; };
	var _bar b; b = get(bar);
	// Only open if allowed or if not initialized
	if (_Bar_Update_Status) || (!(_LeGo_Flags & LeGo_Bars)) {
		View_Open(b.v0);
		View_Open(b.v1);
	};
	b.hidden = FALSE;
};

//========================================
// Internal positioning functions
// Do not use outside of this script
// Use Bar_Move and Bar_Resize instead
//========================================
func void _Bar_MoveTo_Internal(var int bar, var int x, var int y) {
	if(!Hlp_IsValidHandle(bar)) { return; };
	var _bar b; b = get(bar);
	var zCView v; v = View_Get(b.v0);
	x -= v.vsizex>>1;
	y -= v.vsizey>>1;
	x -= v.vposx;
	y -= v.vposy;
	View_Move(b.v0, x, y);
	View_Move(b.v1, x, y);
};
func void _Bar_Resize_Internal(var int bar, var int width, var int height) {
    if(!Hlp_IsValidHandle(bar)) { return; };
    var _bar b; b = get(bar);

    // Remember center position
    var zCView v0; v0 = View_Get(b.v0);
    var int vCenterX; vCenterX = v0.vposx + (v0.vsizex>>1);
    var int vCenterY; vCenterY = v0.vposy + (v0.vsizey>>1);

    // Scale inner view offset
    var zCView v1; v1 = View_Get(b.v1);
    var int barDiffX; barDiffX = v0.vsizex - b.barW;
    var int barDiffY; barDiffY = v0.vsizey - v1.vsizey;
    var int scaleX; scaleX = fracf(width, v0.vsizex);
    var int scaleY; scaleY = fracf(height, v0.vsizey);
    barDiffX = roundf(mulf(mkf(barDiffX), scaleX));
    barDiffY = roundf(mulf(mkf(barDiffY), scaleY));

    // Calculate inner view width
    var int barWidth; var int barX;
    if (width > 0) {
        var int curVal; curVal = fracf(b.barW, v1.vsizex);
        b.barW = width - barDiffX;
        barWidth = roundf(divf(mkf(b.barW), curVal));
        barX = (v0.vposx + roundf(fracf(barDiffX, 2))) - v1.vposx;
    } else {
        barWidth = width;
        barX = 0;
        if (width == 0) { b.barW = 0; };
    };

    // Calculate inner view height
    var int barHeight; var int barY;
    if (height > 0) {
        barHeight = height - barDiffY;
        barY = (v0.vposy + roundf(fracf(barDiffY, 2))) - v1.vposy;
    } else {
        barHeight = height;
        barY = 0;
    };

    // Update outer view
    View_Resize(b.v0, width, height);

    // Update inner view
    View_Resize(b.v1, barWidth, barHeight);
    View_Move(b.v1, barX, barY);

    // Re-center bar
    _Bar_MoveTo_Internal(bar, vCenterX, vCenterY);
};

//========================================
// Bar anchor point
//========================================
const int BAR_ANCHOR_N  = 1 << 1;
const int BAR_ANCHOR_S  = 1 << 2;
const int BAR_ANCHOR_E  = 1 << 3;
const int BAR_ANCHOR_W  = 1 << 4;
const int BAR_ANCHOR_NE = BAR_ANCHOR_N | BAR_ANCHOR_E;
const int BAR_ANCHOR_NW = BAR_ANCHOR_N | BAR_ANCHOR_W;
const int BAR_ANCHOR_SE = BAR_ANCHOR_S | BAR_ANCHOR_E;
const int BAR_ANCHOR_SW = BAR_ANCHOR_S | BAR_ANCHOR_W;

func int Bar_GetAnchorXY(var int x, var int y) {
    var int anchor; anchor = 0;

    // Horizontal
    if (x < (PS_VMax + 1) / 3) { // Left third of the screen: West
        anchor = anchor | BAR_ANCHOR_W;
    } else if (x >= (PS_VMax + 1) /3 * 2) { // Right third of the screen: East
        anchor = anchor | BAR_ANCHOR_E;
    }; // Else: Center

    // Vertical
    if (y < (PS_VMax + 1) / 3) { // Upper third of the screen: North
        anchor = anchor | BAR_ANCHOR_N;
    } else if (y >= (PS_VMax + 1) /3 * 2) { // Lower third of the screen: South
        anchor = anchor | BAR_ANCHOR_S;
    }; // Else: Middle

    return +anchor;
};
func int Bar_GetAnchor(var int bar) {
    if(!Hlp_IsValidHandle(bar)) { return 0; };
    var _bar b; b = get(bar);
    var zCView v; v = View_Get(b.v0);
    var int x; var int y;
    x = v.vposx + (v.vsizex>>1);
    y = v.vposy + (v.vsizey>>1);
    return Bar_GetAnchorXY(x, y);
};

//========================================
// Interface scaling
//========================================
func int Bar_GetInterfaceScaling() {
    // Super cheap, but effective and versatile: Just take (actual width) / (default width) of the health bar
    MEM_InitGlobalInst();
    var oCViewStatusBar hpBar; hpBar = _^(MEM_Game.hpBar);
    return fracf(hpBar.zCView_vsizex, Print_ToVirtual(180, PS_X));
};

//========================================
// Bar Scale
//========================================
func void Bar_ScaleExt(var int bar, var int scaleF, var int x0, var int y0, var int x1, var int y1) {
    if(!Hlp_IsValidHandle(bar)) { return; };
    var _bar b; b = get(bar);
    var zCView v; v = View_Get(b.v0);

    // To be done in pixel coordinates
    var int x; x = Print_ToPixel(v.vposx, x0);
    var int y; y = Print_ToPixel(v.vposy, y0);
    var int w; w = Print_ToPixel(v.vsizex, x0);
    var int h; h = Print_ToPixel(v.vsizey, y0);

    // Align around anchor point and scale position
    var int anchor; anchor = Bar_GetAnchor(bar);
    if (anchor & BAR_ANCHOR_W) {
        var int pixelsFromLeft; pixelsFromLeft = x;
        x = Print_ToVirtual(roundf(mulf(mkf(pixelsFromLeft), scaleF)), x1);
    } else if (anchor & BAR_ANCHOR_E) {
        var int pixelsFromRight; pixelsFromRight = x0 - (x + w);
        x = PS_VMax - Print_ToVirtual(roundf(mulf(mkf(pixelsFromRight + w), scaleF)), x1);
    } else { // Center
        var int w2; w2 = roundf(fracf(w, 2));
        var int pixelsFromCenter; pixelsFromCenter = (x0 / 2) - (x + w2);
        x = (PS_VMax / 2) - Print_ToVirtual(roundf(mulf(mkf(pixelsFromCenter + w2), scaleF)), x1);
    };
    if (anchor & BAR_ANCHOR_N) {
        var int pixelsFromTop; pixelsFromTop = y;
        y = Print_ToVirtual(roundf(mulf(mkf(pixelsFromTop), scaleF)), y1);
    } else if (anchor & BAR_ANCHOR_S) {
        var int pixelsFromBottom; pixelsFromBottom = y0 - (y + h);
        y = PS_VMax - Print_ToVirtual(roundf(mulf(mkf(pixelsFromBottom + h), scaleF)), y1);
    } else { // Middle
        var int h2; h2 = roundf(fracf(h, 2));
        var int pixelsFromMiddle; pixelsFromMiddle = (y0 / 2) - (y + h2);
        y = (PS_VMax / 2) - Print_ToVirtual(roundf(mulf(mkf(pixelsFromMiddle + h2), scaleF)), y1);
    };

    // Scale size
    w = Print_ToVirtual(roundf(mulf(mkf(w), scaleF)), x1);
    h = Print_ToVirtual(roundf(mulf(mkf(h), scaleF)), y1);

    // Center x and y (Bar_MoveTo expects center coordinates)
    x += w>>1;
    y += h>>1;

    // Apply changes (without rescaling)
    _Bar_Resize_Internal(bar, w, h);
    _Bar_MoveTo_Internal(bar, x, y);
};
func void Bar_Scale(var int bar, var int scaleF) {
    if (scaleF != FLOATONE) {
        Print_GetScreenSize();
        Bar_ScaleExt(bar, scaleF, Print_Screen[PS_X], Print_Screen[PS_Y], Print_Screen[PS_X], Print_Screen[PS_Y]);
    };
};

//========================================
// Bar bewegen
//========================================
func void Bar_MoveTo(var int bar, var int x, var int y) {
    if(!Hlp_IsValidHandle(bar)) { return; };
    var int scale; scale = Bar_GetInterfaceScaling();
    Bar_Scale(bar, divf(FLOATONE, scale)); // Scale to one
    _Bar_MoveTo_Internal(bar, x, y);
    Bar_Scale(bar, scale); // Scale back up/down
};
func void Bar_MoveToPxl(var int bar, var int x, var int y) {
    Bar_MoveTo(bar, Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y));
};

//========================================
// Bar Resize
//========================================
func void Bar_Resize(var int bar, var int width, var int height) {
    if(!Hlp_IsValidHandle(bar)) { return; };
    var _bar b; b = get(bar);
    var int scale; scale = Bar_GetInterfaceScaling();
    Bar_Scale(bar, divf(FLOATONE, scale)); // Scale to one
    _Bar_Resize_Internal(bar, width, height);
    Bar_Scale(bar, scale); // Scale back up/down
};
func void Bar_ResizePxl(var int bar, var int x, var int y) {
    Bar_Resize(bar, Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y));
};

//========================================
// Bar Alpha
//========================================
func void Bar_SetAlpha(var int bar, var int alpha) {
	if(!Hlp_IsValidHandle(bar)) { return; };
	var _bar b; b = get(bar);
	View_SetAlpha(b.v0, alpha);
	View_SetAlpha(b.v1, alpha);
};

//========================================
// Bar Texture
//========================================
func void Bar_SetBackTexture(var int bar, var string backTex)
{
    if(!Hlp_IsValidHandle(bar)) { return; };
    var _bar b; b = get(bar);
    View_SetTexture(b.v0, backTex);
};

func void Bar_SetBarTexture(var int bar, var string barTex)
{
    if(!Hlp_IsValidHandle(bar)) { return; };
    var _bar b; b = get(bar);
    View_SetTexture(b.v1, barTex);
};

//========================================
// Auto-hide bars
//========================================
func int _Bar_PlayerStatus() {
    MEM_InitGlobalInst();
    return (Hlp_IsValidNpc(hero)) && (MEM_Game.showPlayerStatus);
};
func void _Bar_UpdateShow(var int bar) {
    if (!Hlp_IsValidHandle(bar)) { return; };
    var _bar b; b = get(bar);
    if (b.hidden == -1) {
        // Previous LeGo versions: Obtain status from open/closed view
        var zCView v; v = View_Get(b.v0);
        b.hidden = (v.isClosed || v.continueClose);
    };
    if (b.hidden) { return; };
    View_Open(b.v0);
    View_Open(b.v1);
};
func void _Bar_UpdateHide(var int bar) {
    if (!Hlp_IsValidHandle(bar)) { return; };
    var _bar b; b = get(bar);
    View_Close(b.v0);
    View_Close(b.v1);
};
func void _Bar_Update() {
    var int status; status = _Bar_PlayerStatus();
    if (_Bar_Update_Status != status) {
        _Bar_Update_Status = status;
        if (status) {
            foreachHndl(_bar@, _Bar_UpdateShow);
        } else {
            foreachHndl(_bar@, _Bar_UpdateHide);
        };
    };
};

//========================================
// Neue Bar erstellen
//========================================
func int Bar_Create(var int inst) {
    Print_GetScreenSize();
    var int ptr; ptr = create(inst);
    var bar bu; bu = MEM_PtrToInst(ptr);
    var int bh; bh = new(_bar@);
    var _bar b; b = get(bh);
    b.valMax = bu.valueMax;
    var int buhh; var int buwh;
    var int ah; var int aw;
    buhh = bu.height / 2;
    buwh = bu.width / 2;
    if(buhh*2 < bu.height) {ah = 1;} else {ah = 0;};
    if(buwh*2 < bu.width) {aw = 1;} else {aw = 0;};
    b.v0 = View_CreatePxl(bu.x - buwh, bu.y - buhh, bu.x + buwh + aw, bu.y + buhh + ah);
    buhh -= bu.barTop;
    buwh -= bu.barLeft;
    b.barW = Print_ToVirtual(bu.width - bu.barLeft * 2 + aw, PS_X);
    b.v1 = View_CreatePxl(bu.x - buwh, bu.y - buhh, bu.x + buwh + aw, bu.y + buhh + ah);
    View_SetTexture(b.v0, bu.backTex);
    View_SetTexture(b.v1, bu.barTex);
    var zCView v; v = View_Get(b.v0);
    v.fxOpen = 0;
    v.fxClose = 0;
    v = View_Get(b.v1);
    v.fxOpen = 0;
    v.fxClose = 0;
    Bar_Scale(bh, Bar_GetInterfaceScaling());
    if (_Bar_PlayerStatus()) {
        View_Open(b.v0);
        View_Open(b.v1);
    };
    Bar_SetValue(bh, bu.value);
    free(ptr, inst);
    return bh;
};

//========================================
// Update bar to new screen resolution
//========================================
var int _Bar_screen_x;
var int _Bar_screen_y;
var int _Bar_scaling;

func void _Bar_UpdateResolution() {
    // To be safe, backup the last resolution manually. Someone might have called Print_GetScreenSize in the meantime!
    Print_GetScreenSize();

    // Update all bar sizes on change of screen resolution
    if (_Bar_screen_x != Print_Screen[PS_X]) || (_Bar_screen_y != Print_Screen[PS_Y])
    || (_Bar_scaling != Bar_GetInterfaceScaling()) {

        // On first call (usually right after Init_Global), record screen size without any changes
        if (_Bar_screen_x) {
            foreachHndl(_bar@, _Bar_UpdateSize);
        };

        _Bar_screen_x = Print_Screen[PS_X];
        _Bar_screen_y = Print_Screen[PS_Y];
        _Bar_scaling = Bar_GetInterfaceScaling();
    };
};
func void _Bar_UpdateSize(var int bar) {
    Bar_ScaleExt(bar, divf(FLOATONE, _Bar_scaling),             // Invert last scaling
                      _Bar_screen_x, _Bar_screen_y,             // From this resolution
                      Print_Screen[PS_X], Print_Screen[PS_Y]);  // To this resolution
    Bar_Scale(bar, Bar_GetInterfaceScaling());                  // Apply new scaling
};
