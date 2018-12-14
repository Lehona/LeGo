/***********************************\
              PERMMEM
\***********************************/

/* const int _MEM_ArraySortFunc_Func = 0;
func void _MEM_ArraySortFunc_Wrapper() {
    MEM_ReadInt(MEM_ReadInt(ESP+4));
    MEM_ReadInt(MEM_ReadInt(ESP+8));
    MEM_CallByPtr(_MEM_ArraySortFunc_Func);
    EAX = MEMINT_PopInt();

    MEM_Info("leave wrapper");
};

func void MEM_ArraySortFunc(var int array, var func comparator) {
    const int hook = 0;

    if(!hook) {
        const int ptr = 0;
        ptr = MEM_Alloc(7);
        MEM_WriteInt(ptr, ASMINT_OP_retn);
        HookEngineF(ptr, 5, _MEM_ArraySortFunc_Wrapper);
        hook = MEM_ReadInt(ptr + 1) + ptr + 5;
        MEM_Free(ptr);
    };

    _MEM_ArraySortFunc_Func = MEM_GetFuncPtr(comparator);

    var zCArray arr; arr = _^(array);

    MEMINT_QSort(arr.array, arr.numInArray, 4, hook);

    MEM_Info("leave func");
}; */

func string MEM_ReadStringArray(var int arr, var int index) {
	return MEM_ReadString(arr+20*index);
};

func int _MEM_ArraySortFuncC(var int v0, var int v1) {};

func void _MEM_ArraySortFunc(var int l, var int r) {
    locals();
    if(l >= r) {
        return;
    };
    var int c;
    var int t; t = l;
    var int m; m = r-4;
    var int p; p = MEM_ReadInt(r);

    MEM_Label(0);
        //while((_MEM_ArraySortFuncC(MEM_ReadInt(t), p) <= 0)&&(t < r));
        MEM_Label(1);
        if((_MEM_ArraySortFuncC(MEM_ReadInt(t), p) <= 0)&&(t < r)) {
            t += 4;
            MEM_Goto(1);
        };
        //end;

        // while((_MEM_ArraySortFuncC(MEM_ReadInt(m), p) >= 0)&&(m > l));
        MEM_Label(2);
        if((_MEM_ArraySortFuncC(MEM_ReadInt(m), p) >= 0)&&(m > l)) {
            m -= 4;
            MEM_Goto(2);
        };
        // end;
    if(t < m) {
        c = MEM_ReadInt(m);
        MEM_WriteInt(m, MEM_ReadInt(t));
        MEM_WriteInt(t, c);
        MEM_Goto(0);
    };
    if(_MEM_ArraySortFuncC(MEM_ReadInt(t), p) > 0) {
        c = MEM_ReadInt(t);
        MEM_WriteInt(t, MEM_ReadInt(r));
        MEM_WriteInt(r, c);
    };
    _MEM_ArraySortFunc(l, t-4);
    _MEM_ArraySortFunc(t+4, r);
};

func void MEM_ArraySortFunc(var int stream, var func fnc) {
    MEM_ReplaceFunc(_MEM_ArraySortFuncC, fnc);
    _MEM_ArraySortFunc(MEM_ReadInt(stream), MEM_ReadInt(stream) + ((MEM_ArraySize(stream)-1)<<2));
};

//========================================
// [intern] Variablen
//========================================
const int HandlesPointer = 0;
const int HandlesInstance = 0;
var int nextHandle; 
var int _PM_ArrayElements;
var int _PM_Inst;
var int _PM_Stack;
const int PM_CurrHandle = 1;
const int _PM_foreachTable = 0;

//========================================
// Anzahl Handles
//========================================
func int numHandles() {
    if (HandlesPointer) {
        return (_HT_GetNumber(HandlesPointer));
    };
    return false;
	/* return (!!HandlesPointer*(_HT_GetNumber(HandlesPointer))); wäre viel schöner gewesen :( */
};

//========================================
// Instanzfunktion callen
//========================================
func int zCParser_CreateInstance(var int inst, var int ptr) {
    CALL_IntParam(ptr);
    CALL_IntParam(inst);
    CALL__thiscall(parser, zCParser__CreateInstance);
    return CALL_RetValAsInt();
};

//========================================
// Handle auf Gültigkeit prüfen
//========================================
func int Hlp_IsValidHandle(var int h) {
    if (!HandlesPointer) { return false; };
	return !!_HT_Get(HandlesPointer, h);
};

//========================================
// [intern]
//========================================
func MEMINT_Helperclass _PM_ToClass(var int inst) {
    var zCPar_Symbol symbInst;
    symbInst = MEM_PtrToInst(MEM_ReadIntArray (currSymbolTableAddress, inst));
    var zCPar_Symbol symbCls;
    symbCls = MEM_PtrToInst(symbInst.parent);
    if ((symbCls.bitfield & zCPar_Symbol_bitfield_type) == zPAR_TYPE_PROTOTYPE) {
        MEM_PtrToInst(symbCls.parent);
    }
    else {
        MEM_PtrToInst(symbInst.parent);
    };
};

//========================================
// [intern]
//========================================
func string _PM_InstName(var int inst) {
    var zCPar_Symbol symbInst;
    symbInst = MEM_PtrToInst(MEM_ReadIntArray (currSymbolTableAddress, inst));
    return symbInst.name;
};

//========================================
// Größe einer Instanz ermitteln
//========================================
func int sizeof(var int inst) {
    var zCPar_Symbol symb; symb = _PM_ToClass(inst);
    return symb.offset;
};

//========================================
// Handle löschen
//========================================
func void clear(var int h) {
    if (!Hlp_IsValidHandle(h)) { return; };
    var int a;
    a = _HT_Get(HandlesPointer, h);
    MEM_Free(a);
	_HT_Remove(HandlesPointer, h);
	_HT_Remove(HandlesInstance, h);
};

//========================================
// Handle freigeben
//========================================
func void release(var int h) {
    if (!Hlp_IsValidHandle(h)) { return; };
	_HT_Remove(HandlesPointer, h);
	_HT_Remove(HandlesInstance, h);
};

//========================================
// Funktion für alle Handles aufrufen
//========================================
const int rBreak = break;
const int rContinue = continue;
const int foreachHndl_ptr = 0;

func void _PM_AddToForeachTable(var int h) {
    if(!_PM_foreachTable) {
        MEM_Call(_PM_CreateForeachTable);
        return;
    };
    var int p; p = _HT_Get(HandlesPointer, h);
    if(p) {
        var int i; i = _HT_Get(HandlesInstance, h);
        var int c; c = MEM_ReadIntArray(_PM_foreachTable, i);
        if(!c) {
            c = MEM_ArrayCreate();
            MEM_WriteIntArray(_PM_foreachTable, i, c);
        };
        MEM_ArrayInsert(c, h);
    };
};

func void _PM_RemoveFromForeachTable(var int h) {
    var int p; p = _HT_Get(HandlesPointer, h);
    if(p) {
        var int i; i = _HT_Get(HandlesInstance, h);
        var int c; c = MEM_ReadIntArray(_PM_foreachTable, i);
        if(!c) {
            return;
        };
        MEM_ArrayRemoveValue(c, h);
        if(!MEM_ArraySize(c)) {
            MEM_ArrayFree(c);
            MEM_WriteIntArray(_PM_foreachTable, i, 0);
        };
    };
};

func void _PM_CreateForeachTable_HTSub(var int key, var int val) {
  _PM_AddToForeachTable(key);
};

func void _PM_CreateForeachTable() {
    if(_PM_foreachTable) {
        MEM_Free(_PM_foreachTable);
    };
    foreachHndl_ptr = MEM_GetFuncPtr(foreachHndl);
    _PM_foreachTable = MEM_Alloc(currSymbolTableLength * 4);
    if(HandlesPointer) {
      _HT_ForEach(HandlesPointer, _PM_CreateForeachTable_HTSub);
    };
};

func void foreachHndl(var int inst, var func fnc) {
    locals();
    if(!_PM_foreachTable) { return; };
    var int c; c = MEM_ReadIntArray(_PM_foreachTable, inst);
    if(!c) {
        return;
    };
    var zCArray z; z = _^(c);
    var int l; l = z.numInArray;
    var int a; a = MEM_Alloc(l<<2); 
    MEM_Copy(z.array, a, l);
    var int i; i = 0;
    var int o; o = MEM_GetFuncPtr(fnc);
    var int p; p = MEM_StackPos.position;
    while(i < l);
        var int h; h = MEM_ReadInt(a+(i<<2)); //handle
        if(_HT_Get(HandlesPointer, h)) {
            h;
            MEM_CallByPtr(o);
            if(MEM_PopIntResult() == rBreak) {
                break;
                // i = l;
            };
        };
        i += 1;
    end;
    MEM_Free(a);
};

func int hasHndl(var int inst) {
    if(!_PM_foreachTable) { return false; };
    var int c; c = MEM_ReadIntArray(_PM_foreachTable, inst);
    if(!c) { return false; };
    return MEM_ArraySize(c) > 0;
};

func void foreachHndlSort(var int inst, var func cmp) {
    if(!_PM_foreachTable) { return; };
    var int c; c = MEM_ReadIntArray(_PM_foreachTable, inst);
    if(!c) { return; };
    MEM_ArraySortFunc(c, cmp);
};

//========================================
// Handle mit Destruktor löschen
//========================================
func void delete(var int h) {
    locals();
    if (!Hlp_IsValidHandle(h)) { return; };
    _PM_RemoveFromForeachTable(h);
    var int inst; inst = _HT_Get(HandlesInstance, h);
    var zCPar_Symbol symbCls; symbCls = _PM_ToClass(inst);
    var int fnc; fnc = MEM_FindParserSymbol(ConcatStrings(symbCls.name, "_DELETE"));
    if(fnc != -1) {
        var int ptr; ptr = _HT_Get(HandlesPointer, h);
        symbCls = MEM_PtrToInst(ptr);
        MEMINT_StackPushInst(symbCls);
        MEM_CallByID(fnc);
    };
    clear(h);
};

//========================================
// Pointer mit Destruktor löschen
//========================================
func void free(var int h, var int inst) {
    if (!h) { return; };
    var zCPar_Symbol symbCls; symbCls = _PM_ToClass(inst);
    var int fnc; fnc = MEM_FindParserSymbol(ConcatStrings(symbCls.name, "_DELETE"));
    if(fnc != -1) {
        symbCls = MEM_PtrToInst(h);
        h; // 'local' variable
        MEMINT_StackPushInst(symbCls);
        MEM_CallByID(fnc);
        h = MEMINT_StackPopInt();
    };
    MEM_Free(h);
}; 

//========================================
// Speicher reservieren.
//========================================
func int create(var int inst) {
    locals();
    var zCPar_Symbol symbCls;
    //Symbol der Klasse holen
    symbCls = _PM_ToClass(inst);

    //Speicher gemäß der Größe eines Objekts der Klasse holen
    var int ptr; ptr = MEM_Alloc(symbCls.offset);
    var int i; i = zCParser_CreateInstance(inst, ptr);
    return ptr;
};

//========================================
// Neues Handle anlegen
//========================================
func int new(var int inst) {
    locals(); var int ptr;
	
	nextHandle += 1;
    if (!HandlesPointer) {
		MEM_InfoBox("This should never happen! If it does anyway, please report to Lehona on WorldOfGothic.");
        //Falls das Array nicht existiert neu anlegen.
        HandlesPointer = _HT_Create();
        HandlesInstance = _HT_Create();
    };
    ptr = create(inst);
	_HT_Insert(HandlesPointer, ptr, nextHandle);
	_HT_Insert(HandlesInstance, inst, nextHandle);
    _PM_AddToForeachTable(nextHandle);
    return nextHandle; //das erste Handle ist somit 1
};

/* provisorisch */
func int wrap(var int inst, var int ptr) {
    locals();
	
	nextHandle += 1;
    if (!HandlesPointer) {
        //Falls das Array nicht existiert neu anlegen.
        HandlesPointer = _HT_Create();
        HandlesInstance = _HT_Create();
    };
	
	_HT_Insert(HandlesPointer, ptr, nextHandle);
	_HT_Insert(HandlesInstance, inst, nextHandle);
    _PM_AddToForeachTable(nextHandle);
    return nextHandle; //das erste Handle ist somit 1
};

//========================================
// Handle als Instanz holen
//========================================
func MEMINT_HelperClass get(var int h) {
	if (!Hlp_IsValidHandle(h)) { return; };
    var int p; p = _HT_Get(HandlesPointer, h);
    if(p) {
        MEM_PtrToInst(p);
        return;
    };
    MEM_Error(ConcatStrings("Tried to 'get' invalid handle ", IntToString(h)));
    MEMINT_StackPushInst(MEMINT_INSTUNASSIGNED);
};

//========================================
// Handle als Pointer holen
//========================================
func int getPtr(var int h) {
    if (!Hlp_IsValidHandle(h)) { return 0; };
	return _HT_Get(HandlesPointer, h);
};

//========================================
// Instanz eines Handles holen
//========================================
func int getInst(var int h) {
	if (!Hlp_IsValidHandle(h)) { return 0; };
	return _HT_Get(HandlesInstance, h);
};

//========================================
// Pointer eines Handles setzen (Debugzwecke)
//========================================
func void setPtr(var int h, var int ptr) {
    if (!Hlp_IsValidHandle(h)){ return; };
    _HT_Change(HandlesPointer, ptr, h);
};

//========================================
// Betrachten der folgenden
// Scripte auf eigene Gefahr :0
//========================================
func void _deleteAll(var int key, var int val) {
	delete(key);
};

func void _PM_Reset() {
    MEM_Info("Reset ALL the handles!");
    if(HandlesPointer) {
		_HT_ForEach(HandlesPointer, _deleteAll);
		_HT_Destroy(HandlesPointer);
		_HT_Destroy(HandlesInstance);
		HandlesPointer = 0;
		HandlesInstance = 0;
    };
	MEM_Info("Resetting done.");
};

const int _PM_Version = 2;

const int _PM_Tabs = 0;
const int _PM_Line = 0;

func void _PM_WTab() {
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < _PM_Tabs) {
        BW_Byte(9); // '\t'
        i += 1;
        MEM_StackPos.position = p;
    };
};
func void _PM_Text(var string t) {
    _PM_WTab();
    BW_Text(t);
};
func string _PM_TextLine() {
    _PM_Line += 1;
    var int p; p = MEM_StackPos.position;
    if(BR_Byte() == 9) {
        MEM_StackPos.position = p;
    };
    _bin_crsr -= 1;
    return BR_TextLine();
};

const int _PM_String   = 0;
const int _PM_Int      = 1;
const int _PM_Class    = 2;
const int _PM_ClassPtr = 3;
const int _PM_IntArr   = 4;
const int _PM_StrArr   = 5;

class _PM_SaveObject_Str {
    var int type;
    var string name;
    var string content;
};
instance _PM_SaveObject_Str@(_PM_SaveObject_Str);
const int _PM_SaveObject_Str_size = 24 + 20;

class _PM_SaveObject_Int {
    var int type;
    var string name;
    var int content;
};
instance _PM_SaveObject_Int@(_PM_SaveObject_Int);
const int _PM_SaveObject_Int_size = 24 + 4;

class _PM_SaveObject_Cls {
    var int type;
    var string name;
    var int content; // zCArray<_PM_SaveObject*>*
    var string class;
};
instance _PM_SaveObject_Cls@(_PM_SaveObject_Cls);
const int _PM_SaveObject_Cls_size = 24 + 4 + 20;

class _PM_SaveObject_Arr {
    var int type;
    var string name;
    var int content; // zCArray<_PM_SaveObject*>*
    var int elements;
};
instance _PM_SaveObject_Arr@(_PM_SaveObject_Arr);
const int _PM_SaveObject_Arr_size = 24 + 4 + 4;

func int _PM_ObjectType(var int obj) {
    return MEM_ReadInt(obj);
};

func string _PM_ObjectName(var int obj) {
    return MEM_ReadString(obj+4);
};

class _PM_SaveStruct {
    var string instName;
    var int inst;
    var string className;
    var int offsStack; // zCArray<int>*
    var int currOffs;
    var int contentStack; // zCArray<zCArray<_PM_SaveObject*>*>*
    var int content; // zCArray<_PM_SaveObject*>*
};
instance _PM_SaveStruct@(_PM_SaveStruct);

const int _PM_FreedNum = 0;
const int _PM_FreedSize = 0;
func void _PM_SaveStruct_DeleteArr(var int arr) {
    locals();
    if(!arr) { return; };
    var zCArray a; a = MEM_PtrToInst(arr);
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < a.numInArray) {
        var int o; o = MEM_ReadIntArray(a.array, i);
        var int t; t = _PM_ObjectType(o);

        _PM_FreedNum += 1;

        if(t <= _PM_Int) {
            // Ein Intobject sieht genau so aus wie ein Stringobject
            var _PM_SaveObject_Str os; os = MEM_PtrToInst(o);
            // Nur hat letzteres als content einen String
            if(t == _PM_String) {
                os.content = "";
                _PM_FreedSize += _PM_SaveObject_Str_size;
            }
            else {
                _PM_FreedSize += _PM_SaveObject_Int_size;
            };
            os.name = "";
        }
        else {
            // Klasse und Array sind auch vom Aufbau gleich
            var _PM_SaveObject_Cls oc; oc = MEM_PtrToInst(o);
            // Nur hat die Klasse am Ende statt elements noch einen string class
            if(t <= _PM_ClassPtr) {
                oc.class = "";
                _PM_FreedSize += _PM_SaveObject_Cls_size;
                if(oc.content) {
                    _PM_SaveStruct_DeleteArr(oc.content);
                };
            }
            else {
                _PM_FreedSize += _PM_SaveObject_Arr_size;
                if(!_PM_Mode&&oc.content) {
                    _PM_SaveStruct_DeleteArr(oc.content);
                };
            };
            oc.name = "";
        };
       MEM_Free(o);
        i += 1;
        MEM_StackPos.position = p;
    };
    MEM_ArrayFree(arr);
};

func void _PM_SaveStruct_Delete(var _PM_SaveStruct this) {
    this.instName = "";
    this.className = "";
    if(this.offsStack) {
        MEM_ArrayFree(this.offsStack);
    };
    if(this.contentStack) {
        var zCArray a; a = MEM_PtrToInst(this.contentStack);
        if(a.numInArray) {
            MEM_Warn(ConcatStrings("contentStack not clean! ", inttostring(a.numInArray)));
        };
        MEM_ArrayFree(this.contentStack);
    };
    if(this.content) {
        _PM_SaveStruct_DeleteArr(this.content);
    };
};

const int _PM_HeadPtr = 0; // _PM_SaveStruct*
var _PM_SaveStruct _PM_Head;
const string _PM_SearchObjCache = "";

const int _PM_DataPoolNum = 0;
const int _PM_DataPoolSize = 0;
func int _PM_Alloc(var int size) {
    _PM_DataPoolNum += 1;
    _PM_DataPoolSize += size;
    return MEM_Alloc(size);
};

const int _PM_Mode = 0;
func void _PM_Error(var string msg) {
    var string res; res = ConcatStrings("PermMem: ", msg);
    if(!_PM_Mode) {
        res = ConcatStrings(res, ", line ");
        res = ConcatStrings(res, IntToString(_PM_Line));
    };
    MEM_Error(res);
};

func int _PM_NewObjectString(var string name, var string content) {
    // if(_PM_Mode == 1) {
        // content = STR_Escape(content);
    // }
    // else {
        // content = STR_Unescape(content);
    // };
    var int ptr; ptr = _PM_Alloc(_PM_SaveObject_Str_size);
    var _PM_SaveObject_Str oStr; oStr = MEM_PtrToInst(ptr);
    oStr.name = name;
    oStr.type = _PM_String;
    oStr.content = content;
    return ptr;
};

func int _PM_NewObjectInt(var string name, var int content) {
    var int ptr; ptr = _PM_Alloc(_PM_SaveObject_Int_size);
    var _PM_SaveObject_Int oInt; oInt = MEM_PtrToInst(ptr);
    oInt.name = name;
    oInt.type = _PM_Int;
    oInt.content = content;
    return ptr;
};

func int _PM_NewObjectClass(var string name, var string class, var int p, var int content) {
    var int ptr; ptr = _PM_Alloc(_PM_SaveObject_Cls_size);
    var _PM_SaveObject_Cls oCls; oCls = MEM_PtrToInst(ptr);
    oCls.name = name;
    if(!p) { oCls.type = _PM_Class; }
    else   { oCls.type = _PM_ClassPtr; };
    oCls.class = class;
    oCls.content = content;
    return ptr;
};

func int _PM_NewTempClass() {
    var int ptr; ptr = MEM_Alloc(_PM_SaveObject_Cls_size);
    var _PM_SaveObject_Cls oCls; oCls = MEM_PtrToInst(ptr);
    oCls.content = _PM_Head.content;
    return ptr;
};

func int _PM_NewObjectArray(var string name, var int type, var int elements, var int content) {
    var int ptr; ptr = _PM_Alloc(_PM_SaveObject_Arr_size);
    var _PM_SaveObject_Arr oArr; oArr = MEM_PtrToInst(ptr);
    oArr.name = name;
    oArr.type = type;
    oArr.elements = elements;
    oArr.content = content;
    return ptr;
};

func int _PM_StringToObject(var string line) {
    if(STR_SplitCount(line, "=") < 2) {
        return -1;
    };
    var string name; name = STR_Split(line, "=", 0);
    var int nameLen; nameLen = STR_Len(name)+1;
    var int dataLen; dataLen = STR_Len(line)-nameLen;
    if(!dataLen) {
        return -1;
    };
    var string data; data = STR_SubStr(line, nameLen, dataLen);
    var string type; type = STR_Prefix(data, 1);
    var string cont; cont = STR_SubStr(data, 1, dataLen-1);
    if(!STR_Compare(type, "s")) {
        return _PM_NewObjectString(name, cont);
    }
    else if(!STR_Compare(type, "i")) {
        return _PM_NewObjectInt(name, STR_ToInt(cont));
    }
    else if((!STR_Compare(type, "c"))||(!STR_Compare(type, "p"))) {
        return _PM_NewObjectClass(name, cont, !STR_Compare(type, "p"), 0);
    }
    else if(!STR_Compare(type, "a")) {
        if(!STR_Compare(STR_Prefix(cont, 3), "INT")) {
            return _PM_NewObjectArray(name, _PM_IntArr, STR_ToInt(STR_Split(cont, ":", 1)), 0);
        }
        else {
            return _PM_NewObjectArray(name, _PM_StrArr, STR_ToInt(STR_Split(cont, ":", 1)), 0);
        };
    };
    return -1;
};

func string _PM_ObjectToString(var int obj) {
    var int type; type = _PM_ObjectType(obj);
    var string name; name = ConcatStrings(_PM_ObjectName(obj), "=");
    var string data; var string prefix;
    if(type == _PM_String) {
        var _PM_SaveObject_Str oStr; oStr = MEM_PtrToInst(obj);
        data = ConcatStrings("s", oStr.content);
    }
    else if(type == _PM_Int) {
        var _PM_SaveObject_Int oInt; oInt = MEM_PtrToInst(obj);
        data = ConcatStrings("i", IntToString(oInt.content));
    }
    else if((type == _PM_Class)||(type == _PM_ClassPtr)) {
        var _PM_SaveObject_Cls oCls; oCls = MEM_PtrToInst(obj);
        if(oCls.type == _PM_Class) { prefix = "c"; }
        else                       { prefix = "p"; };
        if(oCls.content) {
            data = ConcatStrings(prefix, oCls.class);
        }
        else {
            data = ConcatStrings(prefix, "NULL");
        };
    }
    else if((type == _PM_IntArr)||(type == _PM_StrArr)) {
        var _PM_SaveObject_Arr oArr; oArr = MEM_PtrToInst(obj);
        if(type == _PM_IntArr) { prefix = "aINT:"; }
        else                   { prefix = "aSTRING:"; };
        data = ConcatStrings(prefix, IntToString(oArr.elements));
    }
    else {
        return "";
    };
    return ConcatStrings(name, data);
};

func void _PM_DataToSaveObject0(var string s0, var string s1) {
    // Nur ein Dummy. Struct, Archiver, Auto und Kopf rufen sich gegenseitig auf.
    MEM_ReplaceFunc(_PM_DataToSaveObject0, _PM_DataToSaveObject);
    _PM_DataToSaveObject0(s0,s1);
};

func void _PM_AutoPackSymbol(var int symbID) {
    var zCPar_Symbol sym; sym = MEM_PtrToInst(MEM_ReadIntArray(currSymbolTableAddress, symbID));
    var int type; type = sym.bitfield & zCPar_Symbol_bitfield_type;
    if((type == zPAR_TYPE_FLOAT)||(type == zPAR_TYPE_INT)||(type == zPAR_TYPE_FUNC)) {
        _PM_DataToSaveObject0(sym.name, "INT");
    }
    else if(type == zPAR_TYPE_STRING) {
        _PM_DataToSaveObject0(sym.name, "STRING");
    }
    else {
        _PM_Error(ConcatStrings("Symbol kann nicht automatisch gespeichert werden. ", sym.name));
        return;
    };
};

func void _PM_DataToSaveStruct_Struct(var int classID, var int struct) {
    locals();
    var zCPar_Symbol zstruct; zstruct = MEM_PtrToInst(MEM_ReadIntArray(currSymbolTableAddress, struct));
    var zCPar_Symbol zclass;  zclass  = MEM_PtrToInst(MEM_ReadIntArray(currSymbolTableAddress, classID));

    var string structCnt; structCnt = STR_Upper(MEM_ReadString(zstruct.content));

    classID += 1; // Beim ersten Member beginnen, nicht bei der Klasse.
    var int currOffs; currOffs = 0;
    var int maxOffs; maxOffs = zclass.bitfield & zCPar_Symbol_bitfield_ele;

    var int i; i = 0;
    var int splits; splits = STR_SplitCount(structCnt, " ");

    var int p; p = MEM_StackPos.position;
    if(i < splits) {
        if(currOffs >= maxOffs) {
            _PM_Error(ConcatStrings("Die struct beansprucht mehr Symbole als die Klasse besitzt! ", zstruct.name));
            return;
        };

        var string curr; curr = STR_Split(structCnt, " ", i);
        var int num; num = 1;
        var int ptr; ptr = 0;

        if(STR_SplitCount(curr, "|") > 1) {
            num = STR_ToInt(STR_Split(curr, "|", 1));
            if(!num) {
                _PM_Error(ConcatStrings("Struct kaputt! ", zstruct.name));
                return;
            };
            curr = STR_Split(curr, "|", 0);
        };
        if(STR_GetCharAt(curr, STR_Len(curr)-1) == 42) { // *
            curr = STR_Prefix(curr, STR_Len(curr)-1);
            ptr = 1;
        };

        var int p1;
        if(!STR_Compare(curr, "AUTO")) {
            if(ptr) {
                _PM_Error(ConcatStrings("auto* ist keine gültige Klasse. ", zstruct.name));
                return;
            };
            p1 = MEM_StackPos.position;
            if(num) {
                _PM_AutoPackSymbol(classID + currOffs);
                currOffs += 1;
                num -= 1;
                MEM_StackPos.position = p1;
            };
            i += 1;
            MEM_StackPos.position = p;
        };

        if(!STR_Compare(curr, "VOID")) {
            if(ptr) {
                _PM_Error(ConcatStrings("void* ist keine gültige Klasse. ", zstruct.name));
                return;
            };
            currOffs += num;
            i += 1;
            MEM_StackPos.position = p;
        };

        p1 = MEM_StackPos.position;
        if(num) {
            var zCPar_Symbol sym; sym = MEM_PtrToInst(MEM_ReadIntArray(currSymbolTableAddress, classID + currOffs));

            MEM_ArrayPush(_PM_Head.offsStack, _PM_Head.currOffs);
            _PM_Head.currOffs += sym.offset;
            _PM_Head.currOffs = MEM_ReadInt(_PM_Head.currOffs);

            var string name; name = STR_Split(sym.name, ".", 1);

            if(!_PM_Head.currOffs) {
                MEM_ArrayInsert(_PM_Head.content, _PM_NewObjectClass(name, curr, ptr, 0));
                name = "";
                _PM_Head.currOffs = MEM_ArrayPop(_PM_Head.offsStack);
                currOffs += 1;
                num -= 1;
                MEM_StackPos.position = p1;
            };

            var int nArr; nArr = MEM_ArrayCreate();
            MEM_ArrayInsert(_PM_Head.content, _PM_NewObjectClass(name, curr, ptr, nArr));
            name = "";

            MEM_ArrayPush(_PM_Head.contentStack, _PM_Head.content);
            _PM_Head.content = nArr;

            _PM_DataToSaveObject0("", curr);

            _PM_Head.currOffs = MEM_ArrayPop(_PM_Head.offsStack);
            _PM_Head.content = MEM_ArrayPop(_PM_Head.contentStack);

            currOffs += 1;
            num -= 1;
            MEM_StackPos.position = p1;
        };
        i += 1;
        MEM_StackPos.position = p;
    };
};

func int _PM_DataToSaveStruct_Archiver(var int offs, var int archiver) {
    var zCPar_Symbol s; s = MEM_PtrToInst(_PM_Head.currOffs+offs);
    MEMINT_StackPushInst(s);
    MEM_CallByID(archiver);
};

func void _PM_DataToSaveStruct_Auto(var int currID) {
    var zCPar_Symbol sym; sym = MEM_PtrToInst(MEM_ReadIntArray(currSymbolTableAddress, currID));

    var int max; max = sym.bitfield & zCPar_Symbol_bitfield_ele;
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < max) {
        currID += 1;
        _PM_AutoPackSymbol(currID);
        i += 1;
        MEM_StackPos.position = p;
    };
};

func void _PM_DataToSaveObject(var string name, var string className) {
    var int ptr; var int offs; var int sym; var int ele;
    var string newname;
    className = STR_Upper(className);

    // Nachsehen ob es eine Klasse oder ein Member ist
    if(STR_SplitCount(name, ".") > 1) {
        // Und ggf. das offset des Members bestimmen
        sym = MEM_GetParserSymbol(name);
        if(!sym) {
            _PM_Error(ConcatStrings("Unbekanntes Symbol ", name));
            return;
        };
        var zCPar_Symbol zsym; zsym = MEM_PtrToInst(sym);
        offs = zsym.offset;
        ele = zsym.bitfield & zCPar_Symbol_bitfield_ele;
        newname = STR_Split(name, ".", 1);
    }
    else {
        // Tritt nur ein wenn es eine neue Klasse ist
        offs = 0;
    };

    // Bekannte Datentypen direkt speichern
    if((!STR_Compare(className, "INT"))||(!STR_Compare(className, "FLOAT"))||(!STR_Compare(className, "FUNC"))) {
        if(ele == 1) {
            ptr = _PM_NewObjectInt(newname, MEM_ReadInt(_PM_Head.currOffs + offs));
        }
        else {
            ptr = _PM_NewObjectArray(newname, _PM_IntArr, ele, _PM_Head.currOffs + offs);
        };
        MEM_ArrayInsert(_PM_Head.content, ptr);
        return;
    }
    else if(!STR_Compare(className, "STRING")) {
        if(ele == 1) {
            ptr = _PM_NewObjectString(newname, MEM_ReadString(_PM_Head.currOffs + offs));
        }
        else {
            ptr = _PM_NewObjectArray(newname, _PM_StrArr, ele, _PM_Head.currOffs + offs);
        };
        MEM_ArrayInsert(_PM_Head.content, ptr);
        return;
    };

    var int classID; classID = MEM_FindParserSymbol(className);
    if(classID == -1) {
        _PM_Error(concatStrings("Unbekannte Klasse. ", className));
        return;
    };

    // Zuerst nach _Archiver suchen
    sym = MEM_FindParserSymbol(ConcatStrings(className, "_ARCHIVER"));

    if(sym != -1) {
        _PM_DataToSaveStruct_Archiver(offs, sym);
        return;
    };

    // Falls nicht vorhanden nach _Struct suchen
    sym = MEM_FindParserSymbol(ConcatStrings(className, "_STRUCT"));

    if(sym != -1) {
        _PM_DataToSaveStruct_Struct(classID, sym);
        return;
    };

    // Falls ebenfalls nicht vorhanden automatisch packen
    _PM_DataToSaveStruct_Auto(classID);
};

func void _PM_InstToSaveStruct(var int ptr, var int inst) {
    // Speicherkopf vorbereiten
    if(_PM_HeadPtr) {
        free(_PM_HeadPtr, _PM_SaveStruct@);
    };
    _PM_HeadPtr = create(_PM_SaveStruct@);
    _PM_Head = MEM_PtrToInst(_PM_HeadPtr);

    _PM_Head.contentStack = MEM_ArrayCreate();
    _PM_Head.offsStack = MEM_ArrayCreate();

    _PM_Head.instName = _PM_InstName(inst);

    var zCPar_Symbol symbClass; symbClass = _PM_ToClass(inst);
    _PM_Head.className = symbClass.name;

    _PM_Head.currOffs = ptr;
    _PM_Head.content = MEM_ArrayCreate();

    // Zuerst nach Archiver von Instanz suchen
    var int sym; sym = MEM_FindParserSymbol(ConcatStrings(_PM_Head.instName, "_ARCHIVER"));

    if(sym != -1) {
        _PM_DataToSaveStruct_Archiver(0, sym);
        return;
    };

    _PM_DataToSaveObject("", _PM_Head.className);
};

func void _PM_WriteArray(var int obj) {
    var _PM_SaveObject_Arr oArr; oArr = MEM_PtrToInst(obj);

    _PM_Text("[");
    BW_NextLine();

    _PM_Tabs += 1;
    var int j; j = 0;
    var int p; p = MEM_StackPos.position;
    if(j < oArr.elements) {
        _PM_Text(ConcatStrings(IntToString(j), "="));
        if(oArr.type == _PM_IntArr) {
            BW_Text(ConcatStrings("i", IntToString(MEM_ReadIntArray(oArr.content, j))));
        }
        else {
            BW_Text(ConcatStrings("s", MEM_ReadStringArray(oArr.content, j)));
        };
        BW_NextLine();
        j += 1;
        MEM_StackPos.position = p;
    };

    _PM_Tabs -= 1;

    _PM_Text("]");
    BW_NextLine();
};

func void _PM_WriteClass(var int obj) {
    locals();
    var _PM_SaveObject_Cls oCls; oCls = MEM_PtrToInst(obj);
    if(!oCls.content) { return; };

    MEM_ArrayPush(_PM_Head.contentStack, _PM_Head.content);

    _PM_Head.content = oCls.content;

    _PM_Text("{");
    BW_NextLine();

    _PM_Tabs += 1;

    var zCArray arr; arr = MEM_PtrToInst(_PM_Head.content);
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < arr.numInArray) {
        var int currObj; currObj = MEM_ReadIntArray(arr.array, i);

        _PM_Text(_PM_ObjectToString(currObj));
        BW_NextLine();
        if(_PM_ObjectType(currObj) >= _PM_Class) {
            var int type; type = _PM_ObjectType(currObj);

            if(type >= _PM_IntArr) {
                // Arrays
                _PM_WriteArray(currObj);
            }
            else {
                // Unterklassen
                _PM_WriteClass(currObj);
            };

        };
        i += 1;
        MEM_StackPos.position = p;
    };

    _PM_Tabs -= 1;

    _PM_Text("}");
    BW_NextLine();

    _PM_Head.content = MEM_ArrayPop(_PM_Head.contentStack);
};

func void _PM_WriteSaveStruct() {
    _PM_Head = MEM_PtrToInst(_PM_HeadPtr);

    BW_Text(_PM_Head.className);
    BW_Text(":");
    BW_Text(_PM_Head.instName);
    BW_NextLine();

    var int newObj; newObj = _PM_NewTempClass();

    _PM_WriteClass(newObj);

    MEM_Free(newObj);

    BW_NextLine();
};

var int PM_HandleList;
func void _PM_Archive_HTSub(var int key, var int val) {
	if (!PM_HandleList) {
		/* PM_HandleList = List_Create(key); */
		key;
		MEM_Call(List_Create);
		PM_HandleList = MEM_PopIntResult();
	} else {
		/* List_InsertSorted(PM_HandleList, key, List_CmpAscending); */
		PM_HandleList; key; MEM_GetFuncID(List_CmpAscending);
		MEM_Call(List_InsertSorted);
	};
};

func void _PM_Archive_ListSub(var int lPtr) {
	var zCList list; list = _^(lPtr);
	var int key; key = list.data;
	
	PM_CurrHandle = key;
    _PM_InstToSaveStruct(_HT_Get(HandlesPointer, key), _HT_Get(HandlesInstance, key));

    BW_Text(ConcatStrings("HNDL:", IntToString(key/*+1*/)));
    BW_NextLine();

    _PM_WriteSaveStruct();
};

func void _PM_Archive() {
    MEM_Info("===  PermMem::Archive  ===");

    var int TIME; TIME = MEM_GetSystemTime();
    _PM_DataPoolSize = 0; _PM_DataPoolNum = 0;
    _PM_FreedSize = 0;    _PM_FreedNum    = 0;

    _PM_Mode = 1;
	
    var int arrMax; arrMax = _HT_GetNumber(HandlesPointer);

    var int newArr; newArr = MEM_ArrayCreate();

    _PM_Tabs = 0;

    BW_Text(ConcatStrings("PermMem::v", IntToString(_PM_Version)));
    BW_NextLine();
    BW_NextLine();

	_HT_ForEach(HandlesPointer, _PM_Archive_HTSub);
	/* List_ForF(PM_HandleList, _PM_Archive_ListSub); */
	if (PM_HandleList) {
		PM_HandleList; MEM_GetFuncID(_PM_Archive_ListSub);
		MEM_Call(List_ForF);
	};

	PM_HandleList = 0;
    PM_CurrHandle = 1;

    BW_Text("PermMem::End");
    BW_NextLine();

    free(_PM_HeadPtr, _PM_SaveStruct@);
    _PM_HeadPtr = 0;

    MEM_Info(ConcatStrings("buffer used:     ", IntToString(_PM_DataPoolSize)));
    MEM_Info(ConcatStrings("buffer cleaned:  ", IntToString(_PM_FreedSize)));
    MEM_Info(ConcatStrings("objects created: ", IntToString(_PM_DataPoolNum)));
    MEM_Info(ConcatStrings("objects cleaned: ", IntToString(_PM_FreedNum)));
    MEM_Info(ConcatStrings("ellapsed time:   ", IntToString(MEM_GetSystemTime()-TIME)));
    MEM_Info("===        Done        ===");
};

func void _PM_ReadArray(var int type) {
    if(STR_Compare(_PM_TextLine(), "[")) {
        _PM_Error(ConcatStrings("'[' erwartet. ", _PM_Head.instName));
        return;
    };

    _PM_Tabs += 1;

    var int p; p = MEM_StackPos.position;
    var string str; str = _PM_TextLine();
    if(STR_Compare(str, "]")) {
        var int obj; obj = _PM_StringToObject(str);

        if(_PM_ObjectType(obj) != type) {
            _PM_Error(ConcatStrings("Unerwarteter Typ im Array. ", _PM_Head.instName));
            return;
        };

        MEM_ArrayInsert(_PM_Head.content, obj);

        MEM_StackPos.position = p;
    };

    _PM_Tabs -= 1;
};

func void _PM_ReadClass() {
    if(STR_Compare(_PM_TextLine(), "{")) {
        _PM_Error(ConcatStrings("'{' erwartet. ", _PM_Head.instName));
        return;
    };

    _PM_Tabs += 1;

    var int p; p = MEM_StackPos.position;
    var string str; str = _PM_TextLine();
    if(STR_Compare(str, "}")) {
        var int obj; obj = _PM_StringToObject(str);
        var int type; type = _PM_ObjectType(obj);

        MEM_ArrayInsert(_PM_Head.content, obj);

        if(type == _PM_Class||type == _PM_ClassPtr) {
            var _PM_SaveObject_Cls c; c = MEM_PtrToInst(obj);
            if(STR_Compare(c.class, "NULL")) {
                c.content = MEM_ArrayCreate();

                MEM_ArrayPush(_PM_Head.contentStack, _PM_Head.content);
                _PM_Head.content = c.content;

                _PM_ReadClass();

                _PM_Head.content = MEM_ArrayPop(_PM_Head.contentStack);
            };
        }
        else if(type >= _PM_IntArr) {
            var _PM_SaveObject_Arr a; a = MEM_PtrToInst(obj);
            a.content = MEM_ArrayCreate();

            MEM_ArrayPush(_PM_Head.contentStack, _PM_Head.content);
            _PM_Head.content = a.content;

            if(type == _PM_IntArr) {
                _PM_ReadArray(_PM_Int);
            }
            else {
                _PM_ReadArray(_PM_String);
            };

            _PM_Head.content = MEM_ArrayPop(_PM_Head.contentStack);
        };

        MEM_StackPos.position = p;
    };

    _PM_Tabs -= 1;
};

func void _PM_ReadSaveStruct() {
    // Speicherkopf vorbereiten
    if(_PM_HeadPtr) {
        free(_PM_HeadPtr, _PM_SaveStruct@);
    };
    _PM_HeadPtr = create(_PM_SaveStruct@);
    _PM_Head = MEM_PtrToInst(_PM_HeadPtr);

    _PM_Head.contentStack = MEM_ArrayCreate();
    _PM_Head.offsStack = MEM_ArrayCreate();

    _PM_Head.content = MEM_ArrayCreate();

    var string str; str = _PM_TextLine();
    if(STR_SplitCount(str, ":") < 2) {
        _PM_Error(ConcatStrings("Ungültiger Objektkopf: ", str));
        return;
    };

    _PM_Head.className = STR_Split(str, ":", 0);
    _PM_Head.instName = STR_Split(str, ":", 1);

    _PM_Head.inst = MEM_FindParserSymbol(_PM_Head.instName);
    if(_PM_Head.inst == -1) {
        _PM_Error(ConcatStrings("Unbekannte Instanz: ", _PM_Head.instName));
        return;
    };

    var int classPtr; classPtr = MEM_GetParserSymbol(_PM_Head.className);
    if(!classPtr) {
        _PM_Error(ConcatStrings("Unbekannte Klasse: ", _PM_Head.className));
        return;
    };

    var zCPar_Symbol classSym; classSym = MEM_PtrToInst(classPtr);

    // Nach allen Sicherheitschecks endlich den Pointer holen:
    _PM_Head.currOffs = MEM_Alloc(classSym.offset);

    // Und natürlich füllen:
    _PM_ReadClass();
};

func int _PM_GetSymbOffs(var string className, var string symb) {
    var string buf; buf = ConcatStrings(className, ".");
    var int symPtr; symPtr = MEM_FindParserSymbol(ConcatStrings(buf, symb));
    if(symPtr == -1) { return -1; };
    return MEM_ReadInt(MEM_ReadIntArray(currSymbolTableAddress, symPtr)+zCParSymbol_offset_offset);
};

func void _PM_ClassToInst0(var string s0) {
    // Nur ein Dummy. _PM_ClassToInst und _PM_ClassToInst_Auto rufen sich gegenseitig auf
    MEM_ReplaceFunc(_PM_ClassToInst0, _PM_ClassToInst);
    _PM_ClassToInst0(s0);
};

func void _PM_ClassToInst_ClassToPtr(var int obj, var int ptr) {
    locals();
    var _PM_SaveObject_Cls oc; oc = MEM_PtrToInst(obj);
    MEM_ArrayPush(_PM_Head.offsStack, _PM_Head.currOffs);
    MEM_ArrayPush(_PM_Head.contentStack, _PM_Head.content);
    _PM_Head.currOffs = ptr;
    _PM_Head.content = oc.content;

    _PM_ClassToInst0(oc.class);

    _PM_Head.currOffs = MEM_ArrayPop(_PM_Head.offsStack);
    _PM_Head.content = MEM_ArrayPop(_PM_Head.contentStack);
};

func void _PM_ClassToInst_ArrToPtr(var int obj, var int offs) {
    var _PM_SaveObject_Int oi;
    var _PM_SaveObject_Str os;
    var _PM_SaveObject_Arr oa; oa = MEM_PtrToInst(obj);
    var zCArray narr; narr = MEM_PtrToInst(oa.content);
    var int j; j = 0;
    var int p0; p0 = MEM_StackPos.position;
    if(j < narr.numInArray) {
        if(oa.type == _PM_IntArr) {
            oi = MEM_PtrToInst(MEM_ReadIntArray(narr.array, j));
            MEM_WriteIntArray(offs, STR_ToInt(oi.name), oi.content);
        }
        else {
            os = MEM_PtrToInst(MEM_ReadIntArray(narr.array, j));
            MEM_WriteString(offs + 20 * STR_ToInt(os.name), os.content);
        };
        j += 1;
        MEM_StackPos.position = p0;
    };
};

func void _PM_ClassToInst_Auto(var string className) {
    locals();
    var _PM_SaveObject_Int oi;
    var _PM_SaveObject_Str os;
    var zCArray arr; arr = MEM_PtrToInst(_PM_Head.content);
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < arr.numInArray) {
        var int obj; obj = MEM_ReadIntArray(arr.array, i);
        var int type; type = _PM_ObjectType(obj);
        var int offs; offs = _PM_GetSymbOffs(className, _PM_ObjectName(obj));

        if(offs == -1) {
            _PM_Error(ConcatStrings("Unknown Symbol. ", _PM_ObjectName(obj)));
            return;
        };
        offs += _PM_Head.currOffs;

        if(type == _PM_String) {
            os = MEM_PtrToInst(obj);
            MEM_WriteString(offs, os.content);
        }
        else if(type == _PM_Int) {
            oi = MEM_PtrToInst(obj);
            MEM_WriteInt(offs, oi.content);
        }
        else if(type == _PM_Class) {
            _PM_ClassToInst_ClassToPtr(obj, offs);
        }
        else if(type == _PM_ClassPtr) {
            var _PM_SaveObject_Cls oc; oc = MEM_PtrToInst(obj);
            if(oc.content) {
                var int classPtr; classPtr = MEM_GetParserSymbol(oc.class);
                if(!classPtr) {
                    _PM_Error(ConcatStrings("Unknown class. ", oc.class));
                    return;
                };
                var int ptr; ptr = MEM_Alloc(MEM_ReadInt(classPtr + zCParSymbol_offset_offset));
                MEM_WriteInt(offs, ptr);
                _PM_ClassToInst_ClassToPtr(obj, ptr);
            };
        }
        else if(type >= _PM_IntArr) {
            _PM_ClassToInst_ArrToPtr(obj, offs);
        };
        i += 1;
        MEM_StackPos.position = p;
    };
};

func void _PM_ClassToInst_Unarchiver(var int unarchiver) {
    var zCPar_Symbol s; s = MEM_PtrToInst(_PM_Head.currOffs);
    MEMINT_StackPushInst(s);
    MEM_CallByID(unarchiver);
};

func void _PM_ClassToInst(var string className) {
    var int sym; sym = MEM_FindParserSymbol(ConcatStrings(className, "_UNARCHIVER"));

    if(sym != -1) {
        _PM_ClassToInst_Unarchiver(sym);
        return;
    };

    _PM_ClassToInst_Auto(className);
};

func void _PM_SaveStructToInst() {
    var int sym;
    sym = MEM_GetParserSymbol(_PM_Head.instName);
    var zCPar_Symbol s; s = MEM_PtrToInst(sym);
    s.offset = _PM_Head.currOffs;

    sym = MEM_FindParserSymbol(ConcatStrings(_PM_Head.instName, "_UNARCHIVER"));

    if(sym != -1) {
        _PM_ClassToInst_Unarchiver(sym);
        return;
    };

    _PM_ClassToInst(_PM_Head.className);
};

func void _PM_Unarchive() {
    MEM_Info("=== PermMem::UnArchive ===");

    var int TIME; TIME = MEM_GetSystemTime();
    _PM_DataPoolSize = 0; _PM_DataPoolNum = 0;
    _PM_FreedSize = 0;    _PM_FreedNum    = 0;

    _PM_Mode = 0;

    var string str; str = BR_TextLine();
    if((STR_Len(str) != 11)||STR_Compare("PermMem::v", STR_Prefix(str, 10))) {
        _PM_Error("Keine valide PermMem Speicherdatei.");
        return;
    };


    var int v; v = STR_ToInt(STR_SubStr(str, 10, 1));
    if(v < _PM_Version) {
        _PM_Error("Die PermMem Speicherdatei ist veraltet und kann nicht gelesen werden.");
        return;
    }
    else if(v > _PM_Version) {
        _PM_Error("Die PermMem Speicherdatei ist zu neu für diese Scripte und kann nicht gelesen werden.");
        return;
    };

    BR_NextLine();

    _PM_Reset();
    _PM_Line = 2;

    HandlesPointer = _HT_Create();
    HandlesInstance = _HT_Create();

    var int p; p = MEM_StackPos.position;
    str = _PM_TextLine();
    if(!STR_Compare("HNDL:", STR_Prefix(str, 5))) {
         var int i; i = STR_ToInt(STR_SubStr(str, 5, STR_Len(str)-5));

        PM_CurrHandle = i;

        _PM_ReadSaveStruct();
        _PM_SearchObjCache = "";
        _PM_SaveStructToInst();

        BR_NextLine();
        _PM_Line += 1;

        _HT_Insert(HandlesPointer, _PM_Head.currOffs, i);
        _HT_Insert(HandlesInstance, _PM_Head.inst, i);

        MEM_StackPos.position = p;
    }
    else if(STR_Compare("PermMem::End", str)) {
        _PM_Error(ConcatStrings("Unbekannte Zeile in Speicherdatei. ", str));
        return;
    };

    PM_CurrHandle = 1;
    free(_PM_HeadPtr, _PM_SaveStruct@);
    _PM_HeadPtr = 0;

    _PM_CreateForeachTable();

    MEM_Info(ConcatStrings("buffer used:     ", IntToString(_PM_DataPoolSize)));
    MEM_Info(ConcatStrings("buffer cleaned:  ", IntToString(_PM_FreedSize)));
    MEM_Info(ConcatStrings("objects created: ", IntToString(_PM_DataPoolNum)));
    MEM_Info(ConcatStrings("objects cleaned: ", IntToString(_PM_FreedNum)));
    MEM_Info(ConcatStrings("ellapsed time:   ", IntToString(MEM_GetSystemTime()-TIME)));
    MEM_Info("===        Done        ===");
};

func void _PM_ArchiveError() {
    if(_PM_Mode == 1&&(PM_CurrHandle)) {
        return;
    };
    _PM_Error("Archiverfunktionen dürfen nur innerhalb eines Archivers genutzt werden!");
};

func void _PM_UnarchiveError() {
    if(_PM_Mode == 0&&(PM_CurrHandle)) {
        return;
    };
    _PM_Error("Unarchiverfunktionen dürfen nur innerhalb eines Unarchivers genutzt werden!");
};

func void PM_SaveInt(var string name, var int val) {
    _PM_ArchiveError();
    MEM_ArrayInsert(_PM_Head.content, _PM_NewObjectInt(STR_Upper(name), val));
};

func void PM_SaveFloat(var string name, var int flt) {
    PM_SaveInt(name, flt);
};

func void PM_SaveString(var string name, var string val) {
    _PM_ArchiveError();
    MEM_ArrayInsert(_PM_Head.content, _PM_NewObjectString(STR_Upper(name), val));
};

func void PM_SaveFuncID(var string name, var int fnc) {
    var zCPar_Symbol sym; sym = MEM_PtrToInst(MEM_ReadIntArray(currSymbolTableAddress, fnc));
    PM_SaveString(name, sym.name);
};

func void PM_SaveFuncOffset(var string name, var int fnc) {
    PM_SaveFuncID(name, MEM_GetFuncIDByOffset(fnc));
};

func void PM_SaveFuncPtr(var string name, var int fnc) {
    PM_SaveFuncOffset(name, fnc - currParserStackAddress);
};

func void _PM_SaveClassPtr(var string name, var int ptr, var string className, var int p) {
    _PM_ArchiveError();
    // Das hier ist etwas komplizierter als alles andere.
    // Ich muss zuerst ein Klassenobjekt anlegen, dann den offsPtr vom PM_Head überschreiben (und pushen)
    // und dann den Archiver der gegebenen Klasse überschreiben
    name = STR_Upper(name);
    className = STR_Upper(className);
    if(!ptr) {
        MEM_ArrayInsert(_PM_Head.content, _PM_NewObjectClass(name, className, p, 0));
        return;
    };
    var int nArr; nArr = MEM_ArrayCreate();
    MEM_ArrayInsert(_PM_Head.content, _PM_NewObjectClass(name, className, p, nArr));

    MEM_ArrayPush(_PM_Head.contentStack, _PM_Head.content);
    MEM_ArrayPush(_PM_Head.offsStack, _PM_Head.currOffs);

    _PM_Head.content = nArr;
    _PM_Head.currOffs = ptr;

    _PM_DataToSaveObject("", className);

    _PM_Head.content = MEM_ArrayPop(_PM_Head.contentStack);
    _PM_Head.currOffs = MEM_ArrayPop(_PM_Head.offsStack);
};

func void PM_SaveClassPtr(var string name, var int ptr, var string className) {
    _PM_SaveClassPtr(name, ptr, className, 1);
};

func void PM_SaveClass(var string name, var int ptr, var string className) {
    _PM_SaveClassPtr(name, ptr, className, 0);
};

func void _PM_SaveArray(var string name, var int ptr, var int elements, var int type) {
    _PM_ArchiveError();
    MEM_ArrayInsert(_PM_Head.content, _PM_NewObjectArray(STR_Upper(name), type, elements, ptr));
};

func void PM_SaveIntArray(var string name, var int ptr, var int elements) {
    _PM_SaveArray(name, ptr, elements, _PM_IntArr);
};

func void PM_SaveStringArray(var string name, var int ptr, var int elements) {
    _PM_SaveArray(name, ptr, elements, _PM_StrArr);
};

const int _PM_SearchWarn = 1;
func int _PM_SearchObj(var string name) {
    _PM_UnarchiveError();
    const int last = 0;
    name = STR_Upper(name);
    if(!STR_Compare(_PM_SearchObjCache, name)) {
        return last;
    };
    _PM_SearchObjCache = name;
    var int i; i = 0;
    var zCArray arr; arr = MEM_PtrToInst(_PM_Head.content);
    var int p; p = MEM_StackPos.position;
    if(i < arr.numInArray) {
        var int obj; obj = MEM_ReadIntArray(arr.array, i);
        if(!STR_Compare(_PM_ObjectName(obj), name)) {
            last = obj;
            return obj;
        };
        i += 1;
        MEM_StackPos.position = p;
    };
    if(_PM_SearchWarn) {
        MEM_Warn(ConcatStrings("Objekt konnte nicht gefunden werden. ", name));
    };
    _PM_SearchWarn = 1;
    last = 0;
    return 0;
};

func int PM_Exists(var string name) {
    _PM_SearchWarn = 0;
    return !!_PM_SearchObj(name);
};

func int _PM_Load(var string objName, var int type, var int ptr) {
    locals();
    var int obj; obj = _PM_SearchObj(objName);
    if(!obj) { return 0; };
    if(type == -1) { type = _PM_ObjectType(obj); };
    if((_PM_ObjectType(obj) != type&&type < _PM_IntArr)||(!obj)) {
        MEM_Warn(ConcatStrings("Objekt ist invalid oder Typ stimmt nicht überein. ", objName));
        return 0;
    };
    if(type == _PM_String) {
        if(!ptr) { return 0; };
        var _PM_SaveObject_Str os; os = MEM_PtrToInst(obj);
        MEM_WriteString(ptr, os.content);
        return ptr;
    };
    if(type == _PM_Int) {
        var _PM_SaveObject_Int oi; oi = MEM_PtrToInst(obj);
        if(ptr) {
            MEM_WriteInt(ptr, oi.content);
        };
        return oi.content;
    }
    else if(type == _PM_Class||type == _PM_ClassPtr) {
        var _PM_SaveObject_Cls oc; oc = MEM_PtrToInst(obj);
        if(!STR_Compare(oc.class, "NULL")) {
            return 0;
        };
        if(!ptr) {
            ptr = MEM_Alloc(MEM_ReadInt(MEM_GetParserSymbol(oc.class) + zCParSymbol_offset_offset));
        };
        _PM_ClassToInst_ClassToPtr(obj, ptr);
        return ptr;
    }
    else if(type >= _PM_IntArr) {
        if(!ptr) {
            var _PM_SaveObject_Arr oa; oa = MEM_PtrToInst(obj);
            if(type == _PM_IntArr) {
				if (oa.elements > 0) {
					ptr = MEM_Alloc(oa.elements * 4);
				};
            }
            else {
                ptr = MEM_Alloc(oa.elements * 20);
            };
        };
        _PM_ClassToInst_ArrToPtr(obj, ptr);
        return ptr;
    };
    return 0;
};

func int PM_LoadInt(var string name) {
    return _PM_Load(name, _PM_Int, 0);
};

func int PM_LoadFloat(var string name) {
    PM_LoadInt(name);
};

func string PM_LoadString(var string name) {
    var int obj; obj = _PM_SearchObj(name);
    if(!obj||_PM_ObjectType(obj) != _PM_String) {
        MEM_Warn(ConcatStrings("Objekt ist invalid oder kein String. ", name));
        return "";
    };
    var _PM_SaveObject_Str os; os = MEM_PtrToInst(obj);
    return os.content;
};

func int PM_LoadFuncID(var string name) {
    return MEM_FindParserSymbol(PM_LoadString(name));
};

func int PM_LoadFuncOffset(var string name) {
    var zCPar_Symbol s; s = _^(MEM_ReadIntArray(currSymbolTableAddress, PM_LoadFuncID(name)));
    return s.content;
};

func int PM_LoadFuncPtr(var string name) {
    return PM_LoadFuncOffset(name) + currParserStackAddress;
};

func void PM_LoadClass(var string name, var int destPtr) {
    destPtr = _PM_Load(name, _PM_Class, destPtr);
};

func int PM_LoadClassPtr(var string name) {
    return _PM_Load(name, _PM_ClassPtr, 0);
};

func int PM_LoadArray(var string name) {
    return _PM_Load(name, _PM_IntArr, 0);
};

func void PM_LoadArrayToPtr(var string name, var int destPtr) {
    destPtr = _PM_Load(name, _PM_IntArr, destPtr);
};

func int PM_Load(var string name) {
    return _PM_Load(name, -1, 0);
};

func void PM_LoadToPtr(var string name, var int destPtr) {
    destPtr = _PM_Load(name, -1, destPtr);
};





