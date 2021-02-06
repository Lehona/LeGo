/***********************************\
        KLASSEN FÜR PERMMEM
\***********************************/

/* Inhalt:
    int
    func
    float
    string
    zCList
    zCListSort
    zCArray
 */

class _empty {}; // Empty class used for internal (and bad) purposes
instance _empty@(_empty);
class _int { var int i; };
instance int@(_int);
instance func@(_int);
instance float@(_int);

class _string { var string s; };
instance string@(_string);

/* _string */
func void _string_Archiver(var _string this) {
    PM_SaveString("s", this.s);
    var int symbPtr; symbPtr = GetStringSymbolByAddr(_@s(this.s));
    if (symbPtr) {
        PM_SaveString("symb", MEM_ReadString(symbPtr));
    };
};
func void _string_Unarchiver(var _string this) {
    if (PM_Exists("symb")) {
        var int symbPtr; symbPtr = MEM_GetSymbol(PM_LoadString("symb"));
        if (symbPtr) {
            var zCPar_Symbol symb; symb = _^(symbPtr);
            if ((symb.bitfield & zCPar_Symbol_bitfield_type) == zPAR_TYPE_STRING) {
                MEM_Free(_PM_Head.currOffs);                    // Free the just allocated memory
                _PM_Head.currOffs = symb.content;               // Set the pointer
                this = _^(_PM_Head.currOffs);                   // Update the instance
                MEM_ArrayInsert(HandlesWrapped, PM_CurrHandle); // Mark as manually maintained
            };
        };
    };
    this.s = PM_LoadString("s");
};

/* _int */
func void _int_Archiver(var _int this) {
    PM_SaveInt("i", this.i);
    var int symbPtr; symbPtr = _@(this.i) - zCParSymbol_content_offset;
    if (symbPtr) {
        if (MEM_ReadInt(symbPtr) == zString__vtbl) {
            var string symbName; symbName = MEM_ReadString(symbPtr);
            if (MEM_GetSymbol(symbName) == symbPtr) {
                PM_SaveString("symb", symbName);
            };
        };
    };
};
func void _int_Unarchiver(var _int this) {
    if (PM_Exists("symb")) {
        var int symbPtr; symbPtr = MEM_GetSymbol(PM_LoadString("symb"));
        if (symbPtr) {
            var zCPar_Symbol symb; symb = _^(symbPtr);
            if ((_PM_Head.inst == int@)   && ((symb.bitfield & zCPar_Symbol_bitfield_type) == zPAR_TYPE_INT))
            || ((_PM_Head.inst == float@) && ((symb.bitfield & zCPar_Symbol_bitfield_type) == zPAR_TYPE_FLOAT)) {
                MEM_Free(_PM_Head.currOffs);                    // Free the just allocated memory
                _PM_Head.currOffs = _@(symb.content);           // Set the pointer
                this = _^(_PM_Head.currOffs);                   // Update the instance
                MEM_ArrayInsert(HandlesWrapped, PM_CurrHandle); // Mark as manually maintained
            };
        };
    };
    this.i = PM_LoadInt("i");
};

/*
 * Convenience function to wrap a string variable into a handle to make it persistent.
 * Saved and restored automatically by PermMem without any manual work, the string will remain untouched in its
 * usual behavior and handling.
 *
 * var string myString;
 * PM_BindString(myString);   // Only necessary once
 * myString = "Hello World";  // The string will now maintain its contents over saving and loading
 *
 */
func void PM_BindString(var string var) {
    // On first call: Replace myself and jump back to before I was called (+ parameter)
    MEM_ReplaceFunc(PM_BindString, PM_BindStringSub);
    MEM_SetCallerStackPos(MEM_GetCallerStackPos() - 10); // zPAR_TOK_CALL + 4 bytes + zPAR_TOK_PUSHVAR + 4 bytes
};

/* Same for int */
func void PM_BindInt(var int var) {
    MEM_ReplaceFunc(PM_BindInt, PM_BindIntSub);
    MEM_SetCallerStackPos(MEM_GetCallerStackPos() - 10);
};

/* Same for float */
func void PM_BindFloat(var float var) {
    MEM_ReplaceFunc(PM_BindFloat, PM_BindFloatSub);
    MEM_SetCallerStackPos(MEM_GetCallerStackPos() - 10);
};

const int PM_Bind_addr = 0;
func void PM_Bind(/* var string VAR */ var int inst) {
    var int tok; tok = MEMINT_StackPopInstAsInt();
    PM_Bind_addr = MEMINT_StackPopInstAsInt();
    if (tok != zPAR_TOK_PUSHVAR) {
        _PM_Error("First parameter given is not an lValue");
        return;
    };

    // Check if already stored
    foreachHndl(inst, PM_BindSub);
    if (PM_Bind_addr) {
        wrap(inst, PM_Bind_addr);
    };
};
func int PM_BindSub(var int hndl) {
    if (PM_Bind_addr == getPtr(hndl)) {
        PM_Bind_addr = 0;
        return rBreak;
    };
    return rContinue;
};
func void PM_BindStringSub(/* var string VAR */) {
    PM_Bind(/* VAR */ string@);
};
func void PM_BindIntSub(/* var int VAR */) {
    PM_Bind(/* VAR */ int@);
};
func void PM_BindFloatSub(/* var float VAR */) {
    PM_Bind(/* VAR */ float@);
};

const string zCList_Struct = "auto zCList*";
instance zCList@(zCList);

const string zCListSort_Struct = "auto|2 zCListSort*";
instance zCListSort@(zCListSort);

// zCArray ist zu komplex um als struct dargestellt zu werden.
// Deshalb ein eigener Archiver:
func void zCArray_Archiver(var zCArray this) {
    PM_SaveInt("length", this.numInArray);
    PM_SaveIntArray("array", this.array, this.numInArray);
};

func void zCArray_Unarchiver(var zCArray this) {
    this.numInArray = PM_Load("length");
    this.numAlloc = this.numInArray;
    this.array = PM_Load("array");
};

func void zCArray_Delete(var zCArray this) {
    if(this.array) {
        MEM_Free(this.array);
    };
};

instance zCArray@(zCArray);

// zCViewText - der Font-Pointer muss erneuert werden, dazu speichere ich mir den Namen des Fonts

instance zCViewText@(zCViewText){
	_vtbl = zCViewText_vtbl;
	inPrintWin = 0;
	timer = 0;
	timed = 0;
	colored = 0;
	color = 0;
};

func void zCViewText_Archiver(var zCViewText this) {
	PM_SaveInt("vtbl", this._vtbl);
	PM_SaveInt("posx", this.posx);
	PM_SaveInt("posy", this.posy);
	PM_SaveString("text", this.text);
	PM_SaveString("fontname", Print_GetFontName(this.font));
	PM_SaveInt("timer", this.timer);
	PM_SaveInt("inPrintWin", this.inPrintWin);
	PM_SaveInt("color", this.color);
	PM_SaveInt("timed", this.timed);
	PM_SaveInt("colored",this.colored);
};

func void zCViewText_Unarchiver(var zCViewText this) {
	this._vtbl = PM_LoadInt("vtbl");
	this.posx = PM_LoadInt("posx");
	this.posy = PM_LoadInt("posy");
	this.text = PM_LoadString("text");
	this.font = Print_GetFontPtr(PM_LoadString("fontname"));
	this.timer = PM_LoadInt("timer");
	this.inPrintWin = PM_LoadInt("inPrintWin");
	this.color = PM_LoadInt("color");
	this.timed = PM_LoadInt("timed");
	this.colored = PM_LoadInt("colored");

};

func void zCViewText_Delete(var zCViewText txt) {
	txt.timer = 0;
    txt.timed = 1;

    // Taken from Print_DeleteText()
    var zCView v; v = _^(MEM_Game.array_view[0]);
    var int list; list = _@(v.textLines_data);
    var int offs; offs = List_Contains(list, _@(txt));
    if (offs > 1) {
        List_Delete(list, offs);
    };
};


// zCList<zCViewText*>
class zCList__zCViewText {
    var int zCViewPtr;
    var int next;
};

const string zCList__zCViewText_Struct = "zCViewText* zCList__zCViewText*";

instance zCList__zCViewText@(zCList__zCViewText);
