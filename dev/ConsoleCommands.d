/***********************************\
            CONSOLECOMMANDS
\***********************************/

//========================================
// [internal] PM-Class
//========================================
class CCItem {
    var int fncID;
    var string cmd;
    var string desc;
};
instance CCItem@(CCItem);

//=============================================================
// Register auto-completion (needs to be done every game start)
//=============================================================
func void CC_AutoComplete(var string commandPrefix, var string description) {
    var int descPtr; descPtr = _@s(description);
    var int comPtr; comPtr = _@s(commandPrefix);
    const int call = 0;
    if (CALL_Begin(call)) {
        CALL_PtrParam(_@(descPtr));
        CALL_PtrParam(_@(comPtr));
        CALL__thiscall(_@(zcon_address), zCConsole__Register);
        call = CALL_End();
    };
};

func void CCItem_Archiver(var CCItem this) {
    PM_SaveFuncPtr("fncID", this.fncID);
    PM_SaveString("cmd", this.cmd);
    PM_SaveString("desc", this.desc);
};

func void CCItem_Unarchiver(var CCItem this) {
    this.fncID = PM_LoadFuncPtr("fncID");
    this.cmd = PM_LoadString("cmd");
    this.desc = PM_LoadString("desc");
    CC_AutoComplete(this.cmd, this.desc);
};

var int _CC_Symbol;
var string _CC_command;

//========================================
// Check if command is registered
//========================================
func int CC_Active(var func function) {
    _CC_Symbol = MEM_GetFuncPtr(function);
    foreachHndl(CCItem@, _CC_Active);
    return !_CC_Symbol;
};

func int _CC_Active(var int hndl) {
    if(MEM_ReadInt(getPtr(hndl)) != _CC_Symbol) {
        return continue;
    };
    _CC_Symbol = 0;
    return break;
};

//========================================
// Register a new command for the console
//========================================
func void CC_Register(var func function, var string commandPrefix, var string description) {
    // Only add if not already present
    if(CC_Active(function)) {
        return;
    };
    commandPrefix = STR_Upper(commandPrefix);
    // Register auto-completion
    CC_AutoComplete(commandPrefix, description);
    // Add function
    var int hndl; hndl = new(CCItem@);
    var CCItem itm; itm = get(hndl);
    itm.fncID = MEM_GetFuncPtr(function);
    itm.cmd = commandPrefix;
    itm.desc = description;
};

//========================================
// Remove command
//========================================
func void CC_Remove(var func function) {
    _CC_Symbol = MEM_GetFuncPtr(function);
    foreachHndl(CCItem@, _CC_RemoveL);
};

func int _CC_RemoveL(var int hndl) {
    if(MEM_ReadInt(getPtr(hndl)) != _CC_Symbol) {
        return continue;
    };
    delete(hndl);
    return break;
};

//========================================
// [internal] Engine hook
//========================================
func void _CC_Hook() {
    _CC_command = MEM_ReadString(MEM_ReadInt(ESP+1064)); // esp+424h+4h
    foreachHndl(CCItem@, ConsoleCommand);
};
func int ConsoleCommand(var int hndl) {
    var CCItem itm; itm = get(hndl);
    var int cmdLen; cmdLen = STR_Len(itm.cmd);

    if (STR_Len(_CC_command) >= cmdLen) {
        if (Hlp_StrCmp(STR_Prefix(_CC_command, cmdLen), itm.cmd)) {
            MEM_PushStringParam(STR_SubStr(_CC_command, cmdLen, STR_Len(_CC_command)-cmdLen));
            MEM_CallByPtr(itm.fncID);
            var string ret; ret = MEM_PopStringResult();
            if (!Hlp_StrCmp(ret, "")) {
                MEM_WriteString(EAX, ret);
                return rBreak;
            };
        };
    };
    return rContinue;
};
