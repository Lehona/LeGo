/***********************************\
           BINARYMACHINES
\***********************************/

/*--------------------
  Enginecalls
--------------------*/
const int CREATE_ALWAYS = 2;
const int OPEN_EXISTING = 3;
const int GENERIC_ALL = 1073741824;
const int GENERIC_READ = -2147483648;
const int FILE_SHARE_READ = 1;
const int FILE_SHARE_WRITE = 2;
const int FILE_SHARE_DELETE = 4;
const int FILE_ATTRIBUTE_NORMAL = 128;

func int WIN_GetLastError() {
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL__stdcall(GetLastError);
        call = CALL_End();
    };
    return CALL_RetValAsInt();
};

func int WIN_CreateFile(
    var string lpFileName,
    var int dwDesiredAccess,
    var int dwShareMode,
    var int lpSecurityAttributes,
    var int dwCreationDisposition,
    var int dwFlagsAndAttributes,
    var int hTemplateFile) {
    const int call = 0;
    var zString zstr; zstr = MEM_PtrToInst(_@s(lpFileName));
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(hTemplateFile));
        CALL_IntParam(_@(dwFlagsAndAttributes));
        CALL_IntParam(_@(dwCreationDisposition));
        CALL_IntParam(_@(lpSecurityAttributes));
        CALL_IntParam(_@(dwShareMode));
        CALL_IntParam(_@(dwDesiredAccess));
        CALL_PtrParam(_@(zstr.ptr));
        CALL__stdcall(CreateFileA);
        call = CALL_End();
    };
    return CALL_RetValAsPtr();
};

func void WIN_WriteFile(
    var int hFile,
    var int lpBuffer,
    var int nNumberOfBytesToWrite,
    var int lpNumberOfBytesWritten,
    var int lpOverlapped) {
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(lpOverlapped));
        CALL_IntParam(_@(lpNumberOfBytesWritten));
        CALL_IntParam(_@(nNumberOfBytesToWrite));
        CALL_IntParam(_@(lpBuffer));
        CALL_IntParam(_@(hFile));
        CALL__stdcall(WriteFile);
        call = CALL_End();
    };
};
func void WIN_ReadFile(
    var int hFile,
    var int lpBuffer,
    var int nNumberOfBytesToRead,
    var int lpNumberOfBytesRead,
    var int lpOverlapped) {
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(lpOverlapped));
        CALL_IntParam(_@(lpNumberOfBytesRead));
        CALL_IntParam(_@(nNumberOfBytesToRead));
        CALL_IntParam(_@(lpBuffer));
        CALL_IntParam(_@(hFile));
        CALL__stdcall(ReadFile);
        call = CALL_End();
    };
};
func void WIN_CloseHandle(
    var int hObject) {
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(hObject));
        CALL__stdcall(CloseHandle);
        call = CALL_End();
    };
};
func int WIN_GetFileSize(
    var int hFile,
    var int lpFileSizeHigh) {
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(lpFileSizeHigh));
        CALL_IntParam(_@(hFile));
        CALL__stdcall(GetFileSize);
        call = CALL_End();
    };
    return CALL_RetValAsInt();
};

/*--------------------
  Konstanten
--------------------*/
const int _BIN_BufferLength = 32768;

/*--------------------
  Variablen
--------------------*/
var int _bin_open; // Handle des Streams
var int _bin_mode; // Mode (Write/Read)
var int _bin_crsr; // Cursor
var string _bin_prefix; // Debug-Präfix
const int _bin_ccnt = 0; // Aktueller Content
const int _bin_clen = 0; // Aktuelle Streamlänge

/*--------------------
  Hilfsfunktionen
--------------------*/
func void _BIN_Err(var string msg) {
    var int r;
    r = MEM_MessageBox(msg, _bin_prefix, MB_OK | MB_ICONERROR);
};
func int _BIN_nRunning() {
    if(_bin_open) {
        _BIN_Err("Der aktuelle Stream muss zuerst geschlossen werden bevor ein weiterer geöffnet werden kann.");
        return 0;
    };
    return 1;
};
func int _BIN_Running() {
    if(!_bin_open) {
        _BIN_Err("Es ist kein Stream aktiv.");
        return 0;
    };
    return 1;
};
func int _BIN_nMode(var int m) {
    if(_bin_mode != m) {
        _BIN_Err("Falscher Modus.");
        return 0;
    };
    return 1;
};
func void _BIN_StreamLen(var int nlen) {
    nlen += _bin_crsr;
    if(nlen >= _bin_clen) {
        var int len; len = _bin_clen;
        var int pos; pos = MEM_StackPos.position;
        if(nlen >= len) {
            len = len<<1;
            pos = MEM_StackPos.position;
        };
        _bin_ccnt = MEM_Realloc(_bin_ccnt, _bin_clen, len);
        _bin_clen = len;
    };
};
func int _BIN_EOF(var int len) {
    if(_bin_crsr + len > _bin_clen) {
        _BIN_Err("Das Ende des Streams wurde bereits erreicht.");
        return 1;
    };
    return 0;
};

/*============
  BinaryWriter
  ============*/

func int BW_NewFile(var string file) {
    _bin_prefix = "BW_NewFile";
    if(!_BIN_nRunning()) { return 0; };

    _bin_open = WIN_CreateFile(file, GENERIC_ALL, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if(_bin_open==-1) {
        _bin_open = 0;
        var string err; err = ConcatStrings(file, " - Datei konnte nicht erstellt werden. Fehlercode ");
        _BIN_Err(ConcatStrings(err, IntToString(WIN_GetLastError())));
        return 0;
    };

    if(!_bin_ccnt) {
        _bin_clen = _BIN_BufferLength;
        _bin_ccnt = MEM_Alloc(_bin_clen);
    };

    _bin_mode = 0;
    _bin_crsr = 0;
    return 1;
};

func void BW(var int data, var int length) {
    _bin_prefix = "BW";
    if(!_BIN_Running()||!_BIN_nMode(0)) { return; };

    if(length < 1) { length = 1; };
    if(length > 4) { length = 4; };

    _BIN_StreamLen(4);
    MEM_WriteInt(_bin_ccnt + _bin_crsr, data);
    _bin_crsr += length;
};
func void BW_Int(var int data) { BW(data, 4); };
func void BW_Byte(var int data) { BW(data, 1); };
func void BW_Char(var string data) { BW(Str_GetCharAt(data, 0), 1); };

func void BW_Text(var string data) {
    _bin_prefix = "BW_Text";
    if(!_BIN_Running()||!_BIN_nMode(0)) { return; };
    var zString zstr; zstr = MEM_PtrToInst(_@s(data));
    if(!zstr.len) { return; };
    _BIN_StreamLen(zstr.len+4);
    MEM_CopyBytes(zstr.ptr, _bin_ccnt + _bin_crsr, zstr.len);
    _bin_crsr += zstr.len;
};

func void BW_String(var string data) {
    _bin_prefix = "BW_String";
    if(!_BIN_Running()||!_BIN_nMode(0)) { return; };
    BW(STR_Len(data), 4);
    BW_Text(data);
};

func void BW_Bytes(var int dataPtr, var int length) {
    _bin_prefix = "BW_Struct";
    if(!_BIN_Running()||!_BIN_nMode(0)||!length||!dataPtr) { return; };
    _BIN_StreamLen(length);
    MEM_CopyBytes(dataPtr, _bin_ccnt + _bin_crsr, length);
    _bin_crsr += length;
};

func void BW_NextLine() { BW(2573, 2); };

func void BW_Close() {
    _bin_prefix = "BW_Close";
    if(!_BIN_Running()||!_BIN_nMode(0)) { return; };

    var int ptr;
    WIN_WriteFile(_bin_open, _bin_ccnt, _bin_crsr, _@(ptr), 0);
    WIN_CloseHandle(_bin_open);
    _bin_open = 0;
};

/*============
  BinaryReader
  ============*/

func int BR_OpenFile(var string file) {
    _bin_prefix = "BR_OpenFile";
    if(!_BIN_nRunning()) { return 0; };

    _bin_open = WIN_CreateFile(file, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if(_bin_open==-1) {
        _bin_open = 0;
        var string err; err = ConcatStrings(file, " - Datei konnte nicht geöffnet werden. Fehlercode ");
        _BIN_Err(ConcatStrings(err, IntToString(WIN_GetLastError())));
        return 0;
    };
    var int len; len = WIN_GetFileSize(_bin_open, 0);

    if(len > _bin_clen) {
		if (_bin_ccnt) { MEM_Free(_bin_ccnt); };
        _bin_ccnt = MEM_Alloc(len);
        _bin_clen = len;
    };

    var int ptr; ptr = MEM_Alloc(4);
    WIN_ReadFile(_bin_open, _bin_ccnt, len, ptr, 0);
    MEM_Free(ptr);

    WIN_CloseHandle(_bin_open);

    _bin_mode = 1;
    _bin_crsr = 0;
    return 1;
};

func int BR(var int length) {
    _bin_prefix = "BR";
    if(!_BIN_Running()||!_BIN_nMode(1)) { return 0; };

    if(length < 1) { length = 1; };
    if(length > 4) { length = 4; };

    if(_BIN_EOF(length)) { return 0; };

    var int b; b = MEM_ReadInt(_bin_ccnt + _bin_crsr);
    if(length < 4) {
        b = b&((256<<((length-1)<<3))-1);
    };
    _bin_crsr += length;
    return b;
};
func int BR_Int() { return BR(4); };
func int BR_Byte() { return BR(1); };
func string BR_Char() {
    var string str; str = "";
    var zString zstr; zstr = MEM_PtrToInst(_@s(str));
    zstr.ptr = MEM_Alloc(3)+1;
    MEM_WriteByte(zstr.ptr, BR(1));
    zstr.len = 1;
    zstr.res = 1;
    return str;
};

func string BR_Text(var int len) {
    _bin_prefix = "BR_Text";
    if(!_BIN_Running()||!_BIN_nMode(1)) { return ""; };
    var string str; str = "";
    var zString zstr; zstr = MEM_PtrToInst(_@s(str));
    zstr.ptr = MEM_Alloc(len+2)+1;
    MEM_CopyBytes(_bin_ccnt + _bin_crsr, zstr.ptr, len);
    _bin_crsr += len;
    zstr.len = len;
    zstr.res = len;
    return str;
};

func string BR_TextLine() {
    var int s; s = _bin_crsr;
    var int p; p = MEM_StackPos.position;
    if(BR(2) != 2573) {
        _bin_crsr -= 1;
        MEM_StackPos.position = p;
    };
    var int e; e = _bin_crsr;
    _bin_crsr = s;
    var string str; str = BR_Text(e-s-2);
    _bin_crsr = e;
    return str;
};

func void BR_NextLine() {
    var int p; p = MEM_StackPos.position;
    if(BR(2) != 2573) {
        _bin_crsr -= 1;
        MEM_StackPos.position = p;
    };
};

func string BR_String() {
    return BR_Text(BR_Int());
};

func int BR_Bytes(var int length) {
    var int ptr;
    if(length <= 4) {
        ptr = MEM_Alloc(4);
        MEM_WriteInt(ptr, BR(length));
        return ptr;
    };
    _bin_prefix = "BR_Bytes";
    if(!_BIN_Running()||!_BIN_nMode(1)) { return 0; };
    if(_bin_crsr + length > _bin_clen) {
        _bin_Err("Die angegebene Struktur ist in dieser Datei nicht vollständig enthalten.");
        return 0;
    };
    ptr = MEM_Alloc(length);
    MEM_CopyBytes(_bin_ccnt + _bin_crsr, ptr, length);
    _bin_crsr += length;
    return ptr;
};

func void BR_Close() {
    _bin_prefix = "BR_Close";
    if(!_BIN_Running()||!_BIN_nMode(1)) { return; };

    _bin_open = 0;
};