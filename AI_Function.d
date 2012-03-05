/***********************************\
             AI_Function
\***********************************/

//========================================
// Hilfsfunktion STR_StartsWith
//========================================
func int STR_StartsWith(var string str, var string start) {
    var zString z0; z0 = _^(_@s(str));
    var zString z1; z1 = _^(_@s(start));
	if(z1.len > z0.len) { return 0; };
    MEM_CompareBytes(z0.ptr, z1.ptr, z1.len);
};


//========================================
// [intern] Alias zu AI_Function
//========================================
func void _AI_Function(var c_npc slf, var string fnc) {
    if(!_LeGo_Init&LeGo_AI_Function) {
        MEM_Error("LeGo: AI_Function wurde nicht initialisiert!");
        return;
    };

    var string s1; s1 = ConcatStrings("CALL ", fnc);
    AI_PlayAni(slf, s1);
};

//========================================
// Verzögert eine Funktion aufrufen
//========================================
func void AI_Function (var c_npc slf, var func function) {
    _AI_Function(slf, IntToString(MEM_GetFuncID(function)));
};
func void AI_Function_I(var c_npc slf, var func function, var int param) {
    var string s1;
    s1 = ConcatStrings("I ", IntToString(param));
    s1 = ConcatStrings(s1, " ");
    s1 = ConcatStrings(s1, IntToString(MEM_GetFuncID(function)));
    _AI_Function(slf, s1);
};
func void AI_Function_II(var c_npc slf, var func function, var int param1, var int param2) {
    var string s1;
    s1 = ConcatStrings("II ", IntToString(param1));
    s1 = ConcatStrings(s1, " ");
    s1 = ConcatStrings(s1, IntToString(param2));
    s1 = ConcatStrings(s1, " ");
    s1 = ConcatStrings(s1, IntToString(MEM_GetFuncID(function)));
    _AI_Function(slf, s1);
};
func void AI_Function_S(var c_npc slf, var func function, var string param) {
    var string s1;
    s1 = ConcatStrings("S ", param);
    s1 = ConcatStrings(s1, " ");
    s1 = ConcatStrings(s1, IntToString(MEM_GetFuncID(function)));
    _AI_Function(slf, s1);
};
func void AI_Function_SS(var c_npc slf, var func function, var string param1, var string param2) {
    var string s1;
    s1 = ConcatStrings("SS ", param1);
    s1 = ConcatStrings(s1, " ");
    s1 = ConcatStrings(s1, param2);
    s1 = ConcatStrings(s1, " ");
    s1 = ConcatStrings(s1, IntToString(MEM_GetFuncID(function)));
    _AI_Function(slf, s1);
};
func void AI_Function_SI(var c_npc slf, var func function, var string param1, var int param2) {
    var string s1;
    s1 = ConcatStrings("SI ", param1);
    s1 = ConcatStrings(s1, " ");
    s1 = ConcatStrings(s1, IntToString(param2));
    s1 = ConcatStrings(s1, " ");
    s1 = ConcatStrings(s1, IntToString(MEM_GetFuncID(function)));
    _AI_Function(slf, s1);
};
func void AI_Function_IS(var c_npc slf, var func function, var int param1, var string param2) {
    var string s1;
    s1 = ConcatStrings("IS ", IntToString(param1));
    s1 = ConcatStrings(s1, " ");
    s1 = ConcatStrings(s1, param2);
    s1 = ConcatStrings(s1, " ");
    s1 = ConcatStrings(s1, IntToString(MEM_GetFuncID(function)));
    _AI_Function(slf, s1);
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
	var string argc; argc = STR_Split(AniName, " ", 1);
	if (Hlp_StrCmp(argc, "I")) {
		i0 = STR_ToInt(STR_Split(AniName, " ", 2));
		fnc = STR_ToInt(STR_Split(AniName, " ", 3));
		MEM_PushIntParam(i0);
	}
	else if (Hlp_StrCmp(argc, "S")) {
		s0 = STR_Split(AniName, " ", 2);
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
	else if (Hlp_StrCmp(argc, "SS")) {
		s0 = STR_Split(AniName, " ", 2);
		s1 = STR_Split(AniName, " ", 3);
		fnc = STR_ToInt(STR_Split(AniName, " ", 4));
		MEM_PushStringParam(s0);
		MEM_PushStringParam(s1);
	}
	else if (Hlp_StrCmp(argc, "SI")) {
		s0 = STR_Split(AniName, " ", 2);
		i1 = STR_ToInt(STR_Split(AniName, " ", 3));
		fnc = STR_ToInt(STR_Split(AniName, " ", 4));
		MEM_PushStringParam(s0);
		MEM_PushIntParam(i1);
	}
	else if (Hlp_StrCmp(argc, "IS")) {
		i0 = STR_ToInt(STR_Split(AniName, " ", 2));
		s1 = STR_Split(AniName, " ", 3);
		fnc = STR_ToInt(STR_Split(AniName, " ", 4));
		MEM_PushIntParam(i0);
		MEM_PushStringParam(s1);
	}
	else {
		fnc = STR_ToInt(argc);
	};
	MEM_CallByID(fnc);
};

