const int BUFF_GOOD = 1;
const int BUFF_NEUTRAL = 0;
const int BUFF_BAD = -1;

const int BUFFLIST_SIZE = 70; // You really shouldn't have more than this, it will lag!

class lCBuff {
		var string name;
		var int bufftype; // GOOD / NEUTRAL / BAD | 1 / 0 / -1
		var int targetID;  // NPC that is currently affected by this buff
		var int durationMS; // full duration until the buff runs out 
		var int tickMS; // ms between each tick, first tick at tickMS milliseconds.
		var int nextTickNr; // e.g. before the first tick, this will be 1

		var int OnApply; 
		var int OnTick;
		var int OnRemoved;

		var string buffTex; // Currently only used for buffs applied on the hero
		// var int originID; // Who casted/created this buff?
};

func void lCBuff_Archiver(var lCBuff this) {
	PM_SaveString("name", this.name);
	PM_SaveInt("bufftype", this.bufftype);
	PM_SaveInt("targetID", this.targetID);
	PM_SaveInt("durationMS", this.durationMS);
	PM_SaveInt("tickMS", this.tickMS);
	PM_SaveInt("nextTickNr", this.nextTickNr);

	if (this.OnApply > 0) {
		PM_SaveFuncID("OnApply", this.OnApply);
	};
	if (this.OnTick > 0) {
		PM_SaveFuncID("OnTick", this.OnTick);
	};
	if (this.OnRemoved > 0) {
		PM_SaveFuncID("OnRemoved", this.OnRemoved);
	};

	PM_SaveString("buffTex", this.buffTex);

	// if (this.originID > 0) {
	// 	PM_SaveFuncID("originID", this.originID);
	// };
};

func void lCBuff_Unarchiver(var lCBuff this) {
	var int obj;
	if (PM_Exists("name")) { this.name = PM_LoadString("name"); };
	if (PM_Exists("bufftype")) { this.bufftype = PM_Load("bufftype"); };
	if (PM_Exists("targetID")) { this.targetID = PM_Load("targetID"); };
	if (PM_Exists("durationMS")) { this.durationMS = PM_Load("durationMS"); };
	if (PM_Exists("tickMS")) { this.tickMS = PM_Load("tickMS"); };
	if (PM_Exists("nextTickNr")) { this.nextTickNr = PM_Load("nextTickNr"); };

	if (PM_Exists("OnApply")) {
		obj = _PM_SearchObj("OnApply");
		if (_PM_ObjectType(obj) == _PM_String) { // Compatibility
			this.OnApply = PM_LoadFuncID("OnApply");
		} else {
			this.OnApply = PM_Load("OnApply");
		};
	};
	if (PM_Exists("OnTick")) {
		obj = _PM_SearchObj("OnTick");
		if (_PM_ObjectType(obj) == _PM_String) {
			this.OnTick = PM_LoadFuncID("OnTick");
		} else {
			this.OnTick = PM_Load("OnTick");
		};
	};
	if (PM_Exists("OnRemoved")) {
		obj = _PM_SearchObj("OnRemoved");
		if (_PM_ObjectType(obj) == _PM_String) {
			this.OnRemoved = PM_LoadFuncID("OnRemoved");
		} else {
			this.OnRemoved = PM_Load("OnRemoved");
		};
	};

	if (PM_Exists("buffTex")) { this.buffTex = PM_LoadString("buffTex"); };

	// if (PM_Exists("originID")) {
	// 	PM_SaveFuncID("originID", this.originID);
	// 	obj = _PM_SearchObj("originID");
	// 	if (_PM_ObjectType(obj) == _PM_String) {
	// 		this.originID = PM_LoadFuncID("originID");
	// 	} else {
	// 		this.originID = PM_Load("originID");
	// 	};
	// };
};


/* BUFF DISPLAY FOR HERO BEGINS HERE */


var int bufflist_hero; // @zCArray<@lCBuff> 
var int bufflist_views[BUFFLIST_SIZE]; // @zCView

func void Bufflist_Init() {
	Print_GetScreenSize();
	var int xsize; xsize = roundf(divf(mkf(500), Print_Ratio));
	bufflist_hero = new(zCArray@);
	var int k; var int v;
	repeat(k, BUFFLIST_SIZE);
		v = View_Create(((100+xsize)*k),7000, (100+xsize)*k+xsize, 7500);
		MEM_WriteStatArr(bufflist_views, k, v);
	end;
};

func void Bufflist_Add(var int bh) {
	var zCArray arr; arr = get(bufflist_hero);
	var lcBuff b; b = get(bh);
	MEM_ArrayInsert(getPtr(bufflist_hero), bh);

	var int v; v = MEM_ReadStatArr(bufflist_views, arr.numInArray-1);
	View_SetTexture(v, b.buffTex);
	View_Open(v);
};

func void Bufflist_Remove(var int bh) {
	var zCArray arr; arr = get(bufflist_hero);
	var int index; index = MEM_ArrayIndexOf(getPtr(bufflist_hero), bh);



	if (arr.numInArray == 1 && index == 0) { 
		View_Close(bufflist_views[0]); 
	};	

	var string tex; tex = View_GetTexture(MEM_ReadStatArr(bufflist_views, arr.numInArray-1));

	View_SetTexture(MEM_ReadStatArr(bufflist_views, index), tex);

	View_Close(MEM_ReadStatArr(bufflist_views, arr.numInArray-1));
	
	arr.numInArray -= 1;
	if (index == arr.numInArray) { return; };

	MEM_WriteIntArray(arr.array, index, 
			MEM_ReadIntArray(arr.array, arr.numInArray));

	
};

/* BUFF DISPLAY FOR HERO ENDS HERE */


/* Daedalus braucht mal wieder eine Sonderbehandlung */ 
func int SAVE_GetFuncID(var func f) {
		var int i; i = MEM_GetUseInstance();
		var int res; res = MEM_GetFuncID(f);
		MEM_SetUseInstance(i);
		return res;
};


// Buff_Has(npc, buff) checks if a given NPC has a given buff
var int Buff_NpcID;
var int Buff_BuffHndl;
func int _Buff_Check(var int buffh) {
	var lCBuff b; b = get(buffh);
	if (Buff_NpcID == b.targetID) {
			Buff_BuffHndl = buffh;
			return break;
	};
};
func int Buff_Has(var c_npc npc, var int buff) {
		Buff_NpcID = Npc_GetID(npc);
		Buff_BuffHndl = 0;
		ForeachHndl(buff, _Buff_Check);
		if (Buff_BuffHndl != 0) {	
			return Buff_BuffHndl;
		};
};	

func void _Buff_Dispatcher(var int bh) { // This is called every tick and is responsible for deleting the object 
		if (!Hlp_IsValidHandle(bh)) {
				return;
		};


		var lcBuff b; b = get(bh);
		if (b.nextTickNr > b.durationMS/b.tickMS) {
			FF_RemoveData(_Buff_Dispatcher, bh);
			bh;
			MEM_Call(Buff_Remove);
			return;
		};

		if (b.onTick) {
			bh;
			MEM_CallByID(b.onTick);
		};

		b.nextTickNr += 1;
};

func int Buff_Apply(var c_npc npc, var int buff) {
		var int bh; bh = new(buff);
		var lCBuff b; b = get(bh);

		b.targetID = Npc_GetID(npc);
	
		if (b.OnApply) {
				bh;
				MEM_CallByID(b.OnApply);
		};
		b.nextTickNr = 1;

		if (!b.tickMS) { b.tickMS = b.durationMS+1; /* Increase by one so tickCount is zero */ };

		FF_ApplyExtDataGT(_Buff_Dispatcher, b.tickMS, -1, bh);
		

		if (Npc_IsPlayer(npc) && Buffs_DisplayForHero) {
				/* Add this buff to the hero's bufflist, for display */
				BuffList_Add(bh);
		};
		return bh;
};

func int Buff_ApplyUnique(var c_npc n, var int buff) {
		if (!Buff_Has(n, buff)) {
			return Buff_Apply(n, buff);
		};
		return 0;
};


func void Buff_Refresh(var int bh) {
	if (!Hlp_IsValidHandle(bh)) { return; };
	var lcBuff b; b = get(bh);

	b.nextTickNr = 1;
};


func int Buff_ApplyOrRefresh(var c_npc n, var int buff) {
	var int bh; bh = Buff_Has(n, buff);
	if (bh) {
		Buff_Refresh(bh);
		return bh;
	} else {
		return Buff_Apply(n, buff);
	};
};


func void Buff_Remove(var int bh) {
	var lCBuff b; b = get(bh);
	if (b.onRemoved) {
			bh;
			MEM_CallByID(b.onRemoved);
	};

	if (b.targetID == Npc_GetID(hero)) {
			Bufflist_Remove(bh);
	};

	if (Hlp_IsValidHandle(bh)) {
		delete(bh);
	};
};

func int Buff_GetNpc(var int bh) {
	var lCBuff b; b = get(bh);
	return Npc_FindByID(b.targetID);
};


func void _Buff_RemoveAll_Sub(var int buffh) {
	var lCBuff buff; buff = get(buffh);
	if (buff.targetID == Buff_NpcID) {
		Buff_Remove(buffh);
	};
};

func void Buff_RemoveAll(var c_npc n, var int buffInstance) {
	Buff_NpcID = Npc_GetId(n);
	ForeachHndl(buffInstance, _Buff_RemoveAll_Sub);
};
