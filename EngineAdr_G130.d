/***********************************\
       ADRESSEN DER ENGINECALLS
\***********************************/
//========================================
// Talents Aivar field
//========================================
const int AIV_TALENT_INDEX = 69;
//========================================
// Alle (?) genutzen Engineadressen
//========================================
const int CGameManager__ApplySomeSettings           = 4354928; //0x427370
const int CGameManager__Read_Savegame               = 4365600; //0x429D20 Hook: Saves
const int CloseHandle                               = 8028816; //0x7A8290
const int CreateFileA                               = 8028912; //0x7A82F0
const int Cursor_Ptr                                = 9187332; //0x8C3004
const int Cursor_sX                                 = 8962016; //0x88BFE0
const int Cursor_sY                                 = 8962020; //0x88BFE4
const int GetFileSize                               = 8028936; //0x7A8308
const int GetLastError                              = 8029020; //0x7A835C
const int oCGame__changeLevel                       = 6727264; //0x66A660 Hook: Saves
const int oCGame__changeLevelEnd                    = 6729052; //0x66AD5C Hook: Saves
const int oCGame__Render                            = 6732080; //0x66B930 Hook: FrameFunctions
const int oCGame__RenderX                           = 6732427; //0x66BA8B Hook: Quickslots
const int oCGame__UpdateStatus                      = 6713157; //0x666F45 Hook: Focusnames
const int oCGame__UpdateStatus_start                = 6710848; //0x666640 Hook: Bars
const int oCGame__UpdateScreenResolution            = 6710016; //0x666300 unused, kept for compatibility
const int oCGame__UpdateScreenResolution_end        = 6710768; //0x6665F0 Hook: Bars
const int oCItem__Render                            = 7035440; //0x6B5A30
const int oCNpc__CloseInventory                     = 7352019; //0x702ED3 Hook: Quickslots
const int oCNpc__DropUnconscious                    = 7173968; //0x6D7750 Hook: Shields
const int oCNpc__Equip                              = 7189840; //0x6DB550
const int oCNpc__EquipItem                          = 7159568; //0x6D3F10 Hook: Shields
const int oCNpc__EquipWeapon                        = 7190640; //0x6DB870
const int oCNpc__EV_DrawWeapon                      = 7266032; //0x6EDEF0 Hook: Shields
const int oCNpc__EV_DrawWeapon1                     = 7267696; //0x6EE570 Hook: Shields
const int oCNpc__EV_PlayAni                         = 7310464; //0x6F8C80 Hook: AI_Function
const int oCNpc__EV_RemoveWeapon                    = 7269808; //0x6EEDB0 Hook: Shields
const int oCNpc__EV_RemoveWeapon1                   = 7272160; //0x6EF6E0 Hook: Shields
const int oCNpc__OpenInventory                      = 7351568; //0x702D10 Hook: Quickslots
const int oCNpc__PutInSlot                          = 7254448; //0x6EB1B0
const int oCNpc__RemoveFromSlot                     = 7255792; //0x6EB6F0
const int oCNpc__UnequipItem                        = 7160208; //0x6D4190 Hook: Shields
const int oCNpc__UseItem                            = 7197776; //0x6DD450
const int oCNpc__StartDialogAniX                    = 7311499; //0x6F908B
const int oCNpc__StartDialogAniY                    = 7311506; //0x6F9092
const int oCNpc__GetPerceptionFunc                  = 7337088; //0x6FF480
const int oCSavegameManager__SetAndWriteSavegame    = 4426453; //0x438AD5 Hook: Saves
const int oCSavegameManager__SetAndWriteSavegame_bp_offset = 60;
const int parser                                    = ContentParserAddress; //
const int ReadFile                                  = 8221930; //0x7D74EA
const int screen                                    = 9985968; //0x985FB0
const int sysGetTimePtr                             = 5252496; //0x502590
const int WriteFile                                 = 8028918; //0x7A82F6
const int zCAICamera_StartDialogCam                 = 4914112; //0x4AFBC0
const int zCAICamera__current                       = 9176152; //0x8C0458
const int zCAICamera__StartDialogCam                = 4914112; //0x4AFBC0
const int zCAICamera__StartDialogCam_oldInstr       = -529989782;
const int zCFontMan__GetFont                        = 7506544; //0x728A70
const int zCFontMan__Load                           = 7506064; //0x728890
const int zCFont__GetFontName                       = 7510624; //0x729A60
const int zCFont__GetFontX                          = 7510704; //0x729AB0
const int zCFont__GetFontY                          = 7510688; //0x729AA0
const int zCViewText_vtbl                           = 8581740; //0x82F26C
const int zCInput_zinput                            = 9187320; //0x8C2FF8
const int zCInput_Win32__SetDeviceEnabled           = 5057344; //0x4D2B40
const int zCInput_Win32__GetMouseButtonPressedLeft  = 5059024; //0x4D31D0
const int zCInput_Win32__GetMouseButtonPressedMid   = 5059040; //0x4D31E0
const int zCInput_Win32__GetMouseButtonPressedRight = 5059056; //0x4D31F0
const int zCInput_Win32__GetMousePos                = 5058928; //0x4D3170
const int zCParser__CreateInstance                  = 7550304; //0x733560
const int zCParser__CreatePrototype                 = 7550544; //0x733650
const int zCParser__DoStack                         = 7544608; //0x731F20
const int zCRenderer__DrawTile                      = 6082880; //0x5CD140
const int zCTexture__Load                           = 6211824; //0x5EC8F0
const int zCView__@zCView                           = 7625920; //0x745CC0
const int zCView__Close                             = 7631664; //0x747330
const int zCView__InsertBack                        = 7628336; //0x746630
const int zCView__Move                              = 7633888; //0x747BE0
const int zCView__Open                              = 7631104; //0x747100
const int zCView__Render                            = 7653136; //0x74C710
const int zCView__SetFontColor                      = 7642640; //0x749E10
const int zCView__SetSize                           = 7634080; //0x747CA0
const int zCView__zCView                            = 7625728; //0x745C00
const int zCView_Top                                = 7629968; //0x746C90
const int zCView__PrintTimed_color                  = 7635576; //0x748278 Hook: Interface
const int zCView__PrintTimedCX_color                = 7635901; //0x7483BD Hook: Interface
const int zCView__PrintTimedCY_color                = 7636106; //0x74848A Hook: Interface
const int zCView__PrintTimedCXY_color               = 7636470; //0x7485F6 Hook: Interface
const int zCView__PrintTimed_colored                = 7635600; //0x748290 Hook: Interface
const int zCView__PrintTimedCX_colored              = 7635921; //0x7483D1 Hook: Interface
const int zCView__PrintTimedCY_colored              = 7636122; //0x74849A Hook: Interface
const int zCView__PrintTimedCXY_colored             = 7636486; //0x748606 Hook: Interface
const int zCWorld__zCWorld                          = 6390512; //0x6182F0
const int zFontMan                                  = 9979164; //0x98451C
const int zParser__CallFunc                         = 7548848; //0x732FB0
const int zrenderer_adr                             = 9815992; //0x95C7B8
const int zRND_D3D__DrawLine                        = 7742272; //0x762340
const int zRND_D3D__DrawPolySimple                  = 7730832; //0x75F690
const int zRND_D3D__EndFrame                        = 7743872; //0x762980 Hook: Sprite
const int zRND_D3D__SetAlphaBlendFunc               = 7756976; //0x765CB0
const int zCRnd_D3D__XD3D_SetRenderState            = 7706960; //0x759950
const int zRND_D3D_TexMemory_offset                 = 1208;
const int zSinCosApprox                             = 6241488; //0x5F3CD0
const int T_DIALOGGESTURE_                          = 9066848; //0x8A5960
const int _atan2f                                   = 8073430; //0x7B30D6
const int _sinf                                     = 8073536; //0x7B3140
const int _acosf                                    = 8073420; //0x7B30CC
const int menu_savegame_slot_offset                 = 3276;
const int sub_4D3D90_X                              = 5053243; //0x4D1B3B Hook: Cursor
const int zCConsole__Register                       = 7483552; //0x7230A0
const int zCConsoleOutputOverwriteAddr              = 6762406; //0x672FA6 Hook: ConsoleCommands
const int zCOption__ParmValue                       = 4605776; //0x464750
const int zCOptions_dir_string_offset               = 124;     //0x7C     // The class zCOption is defined incorrectly in Ikarus for Gothic1!
const int zCWorld__AdvanceClock                     = 6416720; //0x61E950 Hook: Draw3D
const int zlineCache                                = 9198784; //0x8C5CC0
const int zCLineCache__Line3D                       = 5277344; //0x5086A0
const int zTBSphere3D__Draw                         = 5501248; //0x53F140
const int zTBBox3D__Draw                            = 5508288; //0x540CC0
const int zCOBBox3D__Draw                           = 5512016; //0x541B50
const int zcon_address_lego							= 9978792; //0x9843A8 //zcon_address is defined in Ikarus but only for Gothic2!
const int malloc_adr                                = 8028070; //0x7A7FA6
const int free_adr                                  = 8028076; //0x7A7FAC
const int memcpy_adr                                = 8162912; //0x7C8E60
const int zString__vtbl                             = 8521456; //0x8206F0

//========================================
// More class offsets
//========================================
const int zCParser_datastack_stack_offset =   88; //0x0058
const int zCParser_datastack_sptr_offset  = 4184; //0x1058
const int oCMsgConversation_name_offset   =   88; //0x0058

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
// Globale Flagvariable
//========================================
const int _LeGo_Flags = 0;

//========================================
// Missing Item flag
//========================================
const int ITEM_ACTIVE_LEGO = 1 << 30; // Not defined in Gothic 1. Necessary for EquipWeapon()

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
    MemoryProtectionOverride(9985912, 10);
    if (inst) {
        MEM_WriteInt(9985912, inst);
        MEM_WriteInt(9985916, MEM_ReadInt(inst+zCParSymbol_offset_offset));
    } else {
        MEM_WriteInt(9985912, 0);
        MEM_WriteInt(9985916, 0);
    };
};

func int MEM_GetUseInstance() {
    return MEM_ReadInt(9985912);
};
