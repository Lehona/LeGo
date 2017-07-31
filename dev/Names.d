/***********************************\
                NAMES
\***********************************/
var int Talent_Names;
//========================================
// Namen setzen
//========================================
func void SetName(var int npc, var string nname) {
    var C_NPC slf; slf = Hlp_GetNpc(npc);
	var oCNpc slf_int; slf_int = Hlp_GetNpc(npc); // Stupid Daedalus
    if(TAL_GetValue(slf, Talent_Names)) {
        slf.name = nname;
    };
    // Gothic 1 compatibility. Deviation in class variable name: oCNpc.name_1 (G2), oCNpc.name1 (G1)
    MEM_WriteStringArray(_@(slf_int)+MEM_NpcName_Offset, 1, nname);
};

//========================================
// Namen anzeigen
//========================================
func void ShowName(var int npc) {
    var C_NPC slf; slf = Hlp_GetNpc(npc);
	var oCNpc slf_int; slf_int = Hlp_GetNpc(npc); // Stupid Daedalus
    TAL_SetValue(slf, Talent_Names, 1);
    // Gothic 1 compatibility. Deviation in class variable name: oCNpc.name_1 (G2), oCNpc.name1 (G1)
    var string name1; name1 = MEM_ReadStringArray(_@(slf_int)+MEM_NpcName_Offset, 1);
    MEM_WriteStringArray(_@(slf_int)+MEM_NpcName_Offset, 0, name1);
};