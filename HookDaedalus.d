/***********************************\
            HOOKDAEDALUS
\***********************************/

//========================================
// [intern] Non-persistent hash table
//========================================
const int _DH_htbl = 0;

//========================================
// Check if function is used as hook
//========================================
func int IsHookD(var int funcID) {
    if (!_DH_htbl) {
        return FALSE;
    };

    return _HT_Has(_DH_htbl, funcID);
};

//========================================
// Daedalus function hook
//========================================
func void HookDaedalusFunc(var func hooked, var func hook) {
    // Working with symbol indices is save here, because they are not stored in game saves
    var int hookID; hookID = MEM_GetFuncID(hook);

    // Create hash table persistent only over current session (not stored in game saves)
    if (!_DH_htbl) {
        _DH_htbl = _HT_Create();
    };

    // Handle reinitialization: Prevent re-hooking with already used hook function
    // A function can be hooked any number of times - but each function can only be used once to hook
    if (!IsHookD(hookID)) {
        var int targetPtr; targetPtr = MEM_GetFuncPtr(hooked);
        var int targetOff; targetOff = MEM_GetFuncOffset(hooked);

        // Read code stack at beginning of hooked function
        var int numBytes; numBytes = 0;
        while(numBytes < 5);
            var int tok; tok = MEM_ReadByte(targetPtr+numBytes);
            if (tok == zPAR_TOK_CALL)
            || (tok == zPAR_TOK_CALLEXTERN)
            || (tok == zPAR_TOK_PUSHINT)
            || (tok == zPAR_TOK_PUSHVAR)
            || (tok == zPAR_TOK_PUSHINST)
            || (tok == zPAR_TOK_JUMP)
            || (tok == zPAR_TOK_JUMPF)
            || (tok == zPAR_TOK_SETINSTANCE) {
                numBytes += 5;
            } else {
                numBytes += 1;
                if (tok == zPAR_TOK_RET) && (numBytes < 5) {
                    MEM_Error("HOOKDAEDALUS: Function too short to be hooked!");
                    return;
                };
            };
        end;

        // Secure byte code to be overwritten by jump
        var int codeToRun; codeToRun = MEM_Alloc(numBytes+5);
        MEM_CopyBytes(targetPtr, codeToRun, numBytes);
        MEM_WriteByte(codeToRun+numBytes, zPAR_TOK_JUMP);
        MEM_WriteInt(codeToRun+numBytes+1, targetOff+numBytes);

        // Store original byte code + jump back
        _HT_Insert(_DH_htbl, codeToRun, hookID);
        MEM_ReplaceFunc(hooked, hook);
    };
};
func void HookDaedalusFuncI(var int hookedID, var int hookID) {
    if (hookedID == -1) || (hookID == -1) {
        MEM_Warn("HOOKDAEDALUS: Invalid function symbol(s)!");
        return;
    };
    MEM_PushIntParam(hookedID);
    MEM_PushIntParam(hookID);
    MEM_Call(HookDaedalusFunc);
};
func void HookDaedalusFuncS(var string hookedName, var string hookName) {
    MEM_PushIntParam(MEM_FindParserSymbol(STR_Upper(hookedName)));
    MEM_PushIntParam(MEM_FindParserSymbol(STR_Upper(hookName)));
    MEM_Call(HookDaedalusFuncI);
};
// Wrapper function for naming consistency
func void HookDaedalusFuncF(var func hooked, var func hook) {
    HookDaedalusFunc(hooked, hook);
};

//========================================
// Relay functions
//========================================
func void ContinueCall() {
    var int fromID; fromID = MEM_GetFuncIDByOffset(MEM_GetCallerStackPos());

    // Consistency check
    if (!IsHookD(fromID)) {
        MEM_Error("HOOKDAEDALUS: Invalid use of ContinueCall.");
        return;
    };

    var int to; to = _HT_Get(_DH_htbl, fromID);
    MEM_CallByPtr(to);
};

func void PassArgumentI(var int i) {
    MEM_PushIntParam(i);
};
func void PassArgumentS(var string s) {
    MEM_PushStringParam(s);
};
func void PassArgumentN(var int n) {
    MEM_PushInstParam(n);
};
