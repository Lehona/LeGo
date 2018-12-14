
var int sinApprox; var int cosApprox;
func void SinCosApprox(var int angle) {
    const int sinPtr = 0;
    const int cosPtr = 0;
    if(!sinPtr) {
        sinPtr = _@(sinApprox);
        cosPtr = _@(cosApprox);
    };
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_PtrParam(_@(cosPtr));
        CALL_PtrParam(_@(sinPtr));
        CALL_FloatParam(_@(angle));
        CALL__cdecl(zSinCosApprox);

        call = CALL_End();
    };
};

func void zRND_D3D_DrawPolySimple(var int zCTexturePtr, var int zTRndSimpleVertexPtr, var int num) {
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(num));
        CALL_PtrParam(_@(zTRndSimpleVertexPtr));
        CALL_PtrParam(_@(zCTexturePtr));

        CALL__thiscall(zrenderer_adr, zRND_D3D__DrawPolySimple);

        call = CALL_End();
    };
};

func void zRND_D3D_DrawLine(var int x0, var int y0, var int x1, var int y1, var int color) {
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(color));
        CALL_FloatParam(_@(y1));
        CALL_FloatParam(_@(x1));
        CALL_FloatParam(_@(y0));
        CALL_FloatParam(_@(x0));

        CALL__thiscall(zrenderer_adr, zRND_D3D__DrawLine);

        call = CALL_End();
    };
};

func int zRND_D3D_GetTotalTextureMem() {
    return MEM_ReadInt(zrenderer_adr + zRND_D3D_TexMemory_offset);
};

func void zRND_D3D_SetAlphaBlendFunc(var int zTRnd_AlphaBlendFunc) {
    const int ptr = 0;
    if(!ptr) {
        ptr = _@(zTRnd_AlphaBlendFunc);
    };
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(ptr));
        CALL__thiscall(zrenderer_adr, zRND_D3D__SetAlphaBlendFunc);

        call = CALL_End();
    };
};

const int zRND_ALPHA_FUNC_MAT_DEFAULT = 0;
const int zRND_ALPHA_FUNC_NONE        = 1;
const int zRND_ALPHA_FUNC_BLEND       = 2;
const int zRND_ALPHA_FUNC_ADD         = 3;
const int zRND_ALPHA_FUNC_SUB         = 4;
const int zRND_ALPHA_FUNC_MUL         = 5;
const int zRND_ALPHA_FUNC_MUL2        = 6;
const int zRND_ALPHA_FUNC_TEST        = 7;
const int zRND_ALPHA_FUNC_BLEND_TEST  = 8;


func void zRND_XD3D_SetRenderState(var int state, var int mode) {
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(mode));
        CALL_IntParam(_@(state));

        CALL__thiscall(zrenderer_adr, zCRnd_D3D__XD3D_SetRenderState);

        call = CALL_End();
    };
};

const int D3DRS_ZENABLE = 7;


class zTRndSimpleVertex {
    var int pos[2];
    var int z;
    var int uv[2];
    var int color;
};
const int sizeof_zTRndSimpleVertex = 6 * 4;

class gCSprite {
    var int x;      // float
    var int y;      // float
    var int width;  // float
    var int height; // float
    var int hidden; // bool
    var int prio;
    var string textureName;
    var int buf;    // zCArray*

    var int texture; // zCTexture*
    var int sin; // float (sin(rot)
    var int cos; // float (cos(rot))
    var int stream; // int* (buf->array)
};

const string gCSprite_Struct = "auto|7 zCArray* void|4";

instance gCSprite@(gCSprite);

func void _Sprite_CalcZ(var gCSprite s) {
    var int off; off = s.stream;
    var int i; i = 0;
    repeat(i, 4);
        MEM_WriteInt(off+8, floatEins);
        off += sizeof_zTRndSimpleVertex;
    end;
};

func void _Sprite_CalcRotMat(var gCSprite s, var int x, var int y, var int resPtr) {
    MEM_WriteInt(resPtr,     subf(mulf(x, s.cos), mulf(y, s.sin)));
    MEM_WriteInt(resPtr + 4, addf(mulf(x, s.sin), mulf(y, s.cos)));
};

func void _Sprite_CalcRotForVert(var gCSprite s, var int v, var int x, var int y) {
    var int resPtr; resPtr = s.stream + v * sizeof_zTRndSimpleVertex;
    MEM_WriteInt(resPtr,     addf(s.x, subf(mulf(x, s.cos), mulf(y, s.sin))));
    MEM_WriteInt(resPtr + 4, addf(s.y, addf(mulf(x, s.sin), mulf(y, s.cos))));
};

func void _Sprite_CalcPos(var gCSprite s) {
    var int wh; wh = mulf(s.width, floatHalb);
    var int hh; hh = mulf(s.height, floatHalb);
    var int nwh; nwh = negf(wh);
    var int nhh; nhh = negf(hh);

    s.stream = MEM_ReadInt(s.buf);

    _Sprite_CalcRotForVert(s, 0, nwh, nhh);
    _Sprite_CalcRotForVert(s, 1,  wh, nhh);
    _Sprite_CalcRotForVert(s, 2,  wh,  hh);
    _Sprite_CalcRotForVert(s, 3, nwh,  hh);
};

func void _Sprite_NewBuf(var gCSprite s) {
    s.buf = MEM_ArrayCreate();
    var zCArray arr; arr = _^(s.buf);
    arr.numInArray = sizeof_zTRndSimpleVertex;
    arr.numAlloc = sizeof_zTRndSimpleVertex;
    arr.array = MEM_Alloc(4 * sizeof_zTRndSimpleVertex);
};

//========================================
// UV eines Vertex
//========================================
func void Sprite_SetVertUV(var int h, var int vert, var int x, var int y) {
    if(vert < 0 || vert > 3) { return; };
    var gCSprite s; s = get(h);
    var int off; off = MEM_ReadInt(s.buf) + vert * sizeof_zTRndSimpleVertex;
    MEM_WriteInt(off + 12, x);
    MEM_WriteInt(off + 16, y);
};

//========================================
// UV eines Sprites
//========================================
func void Sprite_SetUV(var int h, var int x0, var int y0, var int x1, var int y1) {
    var gCSprite s; s = get(h);
    var int off; off = MEM_ReadInt(s.buf);
    MEM_WriteInt(off + 12, x0);
    MEM_WriteInt(off + 16, y0);
    off += sizeof_zTRndSimpleVertex;
    MEM_WriteInt(off + 12, x1);
    MEM_WriteInt(off + 16, y0);
    off += sizeof_zTRndSimpleVertex;
    MEM_WriteInt(off + 12, x1);
    MEM_WriteInt(off + 16, y1);
    off += sizeof_zTRndSimpleVertex;
    MEM_WriteInt(off + 12, x0);
    MEM_WriteInt(off + 16, y1);
};

//========================================
// Farbe eines Vertex
//========================================
func void Sprite_SetVertColor(var int h, var int vert, var int col) {
    if(vert < 0 || vert > 3) { return; };
    var gCSprite s; s = get(h);
    MEM_WriteInt(MEM_ReadInt(s.buf) + vert * sizeof_zTRndSimpleVertex + 20, col);
};

//========================================
// Farbe eines Sprites
//========================================
func void Sprite_SetColor(var int h, var int col) {
    var gCSprite s; s = get(h);
    var int off; off = MEM_ReadInt(s.buf);
    var int i; i = 0;
    repeat(i, 4);
        MEM_WriteInt(off + 20, col);
        off += sizeof_zTRndSimpleVertex;
    end;
};

//========================================
// Priorität eines Sprites
//========================================
func void Sprite_SetPrio(var int h, var int prio) {
    var gCSprite s; s = get(h);
    if(s.prio == prio) { return; };
    s.prio = prio;
    foreachHndlSort(gCSprite@, _Sprite_PrioComparer);
};
func int _Sprite_PrioComparer(var int l, var int r) {
    var gCSprite sl; sl = get(l);
    var gCSprite sr; sr = get(r);
    return sl.prio - sr.prio;
};

//========================================
// Position eines Sprites
//========================================
func void Sprite_SetPosPxlF(var int h, var int xf, var int yf) {
    var gCSprite s; s = get(h);
    s.x = xf;
    s.y = yf;
    _Sprite_CalcPos(s);
};

func void Sprite_SetPosPxl(var int h, var int x, var int y) {
    Sprite_SetPosPxlF(h, mkf(x), mkf(y));
};

func void Sprite_SetPos(var int h, var int x, var int y) {
    Sprite_SetPosPxlF(h, Print_ToPixel(x, PS_X), Print_ToPixel(y, PS_Y));
};

//========================================
// Rotation eines Sprites
//========================================
func void Sprite_SetRotationSC(var int h, var int sin, var int cos) {
    var gCSprite s; s = get(h);
    s.sin = sin;
    s.cos = cos;
    _Sprite_CalcPos(s);
};

func void Sprite_SetRotationR(var int h, var int r) {
    var gCSprite s; s = get(h);
    SinCosApprox(r);
    s.sin = sinApprox;
    s.cos = cosApprox;
    _Sprite_CalcPos(s);
};

func void Sprite_SetRotation(var int h, var int r) {
    Sprite_SetRotationR(h, Print_ToRadian(mkf(r)));
};

//========================================
// Rotieren eines Sprites
//========================================
func void Sprite_RotateR(var int h, var int r) {
    var gCSprite s; s = get(h);
    SinCosApprox(r);
    var int res[2];
    _Sprite_CalcRotMat(s, cosApprox, sinApprox, _@(res));
    s.cos = res[0];
    s.sin = res[1];
    _Sprite_CalcPos(s);
};
func void Sprite_Rotate(var int h, var int r) {
    Sprite_RotateR(h, Print_ToRadian(mkf(r)));
};

//========================================
// Breite eines Sprites setzen
//========================================
func void Sprite_SetWidthPxl(var int h, var int w) {
    var gCSprite s; s = get(h);
    s.width = mkf(w);
    _Sprite_CalcPos(s);
};
func void Sprite_SetWidth(var int h, var int w) {
    Sprite_SetWidthPxl(h, Print_ToVirtual(w, PS_X));
};

//========================================
// Höhe eines Sprites setzen
//========================================
func void Sprite_SetHeightPxl(var int h, var int hg) {
    var gCSprite s; s = get(h);
    s.height = mkf(hg);
    _Sprite_CalcPos(s);
};

func void Sprite_SetHeight(var int h, var int hg) {
    Sprite_SetHeightPxl(h, Print_ToVirtual(hg, PS_Y));
};

//========================================
// Breite und Höhe eines Sprites setzen
//========================================
func void Sprite_SetDimPxl(var int h, var int w, var int hg) {
    var gCSprite s; s = get(h);
    s.width = mkf(w);
    s.height = mkf(hg);
    _Sprite_CalcPos(s);
};
func void Sprite_SetDim(var int h, var int w, var int hg) {
    Sprite_SetDimPxl(h, Print_ToPixel(w, PS_X), Print_ToPixel(hg, PS_Y));
};

//========================================
// Sprite skalieren
//========================================
func void Sprite_Scale(var int h, var int x, var int y) {
    var gCSprite s; s = get(h);
    s.width = mulf(s.width, x);
    s.height = mulf(s.height, y);
    _Sprite_CalcPos(s);
};

//========================================
// Sprite verstecken
//========================================
func void Sprite_SetVisible(var int h, var int visible) {
    var gCSprite s; s = get(h);
    s.hidden = !visible;
};

//========================================
// Sprite erstellen
//========================================
func int Sprite_CreatePxl(var int x, var int y, var int width, var int height, var int color, var string tex) {
    var int h; h = new(gCSprite@);
    var gCSprite s; s = get(h);

    s.buf = MEM_ArrayCreate();

    s.x = mkf(x);
    s.y = mkf(y);
    s.width = mkf(width);
    s.height = mkf(height);
    s.textureName = tex;

    _Sprite_NewBuf(s);

    Sprite_SetColor(h, color);
    Sprite_SetUV(h, floatNull, floatNull, floatEins, floatEins);
    Sprite_SetRotationSC(h, floatNull, floatEins);

    _Sprite_CalcPos(s);
    _Sprite_CalcZ(s);

    return h;
};

func int Sprite_Create(var int x, var int y, var int width, var int height, var int color, var string tex) {
    Sprite_CreatePxl(Print_ToPixel(x, PS_X), Print_ToPixel(y, PS_Y), Print_ToPixel(width, PS_X), Print_ToPixel(height, PS_Y), color, tex);
};

//========================================
// Sprite rendern
//========================================
func void Sprite_Render(var int h) {
    var gCSprite s; s = get(h);
    if(s.hidden) {
        return;
    };
    if(!s.texture) {
        s.texture = zCTexture_Load(s.textureName);
    };
    zRND_D3D_DrawPolySimple(s.texture, MEM_ReadInt(s.buf), 4);
};

//========================================
// [intern] alle Sprites rendern
//========================================
func void _Sprite_DoRender() {
    if(!Hlp_IsValidNpc(hero)) { return; }; // Vielen Dank an Sektenspinner für diesen "Hack"

    zRND_XD3D_SetRenderState(D3DRS_ZENABLE, false); // Disable depthbuffer

    zRND_D3D_SetAlphaBlendFunc(zRND_ALPHA_FUNC_BLEND);
    foreachHndl(gCSprite@, Sprite_Render);

    zRND_XD3D_SetRenderState(D3DRS_ZENABLE, true); // Enable depthbuffer
};
