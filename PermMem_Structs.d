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
