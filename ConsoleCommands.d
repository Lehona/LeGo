/***********************************\
            CONSOLECOMMANDS
\***********************************/

//========================================
// [intern] Class / Variables
//========================================
class CCItem {
    var int fncID;
    var string cmd;
};
instance CCItem@(CCItem);

const int _CC_List = 0; // Non-persistent record of all CCs

//========================================
// Check if CC is registered
//========================================
func int CC_Active(var func function) {
    if (!_CC_List) {
        return FALSE;
    };

    var int symID; symID = MEM_GetFuncID(function);

    // Iterate over all registered CCs
    var zCArray a; a = _^(_CC_List);
    repeat(i, a.numInArray); var int i;
        var CCItem cc; cc = _^(MEM_ReadIntArray(a.array, i));
        if (cc.fncID == symID) {
            return TRUE;
        };
    end;

    return FALSE;
};

//========================================
// Remove CC
//========================================
func void CC_Remove(var func function) {
    if (!_CC_List) {
        return;
    };

    var int symID; symID = MEM_GetFuncID(function);

    // Iterate over all registered CCs
    var zCArray a; a = _^(_CC_List);
    repeat(i, a.numInArray); var int i;
        var int ccPtr; ccPtr = MEM_ReadIntArray(a.array, i);
        var CCItem cc; cc = _^(ccPtr);

        if (cc.fncID == symID) {
            MEM_ArrayRemoveIndex(_CC_List, ccPtr);
            MEM_Free(ccPtr);
        };
    end;
};

//========================================
// [intern] Register auto-completion
//========================================
func void CC_AutoComplete(var string commandPrefix, var string description) {
    var int descPtr; descPtr = _@s(description);
    var int comPtr; comPtr = _@s(commandPrefix);

    const int call = 0;
    if (CALL_Begin(call)) {
        CALL_PtrParam(_@(descPtr));
        CALL_PtrParam(_@(comPtr));
        CALL__thiscall(_@(zcon_address_lego), zCConsole__Register);
        call = CALL_End();
    };
};

//========================================
// Register new CC
//========================================
func void CC_Register(var func function, var string commandPrefix, var string description) {
    // Remove any left over handles (from LeGo 2.4.0) if they are unarchived from old game saves
    if (hasHndl(CCItem@)) {
        foreachHndl(CCItem@, _CCItem_deleteHandles);
    };

    // Only add if not already present
    if (CC_Active(function)) {
        return;
    };

    // Check validity of function signature
    var int symID; symID = MEM_GetFuncID(function);
    var zCPar_Symbol symb; symb = _^(MEM_GetSymbolByIndex(symID));
    if ((symb.bitfield & zCPar_Symbol_bitfield_ele) != 1) || (symb.offset != (zPAR_TYPE_STRING >> 12)) {
        MEM_Error(ConcatStrings("CONSOLECOMMANDS: Function has to have one parameter and needs to return a string: ",
           symb.name));
        return;
    };
    symb = _^(MEM_GetSymbolByIndex(symID+1));
    if ((symb.bitfield & zCPar_Symbol_bitfield_type) != zPAR_TYPE_STRING) {
        MEM_Error(ConcatStrings("CONSOLECOMMANDS: Function parameter needs to be a string: ", symb.name));
        return;
    };

    // Register auto-completion
    commandPrefix = STR_Upper(commandPrefix);
    CC_AutoComplete(commandPrefix, description);

    // Create CC object
    var int ccPtr; ccPtr = create(CCItem@);
    var CCItem cc; cc = _^(ccPtr);
    cc.fncID = symID;
    cc.cmd = commandPrefix;

    // Initialize once
    if (!_CC_List) {
        _CC_List = MEM_ArrayCreate();
    };

    // Add CC to 'list'
    MEM_ArrayInsert(_CC_List, ccPtr);
};

//========================================
// [intern] Engine hook
//========================================
func void _CC_Hook() {
    if (!_CC_List) {
        return;
    };

    // Get query entered into console
    var int stackOffset; stackOffset = MEMINT_SwitchG1G2(/*2ach*/ 684, /*424h*/ 1060);
    var string query; query = MEM_ReadString(MEM_ReadInt(ESP+stackOffset+4));

    // Iterate over all registered CCs
    var zCArray a; a = _^(_CC_List);
    repeat(i, a.numInArray); var int i;
        var CCItem cc; cc = _^(MEM_ReadIntArray(a.array, i));

        // Check if entered query starts with defined command
        if (STR_StartsWith(query, cc.cmd)) {
            // Cut off everything after the command
            var int cmdLen; cmdLen = STR_Len(cc.cmd);
            var int qryLen; qryLen = STR_Len(query);
            STR_SubStr(query, cmdLen, qryLen-cmdLen); // Leave on data stack

            // Call the CC function (argument already on data stack)
            MEM_CallByID(cc.fncID);
            var string ret; ret = MEM_PopStringResult();

            // If the CC function returns a valid string, stop the loop
            // This additional check allows multiple CCs with the same command
            if (!Hlp_StrCmp(ret, "")) {
                MEM_WriteString(EAX, ret);
                break;
            };
        };
    end;
};

//========================================
// [intern] Old game save compatibility
//========================================
// ConsoleCommands have been rewritten to not be stored to game saves. To ensure compatibility with old game saves from
// LeGo 2.4.0, this function is necessary to prevent errors on unarchiving, because 'fncID' was stored as string.
func void CCItem_Unarchiver(var CCItem this) {};
func int _CCItem_deleteHandles(var int hndl) {
    delete(hndl);
    return rContinue;
};
