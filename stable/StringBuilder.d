/***********************************\
            STRINGBUILDER
\***********************************/

//========================================
// [intern] Klasse / Variablen
//========================================
class StringBuilder {
    var int ptr;
    var int cln;
    var int cal;
};

const int _SB_Current = 0;

//========================================
// Aktiven StringBuilder setzen
//========================================
func void SB_Use(var int sb) {
    _SB_Current = sb;
};

//========================================
// Aktiven StringBuilder holen
//========================================
func int SB_Get() {
    return _SB_Current;
};

//========================================
// Neuen StringBuilder erstellen
//========================================
func int SB_New() {
    SB_Use(MEM_Alloc(12));
    return _SB_Current;
};

//========================================
// Buffer initialisieren (def: auto)
//========================================
func void SB_InitBuffer(var int size) {
    var StringBuilder c; c = _^(_SB_Current);
    if(c.ptr) {
        MEM_Error("SB_InitBuffer: Der StringBuilder hat bereits einen Buffer.");
        return;
    };
    if(size < 8) {
        size = 8;
    };
    c.ptr = MEM_Alloc(size);
    c.cln = 0;
    c.cal = size;
};

//========================================
// Leeren (wird nicht zerstört!)
//========================================
func void SB_Clear() {
    var StringBuilder c; c = _^(_SB_Current);
    if(c.ptr) {
        MEM_Free(c.ptr);
    };
    c.ptr = 0;
    c.cln = 0;
    c.cal = 0;
};

//========================================
// Stream entkoppeln
//========================================
func void SB_Release() {
    MEM_Free(_SB_Current);
    _SB_Current = 0;
};

//========================================
// StringBuilder komplett zerstören
//========================================
func void SB_Destroy() {
    SB_Clear();
    SB_Release();
};

//========================================
// Stream als String zurückgeben
//========================================
func string SB_ToString() {
    var StringBuilder c; c = _^(_SB_Current);
    if(!c.ptr) { return ""; };
    var string ret; ret = "";
    var zString z; z = _^(_@s(ret));
    z.ptr = MEM_Alloc(c.cln+2)+1;
    MEM_CopyBytes(c.ptr, z.ptr, c.cln);
    z.len = c.cln;
    z.res = c.cln;
    return ret;
};

//========================================
// Stream als Pointer zurückgeben
//========================================
func int SB_GetStream() {
    if(!_SB_Current) {
        return 0;
    };
    return MEM_ReadInt(_SB_Current);
};

//========================================
// Kopie des Streams zurückgeben
//========================================
func int SB_ToStream() {
    if(!_SB_Current) {
        return 0;
    };
    var StringBuilder c; c = _^(_SB_Current);
    var int p; p = MEM_Alloc(c.cln);
    MEM_CopyBytes(c.ptr, p, c.cln);
    return p;
};

//========================================
// Aktuelle Länge
//========================================
func int SB_Length() {
    if(!_SB_Current) {
        return 0;
    };
    return MEM_ReadInt(_SB_Current+4);
};

//========================================
// Rohbytes anhängen
//========================================
func void SBraw(var int ptr, var int len) {
    var StringBuilder c; c = _^(_SB_Current);
    if(!c.ptr) {
        SB_InitBuffer(32);
    };
    var int n; n = c.cln + len;
    if(n > c.cal) {
        var int o; o = c.cal;
        while(n > c.cal);
            c.cal *= 2;
        end;
        c.ptr = MEM_Realloc(c.ptr, o, c.cal);
    };
    MEM_CopyBytes(ptr, c.ptr + c.cln, len);
    c.cln = n;
};

//========================================
// String anhängen
//========================================
func void SB(var string s) {
    var zString z; z = _^(_@s(s));
    SBraw(z.ptr, z.len);
};

//========================================
// Int als ASCII anhängen
//========================================
func void SBi(var int i) {
    SB(IntToString(i));
};

//========================================
// Buchstaben anhängen (ASCII)
//========================================
func void SBc(var int b) {
    var StringBuilder c; c = _^(_SB_Current);
    if(!c.ptr) {
        SB_InitBuffer(32);
    };
    if(c.cln+4 > c.cal) {
        c.ptr = MEM_Realloc(c.ptr, c.cal, c.cal<<1);
        c.cal *= 2;
    };
    MEM_WriteInt(c.ptr+c.cln, b);
    c.cln += 1;
};

//========================================
// Int als 4 Byte roh anhängen
//========================================
func void SBw(var int b) {
    var StringBuilder c; c = _^(_SB_Current);
    if(!c.ptr) {
        SB_InitBuffer(32);
    };
    if(c.cln+4 > c.cal) {
        c.ptr = MEM_Realloc(c.ptr, c.cal, c.cal<<1);
        c.cal *= 2;
    };
    MEM_WriteInt(c.ptr+c.cln, b);
    c.cln += 4;
};

//========================================
// Float anhängen (ASCII)
//========================================
func void SBflt(var float f) {
    SB(FloatToString(f));
};

//========================================
// Int als Float anhängen (ASCII)
//========================================
func void SBf(var int f) {
    f; MEM_Call(SBflt);
};

//========================================
// Länge setzen
//========================================
func void SB_SetLength(var int l) {
    while(l > SB_Length());
		SBw(0);
	end;
    MEM_WriteInt(_SB_Current+4, l);
};

//========================================
// STR_Escape / STR_Unescape
//========================================
const int STR_Sequences[33] = {
    48,  49,  50,  51,  52,  53,  54,  97,
    98,  116, 110, 118, 102, 114, 55,  56,
    57,  65,  66,  67,  68,  69,  70,  71,
    72,  73,  74,  75,  76,  77,  78,  79, 95
};

func string STR_Escape(var string s0) {
    var int osb; osb = SB_Get();

    var zString z; z = _^(_@s(s0));
    const int sb = 0;
    if(!sb) {
        sb = SB_New();
    };
    SB_Use(sb);
    SB_InitBuffer(z.len * 2);
    var int i; i = 0;
    var int l; l = z.len;
    while(i < l);
        var int c; c = MEM_ReadByte(z.ptr + i);
        if(c == 92) { // '\'
            SBc(92);
            SBc(92);
        }
        else if(c < 33) {
            SBc(92);
            SBc(MEM_ReadStatArr(STR_Sequences, c));
        }
        else {
            SBc(c);
        };
        i += 1;
    end;
    var string res; res = SB_ToString();
    SB_Clear();

    SB_Use(osb);
    return res;
};

func string STR_Unescape(var string s0) {
    var int osb; osb = SB_Get();

    var zString z; z = _^(_@s(s0));
    const int sb = 0;
    if(!sb) {
        sb = SB_New();
    };
    SB_Use(sb);
    SB_InitBuffer(z.len);
    var int i; i = 0;
    var int l; l = z.len;
    while(i < l);
        var int c; c = MEM_ReadByte(z.ptr + i);
        if(c == 92) { // '\'
            i += 1;
            c = MEM_ReadByte(z.ptr + i);
            if(c == 92) {
                SBc(92);
            }
            else {
                var int j; j = 0;
                while(j < 33);
                    var int n; n = MEM_ReadStatArr(STR_Sequences, j);
                    if(c == n) {
                        SBc(j);
                        break;
                    };
                    j += 1;
                end;
            };
        }
        else {
            SBc(c);
        };
        i += 1;
    end;
    var string res; res = SB_ToString();
    SB_Clear();

    SB_Use(osb);

    return res;
};

//========================================
// Hilfsfunktion STR_StartsWith
//========================================
func int STR_StartsWith(var string str, var string start) {
    var zString z0; z0 = _^(_@s(str));
    var zString z1; z1 = _^(_@s(start));
    if(z1.len > z0.len) { return 0; };
    MEM_CompareBytes(z0.ptr, z1.ptr, z1.len);
};