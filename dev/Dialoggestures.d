/***********************************\
            DIALOGGESTURES
\***********************************/

//========================================
// [intern]
//========================================
var int _DIAG_Max;
var int _DIAG_Min;

//========================================
// [intern]
//========================================
func void _DIAG_Patch() {
    const int oCNpc__StartDialogAniX = 7700155; // 0x757EBB
    const int oCNpc__StartDialogAniY = 7700162; // 0x757EC2

    const int address = 0;
    if(address) {
        return;
    };

    address = MEM_Alloc(19);

    MemoryProtectionOverride(oCNpc__StartDialogAniX, 5);
    MEM_WriteInt(oCNpc__StartDialogAniX + 0, 233);
    MEM_WriteInt(oCNpc__StartDialogAniX + 1, address-(oCNpc__StartDialogAniX+5));

    /*
        mov ecx, [_DIAG_Max]
        idiv ecx
        add ebx, [_DIAG_Min]
    */

    MEM_WriteByte(address+0,  139);
    MEM_WriteByte(address+1,  013); MEM_WriteInt(address+2, MEM_GetIntAddress(_DIAG_Max));
    MEM_WriteByte(address+6,  247);
    MEM_WriteByte(address+7,  249);
    MEM_WriteByte(address+8,  003);
    MEM_WriteByte(address+9,  021); MEM_WriteInt(address+10, MEM_GetIntAddress(_DIAG_Min));
    MEM_WriteByte(address+14, 233);
    MEM_WriteInt (address+15, oCNpc__StartDialogAniY-(address+19));
};

//========================================
// Minimum und Maximum direkt setzen
//========================================
func void DIAG_SetMinMax(var int min, var int max) {
    _DIAG_Patch();
    min -= 1;
    _DIAG_Min = min;
    _DIAG_Max = max-min;
};

//========================================
// Animation direkt setzen
//========================================
func void _DIAG_SetAni(var string AniName) {
    _DIAG_Patch();
    const int T_DIALOGGESTURE_ = 9148264; // 0x8B9768
    MemoryProtectionOverride(T_DIALOGGESTURE_, 16);
    AniName = STR_Upper(AniName);
    var zString ani; ani = MEM_PtrToInst(STR_GetAddress(AniName));
    if(ani.len < 1 || ani.len > 15) {
        MEM_Error("DIAG_SetAni: Length of AniName has to be between 0 and 16");
    };
    MEM_CopyBytes(ani.ptr, T_DIALOGGESTURE_, ani.len+1); // +1 für \0
};
func void DIAG_SetAni(var string AniName) {
    AniName = ConcatStrings(DIAG_Prefix, AniName);
    AniName = ConcatStrings(AniName, DIAG_Suffix);
    _DIAG_SetAni(AniName);
};

//========================================
// Gesten in Dialogen wechseln
//========================================
func void DIAG(var string AniName, var int Min, var int Max) {
    const int ptr = 0;
    ptr = MEM_Alloc(8);
    MEM_WriteInt(ptr, Min);
    MEM_WriteInt(ptr+4, Max);
    AI_WaitTillEnd(self, other);
    AI_WaitTillEnd(other, self);
    AI_Function_SI(other, _DIAG, AniName, ptr);
    AI_WaitTillEnd(self, other);
};

//========================================
// Gesten zurücksetzen
//========================================
func void DIAG_Reset() {
    AI_WaitTillEnd(self, other);
    AI_WaitTillEnd(other, self);
    AI_Function_SI(other, _DIAG, "T_DIALOGGESTURES_", -1);
    AI_WaitTillEnd(self, other);
};

//========================================
// [intern]
//========================================
func void _DIAG(var string AniName, var int ptr) {
    if(!STR_Compare(AniName, "T_DIALOGGESTURES_")) {
        DIAG_SetMinMax(1, 20);
        _DIAG_SetAni(AniName);
        return;
    };
    DIAG_SetMinMax(MEM_ReadInt(ptr), MEM_ReadInt(ptr+4));
    MEM_Free(ptr);
    DIAG_SetAni(AniName);
};




