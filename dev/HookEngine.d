/***********************************\
             HOOKENGINE
\***********************************/


//-------------------
// Register variables
//-------------------
var int EAX;
var int ECX;
var int EDX;
var int EBX;
var int ESP;
var int EBP;
var int ESI;
var int EDI;


//========================================
// Hook controller
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
    var int iHlpBak;  iHlpBak  = MEM_ReadInt(instHlpAddr); // Is the correct way to do this?
    var int instBak;  instBak  = MEM_GetUseInstance();

    // Update register variables
    EAX = _eax;
    ECX = _ecx;
    EDX = _edx;
    EBX = _ebx;
    ESP = _esp;
    EBP = _ebp;
    ESI = _esi;
    EDI = _edi;

    // Iterate over all registered event handler functions
    var zCArray a; a = _^(evtHAddr);
    repeat(i, a.numInArray); var int i;
        // Remember data stack pointer
        var int sPtr; sPtr = MEM_Parser.datastack_sptr;

        // Add a stack buffer for naughty functions that pop off of the data stack illegally
        repeat(j, 10); var int j;
            MEM_PushIntParam(0);
        end;

        // Call the function
        MEM_CallByID(MEM_ReadIntArray(a.array, i));

        // Reset the data stack pointer (remove buffer and anything left on the stack)
        MEM_Parser.datastack_sptr = sPtr;

        // Restore global instances in between function calls
        MEM_AssignInstSuppressNullWarning = TRUE;
        self  = _^(selfBak);
        other = _^(otherBak);
        item  = _^(itemBak);
        MEM_WriteInt(instHlpAddr, iHlpBak);
        MEM_SetUseInstance(instBak);
        MEM_AssignInstSuppressNullWarning = FALSE;

        // Some registers should be kept read-only in between function calls
        ESP = _esp; // Stack pointer is read-only
        EBP = _ebp; // Base pointer is read-only
        EBX = _ebx;
        EDX = _edx;
        ESI = _esi;
    end;

    // Update modifiable registers
    MEM_WriteInt(ESP-32, EDI);
    // MEM_WriteInt(ESP-28, ESI); // Not updated in "old" HookEngine, but why not exactly?
    // MEM_WriteInt(ESP-16, EBX);
    // MEM_WriteInt(ESP-12, EDX);
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
};


//========================================
// Engine hook
//========================================
func void HookEngineI(var int address, var int oldInstr, var int function) {

    const int hooktbl = 0;  // Hash table for hooks
    var int SymbID;         // Symbol index of 'function'
    var int ptr;            // Pointer to temporary memory of the old instruction
    var int relAdr;         // Relative address from 'address' to new assembly code

    // ----- Safety checks -----
    if (oldInstr < 5) {
        PrintDebug("HOOKENGINE: oldInstr is too small. The minimun required length is 5 bytes.");
        return;
    };

    SymbID = function;
    if (SymbID == -1) {
        PrintDebug("HOOKENGINE: The provided deadalus function was not found.");
        return;
    };

    // ----- Treat possibly protected memory -----
    MemoryProtectionOverride (address, oldInstr+3);

    // ----- Find event handler in hash table -----
    if (!hooktbl) {
        hooktbl = _HT_Create();
    };

    // ----- Hook already present -----
    if (_HT_Has(hooktbl, address)) {
        // Add deadalus function to event handler once
        MEM_PushIntParam(_HT_Get(hooktbl, address));
        MEM_PushIntParam(SymbID);
        MEM_Call(EventPtr_AddOnceI); // EventPtr_AddOnceI(_HT_Get(hooktbl, address), SymbID);
        return;
    };

    // ----- Create event and add function -----
    MEM_Call(EventPtr_Create);
    var int ev; ev = MEM_PopIntResult(); // var int ev; ev = Event_Create();

    MEM_PushIntParam(ev);
    MEM_PushIntParam(SymbID);
    MEM_Call(EventPtr_AddI); // EventPtr_AddI(ev, SymbID);

    _HT_Insert(hooktbl, ev, address);

    // ----- Backup old instruction -----
    ptr = MEM_Alloc(oldInstr);
    MEM_CopyBytes(address, ptr, oldInstr);

    // ----- Allocate new stream for assembly code -----
    ASM_Open(25 + oldInstr + 6 + 1); // Asm code + oldInstr + retn + 1

    // ----- Add jump from engine function to new code -----
    relAdr = ASMINT_CurrRun-address-5;
    MEM_WriteInt(address + 0, 233);
    MEM_WriteInt(address + 1, relAdr);

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

    // Append old instruction
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
