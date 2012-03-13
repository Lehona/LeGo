/***********************************\
                ANIM8
\***********************************/

//========================================
// [intern] Variablen und Klassen
//========================================
var int A8_Arr; //zCArray(h)<A8Head(h)>

class A8Head {
    var int value;
    var int fnc;
    var int flt;
    var int data;
    var int dif;
    var int queue; //zCList<A8Command(h)>*
};

// const string A8Head_Struct = "auto|3 zCList*";

func void A8Head_Archiver(var A8Head this) {
    PM_SaveInt("value", this.value);
    if(this.fnc) { PM_SaveFuncID("loop",  this.fnc);  };
    if(this.flt) { PM_SaveFloat ("float", this.flt);  };
    if(this.data){ PM_SaveInt   ("data",  this.data); };
    if(this.dif) { PM_SaveInt   ("dif",   this.dif);  };
    PM_SaveClassPtr("queue", this.queue, "zCList");
};

func void A8Head_UnArchiver(var A8Head this) {
    this.value = PM_Load("value");
    if(PM_Exists("loop"))  { this.fnc  = PM_LoadFuncID("loop"); };
    if(PM_Exists("float")) { this.flt  = PM_LoadFloat("float"); };
    if(PM_Exists("data"))  { this.data = PM_LoadInt("data");    };
    if(PM_Exists("dif"))   { this.dif  = PM_LoadInt("dif");     };
    this.queue = PM_Load("queue");
};

func void A8Head_Delete(var A8Head h) {
    if(!h.queue) { return; };
    List_For(h.queue, "A8Head_DeleteSub");
    List_Destroy(h.queue);
    };func void A8Head_DeleteSub(var int node) {
    if(Hlp_IsValidHandle(MEM_ReadInt(node))) {
        delete(MEM_ReadInt(node));
    };
};

instance A8Head@(A8Head) {
    A8Head@.queue = List_Create(0);
};

class A8Command {
    var int target;
    var int timeSpan;
    var int startVal;
    var int startTime;
    var int velo;
    var int startV;
    var int interpol;
};

instance A8Command@(A8Command);

//========================================
// Neues Objekt erstellen
//========================================
func int Anim8_New(var int value, var int IsFloat) {
    if(!A8_Arr) {
        A8_Arr = new(zCArray@);
    };
    var int hndl; hndl = new(A8Head@);
    var A8Head h; h = get(hndl);
    if(!IsFloat) {
        h.value = mkf(value);
    }
    else {
        h.value = value;
    };
    h.flt = !!IsFloat;
    var int i; i = MEM_ArrayOverwriteFirst(getPtr(A8_Arr), 0, hndl);

    return hndl;
};

//========================================
// Neues Objekt mit Handler erstellen
//========================================
func int Anim8_NewExt(var int value, var func handler, var int data, var int IsFloat) {
    var int hndl; hndl = Anim8_New(value, IsFloat);
    var A8Head h; h = get(hndl);
    h.fnc = MEM_GetFuncID(handler);
    h.data = data;
    return hndl;
};

//========================================
// Objekt komplett löschen
//========================================
func void Anim8_Delete(var int hndl) {
    if(!Hlp_IsValidHandle(hndl)) {
        MEM_Warn("A8_Delete: Invalid handle");
        return;
    };
    var int p; p = MEM_ArrayOverwrite(getPtr(A8_Arr), hndl, 0);
    if(p == -1) {
        MEM_Warn("A8_Delete: Handle not found");
    };
    delete(hndl);
};

//========================================
// [intern] Beschleunigung berechnen
//========================================
func void _Anim8_SetVelo(var A8Head h, var A8Command c) {
    if(c.interpol == A8_Wait) { return; };
    if(c.interpol == A8_Constant) {
        // v = s/t;
        c.velo = divf(subf(c.target, h.value), c.timeSpan);
    }
    else {
        //a = 2*s/t^2
        c.velo = divf(mulf(mkf(2), subf(c.target, h.value)), mulf(c.timeSpan, c.timeSpan));
        if(c.interpol == A8_SlowEnd) {
            c.startV = mulf(c.velo, c.timeSpan);
            c.velo = negf(c.velo);
        };
    };
};

//========================================
// [intern] Neuer Befehl
//========================================
func void _Anim8_Ext(var int hndl, var int targetVal, var int timeSpan, var int interpol, var int UseQueue) {
    var A8Head h; h = get(hndl);
    if(!UseQueue||!h.queue) {
        A8Head_Delete(h);
        h.queue = List_Create(0);
    };
    var int cmd; cmd = new(A8Command@);
    var A8Command c; c = get(cmd);
    c.target = targetVal;
    if(!h.flt) {
        c.target = mkf(c.target);
    };
    if(h.value == c.target) { interpol = A8_Wait; };
    c.startVal = h.value;
    c.startTime = MEM_Timer.totalTime;
    c.timeSpan = mkf(timeSpan);
    c.interpol = interpol;
    _Anim8_SetVelo(h, c);
    List_Add(h.queue, cmd);
};

//========================================
// [intern] FF-Loop
//========================================
func void _Anim8_Loop() {
    if(!A8_Arr) { return; };
    var zCArray arr; arr = get(A8_Arr);
    var int i; i = -1;
    var int p; p = MEM_StackPos.position;
    while(i < arr.numInArray);
        i += 1;
        var int chndl; chndl = MEM_ReadInt(arr.array + i*4);
        if(!Hlp_IsValidHandle(chndl)) {
            continue;
        };
        var A8Head h; h = get(chndl);
        if(!h.queue) {
            continue;
        };
        if(!List_HasLength(h.queue, 2)) {
            continue;
        };
		
        var int ldata; ldata = List_Get(h.queue, 2);
		if(!ldata) {
			List_Delete(h.queue, 2);
			continue;
		};
		
        var A8Command c; c = get(ldata);

        // Eigentliche Interpolierung

        var int t; t = mkf(MEM_Timer.totalTime - c.startTime);

        if(c.interpol&&c.interpol < A8_Wait) {
            if(c.interpol == A8_Constant) {
                // s = v*t;
                h.value = mulf(c.velo, t);
            }
            else if(c.interpol == A8_SlowEnd) {
                // s = a/2*t^2 + v0*t
                h.value = addf(mulf(mulf(c.velo, floatHalb), mulf(t, t)), mulf(c.startV, t));
            }
            else if(c.interpol == A8_SlowStart) {
                // s = a/2*t^2
                h.value = mulf(mulf(c.velo, floatHalb), mulf(t, t));
            };
            h.value = addf(c.startVal, h.value);
        };

        if(gef(t, c.timeSpan)) {
            if(c.interpol != A8_Wait) {
                h.value = c.target;
            };
        };

        if(h.fnc) {
            if(h.data) {
                h.data;
            };
            if(h.flt) {
                h.value;
            }
            else {
                roundf(h.value);
            };
            MEM_CallById(h.fnc);
        };

        if(gef(t, c.timeSpan)) {
            delete(ldata);
            List_Delete(h.queue, 2);
            // ggf. Liste aktualisieren
            if(List_HasLength(h.queue, 2)) {
				ldata = List_Get(h.queue, 2);
				if(!ldata) {
					List_Delete(h.queue, 2);
					continue;
				};
                c = get(ldata);
                c.startVal = h.value;
                c.startTime = MEM_Timer.totalTime;
                _Anim8_SetVelo(h, c);
            }
            else if(h.dif) {
                Anim8_Delete(chndl);
            };
        };
    end;
};

//========================================
// Wert eines Objektes holen
//========================================
func int Anim8_Get(var int hndl) {
    if(!Hlp_IsValidHandle(hndl)) {
        return 0;
    };
    var A8Head h; h = get(hndl);
    if(h.flt) {
        return h.value;
    };
    return roundf(h.value);
};

//========================================
// Wert eines Objektes setzen
//========================================
func void Anim8_Set(var int hndl, var int v) {
    if(!Hlp_IsValidHandle(hndl)) {
        return;
    };
    var A8Head h; h = get(hndl);
    h.value = v;
};

//========================================
// Objekt zerstören wenn es leer ist?
//========================================
func void Anim8_RemoveIfEmpty(var int hndl, var int on) {
    if(!Hlp_IsValidHandle(hndl)) {
        return;
    };
    var A8Head h; h = get(hndl);
    h.dif = !!on;
};


//========================================
// Ist das Objekt leer?
//========================================
func int Anim8_Empty(var int hndl) {
    if(!Hlp_IsValidHandle(hndl)) {
        return 1;
    };
    var A8Head h; h = get(hndl);
    if(!h.queue) { return 1; };
    return List_HasLength(h.queue, 2);
};

//========================================
// Neuer Befehl
//========================================
func void Anim8(var int hndl, var int target, var int span, var int interpol) {
    _Anim8_Ext(hndl, target, span + (!span), interpol, 0);
};

//========================================
// Neuen Befehl anhängen
//========================================
func void Anim8q(var int hndl, var int target, var int span, var int interpol) {
    _Anim8_Ext(hndl, target, span + (!span), interpol, 1);
};














