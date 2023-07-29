/***********************************\
       ADRESSEN DER ENGINECALLS
\***********************************/
//========================================
// Talents Aivar field
//========================================
const int AIV_TALENT_INDEX = 49;
//========================================
// Alle (?) genutzen Engineadressen
//========================================
const int CGameManager__ApplySomeSettings           = 4362720; //0x4291E0
const int CGameManager__Read_Savegame               = 6696288; //0x662D60 Hook: Saves //Here: oCGame::LoadSavegame!
const int CloseHandle                               = 7984960; //0x79D740
const int CreateFileA                               = 7985014; //0x79D776
const int Cursor_Ptr                                = 9119656; //0x8B27A8
const int Cursor_sX                                 = 8896860; //0x87C15C
const int Cursor_sY                                 = 8896864; //0x87C160
const int GetFileSize                               = 7985056; //0x79D7A0
const int GetLastError                              = 7985110; //0x79D7D6
const int oCGame__changeLevel                       = 6699344; //0x663950 Hook: Saves
const int oCGame__changeLevelEnd                    = 6701276; //0x6640DC Hook: Saves
const int oCGame__Render                            = 6703344; //0x6648F0 Hook: FrameFunctions
const int oCGame__RenderX                           = 6703515; //0x66499B
const int oCGame__UpdateStatus                      = 6684160; //0x65FE00 Hook: Focusnames
const int oCGame__UpdateStatus_start                = 6681824; //0x65F4E0 Hook: Bars
const int oCGame__UpdateScreenResolution            = 6680992; //0x65F1A0 unused, kept for compatibility
const int oCGame__UpdateScreenResolution_end        = 6681744; //0x65F490 Hook: Bars
const int oCItem__Render                            = 6949408; //0x6A0A20
const int oCNpc__CloseInventory                     = 7275012; //0x6F0204 Hook: Quickslots

const int oCNpc__Equip                              = 7111744; //0x6C8440

const int oCNpc__EquipWeapon                        = 7112560; //0x6C8770


const int oCNpc__EV_PlayAni                         = 7233728; //0x6E60C0 Hook: AI_Function


const int oCNpc__OpenInventory                      = 7274400; //0x6EFFA0 Hook: Quickslots | Hook:Inv

const int oCNpc__PutInSlot                          = 7177280; //0x6D8440 - ported
const int oCNpc__RemoveFromSlot                     = 7178720; //0x6D89E0
const int oCNpc__UnequipItem                        = 7080128; //0x6C08C0 Hook: Shields

const int oCNpc__StartDialogAniX                    = 7234894; //0x6E654E
const int oCNpc__StartDialogAniY                    = 7234901; //0x6E6555
const int oCNpc__GetPerceptionFunc                  = 7259456; //0x6EC540
const int oCSavegameManager__SetAndWriteSavegame    = 4431637; //0x439F15 Hook: Saves
const int oCSavegameManager__SetAndWriteSavegame_bp_offset = 60;
const int parser                                    = ContentParserAddress; //
const int ReadFile                                  = 8179862; //0x7CD096
const int screen                                    = 9593876; //0x926414
const int sysGetTimePtr                             = 5280720; //0x5093D0
const int WriteFile                                 = 7985020; //0x79D77C
const int zCAICamera_StartDialogCam                 = 4946992; //0x4B7C30
const int zCAICamera__current                       = 9108300; //0x8AFB4C
const int zCAICamera__StartDialogCam                = 4946992; //0x4B7C30
const int zCAICamera__StartDialogCam_oldInstr       = -110559382;
const int zCFontMan__GetFont                        = 7435936; //0x7176A0
const int zCFontMan__Load                           = 7435424; //0x7174A0
const int zCFont__GetFontName                       = 7440320; //0x7187C0
const int zCFont__GetFontX                          = 7440416; //0x718820
const int zCFont__GetFontY                          = 7440400; //0x718810
const int zCViewText_vtbl                           = 8526364; //0x821A1C
const int zCInput_zinput                            = 9119640; //0x8B2798
const int zCInput_Win32__SetDeviceEnabled           = 5080800; //0x4D86E0




const int zCParser__CreateInstance                  = 7482384; //0x722C10

const int zCParser__DoStack                         = 7476656; //0x7215B0
const int zCRenderer__DrawTile                      = 6076896; //0x5CB9E0
const int zCTexture__Load                           = 6190000; //0x5E73B0
const int zCView__@zCView                           = 7561280; //0x736040
const int zCView__Close                             = 7566944; //0x737660
const int zCView__InsertBack                        = 7563744; //0x7369E0
const int zCView__Move                              = 7569200; //0x737F30
const int zCView__Open                              = 7566400; //0x737440
const int zCView__Render                            = 7589312; //0x73CDC0
const int zCView__SetFontColor                      = 7578496; //0x73A380
const int zCView__SetSize                           = 7569392; //0x737FF0
const int zCView__zCView                            = 7561088; //0x735F80
const int zCView_Top                                = 7565264; //0x736FD0
const int zCView__PrintTimed_color                  = 7570936; //0x7385F8 Hook: Interface
const int zCView__PrintTimedCX_color                = 7571297; //0x738761 Hook: Interface
const int zCView__PrintTimedCY_color                = 7571514; //0x73883A Hook: Interface
const int zCView__PrintTimedCXY_color               = 7571908; //0x7389C4 Hook: Interface
const int zCView__PrintTimed_colored                = 7570960; //0x738610 Hook: Interface
const int zCView__PrintTimedCX_colored              = 7571319; //0x738777 Hook: Interface
const int zCView__PrintTimedCY_colored              = 7571530; //0x73884A Hook: Interface
const int zCView__PrintTimedCXY_colored             = 7571924; //0x7389D4 Hook: Interface
const int zCWorld__zCWorld                          = 6369728; //0x6131C0
const int zFontMan                                  = 9587032; //0x924958
const int zParser__CallFunc                         = 7480928; //0x722660
const int zrenderer_adr                             = 9485712; //0x90BD90
const int zRND_D3D__DrawLine                        = 7678576; //0x752A70
const int zRND_D3D__DrawPolySimple                  = 7668160; //0x7501C0
const int zRND_D3D__EndFrame                        = 7680208; //0x7530D0 Hook: Sprite
const int zRND_D3D__SetAlphaBlendFunc               = 7692592; //0x756130
const int zCRnd_D3D__XD3D_SetRenderState            = 7685808; //0x7546B0
const int zRND_D3D_TexMemory_offset                 = 1204;
const int zSinCosApprox                             = 6219344; //0x5EE650
const int T_DIALOGGESTURE_                          = 8972180; //0x88E794


const int _acosf                                    = 5586476; //0x553E2C _acosf does not exist: End of Alg_AngleUnitRad is equivalent
const int menu_savegame_slot_offset                 = 3276;
const int sub_4D3D90_X                              = 5078742; //0x4D7ED6 Hook: Cursor
const int zCConsole__Register                       = 7411152; //0x7115D0
const int zCConsoleOutputOverwriteAddr              = 6735734; //0x66C776 Hook: ConsoleCommands
const int zcon_address_lego                         = 9586648; //0x9247D8 // zcon_address is defined in Ikarus but only for Gothic2!
const int malloc_adr                                = 7984870; //0x79D6E6
const int free_adr                                  = 7984783; //0x79D68F
const int memcpy_adr                                = 8124416; //0x7BF800
const int zCOptions_dir_string_offset               = 124;     //0x7C     // The class zCOption is defined incorrectly in Ikarus for Gothic1!
const int zCOption__ParmValue                       = 4617536; //0x467540
const int zCWorld__AdvanceClock                     = 6392880; //0x618C30 Hook: Draw3D
const int zlineCache                                = 9130432; //0x8B51C0
const int zCLineCache__Line3D                       = 5303120; //0x50EB50
const int zTBSphere3D__Draw                         = 5533120; //0x546DC0
const int zTBBox3D__Draw                            = 5540080; //0x5488F0
const int zCOBBox3D__Draw                           = 5544048; //0x549870
const int zString__vtbl                             = 8468188; //0x8136DC

//========================================
// More class offsets
//========================================
const int zCParser_datastack_stack_offset =   88; //0x0058
const int zCParser_datastack_sptr_offset  = 4184; //0x1058
const int oCMsgConversation_name_offset   =   96; //0x0060

//========================================
// More assembly op codes
//========================================
// 2 Bytes
const int ASMINT_OP_subESPplus      =   60547; //0xEC83
// 3 Bytes
const int ASMINT_OP_movEAXtoESPplus = 2376841; //0x244489
const int ASMINT_OP_movESPplusToEAX = 2376843; //0x24448B
const int ASMINT_OP_pushESPplus     = 2389247; //0x2474FF

//========================================
// Missing Item flag
//========================================
const int ITEM_ACTIVE_LEGO = 1 << 30; // Not defined in Gothic 1. Necessary for EquipWeapon()

//========================================
// Globale Flagvariable
//========================================
const int _LeGo_Flags = 0;

//========================================
// Namen einer Textur holen
//========================================
func string zCTexture_GetName(var int ptr) { // Eigentlich gar kein Engine-Call
    if(!ptr) { return ""; };
    var zCObject obj; obj = MEM_PtrToInst(ptr);
    return obj.objectName;
};

//========================================
// Pointer auf eine Textur holen
//========================================
func int zCTexture_Load(var string texture) {
    CALL_IntParam(1);
    CALL_zStringPtrParam(texture);
    CALL__cdecl(zCTexture__Load);
    return CALL_RetValAsInt();
};

//========================================
// FontManager holen
//========================================
func int zCFontMan_Load(var string font) {
    CALL_zStringPtrParam(font);
    CALL__Thiscall(MEM_ReadInt(zFontMan), zCFontMan__Load);
    return CALL_RetValAsInt();
};

//========================================
// Pointer auf eine Font holen
//========================================
func int Print_GetFontPtr(var string font) {
    var int i; i = zCFontMan_Load(font);
    CALL_IntParam(i);
    CALL__Thiscall(MEM_ReadInt(zFontMan), zCFontMan__GetFont);
    return CALL_RetValAsInt();
};

//========================================
// Namen einer Font holen
//========================================
func string Print_GetFontName(var int fontPtr) {
    CALL_RetValIszString();
    CALL__Thiscall(fontPtr, zCFont__GetFontName);
    return CALL_RetValAszString();
};

//========================================
// Breite eines Strings holen
//========================================
func int Print_GetStringWidthPtr(var string s, var int font) {
    CALL_zStringPtrParam(s);
    CALL__Thiscall(font, zCFont__GetFontX);
    return CALL_RetValAsInt();
};
func int Print_GetStringWidth(var string s, var string font) {
    return Print_GetStringWidthPtr(s, Print_GetFontPtr(font));
};

//========================================
// Höhe einer Font holen
//========================================
func int Print_GetFontHeight(var string font) {
    var int adr; adr = Print_GetFontPtr(font);
    CALL__thiscall(adr, zCFont__GetFontY);
    return CALL_RetValAsInt();
};

//========================================
// Beliebigen Waypoint holen
//========================================
func int MEM_GetAnyWPPtr() {
    var zCWaynet wayNet; wayNet = MEM_PtrToInst(MEM_World.wayNet);
    return MEM_ReadInt(wayNet.wplist_next+4);
};

func string MEM_GetAnyWP() {
    var zCWaypoint wp; wp = _^(MEM_GetAnyWPPtr());
    return wp.name;
};

//========================================
// Item an Koordinaten einfügen
//========================================
func void MEM_InsertItem(var c_item itm, var int fX, var int fY, var int fZ) {
    var zCWaynet wayNet; wayNet = MEM_PtrToInst(MEM_World.wayNet);
    var zCWaypoint wp; wp = MEM_PtrToInst(MEM_ReadInt(wayNet.wplist_next+4));
    var int x; x = wp.pos[0];
    var int y; y = wp.pos[1];
    var int z; z = wp.pos[2];
    wp.pos[0] = fX;
    wp.pos[1] = fY;
    wp.pos[2] = fZ;
    Wld_InsertItem(Hlp_GetInstanceID(itm), wp.name);
    wp.pos[0] = x;
    wp.pos[1] = y;
    wp.pos[2] = z;
};

//========================================
// Vob an Npc hängen
//========================================
func int oCNpc_PutInSlot(var c_npc slf, var string SlotName, var int oCVobPtr, var int SlotID) {
    CALL_IntParam(SlotID);
    CALL_PtrParam(oCVobPtr);
    CALL_zStringPtrParam(SlotName);
    CALL__thiscall(MEM_InstToPtr(slf), oCNpc__PutInSlot);
    return CALL_RetValAsInt();
};

//========================================
// Vob von Npc entfernen
//========================================
func void oCNpc_RemoveFromSlot(var c_npc slf, var string SlotName, var int retVal, var int SlotID) {
    CALL_IntParam(SlotID);
    CALL_PutRetValTo(_@(retVal));
    CALL_zStringPtrParam(SlotName);
    CALL__thiscall(MEM_InstToPtr(slf), oCNpc__RemoveFromSlot);
};

//========================================
// Item ablegen
//========================================
func void oCNpc_UnequipItem(var c_npc slf, var int oCItemPtr) {
    CALL_PtrParam(oCItemPtr);
    CALL__thiscall(MEM_InstToPtr(slf), oCNpc__UnequipItem);
};

//========================================
// Ein Item auf einem View rendern
//========================================
func void oCItem_Render(var int itm, var int wld, var int view, var int rot) {
    var zCView v; v = _^(view);
    if(v.vposy < 0||(v.vposy+v.vsizey) > 8192) { return; };
    if(v.vposy < 0||(v.vposy+v.vsizey) > 8192) { return; };
    CALL_FloatParam(rot);
    CALL_PtrParam(view);
    CALL_PtrParam(wld);
    CALL__thiscall(itm, oCItem__Render);
};

//========================================
// <funktioniert nicht?>
//========================================
func void zCRenderer_DrawTile(var int this,
                              var int tex,
                              var int vec0x, var int vec0y,
                              var int vec1x, var int vec1y,
                              var int flt,
                              var int vec2x, var int vec2y,
                              var int vec3x, var int vec3y,
                              var int color) {
    const int vec = 0;
    if(!vec) {
        vec = MEM_Alloc(8);
    };
    CALL_IntParam(color);
    CALL_PtrParam(vec);
    CALL_PtrParam(vec);
    CALL_FloatParam(flt);
    CALL_PtrParam(vec);
    MEM_WriteInt(vec+0, vec0x);
    MEM_WriteInt(vec+4, vec0y);
    CALL_PtrParam(vec);
    CALL_PtrParam(tex);
    CALL__thiscall(this, zCRenderer__DrawTile);
};

//========================================
// Beliebiges Item anlegen
//========================================
func void oCNpc_Equip(var int npcPtr, var int itmPtr) {
    CALL_PtrParam(itmPtr);
    CALL__thiscall(npcPtr, oCNpc__Equip);
};

//========================================
// Aktuelle Instanz bearbeiten
//========================================
func void MEM_SetUseInstance(var int inst) {
    MemoryProtectionOverride(9593816, 10);
    if (inst) {
        MEM_WriteInt(9593816, inst);
        MEM_WriteInt(9298300, MEM_ReadInt(inst+zCParSymbol_offset_offset));
    } else {
        MEM_WriteInt(9593816, 0);
        MEM_WriteInt(9298300, 0);
    };
};

func int MEM_GetUseInstance() {
    return MEM_ReadInt(9593816);
};
