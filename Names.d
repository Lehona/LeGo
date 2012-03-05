/***********************************\
                NAMES
\***********************************/

//========================================
// Namen setzen
//========================================
func void SetName(var int npc, var string nname) {
    var oCNpc slf; slf = Hlp_GetNpc(npc);
    if(slf.aiscriptvars[AIV_Name]) {
        slf.name = nname;
    };
    slf.name_1 = nname;
};

//========================================
// Namen anzeigen
//========================================
func void ShowName(var int npc) {
    var oCNpc slf; slf = Hlp_GetNpc(npc);
    slf.aiscriptvars[AIV_Name] = 1;
    slf.name = slf.name_1;
};