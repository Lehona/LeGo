// Eine Hashtable ist eigentlich bloﬂ zCArray<zCArray<_HT_Obj>*>, also ein zweidimensionales Array.

class _HT_Obj {
	var int key;
	var int val;
};
const int HT_SIZE = 599; // Primzahl



func int _HT_CreatePtr(var int size) {
	var int ptr; ptr = MEM_ArrayCreate();
	var zCArray arr; arr = _^(ptr);
	arr.array = MEM_Alloc(size*4);
	arr.numAlloc = size*4;
	arr.numInArray = 0;
	return +ptr;
};

func int _HT_Create() {
	return +_HT_CreatePtr(HT_SIZE);
};

func int hash(var int val) {
	var int hash; hash = MEM_GetBufferCRC32(_@(val), 4);
	return hash & 2147483647; // No negative values
};


func void _HT_Insert(var int ptr, var int val, var int key) {
	var zCArray arr; arr = _^(ptr);
	var int h; h = hash(key) % (arr.numAlloc/4);
	var int bucket; bucket = MEM_ReadIntArray(arr.array, h);
	if (!bucket) { 
		MEM_WriteIntArray(arr.array, h, MEM_ArrayCreate());
		bucket = MEM_ReadIntArray(arr.array, h);
	};
	MEM_ArrayInsert(bucket, key);
	MEM_ArrayInsert(bucket, val);
	arr.numInArray += 1;
	/* resize if needed */
	if (arr.numInArray == arr.numAlloc) {
		var int am; am = arr.numInArray*2;
		ptr;
		am;
		MEM_Call(_HT_Resize);
	};
};


func void _HT_Resize(var int ptr, var int size) {
	var zCArray arr; arr = _^(ptr); var zCArray buck;
	var int htbl; htbl = _HT_CreatePtr(size); var zCArray hArr; hArr = _^(htbl);
	var int i; var int j; var int bucket; i = 0; j = 0;
	repeat(i, arr.numAlloc);
		bucket = MEM_ReadIntArray(arr.array, i);
		if (bucket) {
			buck = _^(bucket);
			repeat(j, buck.numInArray/2);
				_HT_Insert(htbl, MEM_ReadIntArray(buck.array, 2*j+1), MEM_ReadIntArray(buck.array, 2*j));
			end;
			MEM_Free(bucket);
		};
	end;
	MEM_Free(arr.array);
	arr.array = hArr.array;
	arr.numAlloc = size*4;
	arr.numInArray = hArr.array;
};
		
		

func int _HT_GetValue(var int ptr, var int key) {
	var zCArray arr; arr = _^(ptr);
	var int h; h = hash(key) % (arr.numAlloc/4);
	var int bucket; bucket = MEM_ReadIntArray(arr.array, h);
	if (!bucket) { MEM_Info("HT: Key not found"); return -1; };
	var zCArray buck; buck = _^(bucket);
	var int i;
	repeat(i, buck.numInArray/2);
		if (MEM_ArrayRead(bucket, i*2) == key) {
			return (MEM_ArrayRead(bucket, i*2+1));
		};
	end;
	
	MEM_Info("HT: Key not found");	
	return -1;
};

func void _HT_Remove(var int ptr, var int key) {
	var zCArray arr; arr = _^(ptr);
	var int h; h = hash(key) % (arr.numAlloc/4);
	var int bucket; bucket = MEM_ReadIntArray(arr.array, h);
	if (!bucket) { MEM_Info("HT: Key not found"); return; };
	var zCArray buck; buck = _^(bucket);
	var int i;
	repeat(i, buck.numInArray/2);
		if (MEM_ArrayRead(bucket, i*2) == key) {
			MEM_ArrayRemoveIndex(bucket, i*2+1);
			MEM_ArrayRemoveIndex(bucket, i*2);
			return;
		};
	end;
	MEM_Info("HT: Key not found"); 
};
	
func void MEM_SetUseInstance(var int inst) {
	var int ptr; ptr = MEM_ReadIntArray (currSymbolTableAddress, inst);
	MemoryProtectionOverride(11232304, 10);
	MEM_WriteInt(11232304, ptr);
	MEM_WriteInt(11232308, MEM_ReadInt(ptr+28));
};

func int MEM_GetUseInstance() {
	return MEM_ReadInt(11232304);
};
		
	