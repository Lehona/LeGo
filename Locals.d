/***********************************\
               LOCALS
\***********************************/

//========================================
// Arrayfunktionen
//========================================

func int MEM_ArrayLast(var int arr) {
    var zCArray a; a = MEM_PtrToInst(arr);
    return MEM_ReadInt(a.array + 4 * (a.numInArray-1));
};

/*

; String sichern:
	

	

	zPAR_OP_PLUS             add         +
	zPAR_OP_MINUS            sub         -
	zPAR_OP_MUL              mul         *
	zPAR_OP_DIV              div         /
	zPAR_OP_MOD              mod         %
	zPAR_OP_OR               or          |
	zPAR_OP_AND              and         &
	zPAR_OP_LOWER            lwr         <
	zPAR_OP_HIGHER           hgh         >
	zPAR_OP_IS               is          =
	zPAR_OP_LOG_OR           lor         ||
	zPAR_OP_LOG_AND          land        &&
	zPAR_OP_SHIFTL           shl         <<
	zPAR_OP_SHIFTR           shr         >>
	zPAR_OP_LOWER_EQ         leq         <=
	zPAR_OP_EQUAL            eq          ==
	zPAR_OP_NOTEQUAL         neq         !=
	zPAR_OP_HIGHER_EQ        heq         >=
	zPAR_OP_ISPLUS           iadd        +=
	zPAR_OP_ISMINUS          isub        -=
	zPAR_OP_ISMUL            imul        *=
	zPAR_OP_ISDIV            idiv        /=
	zPAR_OP_UN_PLUS          uplus       +
	zPAR_OP_UN_MINUS         uminus      -
	zPAR_OP_UN_NOT           not         !
	zPAR_OP_UN_NEG           neg         ~
	zPAR_TOK_RET             retn        return
	zPAR_TOK_CALL            call
	zPAR_TOK_CALLEXTERN      callx
	zPAR_TOK_POPINT          popi
	zPAR_TOK_PUSHINT         pushi
	zPAR_TOK_PUSHVAR         pushv
	zPAR_TOK_PUSHSTR         pushs
	zPAR_TOK_PUSHINST        pushin
	zPAR_TOK_PUSHINDEX       pushid
	zPAR_TOK_POPVAR          popv
	zPAR_TOK_ASSIGNSTR       astr
	zPAR_TOK_ASSIGNSTRP      astrp
	zPAR_TOK_ASSIGNFUNC      afnc
	zPAR_TOK_ASSIGNFLOAT     aflt
	zPAR_TOK_ASSIGNINST      ains
	zPAR_TOK_JUMP            jmp
	zPAR_TOK_JUMPF           jmpf
	zPAR_TOK_SETINSTANCE     sinst
	zPAR_TOK_ARRAYACCESS     pusha

*/

func int MEM_ArrayOverwrite(var int arr, var int val, var int newVal) {
    var zCArray a; a = MEM_PtrToInst(arr);
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < a.numInArray) {
        if(MEM_ReadInt(a.array+4*i) == val) {
            MEM_WriteInt(a.array+4*i, newVal);
            return i;
        };
        i += 1;
        MEM_StackPos.position = p;
    };
    return -1;
};

func int MEM_ArrayOverwriteFirst(var int arr, var int val, var int newVal) {
    var zCArray a; a = MEM_PtrToInst(arr);
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < a.numInArray) {
        if(MEM_ReadInt(a.array+4*i) == val) {
            MEM_WriteInt(a.array+4*i, newVal);
            return i;
        };
        i += 1;
        MEM_StackPos.position = p;
    };
    MEM_ArrayInsert(arr, newVal);
    return a.numInArray-1;
};

//========================================
// String kopieren
//========================================
func int strcpy(var int ps) {
    var int p0; p0 = MEM_Alloc(20);
    var int p1; p1 = MEM_Alloc(MEM_ReadInt(ps+12)+2)+1;
    MEM_CopyBytes(ps, p0, 20);
    MEM_WriteInt(p0+8, p1);
    MEM_CopyBytes(MEM_ReadInt(ps+8), p1, MEM_ReadInt(ps+12));
    return p0;
};

//========================================
// Lokale Variablen pushen
//========================================
const int _Locals_arr = 0;
func void Locals_PushID(var int id) {
    if(!_Locals_arr) {
        _Locals_arr = MEM_ArrayCreate();
    };
    var zCPar_Symbol symb; symb = MEM_PtrToInst(MEM_ReadIntArray(currSymbolTableAddress, id));

    var int offs; offs = 0;
    var string comp; comp = ConcatStrings(symb.name, ".");
    var int compl; compl = STR_Len(comp);

    var int p; p = MEM_StackPos.position;
    offs += 1;
    symb = MEM_PtrToInst(MEM_ReadIntArray(currSymbolTableAddress, id+offs));
    if(STR_Len(symb.name) <= compl) {
        MEM_ArrayPush(_Locals_arr, offs);
        return;
    };
    if(STR_Compare(comp, STR_Prefix(symb.name, compl)) != 0) {
        MEM_ArrayPush(_Locals_arr, offs);
        return;
    };
    if((symb.bitfield&zCPar_Symbol_bitfield_type) == zPAR_TYPE_STRING) {
        MEM_ArrayPush(_Locals_arr, strcpy(symb.content));
    }
    else {
        MEM_ArrayPush(_Locals_arr, symb.content);
		MEM_ArrayPush(_Locals_arr, symb.offset);
    };
    MEM_StackPos.position = p;
};
func void Locals_Push(var func fnc) {
	Locals_PushID(MEM_GetFuncID(fnc));
};

//========================================
// Lokale Variablen popen
//========================================
func void Locals_PopID(var int id) {
    if(!_Locals_arr) {
        return;
    };
    var zCPar_Symbol symb; symb = MEM_PtrToInst(MEM_ReadIntArray(currSymbolTableAddress, id));

    var int offs; offs = MEM_ArrayPop(_Locals_arr);

    var int p; p = MEM_StackPos.position;
    if(offs > 1) {
        offs -= 1;
        symb = MEM_PtrToInst(MEM_ReadIntArray(currSymbolTableAddress, id+offs));
        if((symb.bitfield&zCPar_Symbol_bitfield_type) == zPAR_TYPE_STRING) {
			var int nPtr; nPtr = MEM_ArrayPop(_Locals_arr);
			symb.content = nPtr;
        }
        else {
			symb.offset = MEM_ArrayPop(_Locals_Arr);
            symb.content = MEM_ArrayPop(_Locals_arr);
        };
        MEM_StackPos.position = p;
    };
};
func void Locals_Pop(var func fnc) {
	Locals_PopID(MEM_GetFuncID(fnc));
};