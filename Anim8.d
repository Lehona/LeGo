/***********************************\
                ANIM8
\***********************************/

//========================================
// [intern] Variablen und Klassen
//========================================

class A8Head {
    var int value;
    var int fnc;
    var int dfnc;
    var int flt;
    var int data;
    var int dif;
    var int ddif;
    var int queue; //zCList<A8Command(h)>*
};

// const string A8Head_Struct = "auto|3 zCList*";

func void A8Head_Archiver(var A8Head this) {
    PM_SaveInt("value", this.value);
    if(this.fnc) { PM_SaveFuncPtr("loop",  this.fnc);  };
    if(this.dfnc){ PM_SaveFuncPtr("del",   this.dfnc);  };
    if(this.flt) { PM_SaveFloat  ("float", this.flt);  };
    if(this.data){ PM_SaveInt    ("data",  this.data); };
    if(this.dif) { PM_SaveInt    ("dif",   this.dif);  };
    if(this.ddif){ PM_SaveInt    ("ddif",  this.ddif); };
    PM_SaveClassPtr("queue", this.queue, "zCList");
};

func void A8Head_UnArchiver(var A8Head this) {
    this.value = PM_Load("value");
    if(PM_Exists("loop"))  { this.fnc  = PM_LoadFuncPtr("loop"); };
    if(PM_Exists("del"))   { this.dfnc = PM_LoadFuncPtr("del");  };
    if(PM_Exists("float")) { this.flt  = PM_LoadFloat("float");  };
    if(PM_Exists("data"))  { this.data = PM_LoadInt("data");     };
    if(PM_Exists("dif"))   { this.dif  = PM_LoadInt("dif");      };
    if(PM_Exists("ddif"))  { this.ddif = PM_LoadInt("ddif");     };
    this.queue = PM_Load("queue");
};

func void A8Head_Delete(var A8Head this) {
    if (this.dfnc) {
        MEM_CallByPtr(this.dfnc);
    };
};

func void A8Head_Empty(var A8Head h) {
    if(!h.queue) { return; };
    List_ForF(h.queue, A8Head_EmptySub);
    List_Destroy(h.queue);
    h.queue = 0;
};

func void A8Head_EmptySub(var int node) {
    if(Hlp_IsValidHandle(MEM_ReadInt(node))) {
        delete(MEM_ReadInt(node));
    };
};

instance A8Head@(A8Head);

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
    var int hndl; hndl = new(A8Head@);
    var A8Head h; h = get(hndl);
    if(!IsFloat) {
        h.value = mkf(value);
    }
    else {
        h.value = value;
    };
    h.flt = !!IsFloat;
    return hndl;
};

//========================================
// Neues Objekt mit Handler erstellen
//========================================
func int Anim8_NewExt(var int value, var func handler, var int data, var int IsFloat) {
    var int hndl; hndl = Anim8_New(value, IsFloat);
    var A8Head h; h = get(hndl);
    h.fnc = MEM_GetFuncPtr(handler);
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
    if(!UseQueue) {
        A8Head_Empty(h);
    };
    if(!h.queue) {
        h.queue = List_Create(0);
    };
    var int cmd; cmd = new(A8Command@);
    var A8Command c; c = get(cmd);
    c.target = targetVal;
    if(!h.flt) {
        c.target = mkf(c.target);
    };
      //if((h.value == c.target) && (!UseQueue)) { interpol = A8_Wait; }; // This seemed to be useless and responsible for a bug
    c.startVal = h.value;
    c.startTime = Timer();
    c.timeSpan = mkf(timeSpan);
    c.interpol = interpol;
    _Anim8_SetVelo(h, c);
    List_Add(h.queue, cmd);
};

//========================================
// [intern] FF-Loop
//========================================
func void _Anim8_FFLoop() {
    MEM_PushIntParam(A8Head@);
    MEM_GetFuncID(_Anim8_Loop);
    MEM_StackPos.position = foreachHndl_ptr;
};
func int _Anim8_Loop(var int hndl) {
    var A8Head h; h = get(hndl);
    if(!h.queue) {
        return rContinue;
    };
    if(h.queue < 1048576) {
        var int s; s = SB_New();
        SB ("A8 sucks. Handle ");
        SBi(hndl);
        SB (" of instance ");
        SB (_PM_InstName(getInst(hndl)));
        SB (" messed up with a queue of ");
        SBi(h.queue);
        SB (". I will ignore it.");
        SB (STR_Unescape("\n"));
        SB ("The pointer was ");
        SBi(getPtr(hndl));
        SB ("...");
        MEM_Warn(SB_ToString());
        SB_Destroy();
        return rContinue;
    };
    if(!List_HasLength(h.queue, 2)) {
        return rContinue;
    };

    var int ldata; ldata = List_Get(h.queue, 2);
    if(!ldata) {
        List_Delete(h.queue, 2);
        return rContinue;
    };

    var A8Command c; c = get(ldata);

    // Eigentliche Interpolierung
    var int t; t = mkf(Timer() - c.startTime);

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
        MEM_CallByPtr(h.fnc);
    };

    if(gef(t, c.timeSpan)) {
        delete(ldata);
        List_Delete(h.queue, 2);
        // ggf. Liste aktualisieren
        if(List_HasLength(h.queue, 2)) {
            ldata = List_Get(h.queue, 2);
            if(!ldata) {
                List_Delete(h.queue, 2);
                return rContinue;
            };
            c = get(ldata);
            c.startVal = h.value;
            c.startTime = Timer();
            _Anim8_SetVelo(h, c);
        }
        else if(h.dif) {
            if(h.ddif) {
                if(h.data) {
                    delete(h.data);
                };
            };
            delete(hndl);
        };
    };
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
// Objektdata zerstören wenn es leer ist?
//========================================
func void Anim8_RemoveDataIfEmpty(var int hndl, var int on) {
    if(!Hlp_IsValidHandle(hndl)) {
        return;
    };
    var A8Head h; h = get(hndl);
    h.ddif = !!on;
};

//========================================
// Registriere eine on-remove Funktion
//========================================
func void Anim8_CallOnRemove(var int hndl, var func dfnc) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };
    var A8Head h; h = get(hndl);
    h.dfnc = MEM_GetFuncPtr(dfnc);
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
    return !List_HasLength(h.queue, 2);
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














