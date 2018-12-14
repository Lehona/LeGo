class HT_Array {
	var int array;
	var int numalloc;
	var int numinarray;
	}; instance HT@(HT_Array) {
};

func void HT_Array_Archiver(var HT_Array this) {    
	PM_SaveInt("length", this.numAlloc); // Hate to do it this way, but that's how I implemented it back then :/
	PM_SaveInt("elements", this.numInArray);
	
	var int ctr; ctr = 0;
    var int k; k = 0;
	repeat(k, this.numAlloc/4);
		var int ptr; ptr = MEM_ReadInt(this.array+k*4);
		if (!ptr) { continue; };
		
		PM_SaveClassPtr(IntToString(ctr), ptr, "zCArray");
		PM_SaveInt(ConcatStrings("pos", IntToString(ctr)), k);
		ctr += 1;
	end;
	PM_SaveInt("subArrays", ctr);
};

func void HT_Array_Unarchiver(var HT_Array this) {
	this.numAlloc = PM_Load("length");
	this.numInArray = PM_Load("elements");
	this.array = MEM_Alloc(this.numAlloc);
	
	var int k; k = 0;
	repeat(k, PM_Load("subArrays"));
		var int pos; pos = PM_Load(ConcatStrings("pos", IntToString(k)));
		MEM_WriteInt(this.array+pos*4, PM_Load(IntToString(k)));
	end;
};

func void HT_Array_delete(var int hndl) {
	_HT_Destroy(getPtr(hndl));
};

func int HT_CreateSized(var int size) {
	return wrap(HT@, _HT_CreatePtr(size));
};

func int HT_Create() {
	return +HT_CreateSized(HT_SIZE);
};

func void HT_Insert(var int hndl, var int val, var int key) {
	_HT_Insert(getPtr(hndl), val, key);
};

func void HT_Resize(var int hndl, var int size) {
	_HT_Resize(getPtr(hndl), size);
};

func int HT_Get(var int hndl, var int key) {
	return _HT_Get(getPtr(hndl), key);
};

func int HT_Has(var int hndl, var int key) {
	return _HT_Has(getPtr(hndl), key);
};

func void HT_Remove(var int hndl, var int key) {
	_HT_Remove(getPtr(hndl), key);
};

func void HT_Change(var int hndl, var int val, var int key) {
	_HT_Change(getPtr(hndl), val, key);
};

func void HT_InsertOrChange(var int hndl, var int val, var int key) {
	_HT_InsertOrChange(getPtr(hndl), val, key);
};

func int HT_GetNumber(var int hndl) {
	return _HT_GetNumber(getPtr(hndl));
};

func void HT_ForEach(var int hndl, var func fnc) {
	_HT_ForEach(getPtr(hndl), fnc);
};

func void HT_Destroy(var int hndl) {
	delete(hndl);
};

