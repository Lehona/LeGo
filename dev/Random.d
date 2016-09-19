/***********************************\
               RANDOM
\***********************************/

//========================================
// Zufallsvariablen
//========================================
const int r_val = 0;

//========================================
// Zufallszahl holen
//========================================
func int r_Next() {
    r_val = (1103515245 * r_val) + 12345;
    if(r_val < 0) {
        r_val += 2147483647;
    };
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