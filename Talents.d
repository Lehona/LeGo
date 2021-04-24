var int _nrTalents;



func int TAL_CreateTalent() {
	_nrTalents += 1;
	return (_nrTalents-1);
};

func int _TAL_CreateArray() {
	var int array; array = new(zCArray@);
	var zCArray arr; arr = get(array);
	var int size; size = 1; // 1 talent default size to not have crashes
	if (_nrTalents) {
		size = _nrTalents;
	};
	arr.array = MEM_Alloc(size*4);
	arr.numInArray = size;
	arr.numAlloc = size;
	return array;
};

func int _TAL_CheckSize(var int zCArr) {
	var zCArray arr; arr = get(zCArr);
	if (arr.numInArray < _nrTalents) { // This only happens if you create talents after having already assigned/read a talent
		arr.array = MEM_Realloc(arr.array, arr.numInArray, _nrTalents);
	};
};

func void TAL_SetValue(var c_npc npc, var int talent, var int value) {
	if (!Hlp_IsValidNpc(npc)) { return; };
	if (!Hlp_IsValidHandle(npc.aivar[AIV_TALENT])) {
		npc.aivar[AIV_TALENT] = _TAL_CreateArray();
	};
	_TAL_CheckSize(npc.aivar[AIV_TALENT]);
	if (talent >= _nrTalents) {
		return;
	};
	MEM_ArrayWrite(getPtr(npc.aivar[AIV_TALENT]), talent, value);
};

func int TAL_GetValue(var c_npc npc, var int talent) {
	if (!Hlp_IsValidNpc(npc)) { return -1; };
	if (!Hlp_IsValidHandle(npc.aivar[AIV_TALENT])) {
		return 0;
	};
	_TAL_CheckSize(npc.aivar[AIV_TALENT]);
	if (talent >= _nrTalents) {
		return 0;
	};
	MEM_ArrayRead(getPtr(npc.aivar[AIV_TALENT]), talent);
};

func int Npc_GetID(var c_npc slf) {
    if (!Hlp_IsValidHandle(slf.aivar[AIV_TALENT])) {
            slf.aivar[AIV_TALENT] = _TAL_CreateArray();
    };
    return slf.aivar[AIV_TALENT];
};

var int ID_NpcPtr;
var int ID_Target;

func void Npc_FindByID_sub(var int node) {
    var zCListSort l; l = _^(node);
    if (l.data) {
        var C_Npc npc; npc = _^(l.data);
        if (npc.aivar[AIV_TALENT] == ID_Target) {
            ID_NpcPtr = l.data;
        };
    };
};

func int Npc_FindByID(var int ID) { // GetByID would probably be too similar to GetID
    ID_NpcPtr = 0;
    ID_Target = ID;
    
	if (MEM_World.voblist_npcs) {
		List_ForFS(MEM_World.voblist_npcs, Npc_FindByID_sub);
    };
    
    
    return ID_NpcPtr;
};