/***********************************\
                BARS
\***********************************/

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
};

instance _bar@(_bar);

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
    MEM_Call(_Bar_PlayerStatus);
    if (MEM_PopIntResult()) {
        View_Open(b.v0);
        View_Open(b.v1);
    };
    Bar_SetValue(bh, bu.value);
    free(ptr, inst);
    return bh;
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
// Bar zeigen
//========================================
func void Bar_Hide(var int bar) {
	if(!Hlp_IsValidHandle(bar)) { return; };
	var _bar b; b = get(bar);
	View_Close(b.v0);
	View_Close(b.v1);
};

//========================================
// Bar verstecken
//========================================
func void Bar_Show(var int bar) {
	if(!Hlp_IsValidHandle(bar)) { return; };
	var _bar b; b = get(bar);
	View_Open(b.v0);
	View_Open(b.v1);
};

//========================================
// Bar bewegen
//========================================
func void Bar_MoveTo(var int bar, var int x, var int y) {
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
func void Bar_MoveToPxl(var int bar, var int x, var int y) {
    Bar_MoveTo(bar, Print_ToVirtual(x, PS_X), Print_ToVirtual(y, PS_Y));
};

//========================================
// Bar Resize
//========================================
func void Bar_Resize(var int bar, var int width, var int height) {
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

    // Update outer view
    View_Resize(b.v0, width, height);

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
        barHeight = v0.vsizey - barDiffY;
        barY = (v0.vposy + roundf(fracf(barDiffY, 2))) - v1.vposy;
    } else {
        barHeight = height;
        barY = 0;
    };

    // Update inner view
    View_Resize(b.v1, barWidth, barHeight);
    View_Move(b.v1, barX, barY);

    // Re-center bar
    Bar_MoveTo(bar, vCenterX, vCenterY);
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
	var zCView v; v = View_Get(b.v0);
	v.alpha = alpha;
	v = View_Get(b.v1);
	v.alpha = alpha;
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
    return (Hlp_IsValidNpc(hero)) && (MEM_Game.showPlayerStatus);
};
func void _Bar_Update() {
    MEM_InitGlobalInst();
    var int status; status = _Bar_PlayerStatus();

    const int SET = 0;
    if (SET != status) {
        SET = status;
        if (SET) {
            foreachHndl(_bar@, Bar_Show);
        } else {
            foreachHndl(_bar@, Bar_Hide);
        };
    };
};

//========================================
// Update bar to new screen resolution
//========================================
var int _Bar_screen_x;
var int _Bar_screen_y;

func void _Bar_UpdateResolution() {
    // To be safe, backup the last resolution manually. Someone might have called Print_GetScreenSize in the meantime!
    Print_GetScreenSize();

    // Update all bar sizes on change of screen resolution
    if (_Bar_screen_x != Print_Screen[PS_X]) || (_Bar_screen_y != Print_Screen[PS_Y]) {

        // On first call (usually right after Init_Global), record screen size without any changes
        if (_Bar_screen_x) {
            foreachHndl(_bar@, _Bar_UpdateSize);
        };

        _Bar_screen_x = Print_Screen[PS_X];
        _Bar_screen_y = Print_Screen[PS_Y];
    };
};
func void _Bar_UpdateSize(var int bar) {
    var _bar b; b = get(bar);
    var zCView v; v = View_Get(b.v0);

    // Resizing to same pixel size
    var int changeX; changeX = fracf(_Bar_screen_x, Print_Screen[PS_X]);
    var int changeY; changeY = fracf(_Bar_screen_y, Print_Screen[PS_Y]);
    var int width;  width  = roundf(mulf(mkf(v.vsizex), changeX));
    var int height; height = roundf(mulf(mkf(v.vsizey), changeY));

    // Repositioning to same pixel coordinates (Gothic places bars at pixel positions!)
    // Since the pixel size is the same across resolutions, the positions need to be too to keep gaps between bars
    // To mind the aspect ratio changes, position relative to either left/top, center/middle or right/bottom of screen
    var int x; var int y; var int pos;
    pos = v.vposx + (v.vsizex>>1);
    if (pos < (PS_VMax + 1) / 3) { // Left third of the screen
        var int pixelsFromLeft;  pixelsFromLeft = Print_ToPixel(v.vposx, _Bar_screen_x);
        x = Print_ToVirtual(pixelsFromLeft, PS_X);
    } else if (pos >= (PS_VMax + 1) /3 * 2) { // Right third of the screen
        var int pixelsFromRight; pixelsFromRight = _Bar_screen_x - Print_ToPixel(v.vposx, _Bar_screen_x);
        x = Print_ToVirtual(Print_Screen[PS_X] - pixelsFromRight, PS_X);
    } else { // Center segment
        var int pixelsFromCenter; pixelsFromCenter = (_Bar_screen_x / 2) - Print_ToPixel(v.vposx, _Bar_screen_x);
        x = Print_ToVirtual(Print_Screen[PS_X] / 2 - pixelsFromCenter, PS_X);
    };
    pos = v.vposy + (v.vsizey>>1);
    if (pos < (PS_VMax + 1) / 3) { // Lower third of the screen
        var int pixelsFromTop;  pixelsFromTop = Print_ToPixel(v.vposy, _Bar_screen_y);
        y = Print_ToVirtual(pixelsFromTop, PS_Y);
    } else if (pos >= (PS_VMax + 1) /3 * 2) { // Upper third of the screen
        var int pixelsFromBottom; pixelsFromBottom = _Bar_screen_y - Print_ToPixel(v.vposy, _Bar_screen_y);
        y = Print_ToVirtual(Print_Screen[PS_Y] - pixelsFromBottom, PS_Y);
    } else { // Middle segment
        var int pixelsFromMiddle; pixelsFromMiddle = (_Bar_screen_y / 2) - Print_ToPixel(v.vposy, _Bar_screen_y);
        y = Print_ToVirtual(Print_Screen[PS_Y] / 2 - pixelsFromMiddle, PS_Y);
    };
    x += width>>1;
    y += height>>1;

    Bar_Resize(bar, width, height);
    Bar_MoveTo(bar, x, y);
};
