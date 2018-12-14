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
        if (!PM_Exists(c)) {
            return;
        };
        MEM_ArrayInsert(this, PM_LoadFuncID(c));
        i += 1;
    end;
};

//========================================
// Event erstellen
//========================================
func int EventPtr_Create() {
    return create(lCEvent);
};
func int Event_Create() {
    return new(lCEvent);
};

//========================================
// Event löschen
//========================================
func void EventPtr_Delete(var int ptr) {
    free(ptr, lCEvent);
};
func void Event_Delete(var int h) {
    delete(h);
};

//========================================
// Hat das Event Listener?
//========================================
func int EventPtr_Empty(var int ptr) {
    return (MEM_ArraySize(ptr) <= 0);
};
func int Event_Empty(var int h) {
    return EventPtr_Empty(getPtr(h));
};

//========================================
// Event auf Listener prüfen
//========================================
func int EventPtr_HasI(var int ptr, var int id) {
    return (MEM_ArrayIndexOf(ptr, id) >= 0);
};
func int EventPtr_Has(var int ptr, var func handler) {
    return EventPtr_HasI(ptr, MEM_GetFuncID(handler));
};
func int Event_Has(var int h, var func handler) {
    return EventPtr_HasI(getPtr(h), MEM_GetFuncID(handler));
};

//========================================
// Listener hinzufügen
//========================================
func void EventPtr_AddI(var int ptr, var int id) {
    MEM_ArrayInsert(ptr, id);
};
func void EventPtr_Add(var int ptr, var func handler) {
    EventPtr_AddI(ptr, MEM_GetFuncID(handler));
};
func void Event_Add(var int h, var func handler) {
    EventPtr_AddI(getPtr(h), MEM_GetFuncID(handler));
};

//========================================
// Listener einmalig hinzufügen
//========================================
func void EventPtr_AddOnceI(var int ptr, var int id) {
    if (!EventPtr_HasI(ptr, id)) {
        EventPtr_AddI(ptr, id);
    };
};
func void EventPtr_AddOnce(var int h, var func handler) {
    EventPtr_AddOnceI(getPtr(h), MEM_GetFuncID(handler));
};
func void Event_AddOnce(var int h, var func handler) {
    EventPtr_AddOnceI(getPtr(h), MEM_GetFuncID(handler));
};

//========================================
// Listener entfernen
//========================================
func void EventPtr_RemoveI(var int ptr, var int id) {
    MEM_ArrayRemoveValueOnce(ptr, id);
};
func void EventPtr_Remove(var int h, var func handler) {
    EventPtr_RemoveI(getPtr(h), MEM_GetFuncID(handler));
};
func void Event_Remove(var int h, var func handler) {
    EventPtr_RemoveI(getPtr(h), MEM_GetFuncID(handler));
};

//========================================
// Event feuern
//========================================
func void EventPtr_Execute(var int ptr, var int d) {
    var zCArray a; a = _^(ptr);
    var int i; i = 0;
    while(i < a.numInArray);
        d;
        MEM_CallByID(MEM_ReadIntArray(a.array, i));
        i += 1;
    end;
};
func void Event_Execute(var int h, var int d) {
    EventPtr_Execute(getPtr(h), d);
};
