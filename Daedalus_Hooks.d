var int HT_Hooks;

func void Init_Hooks() {
	if (!HT_Hooks) {
		HT_Hooks = HT_Create();
	};
};

func void HookDaedalusFunc(var func hooked, var func hooker) {	
	var int hookeeID; hookeeID = MEM_GetFuncID(hooked);
	var int hookerID; hookerID = MEM_GetFuncID(hooker);

	var zCPar_Symbol symb; symb = _^(MEM_GetSymbolByIndex(hookeeID));
	var zCPar_Symbol symb_er; symb_er = _^(MEM_GetSymbolByIndex(hookerID));

	/* If someone uses the same hook function twice, they'll get a popup (or a slap on the wrist) */
	if (HT_Has(HT_Hooks, hookerID)) {
		if (HT_Get(HT_Hooks, hookerID) != symb.content) {
			SB_New();
			SB("Function ");
			SB(symb_er.name);
			SB(" is already hooking another function. It was trying to hook ");
			SB(symb.name);
			MEM_InfoBox(SB_ToString());
		} else {
			MEM_Warn("You're trying to hook a function twice with the same targets. Second hooking ignored, consider yourself sacked.");
		}
	};


	HT_Insert(HT_Hooks, symb.content, hookerID);
	symb.content = symb_er.content;
};

func void ContinueCall() {
	var int fromID; fromID = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());
	var int to; to = HT_Get(HT_Hooks, fromID);
	MEM_CallByOffset(to);
};

func void passArgumentI(var int i) { return +i; };
func void passArgumentS(var string s) {
	CALLINT_PushString(s);
}
func void passArgumentN(var int n) {
	MEMINT_StackPushInst(n);
}