/***********************************\
            HOOKDAEDALUS
\***********************************/

//========================================
// [intern] Non-persistent hash table
//========================================
const int _DH_htbl = 0;

//========================================
// Daedalus function hook
//========================================
func void HookDaedalusFunc(var func hooked, var func hooker) {
    // Working with symbol indices is save here, because they are not stored in game saves
    var int hookeeID; hookeeID = MEM_GetFuncID(hooked);
    var int hookerID; hookerID = MEM_GetFuncID(hooker);

    // Create hash table persistent only over current session (not stored in game saves)
    if (!_DH_htbl) {
        _DH_htbl = _HT_Create();
    };

    /* There cannot be a warning/error, because of reinitialization. Also it cannot be checked whether a different
    function was hooked before, because symb.content will have been overwritten with symb_er.content itself.
    Responsibility lies with the caller! */
    if (!_HT_Has(_DH_htbl, hookerID)) {
        var zCPar_Symbol symb; symb = _^(MEM_GetSymbolByIndex(hookeeID));
        var zCPar_Symbol symb_er; symb_er = _^(MEM_GetSymbolByIndex(hookerID));

        _HT_Insert(_DH_htbl, symb.content, hookerID);
        symb.content = symb_er.content;
    };
};

//========================================
// Relay functions
//========================================
func void ContinueCall() {
    var int fromID; fromID = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());

    // Consistency check
    if (!_HT_Has(_DH_htbl, fromID)) {
        MEM_Error("HOOKDAEDALUS: Invalid use of ContinueCall.");
        return;
    };

    var int to; to = _HT_Get(_DH_htbl, fromID);
    MEM_CallByOffset(to);
};

func void passArgumentI(var int i) {
    MEM_PushIntParam(i);
};
func void passArgumentS(var string s) {
    MEM_PushStringParam(s);
};
func void passArgumentN(var int n) {
    MEM_PushInstParam(n);
};
