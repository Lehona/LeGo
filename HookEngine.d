/***********************************\
             HOOKENGINE
\***********************************/


//========================================
// Enginefunktion beenden
//========================================
const int _EngineStackSize = -1; // INTERN!
func void SkipEngineFunction(var int stack) {
    _EngineStackSize = stack;
};

//-------------------
// OPCODES
//-------------------
// /* 1 Byte */
const int ASMINT_OP_CompareEAX  = 61;    //0x3D
const int ASMINT_OP_JZ_Byte     = 116;   //0x74
const int ASMINT_OP_popEAX      = 88;    //0x58
// /* 2 Byte */
const int ASMINT_OP_addMemToESP = 9475;  //0x2503

//-------------------
// RÜCKGABEVARIABLEN
//-------------------
var int EAX;
func int GetEAX() { return EAX; };
func int EAXAdr() {
    GetEAX();
    MEMINT_StackPopInst();
    MEMINT_StackPushInst(zPAR_TOK_PUSHINT);
};
var int ECX;
func int GetECX() { return ECX; };
func int ECXAdr() {
    GetECX();
    MEMINT_StackPopInst();
    MEMINT_StackPushInst(zPAR_TOK_PUSHINT);
};
var int ESP;
func int GetESP() { return ESP; };
func int ESPAdr() {
    GetESP();
    MEMINT_StackPopInst();
    MEMINT_StackPushInst(zPAR_TOK_PUSHINT);
};

var int EBX;
func int GetEBX() { return EBX; };
func int EBXAdr() {
    GetEBX();
    MEMINT_StackPopInst();
    MEMINT_StackPushInst(zPAR_TOK_PUSHINT);
};

var int EBP;
func int GetEBP() { return EBP; };
func int EBPAdr() {
    GetEBP();
    MEMINT_StackPopInst();
    MEMINT_StackPushInst(zPAR_TOK_PUSHINT);
};

var int EDI;
func int GetEDI() { return EDI; };
func int EDIAdr() {
    GetEDI();
    MEMINT_StackPopInst();
    MEMINT_StackPushInst(zPAR_TOK_PUSHINT);
};


//========================================
// Engine hooken
//========================================
func void HookEngine(var int address, var int oldInstr, var string function) {
    function = STR_Upper(function);

    var int SymbID;   // Symbolindex von 'function'
    var int ptr;      // Pointer auf den Zwischenspeicher der alten Anweisung
    var int relAdr;   // Relative Addresse zum neuen Assemblercode, ausgehend von 'address'

    // ----- Sicherheitsabfragen -----
    if(oldInstr < 5) {
        PrintDebug("HOOKENGINE: oldInstr ist zu kurz. Es werden mindestens 5 Bytes erwartet.");
        return;
    };

    SymbID = MEM_FindParserSymbol(function);
    if(!SymbID) {
        PrintDebug("HOOKENGINE: Die gegebene Daedalusfunktion kann nicht gefunden werden.");
        return;
    };

    MemoryProtectionOverride (address, oldInstr+3);
    // ----- Eventuell geschützen Speicher behandeln -----

    // ----- Die alte Anweisung sichern -----
    ptr = MEM_Alloc(oldInstr);
    MEM_CopyBytes(address, ptr, oldInstr);

    // ----- Einen neuen Stream für den Assemblercode anlegen -----
    ASM_Open(140 + oldInstr); // Play it safe.

    // ----- Jump aus der Enginefunktion in den neuen Code einfügen -----
    relAdr = ASMINT_CurrRun-address-5;
    MEM_WriteInt(address + 0, 233);
    MEM_WriteInt(address + 1, relAdr);

    // ----- Neuen Assemblercode verfassen -----

    // Alle Register sichern

    // EAX in Daedalus Variable sichern
    ASM_2(ASMINT_OP_movEAXToMem);
    ASM_4(EAXAdr());
    ASM_1(ASMINT_OP_pusha);

    // ECX in Daedalus Variable sichern
    ASM_2(ASMINT_OP_movECXtoEAX);
    ASM_2(ASMINT_OP_movEAXToMem);
    ASM_4(ECXAdr());

    // ESP in Daedalus Variable sichern
    ASM_2(ASMINT_OP_movESPtoEAX);
    ASM_2(ASMINT_OP_addImToEAX);
    ASM_1(4*8);                  // Wegen pushad [Danke an Sektenspinner]
    ASM_2(ASMINT_OP_movEAXToMem);
    ASM_4(ESPAdr());

    // EBX in Daedalus Variable sichern
    ASM_2(ASMINT_OP_movEBXtoEAX);
    ASM_2(ASMINT_OP_movEAXtoMem);
    ASM_4(EBXAdr());

    // EBP in Daedalus Variable sichern
    ASM_2(ASMINT_OP_movEBPtoEAX);
    ASM_2(ASMINT_OP_movEAXtoMem);
    ASM_4(EBPAdr());

    // EDI in Daedalus Variable sichern
    ASM_2(ASMINT_OP_movEDItoEAX);
    ASM_2(ASMINT_OP_movEAXtoMem);
    ASM_4(EDIAdr());

    // --- Daedalusfunktion aufrufen ---

    ASM_1(ASMINT_OP_pushIm);
    ASM_4(SymbID);

    ASM_1(ASMINT_OP_pushIm);
    ASM_4(parser);

    ASM_1(ASMINT_OP_call);
    ASM_4(zParser__CallFunc-ASM_Here()-4);

    ASM_2(ASMINT_OP_addImToESP);
    ASM_1(8);

    ASM_1(ASMINT_OP_popa);

    ASM_1(ASMINT_OP_movMemToEAX);
    ASM_4(ECXAdr());
    ASM_2(ASMINT_OP_movEAXtoECX);

    ASM_1(ASMINT_OP_movMemToEAX);
    ASM_4(EAXAdr());


    ASM_1(ASMINT_OP_pushEAX);

    ASM_1(ASMINT_OP_movMemToEAX);
    ASM_4(MEM_GetIntAddress(_EngineStackSize));

    ASM_1(ASMINT_OP_CompareEAX);
    ASM_4(-1);

    ASM_1(ASMINT_OP_JZ_Byte);
    ASM_1(19);

    // if (_EngineStackSize != -1) {

        const int m1 = -1;
        ASM_1(ASMINT_OP_movMemToEAX);
        ASM_4(MEM_GetIntAddress(m1));

        ASM_2(ASMINT_OP_movEAXToMem);
        ASM_4(MEM_GetIntAddress(_EngineStackSize));

        ASM_1(ASMINT_OP_popEAX);

        ASM_2(ASMINT_OP_addMemToESP);
        ASM_4(MEM_GetIntAddress(_EngineStackSize));

        ASM_1(ASMINT_OP_retn);

    // }

    ASM_1(ASMINT_OP_popEAX);

    // Alte Anweisung wieder einfügen
    MEM_CopyBytes(ptr, ASMINT_Cursor, oldInstr);
    MEM_Free(ptr);

    ASMINT_Cursor += oldInstr;

    // Zur Enginefunktion zurückkehren
    ASM_1(ASMINT_OP_pushIm);
    ASM_4(address + oldInstr);
    ASM_1(ASMINT_OP_retn);

    ASM_Close();
};