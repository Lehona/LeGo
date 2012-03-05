/***********************************\
               RANDOM
\***********************************/

//========================================
// Zufallsvariablen
//========================================
var int r_val;

//========================================
// Zufallszahl holen
//========================================
func int r_Next() {
    var int lo; var int hi;
    lo = 16807 * (r_val & 65535);
    hi = 16807 * (r_val >> 16);
    lo += (hi & 32767) << 16;
    lo += hi >> 15;
    if(lo < 0) {
        lo += 2147483647;
    };
    r_val = lo;
    return r_val;
};

func int r_Max(var int max) {
    return r_Next()%(max+1);
};

func int r_MinMax(var int min, var int max) {
    return r_Max(max - min) + min;
};

//========================================
// Zufall initialisieren
//========================================
func void r_Init(var int seed) {
    r_val = seed;
    r_val = r_Next();
    r_val = r_Next();
    r_val = r_Next();
};

func void r_DefaultInit() {
    CALL__cdecl(sysGetTimePtr);
    r_Init(CALL_RetValAsInt());
};