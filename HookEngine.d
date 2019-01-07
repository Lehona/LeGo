/***********************************\
             HOOKENGINE
\***********************************/


//---------------------
// Register variables
//---------------------
var int EAX;
var int ECX;
var int EDX;
var int EBX;
var int ESP;
var int EBP;
var int ESI;
var int EDI;

//---------------------
// Overwrite instances
//---------------------
var int HookOverwriteInstances; // self, other, item

//========================================
// [intern] Hook controller
//========================================
func void _Hook(var int evtHAddr, // ESP-36
                var int _edi,     // ESP-32 // Function parameters in order of popad (reverse order of pushad)
                var int _esi,     // ESP-28
                var int _ebp,     // ESP-24
                var int _esp,     // ESP-20
                var int _ebx,     // ESP-16
                var int _edx,     // ESP-12
                var int _ecx,     // ESP-8
                var int _eax) {   // ESP-4

    // Backup use-instance before anything else. Temporary variable for now, because it's done before locals()
    var int _instBak_temp; _instBak_temp = MEM_GetUseInstance();

    // Local backup for recursive hooks
    locals();

    // Secure register variables locally for recursive hooks
    var int eaxBak; eaxBak = EAX;
    var int ecxBak; ecxBak = ECX;
    var int edxBak; edxBak = EDX;
    var int ebxBak; ebxBak = EBX;
    var int espBak; espBak = ESP;
    var int ebpBak; ebpBak = EBP;
    var int esiBak; esiBak = ESI;
    var int ediBak; ediBak = EDI;

    // Get address of yINSTANCE_HELP by symbol index 0
    const int instHlpAddr = 0;
    if (!instHlpAddr) {
        instHlpAddr = MEM_GetSymbolByIndex(0)+zCParSymbol_offset_offset;
    };

    // Also secure global instances
    var int selfBak;  selfBak  = _@(self);
    var int otherBak; otherBak = _@(other);
    var int itemBak;  itemBak  = _@(item);
    var int iHlpBak;  iHlpBak  = MEM_ReadInt(instHlpAddr);
    var int instBak;  instBak  = _instBak_temp;

    // Update register variables
    EAX = _eax;
    ECX = _ecx;
    EDX = _edx;
    EBX = _ebx;
    ESP = _esp;
    EBP = _ebp;
    ESI = _esi;
    EDI = _edi;

    // Check whether Ikarus is initialized for hooks that happen during level change
    if (!_@(MEM_Parser)) {
        MEM_InitLabels();
        MEM_InitGlobalInst();
    };

    // Do not overwrite the global instances by default
    HookOverwriteInstances = FALSE;

    // Iterate over all registered event handler functions
    var zCArray a; a = _^(evtHAddr);
    repeat(i, a.numInArray); var int i;
        // Clear data stack in-between function calls
        MEM_Parser.datastack_sptr = 0;

        // Call the function
        MEM_CallByID(MEM_ReadIntArray(a.array, i));

        // Restore global instances in between function calls
        if (!HookOverwriteInstances) {
            MEM_AssignInstSuppressNullWarning = TRUE;
            self  = _^(selfBak);
            other = _^(otherBak);
            item  = _^(itemBak);
            MEM_AssignInstSuppressNullWarning = FALSE;
        };
        MEM_WriteInt(instHlpAddr, iHlpBak);
        MEM_SetUseInstance(instBak);

        // Stack registers should be kept read-only in between function calls
        ESP = _esp; // Stack pointer is read-only
        EBP = _ebp; // Base pointer is read-only
    end;

    // Update modifiable registers on stack (ESP points to the position before pushad)
    MEM_WriteInt(ESP-32, EDI);
    MEM_WriteInt(ESP-28, ESI);
    MEM_WriteInt(ESP-16, EBX);
    MEM_WriteInt(ESP-12, EDX);
    MEM_WriteInt(ESP-8,  ECX);
    MEM_WriteInt(ESP-4,  EAX);

    // Restore register variables for recursive hooks
    EDI = ediBak;
    ESI = esiBak;
    EBP = ebpBak;
    ESP = espBak;
    EBX = ebxBak;
    EDX = edxBak;
    ECX = ecxBak;
    EAX = eaxBak;

    // Just to be safe: restore again at the very end of the function
    MEM_SetUseInstance(instBak);
};


//-------------------------
// Hash table of all hooks
//-------------------------
const int _Hook_htbl = 0;


//========================================
// Engine hook
//========================================
func void HookEngineI(var int address, var int oldInstr, var int function) {

    var int SymbID;         // Symbol index of 'function'
    var int ptr;            // Pointer to temporary memory of the old instruction
    var int relAdr;         // Relative address from 'address' to new assembly code

    // ----- Safety checks -----
    if (oldInstr < 5) {
        PrintDebug("HOOKENGINE: oldInstr is too small. The minimum required length is 5 bytes.");
        return;
    };

    SymbID = function;
    if (SymbID == -1) {
        PrintDebug("HOOKENGINE: The provided deadalus function was not found.");
        return;
    };

    // ----- Find event handler in hash table -----
    if (!_Hook_htbl) {
        _Hook_htbl = _HT_Create();
    };

    // ----- Hook already present -----
    if (_HT_Has(_Hook_htbl, address)) {
        // Add deadalus function (new listener) to event handler once
        MEM_PushIntParam(_HT_Get(_Hook_htbl, address));
        MEM_PushIntParam(SymbID);
        MEM_Call(EventPtr_AddOnceI); // EventPtr_AddOnceI(_HT_Get(_Hook_htbl, address), SymbID);
        return;
    };

    // ----- Create event and add function as listener -----
    MEM_Call(EventPtr_Create);
    var int ev; ev = MEM_PopIntResult(); // var int ev; ev = Event_Create();

    MEM_PushIntParam(ev);
    MEM_PushIntParam(SymbID);
    MEM_Call(EventPtr_AddI); // EventPtr_AddI(ev, SymbID);

    _HT_Insert(_Hook_htbl, ev, address);

    // ----- Backup old instruction -----
    ptr = MEM_Alloc(oldInstr);
    MEM_CopyBytes(address, ptr, oldInstr);

    // ----- Allocate new stream for assembly code -----
    ASM_Open(25 + oldInstr + 6 + 1); // Asm code + oldInstr + retn + 1

    // ----- Treat possibly protected memory -----
    MemoryProtectionOverride(address, oldInstr+3);

    // ----- Add jump from engine function to new code -----
    relAdr = ASMINT_CurrRun-address-5;
    MEM_WriteByte(address + 0, ASMINT_OP_jmp);
    MEM_WriteInt (address + 1, relAdr);

    // ----- Write new assembly code -----

    // Call deadalus hook function
    ASM_1(ASMINT_OP_pusha); // ESP -= 32 (8*4)

    ASM_1(ASMINT_OP_pushIm);
    ASM_4(ev);

    ASM_1(ASMINT_OP_pushIm);
    ASM_4(MEM_GetFuncID(_Hook));

    ASM_1(ASMINT_OP_pushIm);
    ASM_4(parser);

    ASM_1(ASMINT_OP_call);
    ASM_4(zParser__CallFunc-ASM_Here()-4);

    ASM_2(ASMINT_OP_addImToESP);
    ASM_1(12); // 3*4: parser, _Hook, address

    ASM_1(ASMINT_OP_popa); // Pop altered registers

    // Append original instruction
    MEM_CopyBytes(ptr, ASMINT_Cursor, oldInstr);
    MEM_Free(ptr);

    ASMINT_Cursor += oldInstr;

    // Return to engine function
    ASM_1(ASMINT_OP_pushIm);
    ASM_4(address + oldInstr);
    ASM_1(ASMINT_OP_retn);

    var int i; i = ASM_Close();
};
func void HookEngineF(var int address, var int oldInstr, var func function) {
    HookEngineI(address, oldInstr, MEM_GetFuncID(function));
};
func void HookEngine(var int address, var int oldInstr, var string function) {
    HookEngineI(address, oldInstr, MEM_FindParserSymbol(STR_Upper(function)));
};
// Wrapper function for naming consistency
func void HookEngineS(var int address, var int oldInstr, var string function) {
    HookEngine(address, oldInstr, function);
};


//========================================
// Check if address is hooked
//========================================
func int IsHooked(var int address) {
    if (!_Hook_htbl) {
        return FALSE;
    };

    return _HT_Has(_Hook_htbl, address);
};


//========================================
// Check if function hooks engine
//========================================
func int IsHookI(var int address, var int function) {
    if (!IsHooked(address)) {
        return FALSE;
    };

    var int ev; ev = _HT_Get(_Hook_htbl, address);
    var int SymbID; SymbID = function;

    // Check if listener exists
    MEM_PushIntParam(ev);
    MEM_PushIntParam(SymbID);
    MEM_Call(EventPtr_HasI); // EventPtr_HasI(ev, SymbID)
    return MEM_PopIntResult(); // This line is redundant (left here for readability)
};
func int IsHookF(var int address, var func function) {
    return IsHookI(address, MEM_GetFuncID(function));
};
func int IsHook(var int address, var string function) {
    return IsHookI(address, MEM_FindParserSymbol(STR_Upper(function)));
};


//========================================
// Remove listener (and engine hook)
//========================================
func void RemoveHookI(var int address, var int oldInstr, var int function) {
    if (!IsHookI(address, function)) {
        return;
    };

    var int ev; ev = _HT_Get(_Hook_htbl, address);
    var int SymbID; SymbID = function;

    // Remove listener
    MEM_PushIntParam(ev);
    MEM_PushIntParam(SymbID);
    MEM_Call(EventPtr_RemoveI); // EventPtr_RemoveI(ev, SymbID)

    // Is event empty now?
    MEM_PushIntParam(ev);
    MEM_Call(EventPtr_Empty); // EventPtr_Empty(ev);
    if (MEM_PopIntResult()) && (oldInstr >= 5) {
        /* If RemoveHookI is called with oldInstr == 0, the hook (ASM jump) remains.
         * This is good for adding and removing a listener/hook frequently.
         */

        // Remove hook from hash table
        _HT_Remove(_Hook_htbl, address);

        // Delete event
        MEM_PushIntParam(ev);
        MEM_Call(EventPtr_Delete); // EventPtr_Delete(ev);

        // Check integrity of opcode at address (expecting jump)
        if (MEM_ReadByte(address) != ASMINT_OP_jmp) {
            MEM_Error("HOOKENGINE: Hook was invalidated by overwritten opcode");
            return;
        };

        // Remove engine hook
        var int newCodeAddr; newCodeAddr = MEM_ReadInt(address+1)+address+5;
        var int rvtCodeAddr; rvtCodeAddr = newCodeAddr+25; // Original code

        // Replace jump with original instruction
        MEM_CopyBytes(rvtCodeAddr, address, oldInstr);

        // Free previously allocated space in memory (does this work as expected?)
        MEM_Free(newCodeAddr);
    };
};
func void RemoveHookF(var int address, var int oldInstr, var func function) {
    RemoveHookI(address, oldInstr, MEM_GetFuncID(function));
};
func void RemoveHook(var int address, var int oldInstr, var string function) {
    RemoveHookI(address, oldInstr, MEM_FindParserSymbol(STR_Upper(function)));
};


//========================================
// Replace Engine Function
//========================================
func void ReplaceEngineFuncI(var int funcAddr, var int thiscall_numParams, var int replaceFunc) {
    // Check if already hooked
    if (IsHooked(funcAddr)) {
        if (!IsHookI(funcAddr, replaceFunc)) {
            MEM_Error("Cannot replace/disable engine function: Address already hooked");
        };
        return;
    };

    // Write return at beginning of function
    MemoryProtectionOverride(funcAddr, 3);
    if (thiscall_numParams) {
        MEM_WriteByte(funcAddr,   /*C2*/ 194); // retn
        MEM_WriteByte(funcAddr+1, thiscall_numParams*4);
        MEM_WriteByte(funcAddr+2, 0);
    } else {
        MEM_WriteByte(funcAddr, ASMINT_OP_retn);
    };

    // Hook on top of return instruction
    if (replaceFunc != /*NOFUNC*/ -1) {
        HookEngineI(funcAddr, 5, replaceFunc);
    };
};
func void ReplaceEngineFuncF(var int funcAddr, var int thiscall_numParams, var func replaceFunc) {
    ReplaceEngineFuncI(funcAddr, thiscall_numParams, MEM_GetFuncID(replaceFunc));
};
func void ReplaceEngineFunc(var int funcAddr, var int thiscall_numParams, var string replaceFunc) {
    ReplaceEngineFuncI(funcAddr, thiscall_numParams, MEM_FindParserSymbol(STR_Upper(replaceFunc)));
};

// Simple replace functions for return values
func void Hook_ReturnFalse() {
    EAX = FALSE;
};
func void Hook_ReturnTrue() {
    EAX = TRUE;
};

//========================================
// Disable Engine Function
//========================================
func void DisableEngineFunc(var int funcAddr, var int thiscall_numParams) {
    ReplaceEngineFuncI(funcAddr, thiscall_numParams, -1);
};
