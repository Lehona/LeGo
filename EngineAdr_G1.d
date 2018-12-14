var int YouHaveToDeleteOneOfTheEngineAdrFilesInTheLeGoDirectory;


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
const int CGameManager__ApplySomeSettings           = 4351936; //
const int CGameManager__Read_Savegame               = 4361040; //0x428B50 Hook: Saves
const int CloseHandle                               = 7712294; //
const int CreateFileA                               = 7712348; //
const int Cursor_Ptr                                = 8834220; //0x86CCAC
const int Cursor_sX                                 = 8611128; //0x836538
const int Cursor_sY                                 = 8611132; //0x83653C
const int GetFileSize                               = 7712378; //
const int GetLastError                              = 7712444; //
const int oCGame__changeLevel                       = 6540640; //0x63CD60 Hook: Saves
const int oCGame__changeLevelEnd                    = 6542428; //0x63D45C Hook: Saves
const int oCGame__Render                            = 6544352; //Hook: FrameFunctions
const int oCGame__RenderX                           = 6544518; //
const int oCGame__UpdateStatus                      = 6526632; //Hook: Focusnames
const int oCItem__Render                            = 6762352; //
const int oCNpc__CloseInventory                     = 7058164; // Hook: Quickslots
//const int oCNpc__DropUnconscious                    = 7560880; //0x735EB0 Hook: Shields*/
const int oCNpc__Equip                              = 6908144; //
//const int oCNpc__EquipItem                          = 7545792; //0x7323C0 Hook: Shields
const int oCNpc__EquipWeapon                        = 6908960;
//const int oCNpc__EV_DrawWeapon                      = 7654416; //0x74CC10 Hook: Shields
//const int oCNpc__EV_DrawWeapon1                     = 7656160; //0x74D2E0 Hook: Shields
const int oCNpc__EV_PlayAni                         = 7020080; // Hook: AI_Function
//const int oCNpc__EV_RemoveWeapon                    = 7658272; //0x74DB20 Hook: Shields
//const int oCNpc__EV_RemoveWeapon1                   = 7660720; //0x74E4B0 Hook: Shields*/
const int oCNpc__OpenInventory                      = 7057568; //0x6BB0A0 Hook: Quickslots | Hook:Inv
const int oCNpc__OpenInventory2                    = 7057813; // 6BB195
const int oCNpc__PutInSlot                          = 6969664; //0x6A5940 - ported
const int oCNpc__RemoveFromSlot                     = 7643760; //0x74A270
const int oCNpc__UnequipItem                        = 6880192; // Hook: Shields
//const int oCNpc__UseItem                            = 7584784; //0x73BC10
const int oCNpc__StartDialogAniX                    = 7021070; //
const int oCNpc__StartDialogAniY                    = 7021077; //
const int oCSavegameManager__SetAndWriteSavegame    = 4414389; // Hook: Saves
const int oCSavegameManager__SetAndWriteSavegame_bp_offset = 60;
const int parser                                    = ContentParserAddress; //
const int ReadFile                                  = 7905244; //
const int screen                                    = 9298364; //0x8DE1BC
const int sysGetTimePtr                             = 5204320; //
const int WriteFile                                 = 7712354; //
const int zCAICamera_StartDialogCam                 = 4889792; //0x4A9CC0
const int zCAICamera__current                       = 8823248; //0x86A1D0
const int zCAICamera__StartDialogCam                = 4889792; //0x4A9CC0
const int zCAICamera__StartDialogCam_oldInstr       = 1785266026;
const int zCFontMan__GetFont                        = 7205408; //
const int zCFontMan__Load                           = 7204928; //
const int zCFont__GetFontName                       = 7209408; //
const int zCFont__GetFontX                          = 7209488; //
const int zCFont__GetFontY                          = 7209472; //
const int zCViewText_vtbl                           = 8251988; //
const int zCInput_zinput                            = 8834208;
const int zCInput_Win32__SetDeviceEnabled           = 5015312;
/*const int zCInput_Win32__GetMouseButtonPressedLeft  = 5068688; //0x4D5790
const int zCInput_Win32__GetMouseButtonPressedMid   = 5068704; //0x4D57A0
const int zCInput_Win32__GetMouseButtonPressedRight = 5068720; //0x4D57B0
const int zCInput_Win32__GetMousePos                = 5068592; //0x4D5730*/
const int zCParser__CreateInstance                  = 7248864; //
//const int zCParser__CreatePrototype                 = 7942288; //0x793090
const int zCParser__DoStack                         = 7243264; //
const int zCRenderer__DrawTile                      = 5958208; //
const int zCTexture__Load                           = 6064880; //
const int zCView__@zCView                           = 7322848; //
const int zCView__Close                             = 7328400; //
const int zCView__InsertBack                        = 7325248; //
const int zCView__Move                              = 7330624; //
const int zCView__Open                              = 7327856; //
const int zCView__Render                            = 7349744; //
const int zCView__SetFontColor                      = 7339392; //
const int zCView__SetSize                           = 7330816; //
const int zCView__zCView                            = 7322656; //
const int zCView_Top                                = 7326736; //0x6FCC10
const int zCWorld__zCWorld                          = 6235152; //
const int zFontMan                                  = 9291548; //
const int zParser__CallFunc                         = 7247504; //
const int zrenderer_adr                             = 9199312; //
const int zRND_D3D__DrawLine                        = 7432960; //
const int zRND_D3D__DrawPolySimple                  = 7422960; //
const int zRND_D3D__EndFrame                        = 7434576; // Hook: Sprite
const int zRND_D3D__SetAlphaBlendFunc               = 7446336; //
const int zCRnd_D3D__XD3D_SetRenderState            = 7439808; //
const int zRND_D3D_TexMemory_offset                 = 1204;
const int zSinCosApprox                             = 6092704; //
const int T_DIALOGGESTURE_                          = 8686000;
const int _atan2f                                   = 7757480; //
const int _sinf                                     = 7757586; //
const int _acosf                                    = 7757470; //
const int menu_savegame_slot_offset                 = 3276;
const int sub_4D3D90_X                              = 5013602; //0x4C8062 Hook: Cursor
const int zCConsole__Register                       = 7182656; //0x6D9940
const int zCConsoleOutputOverwriteAddr              = 6573691; //0x644E7B Hook: ConsoleCommands
const int zcon_address_lego                         = 9291168; //0x8DC5A0 // zcon_address is defined in Ikarus but only for Gothic2!
const int zCOptions_dir_string_offset               = 120;     //0x78     // The class zCOption is defined incorrectly in Ikarus for Gothic1!
const int zCOption__ParmValue                       = 4586784; //0X45FD20
const int zCWorld__AdvanceClock                     = 6257280; //0x5F7A80 Hook: Draw3D
const int zlineCache                                = 8844672; //0x86F580
const int zCLineCache__Line3D                       = 5224976; //0x4FBA10
const int zTBSphere3D__Draw                         = 5440832; //0x530540
const int zTBBox3D__Draw                            = 5447312; //0x531E90
const int zCOBBox3D__Draw                           = 5451040; //0x532D20

// mark56 | not used
// inv
//const int _oCNpc__CloseDeadNpc                      = 7060128; // .text:006BBAA0
//const int _oCNpc__CloseSteal                        = 7059552; // .text:006BB860
//const int _oCNpc__CloseTradeContainer               = 6503824; // .text:00633D90
//const int _oCNpc__OpenDeadNpc                       = 7059600; // .text:006BB890
//const int _oCNpc__OpenSteal                         = 7058256; // .text:006BB350
//const int _oCNpc__OpenTradeContainer                = 6503392; // .text:00633BE0
//const int _oCNpc__DoDie                             = 6894752; // .text:006934A0

const int oCAniCtrl_Human_IsInWater                 = 6484544; // .text:0062F240
const int oCAniCtrl__Human_GetLayerAni              = 6451776; // .text:00627240
const int zCModelAni__GetAniID                      = 6427072; // .text:006211C0
const int zCModelAni__GetAniName                    = 5759840; // .text:0057E360
const int zCModel__GetAniIDFromAniName              = 4713552; // .text:0047EC50



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
    CALL_IntParam(retVal);
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
    MemoryProtectionOverride(9298296, 10);
    if (inst) {
        MEM_WriteInt(9298296, inst);
        MEM_WriteInt(9298300, MEM_ReadInt(inst+zCParSymbol_offset_offset));
    } else {
        MEM_WriteInt(9298296, 0);
        MEM_WriteInt(9298300, 0);
    };
};

func int MEM_GetUseInstance() {
    return MEM_ReadInt(9298296);
};
