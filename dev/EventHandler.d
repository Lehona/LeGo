/***********************************\
             EVENTHANDLER
\***********************************/

//========================================
// [intern] PermMem Klasse
//========================================
instance lCEvent(zCArray);

func void lCEvent_Archiver(var zCArray this) {
    var int i; i = 0;
    while(i < this.numInArray);
        PM_SaveFuncID(ConcatStrings("handler", IntToString(i)), MEM_ReadIntArray(this.array, i));
        i += 1;
    end;
};

func void lCEvent_Unarchiver(var zCArray arr) {
    var int i; i = 0;
    var int this; this = MEM_InstToPtr(arr);
    while(true);
        var string c; c = ConcatStrings("handler", IntToString(i));
        if(!PM_Exists(c)) {
            return;
        };
        MEM_ArrayInsert(this, PM_LoadFuncID(c));
        i += 1;
    end;
};

//========================================
// Event erstellen
//========================================
func int Event_Create() {
    return new(lCEvent);
};

//========================================
// Event löschen
//========================================
func void Event_Delete(var int h) {
    delete(h);
};

//========================================
// Listener hinzufügen
//========================================
func void Event_Add(var int h, var func handler) {
    MEM_ArrayInsert(getPtr(h), MEM_GetFuncID(handler));
};

//========================================
// Listener einmalig hinzufügen
//========================================
func void Event_AddOnce(var int h, var func handler) {
    var int id; id = MEM_GetFuncID(handler);
    if(MEM_ArrayIndexOf(getPtr(h), id) == -1) {
        MEM_ArrayInsert(getPtr(h), id);
    };
};

//========================================
// Listener entfernen
//========================================
func void Event_Remove(var int h, var func handler) {
    MEM_ArrayRemoveValueOnce(getPtr(h), MEM_GetFuncID(handler));
};

//========================================
// Event feuern
//========================================
func void Event_Execute(var int h, var int d) {
    var zCArray a; a = get(h);
    var int i; i = 0;
    while(i < a.numInArray);
        d;
        MEM_CallByID(MEM_ReadIntArray(a.array, i));
        i += 1;
    end;
};