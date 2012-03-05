/***********************************\
       ADRESSEN DER ENGINECALLS
\***********************************/

const int CGameManager__ApplySomeSettings           = 4355760; //0x4276B0
const int CGameManager__Read_Savegame               = 4366438; //0x42A066
const int CloseHandle                               = 8079190; //0x7B4756
const int CreateFileA                               = 8079286; //0x7B47B6
const int Cursor_Ptr                                = 9246300; //0x8D165C
const int Cursor_sX                                 = 9019720; //0x89A148
const int Cursor_sY                                 = 9019724; //0x89A14C
const int GetFileSize                               = 8079310; //0x7B47CE
const int GetLastError                              = 8079394; //0x7B4822
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
const int oCSavegameManager__SetAndWriteSavegame    = 4428037; //0x439105 Hook: Saves
const int parser                                    =11223232; //0xAB40C0
const int ReadFile                                  = 8272388; //0x7E3A04
const int sysGetTimePtr                             = 5264000; //0x505280
const int WriteFile                                 = 8079292; //0x7B47BC
const int zCAICamera_StartDialogCam                 = 4923632; //0x4B20F0
const int zCAICamera__current                       = 9235128; //0x8CEAB8
const int zCAICamera__StartDialogCam                = 4923632; //0x4B20F0
const int zCFont__GetFontName                       = 7902368; //0x7894A0
const int zCFont__GetFontX                          = 7902448; //0x7894F0
const int zCFont__GetFontY                          = 7902432; //0x7894E0
const int zCFontMan__Load							= 7897808; //0x7882D0
const int zCFontMan__GetFont						= 7898288; //0x7884B0
const int zFontMan									=11221460; //0xAB39D4
const int zCInput_Win32__GetMouseButtonPressedLeft  = 5068688; //0x4D5790
const int zCInput_Win32__GetMouseButtonPressedMid   = 5068704; //0x4D57A0
const int zCInput_Win32__GetMouseButtonPressedRight = 5068720; //0x4D57B0
const int zCInput_Win32__GetMousePos                = 5068592; //0x4D5730
const int zCParser__CreateInstance                  = 7942048; //0x792FA0
const int zCParser__CreatePrototype                 = 7942288; //0x793090
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
const int zCWorld__zCWorld                          = 6421056; //0x61FA40
const int zParser__CallFunc                         = 7940592; //0x7929F0
const int zrenderer_adr                             = 9973512; //0x982F08


// Globale Flagvariable (manche Pakete wollen wissen ob sie erwünscht sind...)
const int _LeGo_Flags = 0;




// Wrapper für Engine-Funktionen


// Interface 

func string zCTexture_GetName(var int ptr) { // Eigentlich gar kein Engine-Call
	var zCObject obj; obj = MEM_PtrToInst(ptr);
	return obj.objectName;
};

func int zCTexture_Load(var string texture) {
	CALL_IntParam(1);
	CALL_zStringPtrParam(texture);
	CALL__cdecl(zCTexture__Load);
	return CALL_RetValAsInt();
};
	
	

func int zCFontMan_Load(var string font) {
	CALL_zStringPtrParam(font);
	CALL__Thiscall(MEM_ReadInt(zFontMan), zCFontMan__Load);
	return CALL_RetValAsInt();
};
	
func int Print_GetFontPtr(var string font) {
    var int i; i = zCFontMan_Load(font);
	CALL_IntParam(i);
	CALL__Thiscall(MEM_ReadInt(zFontMan), zCFontMan__GetFont);
	return CALL_RetValAsInt();
};

func string Print_GetFontName(var int fontPtr) {
	CALL_RetValIszString();
	CALL__Thiscall(fontPtr, zCFont__GetFontName);
	return CALL_RetValAszString();
};

func int Print_GetStringWidth(var string s, var string font) {
	var int adr; adr = Print_GetFontPtr(font);
	CALL_zStringPtrParam(s);
	CALL__Thiscall(adr, zCFont__GetFontX);
	return CALL_RetValAsInt();
};

func int Print_GetFontHeight(var string font) {
	var int adr; adr = Print_GetFontPtr(font);
	CALL__thiscall(adr, zCFont__GetFontY);
	return CALL_RetValAsInt();
};






// Globale Konstante für den Spielstatus
var int Gamestate;

const int Game_NewGame     = 0;
const int Game_Loaded      = 1;
const int Game_WorldChange = 2;

