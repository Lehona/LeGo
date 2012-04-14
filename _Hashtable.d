// Eine Hashtable ist eigentlich bloﬂ zCArray<zCArray<_HT_Obj>*>, also ein zweidimensionales Array.

class _HT_Obj {
	var int key;
	var int val;
};
const int HT_SIZE = 49999; // Prim*4! Yay!

func int _HT_Create() {
	var zCArray arr; arr = _^(MEM_ArrayCreate());
	arr.array = MEM_Alloc(HT_SIZE*4);
	arr.numAlloc = HT_SIZE*4;
	arr.numInArray = 0;
	return _@(arr)+0;
};

func int hash(var int val) {
	return MEM_GetBufferCRC32(_@(val), 4);
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

func void MEM_SetUseInstance(var int inst) {
	MEM_WriteInt(11232304, inst);
	MEM_WriteInt(11232308, MEM_ReadInt(inst+28));
};

func MEM_GetUseInstance() {
	return MEM_ReadInt(11232304);
};
		
	