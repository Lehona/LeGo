/***********************************\
              TRIALOGE
\***********************************/

//========================================
// EquipWeapon von Sektenspinner
//  Wer diese Funktion schon besitzt kann
//  sie hier einfach auskommentieren
//========================================
/* EquipWeapon_TogglesEquip configure the behaviour
   when trying to equip an already equipped weapon:
    0: EquipWeapon will do nothing
    1: EquipWeapon will unequip this weapon
 */
const int EquipWeapon_TogglesEquip = 1;

func void EquipWeapon (var C_NPC slf, var int ItemInst) {

    if (!Npc_HasItems (slf, ItemInst)) {
        CreateInvItems (slf, ItemInst, 1);
    };

    if (!Npc_GetInvItem(slf, ItemInst)) {
        MEM_AssertFail("Unexpected behaviour in EquipWeapon.");
        return;
    };

    if ((item.mainflag == ITEM_KAT_NF) && (Npc_HasReadiedMeleeWeapon(slf)))
    || ((item.mainflag == ITEM_KAT_FF) && (Npc_HasReadiedRangedWeapon(slf))) {
        MEM_Warn ("EquipWeapon: Caller wants to equip a weapon while weapon of the same type is readied. Ignoring request.");
        return;
    };

    if (item.flags & ITEM_ACTIVE_LEGO)
    && (!EquipWeapon_TogglesEquip) {
        /* calling EquipWeapon would unequip the weapon. */
        MEM_Info ("EquipWeapon: This weapon is already equipped. Ignoring request.");
        return;
    };

    CALL_PtrParam(MEM_InstToPtr(item));
    CALL__thiscall(MEM_InstToPtr(slf), oCNpc__EquipWeapon);
};

//========================================
// Hilfsfunktionen
//========================================
func int Npc_GetArmor(var c_npc slf) {
    if(!Npc_HasEquippedArmor(slf)) { return -1; };
    var c_item itm; itm = Npc_GetEquippedArmor(slf);
    return Hlp_GetInstanceID(itm);
};
func int Npc_GetMeleeWeapon(var c_npc slf) {
    if(!Npc_HasEquippedMeleeWeapon(slf)) { return 0; };
    var c_item itm; itm = Npc_GetEquippedMeleeWeapon(slf);
    return Hlp_GetInstanceID(itm);
};
func int Npc_GetRangedWeapon(var c_npc slf) {
    if(!Npc_HasEquippedRangedWeapon(slf)) { return 0; };
    var c_item itm; itm = Npc_GetEquippedRangedWeapon(slf);
    return Hlp_GetInstanceID(itm);
};

//========================================
// Userkonstanten
//========================================

const int TRIA_MaxNPC = 256; // Wie viele Npcs nehmen maximal an einem Trialog teil?

//========================================
// Dialogkamera neu einstellen
//========================================
func void DiaCAM_Update() {
    // Diese Funktion wurde von Sektenspinner niedergeschrieben.
    if(InfoManager_HasFinished()) { return; };
    var int aiCam; aiCam = MEM_ReadInt(zCAICamera__current);
    CALL_IntParam(1);
    CALL__thiscall(aiCam, zCAICamera_StartDialogCam);
};

//========================================
// Dialogkamera abschalten
//========================================
func void DiaCAM_Disable() {
    MemoryProtectionOverride(zCAICamera__StartDialogCam, 4);
    MEM_WriteInt(zCAICamera__StartDialogCam, 268436674); // retn 4
};

//========================================
// Dialogkamera einschalten
//========================================
func void DiaCAM_Enable() {
    MemoryProtectionOverride(zCAICamera__StartDialogCam, 4);
    MEM_WriteInt(zCAICamera__StartDialogCam, zCAICamera__StartDialogCam_oldInstr);
};


//========================================
// [intern] Variablen
//========================================
var int TRIA_NpcPtr[TRIA_MaxNPC]; // Sammlung aller Teilnehmer
var int TRIA_Running;             // Läuft ein Trialog?
var int TRIA_CPtr;                // Zähler für die Sammlung
var int TRIA_Last;                // Der Npc der zuletzt gesprochen hat
var int TRIA_Self;                // Pointer auf self
var string TRIA_Camera;           // Läuft eine Kamerafahrt?

func void ZS_TRIA() {};
func int ZS_TRIA_Loop() {
    if (InfoManager_hasFinished()) { // Im Zustand bleiben bis Dialog fertig
        return LOOP_END;
    } else {
        return LOOP_CONTINUE;
    };
};

//========================================
// Npcs aufeinander warten lassen
//========================================
func void TRIA_Wait() {
    AI_WaitTillEnd(hero, self);
    AI_WaitTillEnd(self, hero);
    AI_WaitTillEnd(hero, self);
};

//========================================
// [intern] Visuals aktualisieren
//========================================
func void _TRIA_UpdateVisual(var c_npc slf, var int armor) {
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    
	Mdl_SetVisualBody(
        slf,
        npc.body_visualName,
        (npc.bitfield[0]&oCNpc_bitfield0_body_TexVarNr)>>14,
        (npc.bitfield[1]&oCNpc_bitfield1_body_TexColorNr),
        npc.head_visualName,
        (npc.bitfield[1]&oCNpc_bitfield1_head_TexVarNr)>>16,
        (npc.bitfield[2]&oCNpc_bitfield2_teeth_TexVarNr),
        armor);
};

//========================================
// Angelegte Waffe tauschen
//========================================
func void Npc_TradeItem(var c_npc slf, var int itm0, var int itm1) {
    if(itm0) {
        EquipWeapon(slf, itm0);
        Npc_RemoveInvItem(slf, itm0);
    };
    if(itm1) {
        CreateInvItem(slf, itm1);
        EquipWeapon(slf, itm1);
    };
};

//========================================
// [intern] Npcs kopieren
//========================================
class _TRIA_fltWrapper {
    var float f0;
    var float f1;
    var float f2;
    var float f3;
};

func void _TRIA_Copy(var int n0, var int n1) {
    var c_npc np0; np0 = MEM_PtrToInst(n0);
    var c_npc np1; np1 = MEM_PtrToInst(n1);
    var oCNpc onp0; onp0 = MEM_PtrToInst(n0);
    var oCNpc onp1; onp1 = MEM_PtrToInst(n1);
    var int a0; a0 = Npc_GetArmor(np0);
    var int a1; a1 = Npc_GetArmor(np1);
    var _TRIA_fltWrapper fn0; fn0 = MEM_PtrToInst(_@(onp0.model_scale));
    var _TRIA_fltWrapper fn1; fn1 = MEM_PtrToInst(_@(onp1.model_scale));
    MEM_SwapBytes(n0+60,                       n1+60,                      64);                          // trafo
    MEM_SwapBytes(n0+MEM_NpcName_Offset,       n1+MEM_NpcName_Offset,      MEMINT_SwitchG1G2(272, 312)); // name, voice
    MEM_SwapBytes(_@(onp0.bitfield),           _@(onp1.bitfield),          20);                          // bitfield
    MEM_SwapBytes(_@s(onp0.mds_name),          _@s(onp1.mds_name),         76);                          // visuals
	MEM_SwapBytes(_@(onp0._zCVob_bitfield),    _@(onp1._zCVob_bitfield),   20);                          // vob bitfield
	MEM_SwapBytes(_@(onp0._zCVob_visualAlpha), _@(onp1._zCVob_visualAlpha), 4);
    Mdl_SetModelScale(np0, fn0.f0, fn0.f1, fn0.f2);
    Mdl_SetModelScale(np1, fn1.f0, fn1.f1, fn1.f2);
    Mdl_SetModelFatness(np0, fn0.f3);
    Mdl_SetModelFatness(np1, fn1.f3);
    _TRIA_UpdateVisual(np0, a1);
    _TRIA_UpdateVisual(np1, a0);
    Npc_RemoveInvItem(np0, a0);
    Npc_RemoveInvItem(np1, a1);
    var int mw0; mw0 = Npc_GetMeleeWeapon(np0);
    var int rw0; rw0 = Npc_GetRangedWeapon(np0);
    var int mw1; mw1 = Npc_GetMeleeWeapon(np1);
    var int rw1; rw1 = Npc_GetRangedWeapon(np1);
    Npc_TradeItem(np0, mw0, mw1);
    Npc_TradeItem(np0, rw0, rw1);
    Npc_TradeItem(np1, mw1, mw0);
    Npc_TradeItem(np1, rw1, rw0);
};

//========================================
// [intern] Kopieren.
//========================================
func void _TRIA_CopyNpc(var int slf) {
    if(slf == TRIA_Last) {
        return;
    };
    if(slf == TRIA_Self) {
        _TRIA_Copy(TRIA_Self, TRIA_Last);
    }
    else if(TRIA_Last == TRIA_Self) {
        _TRIA_Copy(TRIA_Self, slf);
    }
    else {
        _TRIA_Copy(TRIA_Self, TRIA_Last);
        _TRIA_Copy(TRIA_Self, slf);
    };
    TRIA_Last = slf;
};

//========================================
// [intern] Npcs einstellen
//========================================
func void _TRIA_InitNPC(var c_npc slf) {
    Npc_ClearAIQueue(slf);
    AI_StandUp(slf);
    AI_StopLookAt(slf);
    AI_RemoveWeapon(slf);
    AI_TurnToNpc(slf, hero);
    AI_WaitTillEnd(hero, slf);
    AI_StartState(slf, ZS_TRIA, 0, "");
};

//========================================
// Npc in das Gespräch einladen
//========================================
func void TRIA_Invite(var c_npc slf) {
    if(TRIA_Running) {
        MEM_Warn("TRIA_Invite: Der Trialog läuft bereits.");
        return;
    };
    if(TRIA_CPtr == TRIA_MaxNPC) {
        MEM_Error("TRIA_Invite: Zu viele Npcs. Erhöhe bitte TRIA_MaxNPC.");
        return;
    };
    if(Hlp_GetInstanceID(slf) == Hlp_GetInstanceID(hero)
    || Hlp_GetInstanceID(slf) == Hlp_GetInstanceID(self)) {
        MEM_Warn("TRIA_Invite: Der Held und/oder Self können nicht eingeladen werden. Sie sind bereits anwesend.");
        return;
    };
    if((Npc_GetDistToNpc(slf, hero) > truncf(MEM_ReadInt(SPAWN_INSERTRANGE_Address)))
    || (Npc_IsDead(slf))
    || (!Hlp_IsValidNpc(slf))) {
        MEM_Error(ConcatStrings("TRIA_Invite: Der Npc ist nicht in der KI-Glocke und/oder tot: ", slf.name));
        return;
    };
    MEM_WriteStatArr(TRIA_NpcPtr, TRIA_CPtr, MEM_InstToPtr(slf));
    TRIA_CPtr += 1;
};

//========================================
// Trialog starten
//========================================
func void TRIA_Start() {
    if(TRIA_Running) {
        MEM_Warn("TRIA_Start: Es läuft bereits ein Trialog.");
        return;
    };
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < TRIA_CPtr) {
        var c_npc slf; slf = MEM_PtrToInst(MEM_ReadStatArr(TRIA_NpcPtr, i));
        _TRIA_InitNpc(slf);
        i += 1;
        MEM_StackPos.position = p;
    };

    // Npc_ClearAIQueue(self); //Mit diesem Befehl beendet sich der Dialog nicht richtig, daher auskommentiert. Ich habe Angst, dass ich irgendwas anderes kaputt gemacht habe, aber bisher konnte ich keine Probleme feststellen.
    Npc_ClearAIQueue(hero);
    Ai_Output(hero,self,"");

    var c_npc selfCopy; selfCopy = Hlp_GetNpc(self);
    self = MEM_NullToInst();
    TRIA_Invite(selfCopy);
    self = Hlp_GetNpc(selfCopy);
    TRIA_Wait();
    TRIA_Last = MEM_InstToPtr(self);
    TRIA_Self = TRIA_Last;
    TRIA_Running = 1;
};

//========================================
// Alle Npcs aufeinander warten lassen
//========================================
func void TRIA_Barrier() {
    if(!TRIA_Running) {
        MEM_Warn("TRIA_Next: Kein Trialog gestartet.");
        return;
    };
    TRIA_Wait();
    var int i; i = !1;
    var int j; j = 0;
    var c_npc last; last = MEM_PtrToInst(MEM_ReadStatArr(TRIA_NpcPtr, TRIA_CPtr)); // Ist immer self, aber so ist es verständlicher
    var int p; p = MEM_StackPos.position;
    if(i < TRIA_CPtr) {
        var c_npc curr; curr = MEM_PtrToInst(MEM_ReadStatArr(TRIA_NpcPtr, i));
        AI_WaitTillEnd(curr, last);
        last = Hlp_GetNpc(curr);
        i += 1;
        MEM_StackPos.position = p;
    };
    if(!j) {
        j = 1; i = 0;
        MEM_StackPos.position = p;
    };
};

//========================================
// Den nächsten Npc als "self" setzen
//========================================
func void TRIA_Next(var c_npc n0) {
    if(!TRIA_Running) {
        MEM_Warn("TRIA_Next: Kein Trialog gestartet.");
        return;
    };
    if(Hlp_GetInstanceID(n0) == Hlp_GetInstanceID(hero)) {
        MEM_Warn("TRIA_Next: 'hero' ist kein erlaubter Parameter für diese Funktion.");
        return;
    };

    var int i; i = 0;
    var int j; j = MEM_InstToPtr(n0);
    var int p; p = MEM_StackPos.position;
    if(i < TRIA_CPtr) {
        if(MEM_ReadStatArr(TRIA_NpcPtr, i) != j) {
            i += 1;
            MEM_StackPos.position = p;
        };
    };
    if(i == TRIA_CPtr) {
        MEM_Error(ConcatStrings("TRIA_Next: Der Npc ist nicht eingeladen worden: ", n0.name));
        return;
    };

    TRIA_Wait();
    AI_Function_I(hero, _TRIA_Next, j);
};
func void _TRIA_Next(var int n0) {
    _TRIA_CopyNpc(n0);
};

//========================================
// Kamerafahrt starten
//========================================
func void TRIA_Cam(var string evt) {
    TRIA_Wait();
    if(!STR_Len(evt)) {
        if(!STR_Len(TRIA_Camera)) { return; };
        AI_Function_S(hero, _TRIA_Uncam, TRIA_Camera);
    }
    else {
        if(STR_Len(TRIA_Camera)) {
            AI_Function_S(hero, Wld_SendUntrigger, TRIA_Camera);
        };
        AI_Function_S(hero, _TRIA_Cam, evt);
    };
    TRIA_Camera = evt;
};
func void _TRIA_Cam(var string evt) {
    DiaCAM_Disable();
    Wld_SendTrigger(evt);
};
func void _TRIA_Uncam(var string evt) {
    DiaCAM_Enable();
    DiaCAM_Update();
    Wld_SendUntrigger(evt);
};

//========================================
// Trialog abschließen
//========================================
func void TRIA_Finish() {
    if(!TRIA_Running) {
        MEM_Warn("TRIA_Finish: Kein Trialog gestartet.");
        return;
    };
    TRIA_Wait();
    TRIA_Cam("");
    AI_Function(hero, _TRIA_Finish);
};
func void _TRIA_Finish() {
    if(TRIA_Last != TRIA_Self) {
        _TRIA_Copy(TRIA_Self, TRIA_Last);
    };
    var int i; i = 0;
    var int p; p = MEM_StackPos.position;
    if(i < TRIA_CPtr-1) {
        var c_npc slf; slf = MEM_PtrToInst(MEM_ReadStatArr(TRIA_NpcPtr, i));
        //AI_ContinueRoutine(slf);
        i += 1;
        MEM_StackPos.position = p;
    };
    TRIA_Running = 0;
    TRIA_CPtr = 0;
};

