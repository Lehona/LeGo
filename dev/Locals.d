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
// Locals
//========================================
func void Locals() {
    // Okay. Auf gehts.

    var zCPar_Symbol s;
    const string locals_bufferStr = "";
    const int locals_bufferInt = 0;
    var string locals_retstr;
    var zCPar_Symbol retinst;
    var int arr, var int type;
    var int sPtr;

    // Array vorbereiten
    const int locals_Arr = 0;
    if(!locals_Arr) {
        locals_Arr = MEM_ArrayCreate();
    };

    // Zuerst alle Symbole die ich für die Tokens brauche initialisieren. //{
    const int arrayinsert   = -1;
    const int arraypop      = -1;
    const int copybytes     = -1;
    const int clear         = -1;
    const int alloc         = -1;
    const int free          = -1;
    const int readint       = -1;
    const int writeint      = -1;

    const int bufferstr     = -1;
    const int bufferstrPtr  = -1;
    const int bufferint     = -1;
    const int retstr        = -1;
    if(arrayinsert == -1) {
        arrayinsert  = MEM_GetFuncOffset(MEM_ArrayInsert);
        arraypop     = MEM_GetFuncOffset(MEM_ArrayPop);
        copybytes    = MEM_GetFuncOffset(MEM_CopyBytes);
        clear        = MEM_GetFuncOffset(MEM_Clear);
        alloc        = MEM_GetFuncOffset(MEM_Alloc);
        free         = MEM_GetFuncOffset(MEM_Free);
        readint      = MEM_GetFuncOffset(MEM_ReadInt);
        writeint     = MEM_GetFuncOffset(MEM_WriteInt);

        bufferstr    = s + 1;
        bufferstrPtr = _@s(locals_bufferStr) + 8;
        bufferint    = s + 2;
        retstr       = s + 3;
    };
    //}

    // Ein neuer StringBuilder. In ihm werden alle neuen Tokens gespeichert.
    var int stream; stream = SB_New();

    // Funktion bestimmen
    var int p;   p   = MEM_GetCallerStackPos();
    var int fid; fid = MEM_GetFuncIDByOffset(p);
    var int cid; cid = fid;
    var int mid;
    if(cid == -1) {
        MEM_Error("Locals: CallStackPos invalid");
        return;
    };

    // Tokenarray zusammenschrauben
    s = _^(MEM_ReadIntArray(currSymbolTableAddress, cid));
    var string fname; fname = ConcatStrings(s.name, ".");
    var int    fret;  fret  = s.offset;
    var int    foff;  foff  = s.content;

    MEM_Info(ConcatStrings("Locals: Install at ", s.name));
    MEM_Info(ConcatStrings("        Offset is ", IntToString(p - foff)));

    // Größe bestimmen
    var int size; size = 0;

    while(1); //{
        cid += 1;
        sPtr = MEM_ReadIntArray(currSymbolTableAddress, cid);
        s = _^(sPtr);
        if(!STR_StartsWith(s.name, fname)) {
            break;
        };
        arr  = s.bitfield & zCPar_Symbol_bitfield_ele;
        type = s.bitfield & zCPar_Symbol_bitfield_type;
        if(arr > 1) {
            if(type == zPAR_TYPE_STRING) {
                MEM_Error("Locals: Stringarrays are not implemented. Sorry!");
                return;
            }
            else {
                size += s_array + s_p_array;
            };
        }
        else if(type == zPAR_TYPE_STRING) {
            size += s_string + s_p_string;
        }
        else if(type == zPAR_TYPE_INSTANCE) {
            size += s_inst + s_p_inst;
        }
        else {
            size += s_int + s_p_int;
        };
    end; //}

    mid = cid;
    cid = fid;

    size += s_header + s_assignblock * 2 + s_skipblock + s_misc + 10;
    if(fret == 0) {}
    else if(fret == (zPAR_TYPE_STRING>>12)) {
        size += s_ret_string;
    }
    else if(fret == (zPAR_TYPE_INSTANCE>>12)) {
        size += s_ret_inst;
    }
    else {
        size += s_ret_int;
    };


    SB_InitBuffer(size);
    SBw(1000); // Remember-int

    stream = SB_GetStream();

    // Optmimierungshook
    SBc(zPAR_TOK_PUSHINT);  SBw(stream);
    SBc(zPAR_TOK_CALL);     SBw(readint);
    SBc(zPAR_TOK_JUMPF);    SBw(false);

    const int s_header = 3 * 5;

    // Zuerst alle Symbole pushen
    while(1); //{
        cid += 1;
        if(cid == mid) {
            break;
        };

        sPtr = MEM_ReadIntArray(currSymbolTableAddress, cid);
        s = _^(sPtr);

        arr  = s.bitfield & zCPar_Symbol_bitfield_ele;
        type = s.bitfield & zCPar_Symbol_bitfield_type;
        if(arr > 1) {
            arr *= 4;
            SBc(zPAR_TOK_PUSHINT); SBw(arr);
            SBc(zPAR_TOK_CALL);    SBw(alloc);
            SBc(zPAR_TOK_PUSHVAR); SBw(bufferint);
            SBc(zPAR_OP_IS);
            SBc(zPAR_TOK_PUSHINT); SBw(s.content);
            SBc(zPAR_TOK_PUSHVAR); SBw(bufferint);
            SBc(zPAR_TOK_PUSHINT); SBw(arr);
            SBc(ZPAR_TOK_CALL);    SBw(copybytes);
            SBc(zPAR_TOK_PUSHINT); SBw(locals_Arr);
            SBc(zPAR_TOK_PUSHVAR); SBw(bufferint);
            SBc(zPAR_TOK_CALL);    SBw(arrayinsert);

            const int s_array = 10 * 5 + 1;
        }
        else if(type == zPAR_TYPE_STRING) {
            SBc(zPAR_TOK_PUSHVAR);   SBw(cid);
            SBc(zPAR_TOK_PUSHVAR);   SBw(bufferstr);
            SBc(zPAR_TOK_ASSIGNSTR);
            SBc(zPAR_TOK_PUSHINT);   SBw(12);
            SBc(zPAR_TOK_CALL);      SBw(alloc);
            SBc(zPAR_TOK_PUSHVAR);   SBw(bufferint);
            SBc(zPAR_OP_IS);
            SBc(zPAR_TOK_PUSHINT);   SBw(bufferstrPtr);
            SBc(zPAR_TOK_PUSHVAR);   SBw(bufferint);
            SBc(zPAR_TOK_PUSHINT);   SBw(12);
            SBc(zPAR_TOK_CALL);      SBw(copybytes);
            SBc(zPAR_TOK_PUSHINT);   SBw(bufferstrPtr);
            SBc(zPAR_TOK_PUSHINT);   SBw(12);
            SBc(zPAR_TOK_CALL);      SBw(clear);
            SBc(zPAR_TOK_PUSHINT);   SBw(locals_Arr);
            SBc(zPAR_TOK_PUSHVAR);   SBw(bufferint);
            SBc(zPAR_TOK_CALL);      SBw(arrayinsert);

            const int s_string = 15 * 5 + 2;
        }
        else if(type == zPAR_TYPE_INSTANCE) {
            SBc(zPAR_TOK_PUSHINT);  SBw(locals_Arr);
            SBc(zPAR_TOK_PUSHINT);  SBw(_@(s.offset));
            SBc(zPAR_TOK_CALL);     SBw(readint);
            SBc(zPAR_TOK_CALL);     SBw(arrayinsert);

            const int s_inst = 4 * 5;
        }
        else {
            SBc(zPAR_TOK_PUSHINT); SBw(locals_Arr);
            SBc(zPAR_TOK_PUSHVAR); SBw(cid);
            SBc(zPAR_TOK_CALL);    SBw(arrayinsert);

            const int s_int = 3 * 5;
        };
    end; //}

    MEM_WriteInt(stream + 4 + 11, (stream + SB_Length()) - currParserStackAddress);

    SBc(zPAR_TOK_PUSHINT); SBw(stream);
    SBc(zPAR_TOK_PUSHINT); SBw(stream);
    SBc(zPAR_TOK_CALL);    SBw(readint);
    SBc(zPAR_TOK_PUSHINT); SBw(1);
    SBc(zPAR_OP_PLUS);
    SBc(zPAR_TOK_CALL);    SBw(writeint);

    const int s_assignblock = 5 * 5 + 1;

    // Dann die Funktion callen
    SBc(zPAR_TOK_CALL);    SBw(foff+5);

    SBc(zPAR_TOK_PUSHINT); SBw(stream);
    SBc(zPAR_TOK_PUSHINT); SBw(1);
    SBc(zPAR_TOK_PUSHINT); SBw(stream);
    SBc(zPAR_TOK_CALL);    SBw(readint);
    SBc(zPAR_OP_MINUS);
    SBc(zPAR_TOK_CALL);    SBw(writeint);

    SBc(zPAR_TOK_PUSHINT); SBw(stream);
    SBc(zPAR_TOK_CALL);    SBw(readint);
    SBc(zPAR_OP_UN_NOT);
    SBc(zPAR_TOK_JUMPF);   SBw(stream + SB_Length() + 4 + 1 - currParserStackAddress);
    SBc(zPAR_TOK_RET);

    const int s_skipblock = 3 * 5 + 2;

    // Den Rückgabewert behandeln:
    if(fret == 0) {}
    else if(fret == (zPAR_TYPE_STRING>>12)) {
        SBc(zPAR_TOK_PUSHVAR);    SBc(retstr);
        SBc(zPAR_TOK_ASSIGNSTR);
        SBc(zPAR_TOK_PUSHVAR);    SBc(retstr);

        const int s_ret_string = 2 * 5 + 1;
    }
    else if(fret == (zPAR_TYPE_INSTANCE>>12)) {
        SBc(zPAR_TOK_PUSHINST);   SBc(retinst);
        SBc(zPAR_TOK_ASSIGNINST);
        SBc(zPAR_TOK_PUSHINST);   SBc(retinst);

        const int s_ret_inst = 2 * 5 + 1;
    }
    else {
        SBc(zPAR_OP_UN_PLUS);

        const int s_ret_int = 1;
    };

    // Und wieder alles popen
    while(1); //{
        cid -= 1;
        if(cid == fid) {
            break;
        };

        sPtr = MEM_ReadIntArray(currSymbolTableAddress, cid);
        s = _^(sPtr);

        arr  = s.bitfield & zCPar_Symbol_bitfield_ele;
        type = s.bitfield & zCPar_Symbol_bitfield_type;
        if(arr > 1) {
            arr *= 4;
            SBc(zPAR_TOK_PUSHINT); SBw(locals_Arr);
            SBc(zPAR_TOK_CALL);    SBw(arraypop);
            SBc(zPAR_TOK_PUSHVAR); SBw(bufferint);
            SBc(zPAR_OP_IS);
            SBc(zPAR_TOK_PUSHVAR); SBw(bufferint);
            SBc(zPAR_TOK_PUSHINT); SBw(s.content);
            SBc(zPAR_TOK_PUSHINT); SBw(arr);
            SBc(zPAR_TOK_CALL);    SBw(copybytes);
            SBc(zPAR_TOK_PUSHVAR); SBw(bufferint);
            SBc(zPAR_TOK_CALL);    SBw(free);

            const int s_p_array = 9 * 5 + 1;
        }
        else if(type == zPAR_TYPE_STRING) {
            SBc(zPAR_TOK_PUSHINT);     SBw(locals_Arr);
            SBc(zPAR_TOK_CALL);        SBw(arraypop);
            SBc(zPAR_TOK_PUSHVAR);     SBw(bufferint);
            SBc(zPAR_OP_IS);
            SBc(zPAR_TOK_PUSHVAR);     SBw(bufferint);
            SBc(zPAR_TOK_PUSHINT);     SBw(bufferstrPtr);
            SBc(zPAR_TOK_PUSHINT);     SBw(12);
            SBc(zPAR_TOK_CALL);        SBw(copybytes);
            SBc(zPAR_TOK_PUSHVAR);     SBw(bufferint);
            SBc(zPAR_TOK_CALL);        SBw(free);
            SBc(zPAR_TOK_PUSHVAR);     SBw(bufferstr);
            SBc(zPAR_TOK_PUSHVAR);     SBw(cid);
            SBc(zPAR_TOK_ASSIGNSTR);

            const int s_p_string = 11 * 5 + 2;
        }
        else if(type == zPAR_TYPE_INSTANCE) {
            SBc(zPAR_TOK_PUSHINT);     SBw(_@(s.offset));
            SBc(zPAR_TOK_PUSHINT);     SBw(locals_Arr);
            SBc(zPAR_TOK_CALL);        SBw(arraypop);
            SBc(zPAR_TOK_CALL);        SBw(writeint);

            const int s_p_inst = 4 * 5;
        }
        else {
            SBc(zPAR_TOK_PUSHINT);     SBw(locals_Arr);
            SBc(zPAR_TOK_CALL);        SBw(arraypop);
            SBc(zPAR_TOK_PUSHVAR);     SBw(cid);
            SBc(zPAR_OP_IS);

            const int s_p_int = 3 * 5 + 1;
        };
    end; //}

    SBc(zPAR_TOK_RET);

    const int s_misc = 5 + 1 + 4; // call + ret + remember-int

    // Jetzt muss die Funktion aber noch neu sortiert werden, damit alles glatt geht:

    var int len; len = (p - 5) - foff;
    foff += currParserStackAddress;
    if(len) {
        var int pre; pre = MEM_Alloc(len);
        MEM_CopyBytes(foff, pre, len);
        MEM_CopyBytes(pre, foff+5, len);
        MEM_Free(pre);
    };

    if(SB_Length() > size) {
        MEM_Error(STR_Unescape("LeGo::Locals\n\nLength of the StringBuilder exceeded calculated\nsize of locals stream.\n\nPlease report errorcode: loc403"));
    };

    SB_Release();

    MEM_WriteInt(foff+0, zPAR_TOK_JUMP);
    MEM_WriteInt(foff+1, (stream+4) - currParserStackAddress);

    MEM_ArrayInsert(locals_Arr, stream);

    MEM_CallByOffset(p);

    stream = MEM_ArrayPop(locals_Arr);

    MEM_WriteInt(stream, 0);
    MEM_SetCallerStackPos(_@(zPAR_TOK_RET) - currParserStackAddress);
};

//========================================
// Hilfsfunktionen
//========================================
func int Token_GetSize(var int tok) {
    if((tok >= zPAR_TOK_CALL && tok <= zPAR_TOK_PUSHINDEX)||(tok >= zPAR_TOK_JUMP && tok <= zPAR_TOK_SETINSTANCE)) {
        return 5;
    };
    return 1;
};

func int Tokens_Copy(var int src, var int dest, var int len) {
    MEM_Warn(ConcatStrings("Now movin tokens: ", inttostring(len)));
    var int p; p = MEM_Alloc(len);
    MEM_CopyBytes(src, p, len);
    MEM_CopyBytes(p, dest, len);
    MEM_Free(p);
    var int dstC; dstC = dest;
    var int dstF; dstF = dest+len;
    var int srcF; srcF = src+len;
    var int diff; diff = dest-src;
    while(dstC < dstF);
        var int tok; tok = MEM_ReadByte(dstC);
        if(tok == zPAR_TOK_JUMPF || tok == zPAR_TOK_JUMP) {
            MEM_Info("Move if for Bytes.");
            MEM_Info(inttostring(diff));
            var int trg; trg = MEM_ReadInt(dstC+1);
            if(trg <= srcF && trg >= src) {
                MEM_WriteInt(dstC+1, trg+diff);
            };
        };
        dstC += Token_GetSize(tok);
    end;
};

//========================================
// Final
//========================================
func int Final() {
    // Alle benötigten Funktionsoffsets
    const int setcallerpos = -1;
    if(setcallerpos == -1) {
        setcallerpos = MEM_GetFuncOffset(MEM_SetCallerStackPos);
    };

    var int p;   p   = MEM_GetCallerStackPos();
    var int pa;  pa  = p + currParserStackAddress;

    if(MEM_ReadByte(pa) != zPAR_TOK_JUMPF) {
        MEM_Error("final() darf nur hinter einem if verwendet werden!");
        return false;
    };

    var int ifp; ifp = MEM_ReadInt(pa + 1);
    var int ifl; ifl = ifp - p - 5;

    var int s; s = SB_New();

    SBc(zPAR_TOK_PUSHINT); SBw(p);
    SBc(zPAR_TOK_CALL);    SBw(setcallerpos);
    SBc(zPAR_TOK_JUMP);    SBw(ifp);

    var int ptr; ptr = SB_GetStream();
    SB_Release();

    MEM_WriteInt(pa-5, zPAR_TOK_CALL);
    MEM_WriteInt(pa-4, ptr - currParserStackAddress);

    Tokens_Copy(pa+5, pa, ifl);
    MEM_WriteInt(pa+ifl, zPAR_TOK_RET | (zPAR_TOK_RET<<8) | (zPAR_TOK_RET<<16) | (zPAR_TOK_RET<<24));

    MEM_SetCallerStackPos(p - 5);
};



