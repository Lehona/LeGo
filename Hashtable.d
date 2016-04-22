class HT_Array {
	var int array;
	var int numalloc;
	var int numinarray;
	}; instance HT@(HT_Array) {
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

