/***********************************\
             AI_Function
\***********************************/

//========================================
// [intern] Alias zu AI_Function
//========================================
func void _AI_Function(var c_npc slf, var string fnc) {
    AI_PlayAni(slf, ConcatStrings("CALL ", fnc));
};

//========================================
// Verzögert eine Funktion aufrufen
//========================================
func void AI_Function (var c_npc slf, var func function) {
    _AI_Function(slf, IntToString(MEM_GetFuncID(function)));
};
func void AI_Function_I(var c_npc slf, var func function, var int param) {
    var int s; s = SB_New();
    SB ("I ");
    SBi(param);
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_II(var c_npc slf, var func function, var int param1, var int param2) {
    var int s; s = SB_New();
    SB ("II ");
    SBi(param1);
    SB (" ");
    SBi(param2);
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_N(var c_npc slf, var func function, var int param) {
    var int s; s = SB_New();
    SB ("N ");
    SBi(param);
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_NN(var c_npc slf, var func function, var int param1, var int param2) {
    var int s; s = SB_New();
    SB ("NN ");
    SBi(param1);
    SB (" ");
    SBi(param2);
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_S(var c_npc slf, var func function, var string param) {
    var int s; s = SB_New();
    SB ("S ");
    SB (STR_Escape(param));
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_SS(var c_npc slf, var func function, var string param1, var string param2) {
    var int s; s = SB_New();
    SB ("SS ");
    SB (STR_Escape(param1));
    SB (" ");
    SB (STR_Escape(param2));
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_IN(var c_npc slf, var func function, var int param1, var int param2) {
    var int s; s = SB_New();
    SB ("IN ");
    SBi(param1);
    SB (" ");
    SBi(param2);
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_NI(var c_npc slf, var func function, var int param1, var int param2) {
    var int s; s = SB_New();
    SB ("NI ");
    SBi(param1);
    SB (" ");
    SBi(param2);
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_SI(var c_npc slf, var func function, var string param1, var int param2) {
    var int s; s = SB_New();
    SB ("SI ");
    SB (STR_Escape(param1));
    SB (" ");
    SBi(param2);
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_IS(var c_npc slf, var func function, var int param1, var string param2) {
    var int s; s = SB_New();
    SB ("IS ");
    SBi(param1);
    SB (" ");
    SB (STR_Escape(param2));
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_SN(var c_npc slf, var func function, var string param1, var int param2) {
    var int s; s = SB_New();
    SB ("SN ");
    SB (STR_Escape(param1));
    SB (" ");
    SBi(param2);
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};
func void AI_Function_NS(var c_npc slf, var func function, var int param1, var string param2) {
    var int s; s = SB_New();
    SB ("NS ");
    SBi(param1);
    SB (" ");
    SB (STR_Escape(param2));
    SB (" ");
    SBi(MEM_GetFuncID(function));
    _AI_Function(slf, SB_ToString());
    SB_Destroy();
};

//========================================
// [intern] Enginehook
//========================================
func void _AI_FUNCTION_EVENT() {
    var string s0; var string s1;
    var int i0; var int i1; var int fnc;
    var int ptr; ptr = EBP+88;
    MEMINT_StackPushVar(ptr);
    var string AniName; AniName = MEMINT_PopString();

    if(!STR_StartsWith(AniName, "CALL ")) {
        return;
    };

    // Provide global instances (will be reverted by HookEngine afterwards)
    self = _^(ECX);
    other = MEM_NullToInst(); // Invalidate to avoid misuse
    item = MEM_NullToInst();

    var string argc; argc = STR_Split(AniName, " ", 1);
    if (Hlp_StrCmp(argc, "I")) {
        i0 = STR_ToInt(STR_Split(AniName, " ", 2));
        fnc = STR_ToInt(STR_Split(AniName, " ", 3));
        MEM_PushIntParam(i0);
    }
    else if (Hlp_StrCmp(argc, "N")) {
        i0 = STR_ToInt(STR_Split(AniName, " ", 2));
        fnc = STR_ToInt(STR_Split(AniName, " ", 3));
        MEM_PushInstParam(i0);
    }
    else if (Hlp_StrCmp(argc, "S")) {
        s0 = STR_Unescape(STR_Split(AniName, " ", 2));
        fnc = STR_ToInt(STR_Split(AniName, " ", 3));
        MEM_PushStringParam(s0);
    }
    else if (Hlp_StrCmp(argc, "II")) {
        i0 = STR_ToInt(STR_Split(AniName, " ", 2));
        i1 = STR_ToInt(STR_Split(AniName, " ", 3));
        fnc = STR_ToInt(STR_Split(AniName, " ", 4));
        MEM_PushIntParam(i0);
        MEM_PushIntParam(i1);
    }
    else if (Hlp_StrCmp(argc, "NN")) {
        i0 = STR_ToInt(STR_Split(AniName, " ", 2));
        i1 = STR_ToInt(STR_Split(AniName, " ", 3));
        fnc = STR_ToInt(STR_Split(AniName, " ", 4));
        MEM_PushInstParam(i0);
        MEM_PushInstParam(i1);
    }
    else if (Hlp_StrCmp(argc, "SS")) {
        s0 = STR_Unescape(STR_Split(AniName, " ", 2));
        s1 = STR_Unescape(STR_Split(AniName, " ", 3));
        fnc = STR_ToInt(STR_Split(AniName, " ", 4));
        MEM_PushStringParam(s0);
        MEM_PushStringParam(s1);
    }
    else if (Hlp_StrCmp(argc, "IN")) {
        i0 = STR_ToInt(STR_Split(AniName, " ", 2));
        i1 = STR_ToInt(STR_Split(AniName, " ", 3));
        fnc = STR_ToInt(STR_Split(AniName, " ", 4));
        MEM_PushIntParam(i0);
        MEM_PushInstParam(i1);
    }
    else if (Hlp_StrCmp(argc, "NI")) {
        i0 = STR_ToInt(STR_Split(AniName, " ", 2));
        i1 = STR_ToInt(STR_Split(AniName, " ", 3));
        fnc = STR_ToInt(STR_Split(AniName, " ", 4));
        MEM_PushInstParam(i0);
        MEM_PushIntParam(i1);
    }
    else if (Hlp_StrCmp(argc, "SI")) {
        s0 = STR_Unescape(STR_Split(AniName, " ", 2));
        i1 = STR_ToInt(STR_Split(AniName, " ", 3));
        fnc = STR_ToInt(STR_Split(AniName, " ", 4));
        MEM_PushStringParam(s0);
        MEM_PushIntParam(i1);
    }
    else if (Hlp_StrCmp(argc, "IS")) {
        i0 = STR_ToInt(STR_Split(AniName, " ", 2));
        s1 = STR_Unescape(STR_Split(AniName, " ", 3));
        fnc = STR_ToInt(STR_Split(AniName, " ", 4));
        MEM_PushIntParam(i0);
        MEM_PushStringParam(s1);
    }
    else if (Hlp_StrCmp(argc, "SN")) {
        s0 = STR_Unescape(STR_Split(AniName, " ", 2));
        i1 = STR_ToInt(STR_Split(AniName, " ", 3));
        fnc = STR_ToInt(STR_Split(AniName, " ", 4));
        MEM_PushStringParam(s0);
        MEM_PushInstParam(i1);
    }
    else if (Hlp_StrCmp(argc, "NS")) {
        i0 = STR_ToInt(STR_Split(AniName, " ", 2));
        s1 = STR_Unescape(STR_Split(AniName, " ", 3));
        fnc = STR_ToInt(STR_Split(AniName, " ", 4));
        MEM_PushInstParam(i0);
        MEM_PushStringParam(s1);
    }
    else {
        fnc = STR_ToInt(argc);
    };
    MEM_CallByID(fnc);
};

