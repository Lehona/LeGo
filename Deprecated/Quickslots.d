
const int zCVob_bitfield4_posInQs = ((1 << 5) - 1) << 7;
const int zCVob_bitfield4_amount = ((1 << 16) - 1) << 12;

const int    QS_SlotSize       = 90;                        // Größe des Renders auf dem Bildschirm
const int    QS_DigitMarginX   = 2;                         // Abstand der Nummerierungen vom Rand des Slots
const int    QS_DigitMarginY   = 12;                        // Abstand der Nummerierungen vom Boden des Slots
const int    QS_DigitCol0      = COL_White;                 // Schriftfarbe
const int    QS_DigitCol1      = COL_White;                 // Schriftfarbe
const string QS_DigitFont      = "FONT_UBUNTU_23.TGA";   // Schriftart der Nummerierung
const string QS_SlotBackTex    = "QUICKSLOTS.TGA";          // Hintergrundtextur
const int    QS_SlotBackX      = 512;                       // Breite der Hintergrundtextur
const int    QS_SlotBackY      = 128;                       // Höhe der Hintergrundtextur
const int    QS_SlotBackMargin = 45;                        // Abstand der Mitte des Balkens zum unteren Bildschirmrand
const int    QS_SlotDist       = 50;                        // Abstand der einzelnen Slots horizontal zueinander
const int    QS_SlotDistSep    = 10;                        // Zusatzabstand zwischen Standardwaffen und Zusatzslots

// instance oWorld@(oWorld);

const int _QS_Wld = 0; // oWorld*

var int _QS_Bg;          // zCView(h)
var int _QS_SlotData[9]; // cQS_Slot(h)

var int QSA8;
var int _QS_O;

const int QS_BarWidth = 9 * QS_SlotDist + QS_SlotDistSep;

const int _QS_XDist0 = 0;
const int _QS_YDist0 = 0;
const int _QS_YDist1 = 0;

class cQS_Slot {
    var int v; // zCView(h)
    var int t; // zCViewText(h)
    var int a; // zCViewText(h)
    var int i;
    var int p;
};

instance cQS_Slot@(cQS_Slot);

func void cQS_Slot_Delete(var cQS_Slot this) {
    delete(this.v);
    delete(this.t);
    delete(this.a);
};

var int cQS_Slot_Unarchive_v;
var int cQS_Slot_Unarchive_i;
func void cQS_Slot_Unarchive(var cQS_Slot this) {
    cQS_Slot_Unarchive_v = 0;
    cQS_Slot_Unarchive_i = this.i;
    var oCNpc her; her = Hlp_GetNpc(hero);
    List_ForS(her.inventory2_oCItemContainer_contents, "cQS_Slot_Unarchive_f");
    if(cQS_Slot_Unarchive_v) {
        this.p = cQS_Slot_Unarchive_v;
    }
    else {
        this.i = 0;
        this.p = 0;
    };
};func void cQS_Slot_Unarchive_f(var int node) {
    if(cQS_Slot_Unarchive_v) { return; };
    var oCItem itm; itm = MEM_PtrToInst(MEM_ReadInt(node+4));
    if(itm.instanz != cQS_Slot_Unarchive_i) { return; };
    cQS_Slot_Unarchive_v = MEM_ReadInt(node+4);
};

func void _QS_RenderItem(var int itm, var int slot) {
    if(!itm) { return; };
    var cQS_Slot this; this = get(MEM_ReadStatArr(_QS_SlotData, slot));
    var zCView v; v = View_Get(this.v);
    if(v.vposy < 0||(v.vposy+v.vsizey) > 8191) { return; };
    oCItem_Render(itm, _QS_Wld, View_GetPtr(this.v), floatNULL);
};

var int _QS_AvSlots;
func void _Quickslots_Hook() {
    // MEM_Call(cNI_Loop);

    var zCView vw; vw = View_Get(_QS_Bg);
    vw.alpha = 255;
    View_Render(_QS_Bg);
    vw.alpha = 0;

    var oCItem itm;
    if(Npc_HasReadiedMeleeWeapon(hero)) {
        itm = Npc_GetReadiedWeapon(hero);
        _QS_RenderItem(MEM_InstToPtr(itm), 7);
    }
    else {
        itm = Npc_GetEquippedMeleeWeapon(hero);
        _QS_RenderItem(MEM_InstToPtr(itm), 7);
    };
    if(Npc_HasReadiedRangedWeapon(hero)) {
        itm = Npc_GetReadiedWeapon(hero);
        _QS_RenderItem(MEM_InstToPtr(itm), 8);
    }
    else {
        itm = Npc_GetEquippedRangedWeapon(hero);
        _QS_RenderItem(MEM_InstToPtr(itm), 8);
    };
    var oCNpc her; her = Hlp_GetNpc(hero);
    _QS_AvSlots = 0;
    List_ForS(her.inventory2_oCItemContainer_contents, "_QS_CheckSlots");
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < 7) {
        var cQS_Slot this; this = get(MEM_ReadStatArr(_QS_SlotData, i));
        var int j; j = this.p;
        if(j) {
            if(_QS_AvSlots&(1<<(i+1))) {
                _QS_RenderItem(j, i);
                itm = MEM_PtrToInst(j);
                if(((itm._zCVob_bitfield[4] & zCVob_bitfield4_amount)>>12) != itm.amount) {
                    var zCViewText t; t = Print_GetText(this.a);
                    itm._zCVob_bitfield[4] = (itm._zCVob_bitfield[4]&~zCVob_bitfield4_amount)|((itm.amount<<12)&zCVob_bitfield4_amount); // Überläufe
                    if(itm.amount<2) {
                        t.text = "";
                    }
                    else {
                        var zCView v; v = View_Get(this.v);
                        var string n; n = IntToString(itm.amount);
                        t.posX = Print_ToVirtual(v.pposx + _QS_XDist0 - Print_GetStringWidth(n, QS_DigitFont), PS_X);
                        t.text = n;
                    };
                };
            }
            else {
                this.i = 0;
                this.p = 0;
                t = Print_GetText(this.a);
                t.text = "";
            };
        };
        i += 1;
        MEM_StackPos.position = p;
    };
};

func void _QS_CheckSlots(var int node) {
    var int i; i = MEM_ReadInt(node+4);
    if(!i) { return; };
    var oCItem itm; itm = MEM_PtrToInst(i);
    _QS_AvSlots = _QS_AvSlots | (1<<((itm._zCVob_bitfield[4] & zCVob_bitfield4_posInQs)>>7));
};

func void QS_Init() {
    _QS_XDist0 = (QS_SlotSize/2) + (QS_SlotDist/2) - QS_DigitMarginX;
    _QS_YDist0 = Print_ToVirtual((QS_SlotSize/2)+(QS_SlotDist/2)-QS_DigitMarginY, PS_Y);
    _QS_YDist1 = Print_ToVirtual(QS_SlotDist-(QS_DigitMarginY*2)+Print_GetFontHeight(QS_DigitFont), PS_Y);

    if(!_QS_Wld) {
        _QS_Wld = create(oWorld@);
        CALL__thiscall(_QS_Wld, zCWorld__zCWorld);
        var oWorld w; w = MEM_PtrToInst(_QS_Wld);
        w.m_bIsInventoryWorld = 1;

        // HookEngineF(oCGame__RenderX, 6, _Quickslots_Hook);
        HookEngineF(oCNpc__CloseInventory, 6, _QS_CloseInv);
        HookEngineF(oCNpc__OpenInventory, 6, _QS_OpenInv);
        // Neue Quest: Vernichte die Runenmagie
        MemoryProtectionOverride(7577148, 5);
        MEM_WriteByte(7577148+0, 233/*E9*/);
        MEM_WriteByte(7577148+1, 229/*E5*/);
        MEM_WriteByte(7577148+2, 001/*01*/);
        MEM_WriteByte(7577148+3, 000/*00*/);
        MEM_WriteByte(7577148+4, 000/*00*/);
        // Quest Erfolg: Vernichte die Runenmagie
    };

    if(Hlp_IsValidHandle(_QS_Bg)) { return; };

    var int i; i = 0;
    var int p; p = 0;
    var int m; m = 0;
    var int q; q = 0;
    var int x;
    var int y;
    var int o; o = Print_Screen[PS_X]/2 - QS_BarWidth/2 + (QS_SlotDist>>1);
    var int k; k = Print_Screen[PS_Y] - QS_SlotBackMargin;
    var int s; s = QS_SlotDist;
    var int c1; var cQS_Slot t;

    _QS_Bg = View_CreateCenterPxl(Print_Screen[PS_X]/2, k, QS_SlotBackX, QS_SlotBackY);
    View_SetTexture(_QS_Bg, QS_SlotBackTex);
    View_Open(_QS_Bg);
    var zCView vw; vw = View_Get(_QS_Bg);
    vw.alpha = 0;

    Render_AddViewPrio(_QS_Bg, 100);

    QSA8 = Anim8_NewExt(vw.vposy, QS_A8Handler, 0, false);
    FF_Apply(_QS_FFLoop);
};

func void QS_Hide() {
    var zCView vw; vw = View_Get(_QS_Bg);
    Anim8(QSA8, vw.vposy, 0, A8_Constant);
    Anim8q(QSA8, 8192, 200, A8_SlowEnd);
};

func void QS_Show() {
    var zCView vw; vw = View_Get(_QS_Bg);
    Anim8(QSA8, vw.vposy, 0, A8_Constant);
    Anim8q(QSA8, Print_ToVirtual(Print_Screen[PS_Y] - QS_SlotBackMargin - (QS_SlotBackY>>1), PS_Y), 200, A8_SlowEnd);
};


func void _QS_OpenInv() {
    if(MEM_InstToPtr(hero) != ECX) {
        return;
    };
    QS_Hide();
    _QS_O = 1;
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < 7) {
        var cQS_Slot this; this = get(MEM_ReadStatArr(_QS_SlotData, i));
        var int ptr; ptr = this.p;
        if(ptr) {
            var oCItem itm; itm = MEM_PtrToInst(ptr);
            itm.flags = itm.flags | Item_Active;
        };
        i += 1;
        MEM_StackPos.position = p;
    };
};

func void _QS_CloseInv() {
    if(MEM_InstToPtr(hero) != ECX && !_QS_O) {
        return;
    };
    QS_Show();
    _QS_O = 0;
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < 7) {
        var cQS_Slot this; this = get(MEM_ReadStatArr(_QS_SlotData, i));
        var int ptr; ptr = this.p;
        if(ptr) {
            var oCItem itm; itm = MEM_PtrToInst(ptr);
            itm.flags = itm.flags & ~Item_Active;
        };
        i += 1;
        MEM_StackPos.position = p;
    };
};

func int QS_GetItemSlot(var int oCItemPtr) {
    var oCItem i; i = MEM_PtrToInst(oCItemPtr);
    return ((i._zCVob_bitfield[4] & zCVob_bitfield4_posInQs)>>7)-1;
};

func void QS_ClearSlot(var int id) {
    if((id < 0)||(id > 9)) { return; };
    var cQS_Slot this; this = get(MEM_ReadStatArr(_QS_SlotData, id));
    if(this.p) {
        var oCItem i; i = MEM_PtrToInst(this.p);
        i.flags = i.flags & ~Item_Active;
        i._zCVob_bitfield[4] = i._zCVob_bitfield[4] & ~zCVob_bitfield4_posInQs;
    };
    this.p = 0;
    this.i = 0;
    var zCViewText t; t = Print_GetText(this.a);
    t.text = "";
};

func void QS_SetItemSlot(var int oCItemPtr, var int id) {
    if((id < 0)||(id > 9)) { return; };
    QS_ClearSlot(id);
    if(QS_GetItemSlot(oCItemPtr)+1) {
        QS_ClearSlot(QS_GetItemSlot(oCItemPtr));
    };
    var oCItem i; i = MEM_PtrToInst(oCItemPtr);
    i.flags = i.flags | Item_Active;
    i._zCVob_bitfield[4] = (i._zCVob_bitfield[4] & ~zCVob_bitfield4_posInQs) | ((id+1) << 7);
    var cQS_Slot this; this = get(MEM_ReadStatArr(_QS_SlotData, id));
    this.p = MEM_InstToPtr(i);
    this.i = i.instanz;
};

func int QS_GetSlotItem(var int id) {
    if((id < 0)||(id > 9)) { return 0; };
    var cQS_Slot this; this = get(MEM_ReadStatArr(_QS_SlotData, id));
    return this.p;
};

func void _QS_FFLoop() {
    var cQS_Slot this;
    var int j;
    var int k;
    var int l;

    if(_QS_O) {
        var oCNpc her; her = Hlp_GetNpc(hero);
        if(her.inventory2_oCItemContainer_selectedItem != -1) {
            var int iPtr; iPtr = List_GetS(her.inventory2_oCItemContainer_contents, her.inventory2_oCItemContainer_selectedItem+2);
            var oCItem i; i = MEM_PtrToInst(iPtr);

            var int key; key = KEY_4;
            var int item; item = 0;

            var int p; p = MEM_StackPos.position;
            if(key <= KEY_0) {
                if(MEM_KeyState(key) == KEY_PRESSED) {
                    if(QS_GetItemSlot(iPtr) == item) {
                        QS_ClearSlot(item);
                    }
                    else {
                        QS_SetItemSlot(iPtr, item);
                    };
                };
                item += 1;
                key += 1;
                MEM_StackPos.position = p;
            };
        };
    }
    else {
        key = KEY_4;
        item = 0;

        p = MEM_StackPos.position;
        if(key <= KEY_0) {
            if(MEM_KeyState(key) == KEY_PRESSED) {
                j = QS_GetSlotItem(item);
                if(j) {
                    i = MEM_PtrToInst(j);
                    AI_StandUpQuick(hero);
                    AI_RemoveWeapon(hero);
                    if(i.mainflag == Item_Kat_Rune) {
                        AI_ReadySpell(hero, SPL_FullHeal, SPL_Cost_FullHeal);
                    }
                    else if((i.mainflag != Item_Kat_NF)&&(i.mainflag != Item_Kat_FF)) {
                        AI_UseItem(hero, Hlp_GetInstanceID(i));
                    }
                    else {
                        AI_Function_II(hero, oCNpc_Equip, MEM_InstToPtr(hero), j);
                    };
                    if(!Npc_IsInFightMode(hero, FMode_None)) {
                        if((i.mainflag == Item_Kat_NF)||(Npc_HasReadiedMeleeWeapon(hero))) {
                            AI_ReadyMeleeWeapon(hero);
                        }
                        else if((i.mainflag == Item_Kat_FF)||(Npc_HasReadiedRangedWeapon(hero))) {
                            AI_ReadyRangedWeapon(hero);
                        }
                        else {
                            AI_ReadyMeleeWeapon(hero);
                        };
                    };
                };
            };
            item += 1;
            key += 1;
            MEM_StackPos.position = p;
        };
    };
};

func void QS_A8Handler(var int v) {
    var int k; var int l;
    var int j; var int p;
    var cQS_Slot this;

    View_MoveTo(_QS_Bg, -1, v);
    v += Print_ToVirtual((QS_SlotBackY - QS_SlotSize)/2, PS_Y);
    k = v+_QS_YDist0;
    l = k-_QS_YDist1;
    j = 0;
    p = MEM_StackPos.position;
    if(j < 9) {
        this = get(MEM_ReadStatArr(_QS_SlotData, j));
        View_MoveTo(this.v, -1, v);
        var zCViewText txt;
        txt = Print_GetText(this.t); txt.posY = l;
        txt = Print_GetText(this.a); txt.posY = k;

        j += 1;
        MEM_StackPos.position = p;
    };
};




