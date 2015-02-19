const int _render_wld = 0;
var int _render_list;

class RenderItem {
    var int inst;
    var int itmPtr; // oCItem*
    var int view;
    var int view_open;
    var int priority; // standardmäßig 0! TODO: Höhere Priorität = weiter oben oder unten?
};
instance RenderItem@(RenderItem);


func int Render_AddItemPrio(var int itemInst, var int x1, var int y1, var int x2, var int y2, var int priority) {
    var int h; h = new(RenderItem@);
    var RenderItem itm; itm = get(h);
    itm.inst = itemInst;
    itm.view = View_Create(x1, y1, x2, y2);
    itm.priority = priority;
    View_Open(itm.view);
    MEMINT_GetMemHelper(); // Ich sichere mir jetzt Items im MEM_Helper von Ikarus - gute Idee??? // Nein, unbedingt beheben! TODO
    CreateInvItem(MEM_Helper, itemInst);
    itm.itmPtr = _@(item);
    var zCList l; l = get(_render_list);
    if (l.data) {
        List_InsertSorted(getPtr(_render_list), h, _Render_Comparator);
    } else {
        l.data = h;
    };
    return +h;
};

func int Render_AddItem(var int itemInst, var int x1, var int y1, var int x2, var int y2) {
    return +Render_AddItemPrio(itemInst, x1, y1, x2, y2, 0);
};

func int Render_AddViewPrio(var int view, var int priority) {
    var int h; h = new(RenderItem@);
    var RenderItem itm; itm = get(h);
    itm.inst = 0;
    itm.view = view;
    itm.priority = priority;
    itm.view_open = 1;
    itm.itmPtr = 0;
    var zCList l; l = get(_render_list);
    if (l.data) {
        List_InsertSorted(getPtr(_render_list), h, _Render_Comparator);
    } else {
        l.data = h;
    };
    return +h;
};

func int Render_AddView(var int view) {
    return +Render_AddViewPrio(view, 0);
};

func void Render_OpenView(var int ID) {
    var RenderItem itm; itm = get(ID);
    itm.view_open = 1;
    /* Item-Views werden nur gerendert, wenn sie auch offen sind. */
    if (itm.itmPtr) {
        View_Open(itm.view);
    };
};

func void Render_CloseView(var int ID) {
    var RenderItem itm; itm = get(ID);
    itm.view_open = 0;
    /* Item-Views werden nur gerendert, wenn sie auch offen sind. */
    if (itm.itmPtr) {
        View_Close(itm.view);
    };
};

func void Render_Remove(var int ID) {
    var RenderItem itm; itm = get(ID);
    if (itm.view) {
        View_Delete(itm.view);
    };
    MEMINT_GetMemHelper();
    Npc_RemoveInvItem(MEM_Helper, itm.inst); // Alle Gegenstände, die der MEM_Helper hat, werden auch gerade gebraucht.
    List_Delete(getPtr(_render_list), List_Contains(getPtr(_render_list), ID));
    delete(ID);
};


func void _Render_Hook_Sub(var int list) {
    var RenderItem itm;
    var zCList l; l = _^(list);
    if (l.data) {
        itm = get(l.data);
        if (itm.itmPtr) {
            oCItem_Render(itm.itmPtr, _render_wld, View_GetPtr(itm.view), floatNULL);
        } else if ((itm.view_open) && (itm.view)) {
            View_Render(itm.view);
        };
    };
};

// TODO: Neues Spiel -> Neues Spiel crasht noch.
func void _Render_Hook() {
    if (!(getPtr(_render_list))) { return; };
    List_ForF(getPtr(_render_list), _Render_Hook_Sub);
};

func int _Render_Comparator(var int data1, var int data2) {
    var RenderItem itm1; itm1 = get(data1);
    var RenderItem itm2; itm2 = get(data2);
    return (itm1.priority > itm2.priority);
};

func void _Render_RestorePointer_Sub(var int list) {
    // TODO: Nach dieser Funktion hat der Render immer nur 1 Item von jeder Instanz im Inventar, das könnte gehörig schief gehen?
    var RenderItem itm;
    var zCList l; l = _^(list);
    if (l.data) {
        itm = get(l.data);
        if (itm.inst) {
            if (Npc_HasItems(MEM_Helper, itm.inst)) {
                Npc_RemoveInvItems(MEM_Helper, itm.inst, Npc_HasItems(MEM_Helper, itm.inst));
            };
            CreateInvItem(MEM_Helper, itm.inst);
            itm.itmPtr = _@(item);
        };
    };
};

func void _Render_RestorePointer() {
    MEMINT_GetMemHelper();
    List_ForF(getPtr(_render_list), _Render_RestorePointer_Sub);
};

func void _Render_RestorePointer_Listener(var int state) {
    if (state == GAMESTATE_SAVING) {
        _Render_RestorePointer();
    };
};

instance oWorld@(oWorld);
func void _Render_Init() {
    if(_render_wld) { return; };

     HookEngineF(oCGame__RenderX, 6, _Render_Hook);
    // Welt zum Rendern
    _render_wld = create(oWorld@);
    CALL__thiscall(_render_wld, zCWorld__zCWorld);
    var oWorld w; w = MEM_PtrToInst(_render_wld);
    w.m_bIsInventoryWorld = 1;
};