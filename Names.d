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
    slf_int.name_1 = nname;
};

//========================================
// Namen anzeigen
//========================================
func void ShowName(var int npc) {
    var C_NPC slf; slf = Hlp_GetNpc(npc);
	var oCNpc slf_int; slf_int = Hlp_GetNpc(npc); // Stupid Daedalus
    TAL_SetValue(slf, Talent_Names, 1);
    slf_int.name = slf_int.name_1;
};