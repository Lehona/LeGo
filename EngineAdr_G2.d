var int YouHaveToDeleteOneOfTheEngineAdrFilesInTheLeGoDirectory;


/***********************************\
       ADRESSEN DER ENGINECALLS
\***********************************/
//========================================
// Talents Aivar field
//========================================
const int AIV_TALENT_INDEX = 89;
//========================================
// Alle (?) genutzen Engineadressen
//========================================
const int CGameManager__ApplySomeSettings           = 4355760; //0x4276B0
const int CGameManager__Read_Savegame               = 4366400; //0x42A040 Hook: Saves
const int CloseHandle                               = 8079190; //0x7B4756
const int CreateFileA                               = 8079286; //0x7B47B6
const int Cursor_Ptr                                = 9246300; //0x8D165C
const int Cursor_sX                                 = 9019720; //0x89A148
const int Cursor_sY                                 = 9019724; //0x89A14C
const int GetFileSize                               = 8079310; //0x7B47CE
const int GetLastError                              = 8079394; //0x7B4822
const int oCGame__changeLevel                       = 7107216; //0x6C7290 Hook: Saves
const int oCGame__changeLevelEnd                    = 7109323; //0x6C7ACB Hook: Saves
const int oCGame__Render                            = 7112352; //0x6C86A0 Hook: FrameFunctions
const int oCGame__RenderX                           = 7112704; //0x6C8800 Hook: Quickslots
const int oCGame__UpdateStatus                      = 7093113; //0x6C3B79 Hook: Focusnames
const int oCItem__Render                            = 7420608; //0x713AC0
const int oCNpc__CloseInventory                     = 7742483; //0x762413 Hook: Quickslots
const int oCNpc__DropUnconscious                    = 7560880; //0x735EB0 Hook: Shields
const int oCNpc__Equip                              = 7576720; //0x739C90
const int oCNpc__EquipItem                          = 7545792; //0x7323C0 Hook: Shields
const int oCNpc__EquipWeapon                        = 7577648; //0x73A030
const int oCNpc__EV_DrawWeapon                      = 7654416; //0x74CC10 Hook: Shields
const int oCNpc__EV_DrawWeapon1                     = 7656160; //0x74D2E0 Hook: Shields
const int oCNpc__EV_PlayAni                         = 7699121; //0x757AB1 Hook: AI_Function
const int oCNpc__EV_RemoveWeapon                    = 7658272; //0x74DB20 Hook: Shields
const int oCNpc__EV_RemoveWeapon1                   = 7660720; //0x74E4B0 Hook: Shields
const int oCNpc__OpenInventory                      = 7742032; //0x762250 Hook: Quickslots
const int oCNpc__PutInSlot                          = 7642288; //0x749CB0
const int oCNpc__RemoveFromSlot                     = 7643760; //0x74A270
const int oCNpc__UnequipItem                        = 7546560; //0x7326C0 Hook: Shields
const int oCNpc__UseItem                            = 7584784; //0x73BC10
const int oCNpc__StartDialogAniX                    = 7700155; // 0x757EBB
const int oCNpc__StartDialogAniY                    = 7700162; // 0x757EC2
const int oCSavegameManager__SetAndWriteSavegame    = 4428037; //0x439105 Hook: Saves
const int oCSavegameManager__SetAndWriteSavegame_bp_offset = 60;
const int parser                                    =11223232; //0xAB40C0
const int ReadFile                                  = 8272388; //0x7E3A04
const int screen                                    =11232360; //0xAB6468
const int sysGetTimePtr                             = 5264000; //0x505280
const int WriteFile                                 = 8079292; //0x7B47BC
const int zCAICamera_StartDialogCam                 = 4923632; //0x4B20F0
const int zCAICamera__current                       = 9235128; //0x8CEAB8
const int zCAICamera__StartDialogCam                = 4923632; //0x4B20F0
const int zCAICamera__StartDialogCam_oldInstr       = 275316586;
const int zCFontMan__GetFont                        = 7898288; //0x7884B0
const int zCFontMan__Load                           = 7897808; //0x7882D0
const int zCFont__GetFontName                       = 7902368; //0x7894A0
const int zCFont__GetFontX                          = 7902448; //0x7894F0
const int zCFont__GetFontY                          = 7902432; //0x7894E0
const int zCViewText_vtbl                           = 8643396; //0x83E344
const int zCInput_zinput                            = 9246288; //0x8D1650
const int zCInput_Win32__SetDeviceEnabled           = 5067008; //0x4D5100
const int zCInput_Win32__GetMouseButtonPressedLeft  = 5068688; //0x4D5790
const int zCInput_Win32__GetMouseButtonPressedMid   = 5068704; //0x4D57A0
const int zCInput_Win32__GetMouseButtonPressedRight = 5068720; //0x4D57B0
const int zCInput_Win32__GetMousePos                = 5068592; //0x4D5730
const int zCParser__CreateInstance                  = 7942048; //0x792FA0
const int zCParser__CreatePrototype                 = 7942288; //0x793090
const int zCParser__DoStack                         = 7936352; //0x791960
const int zCRenderer__DrawTile                      = 6110448; //0x5D3CF0
const int zCTexture__Load                           = 6239904; //0x5F36A0
const int zCView__@zCView                           = 8017856; //0x7A57C0
const int zCView__Close                             = 8023600; //0x7A6E30
const int zCView__InsertBack                        = 8020272; //0x7A6130
const int zCView__Move                              = 8025824; //0x7A76E0
const int zCView__Open                              = 8023040; //0x7A6C00
const int zCView__Render                            = 8045072; //0x7AC210
const int zCView__SetFontColor                      = 8034576; //0x7A9910
const int zCView__SetSize                           = 8026016; //0x7A77A0
const int zCView__zCView                            = 8017664; //0x7A5700
const int zCView_Top                                = 8021904; //007A6790
const int zCWorld__zCWorld                          = 6421056; //0x61FA40
const int zFontMan                                  =11221460; //0xAB39D4
const int zParser__CallFunc                         = 7940592; //0x7929F0
const int zrenderer_adr                             = 9973512; //0x982F08
const int zRND_D3D__DrawLine                        = 6609120; //0x64D8E0
const int zRND_D3D__DrawPolySimple                  = 6597680; //0x64AC30
const int zRND_D3D__EndFrame                        = 6610720; //0X64DF20 Hook: Sprite
const int zRND_D3D__SetAlphaBlendFunc               = 6628880; //0x652610
const int zCRnd_D3D__XD3D_SetRenderState            = 6573808; //0x644EF0
const int zRND_D3D_TexMemory_offset                 = 1208;
const int zSinCosApprox                             = 6269632; //0x5FAAC0
const int T_DIALOGGESTURE_                          = 9148264; //0x8B9768
const int _atan2f                                   = 8123804; //0x7BF59C
const int _sinf                                     = 8123910; //0x7BF606
const int _acosf                                    = 8123794; //0x7BF592
const int menu_savegame_slot_offset                 = 3276;
const int sub_4D3D90_X                              = 5062907; //0x4D40FB Hook: Cursor
const int zCConsole__Register                       = 7875296; //0x782AE0
const int zCConsoleOutputOverwriteAddr              = 7142904; //0x6CFDF8 Hook: ConsoleCommands
const int zCOption__ParmValue                       = 4608896; //0x465380
const int zCOptions_dir_string_offset               = 124;     //0x7C     // The class zCOption is defined incorrectly in Ikarus for Gothic1!
const int zCWorld__AdvanceClock                     = 6447328; //0x6260E0 Hook: Draw3D
const int zlineCache                                = 9257720; //0x8D42F8
const int zCLineCache__Line3D                       = 5289040; //0x50B450
const int zTBSphere3D__Draw                         = 5521904; //0x5441F0
const int zTBBox3D__Draw                            = 5529312; //0x545EE0
const int zCOBBox3D__Draw                           = 5533040; //0x546D70
const int zcon_address_lego							= 11221088; //0xAB3860 //zcon_address is defined in Ikarus but only for Gothic2!

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
    MemoryProtectionOverride(11232304, 10);
    if (inst) {
        MEM_WriteInt(11232304, inst);
        MEM_WriteInt(11232308, MEM_ReadInt(inst+zCParSymbol_offset_offset));
    } else {
        MEM_WriteInt(11232304, 0);
        MEM_WriteInt(11232308, 0);
    };
};

func int MEM_GetUseInstance() {
    return MEM_ReadInt(11232304);
};
