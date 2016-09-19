/***********************************\
                 LIST
\***********************************/

//========================================
// [intern] Error
//========================================
func void _List_Err(var string fnc, var string msg) {
    var int s; s = SB_New();
    SB("List_");
    SB(fnc);
    SB(": ");
    SB(msg);
    MEM_Error(SB_ToString());
    SB_Destroy();
};
func void _List_ErrPtr(var string fnc) {
    _List_Err(fnc, "No valid pointer");
};
func void _List_ErrLen(var string fnc) {
    _List_Err(fnc, "Nr is greater than the list");
};
func void _List_ErrNum(var string fnc, var int n) {
    _List_Err(fnc, ConcatStrings("Nr must be at least ", IntToString(n)));
};

//========================================
// Ende einer Liste (Node)
//========================================
func int List_End(var int list) {
    if(!list) {
        _List_ErrPtr("End");
        return 0;
    };
    var zCList l; l = _^(list);
    while(l.next);
        l = _^(l.next);
    end;
    return _@(l);
};

func int List_EndS(var int list) {
    if(!list) {
        _List_ErrPtr("EndS");
        return 0;
    };
    var zCListSort l; l = _^(list);
    while(l.next);
        l = _^(l.next);
    end;
    return _@(l);
};

//========================================
// Länge einer Liste
//========================================
func int List_Length(var int list) {
    if(!list) {
        _List_ErrPtr("Length");
        return 0;
    };
    var zCList l; l = _^(list);
    var int i; i = 1;
    while(l.next);
        l = _^(l.next);
        i += 1;
    end;
    return i;
};

func int List_LengthS(var int list) {
    if(!list) {
        _List_ErrPtr("LengthS");
        return 0;
    };
    var zCListSort l; l = _^(list);
    var int i; i = 1;
    while(l.next);
        l = _^(l.next);
        i += 1;
    end;
    return i;
};

//========================================
// Länge einer Liste erfragen (schneller)
//========================================
func int List_HasLength(var int list, var int len) {
    if(!list) {
        _List_ErrPtr("Length");
        return 0;
    };
    if(len == 1) {
        return 1;
    };
    var zCList l; l = _^(list);
    var int i; i = 1;
    while(l.next);
        l = _^(l.next);
        i += 1;
        if(i == len) {
            return 1;
        };
    end;
    return 0;
};

func int List_HasLengthS(var int list, var int len) {
    if(!list) {
        _List_ErrPtr("Length");
        return 0;
    };
    if(len == 1) {
        return 1;
    };
    var zCListSort l; l = _^(list);
    var int i; i = 1;
    while(l.next);
        l = _^(l.next);
        i += 1;
        if(i == len) {
            return 1;
        };
    end;
    return 0;
};

//========================================
// Node einer Liste (Node)
//========================================
func int List_Node(var int list, var int nr) {
    if(!list) {
        _List_ErrPtr("Node");
        return 0;
    };
    var zCList l; l = _^(list);
    var int i; i = 1;
    while(i < nr);
        if(!l.next) {
            _List_ErrLen("Node");
            return 0;
        };
        list = l.next;
        l = _^(list);
        i += 1;
    end;
    return list;
};

func int List_NodeS(var int list, var int nr) {
    if(!list) {
        _List_ErrPtr("NodeS");
        return 0;
    };
    var zCListSort l; l = _^(list);
    var int i; i = 1;
    while(i < nr);
        if(!l.next) {
            _List_ErrLen("NodeS");
            return 0;
        };
        l = _^(l.next);
        i += 1;
    end;
    return _@(l);
};


//========================================
// Objekt an die Liste anfügen
//========================================
func void List_Add(var int list, var int data) {
    if(!list) {
        _List_ErrPtr("Add");
        return;
    };
    var zCList l; l = _^(List_End(list));
    l.next = create(zCList@);
    l = _^(l.next);
    l.data = data;
};

func void List_AddS(var int list, var int data) {
    if(!list) {
        _List_ErrPtr("AddS");
        return;
    };
    var zCListSort l; l = _^(List_EndS(list));
    l.next = create(zCListSort@);
    l = _^(l.next);
    l.data = data;
};

//========================================
// Node aus Liste löschen
//========================================
func void List_Delete(var int list, var int nr) {
    if(!list) {
        _List_ErrPtr("Delete");
        return;
    };
    if(nr == 1) {
        var zCList l; l = _^(list);
        l.data = 0;
        return;
    };
    if (nr < 1) {
        _List_ErrNum("Delete", 1);
        return;
    };
    var int p; p = List_Node(list, nr-1);
    if(!p) { return; };
    var zCList prev; prev = _^(p);
    if(!prev.next) {
        _List_ErrLen("Delete");
        return;
    };
    var zCList del; del = _^(prev.next);
    prev.next = del.next;
    MEM_Free(_@(del));
};

func void List_DeleteS(var int list, var int nr) {
    if(!list) {
        _List_ErrPtr("DeleteS");
        return;
    };
    if(nr == 1) {
        var zCListSort l; l = _^(list);
        l.data = 0;
        return;
    };
    if (nr < 1) {
        _List_ErrNum("DeleteS", 1);
        return;
    };
    var int p; p = List_NodeS(list, nr-1);
    if(!p) { return; };
    var zCListSort prev; prev = _^(p);
    if(!prev.next) {
        _List_ErrLen("DeleteS");
        return;
    };
    var zCListSort del; del = _^(prev.next);
    prev.next = del.next;
    MEM_Free(_@(del));
};

//========================================
// Liste komplett zerstören
//========================================
func void List_Destroy(var int list) {
    if(!list) {
        _List_ErrPtr("Destroy");
        return;
    };
    var zCList l; l = _^(list);
    while(l.next);
        var int n; n = l.next;
        MEM_Free(_@(l));
        l = _^(n);
    end;
};

func void List_DestroyS(var int list) {
    if(!list) {
        _List_ErrPtr("DestroyS");
        return;
    };
    var zCListSort l; l = _^(list);
    while(l.next);
        var int n; n = l.next;
        MEM_Free(_@(l));
        l = _^(n);
    end;
};

//========================================
// Funktion auf eine Liste anwenden
//========================================
func void List_ForF(var int list, var func fnc) {
    if(!list) {
        _List_ErrPtr("ForF");
        return;
    };
    var zCList l;
    while(list);
        l = _^(list);
        list;
        MEM_Call(fnc);
        list = l.next;
    end;
};
func void List_For(var int list, var string fnc) {
    if(!list) {
        _List_ErrPtr("For");
        return;
    };
    var int f; f = MEM_FindParserSymbol(STR_Upper(fnc));
    var zCList l;
    while(list);
        l = _^(list);
        list;
        MEM_CallByID(f);
        list = l.next;
    end;
};

func void List_ForFS(var int list, var func fnc) {
    if(!list) {
        _List_ErrPtr("ForFS");
        return;
    };
    var zCListSort l;
    while(list);
        l = _^(list);
        list;
        MEM_Call(fnc);
        list = l.next;
    end;
};
func void List_ForS(var int list, var string fnc) {
    if(!list) {
        _List_ErrPtr("ForS");
        return;
    };
    var int f; f = MEM_FindParserSymbol(STR_Upper(fnc));
    var zCListSort l;
    while(list);
        l = _^(list);
        list;
        MEM_CallByID(f);
        list = l.next;
    end;
};

//========================================
// Liste in zCArray umwandeln
//========================================
func int List_ToArray(var int list) {
    if(!list) {
        _List_ErrPtr("ToArray");
        return 0;
    };
    var int n; n = List_Length(list);
    var int a; a = MEM_ArrayCreate();
    if(!n) {
        return a;
    };
    var zCList l;
    while(list);
        l = _^(list);
        MEM_ArrayInsert(a, l.data);
        list = l.next;
    end;
    return a;
};

func int List_ToArrayS(var int list) {
    if(!list) {
        _List_ErrPtr("ToArrayS");
        return 0;
    };
    var int n; n = List_LengthS(list);
    var int a; a = MEM_ArrayCreate();
    if(!n) {
        return a;
    };
    var zCListSort l;
    while(list);
        l = _^(list);
        MEM_ArrayInsert(a, l.data);
        list = l.next;
    end;
    return a;
};

//========================================
// Data an einem Offset erhalten
//========================================
func int List_Get(var int list, var int nr) {
    if(!list) {
        _List_ErrPtr("Get");
        return 0;
    };
    var zCList l; l = _^(List_Node(list, nr));
    return l.data;
};

func int List_GetS(var int list, var int nr) {
    if(!list) {
        _List_ErrPtr("GetS");
        return 0;
    };
    var zCListSort l; l = _^(List_NodeS(list, nr));
    return l.data;
};

//========================================
// Data einer Node setzen
//========================================
func int List_Set(var int node, var int data) {
    if(!node) {
        _List_ErrPtr("Set");
        return 0;
    };
    var zCList l; l = _^(node);
    l.data = data;
};

func int List_SetS(var int node, var int data) {
    if(!node) {
        _List_ErrPtr("SetS");
        return 0;
    };
    var zCListSort l; l = _^(node);
    l.data = data;
};

//========================================
// Nach Data suchen
//========================================
func int List_Contains(var int list, var int data) {
    if(!list) {
        _List_ErrPtr("Contains");
        return 0;
    };
    var zCList l;
    var int i; i = 1;
    while(list);
        l = _^(list);
        if(l.data == data) {
            return i;
        };
        i += 1;
        list = l.next;
    end;
    return 0;
};

func int List_ContainsS(var int list, var int data) {
    if(!list) {
        _List_ErrPtr("ContainsS");
        return 0;
    };
    var zCListSort l;
    var int i; i = 1;
    while(list);
        l = _^(list);
        if(l.data == data) {
            return i;
        };
        i += 1;
        list = l.next;
    end;
    return 0;
};

//========================================
// Data an einem Offset einfügen
//========================================
func void List_AddOffset(var int list, var int offset, var int data) {
    if(!list) {
        _List_ErrPtr("AddOffset");
        return;
    };
    if(offset <= 1) {
        _List_ErrNum("AddOffset", 2);
        return;
    };
    var int p; p = List_Node(list, offset-1);
    if(!p) {
        return;
    };
    var zCList prev; prev = _^(p);
    if(!prev.next) {
        _List_ErrLen("AddOffset");
        return;
    };
    var int n; n = create(zCList@);
    var zCList next; next = _^(n);
    next.data = data;
    next.next = prev.next;
    prev.next = n;
};

func void List_AddOffsetS(var int list, var int offset, var int data) {
    if(!list) {
        _List_ErrPtr("AddOffsetS");
        return;
    };
    if(offset <= 1) {
        _List_ErrNum("AddOffsetS", 2);
        return;
    };
    var int p; p = List_NodeS(list, offset-1);
    if(!p) {
        return;
    };
    var zCListSort prev; prev = _^(p);
    if(!prev.next) {
        _List_ErrLen("AddOffsetS");
        return;
    };
    var int n; n = create(zCListSort@);
    var zCListSort next; next = _^(n);
    next.data = data;
    next.next = prev.next;
    prev.next = n;
};

//========================================
// Node nach unten bewegen
//========================================
func void List_MoveDown(var int list, var int offset) {
    if(!list) {
        _List_ErrPtr("MoveDown");
        return;
    };
    if(offset <= 2) {
        _List_ErrNum("MoveDown", 3);
        return;
    };
    var int l0, var int l1, var int l2;
    var zCList zl0, var zCList zl1, var zCList zl2;
    l0 = List_Node(list, offset-2);
    if(!l0) { return; };
    zl0 = _^(l0);
    if(!zl0.next) {    _List_ErrLen("MoveDown"); return; };
    l1 = zl0.next;
    zl1 = _^(l1);
    if(!zl1.next) { _List_ErrLen("MoveDown"); return; };
    l2 = zl1.next;
    zl2 = _^(l2);
    zl0.next = l2;
    zl1.next = zl2.next;
    zl2.next = l1;
};

func void List_MoveDownS(var int list, var int offset) {
    if(!list) {
        _List_ErrPtr("MoveDownS");
        return;
    };
    if(offset <= 2) {
        _List_ErrNum("MoveDownS", 3);
        return;
    };
    var int l0, var int l1, var int l2;
    var zCListSort zl0, var zCListSort zl1, var zCListSort zl2;
    l0 = List_NodeS(list, offset-2);
    if(!l0) { return; };
    zl0 = _^(l0);
    if(!zl0.next) {    _List_ErrLen("MoveDownS"); return; };
    l1 = zl0.next;
    zl1 = _^(l1);
    if(!zl1.next) { _List_ErrLen("MoveDownS"); return; };
    l2 = zl1.next;
    zl2 = _^(l2);
    zl0.next = l2;
    zl1.next = zl2.next;
    zl2.next = l1;
};

//========================================
// Node nach oben bewegen
//========================================
func void List_MoveUp(var int list, var int offset) {
    List_MoveDown(list, offset+1);
};

func void List_MoveUpS(var int list, var int offset) {
    List_MoveDownS(list, offset+1);
};

//========================================
// Liste erstellen
//========================================
func int List_Create(var int data) {
    var int ptr; ptr = create(zCList@);
    var zCList l; l = _^(ptr);
    l.data = data;
    l.next = 0;
    return ptr;
};

func int List_CreateS(var int data) {
    var int ptr; ptr = create(zCListSort@);
    var zCListSort l; l = _^(ptr);
    l.data = data;
    l.next = 0;
    return ptr;
};

//========================================
// Listen verketten
//========================================
func void List_Concat(var int list0, var int list1) {
    if((!list0)||(!list1)) {
        _List_ErrPtr("Concat");
        return;
    };
    var zCList l; l = _^(List_End(list0));
    l.next = list1;
};

func void List_ConcatS(var int list0, var int list1) {
    if((!list0)||(!list1)) {
        _List_ErrPtr("ConcatS");
        return;
    };
    var zCListSort l; l = _^(List_EndS(list0));
    l.next = list1;
};

//========================================
// In eine sortierte Liste einfügen
//========================================
func int List_Compare(var int data1, var int data2, var func compare) { // True if data1 > data2
    data1;
    data2;
    MEM_Call(compare);
};

func int List_CmpAscending(var int data1, var int data2) {
	return data1 > data2;
};

func int List_CmpDescending(var int data1, var int data2) {
	return data1 < data2;
};

func void List_InsertSorted(var int list, var int data, var func compare) {
    if(!list) {
        _List_ErrPtr("InsertSorted");
        return;
    };

    var zCList lp; var zCList ln; lp = _^(list);
    var int lptr; lptr = create(zClist@);
    var zCList lnew; lnew = _^(lptr);

    if (List_Compare(lp.data, data, compare)) { // In this case data is smaller than the first node, so I have to insert the data and swap values to preserve the pointer
        lnew.next = lp.next;
        lp.next = lptr;
        lnew.data = lp.data;
        lp.data = data;
        return;
    };

    while(lp.next); // while there is a next node
        ln = _^(lp.next);
        if (List_Compare(ln.data, data, compare)) {
            /* ln.data is bigger, but lp.data isn't, so I have to insert it inbetween! */
            lnew.next = lp.next;
            lp.next = lptr;
            lnew.data = data;
            return;
        };
        lp = _^(lp.next);
    end;
    /* this means even the last node is smaller than data */
    lp.next = lptr;
    lnew.data = data;
};


func void List_InsertSortedS(var int list, var int data, var func compare) {
    if(!list) {
        _List_ErrPtr("InsertSortedS");
        return;
    };

    var zCListSort lp; var zCListSort ln; lp = _^(list);
    var int lptr; lptr = create(zCListSort@);
    var zCListSort lnew; lnew = _^(lptr);

    if (List_Compare(lp.data, data, compare)) { // In this case data is smaller than the first node, so I have to insert the data and swap values to preserve the pointer
        lnew.next = lp.next;
        lp.next = lptr;
        lnew.data = lp.data;
        lp.data = data;
        return;
    };

    while(lp.next); // while there is a next node
        ln = _^(lp.next);
        if (List_Compare(ln.data, data, compare)) {
            /* ln.data is bigger, but lp.data isn't, so I have to insert it inbetween! */
            lnew.next = lp.next;
            lp.next = lptr;
            lnew.data = data;
            return;
        };
        lp = _^(lp.next);
    end;
    /* this means even the last node is smaller than data */
    lp.next = lptr;
    lnew.data = data;
};














