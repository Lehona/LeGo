/***********************************\
             BLOODSPLATS
\***********************************/

//========================================
// [intern] Variablen
//========================================
var int Hero_LastHP; //Wird in Bloodsplats_Loop gesetzt.

//========================================
// Spritzer auf den Bildschirm
//========================================
func void Bloodsplat(var int currDam) {
    if(!currDam) {
        return; //Kein Schaden.
    };

    var int ptr; var zCView v;
    var int x; var int y; var int mult;

    var int texSizeX; var int texSizeY;

    Print_GetScreenSize();
    mult = divf(mkf(Print_Screen[PS_X]), mkf(Print_Screen[PS_Y]));

    texSizeX = currDam<<BLOODSPLAT_DAM;
    if(texSizeX > 6144) { texSizeX = 6144; };

    texSizeY = roundf(mulf(mkf(texSizeX), mult));

    if(texSizeX > 3072) {
        // Volltreffer
        x = (r_Max(2)<<13) - (texSizeX>>1);
        y = 1024+r_Max(6144) - (texSizeY>>1);
    }
    else {
        // Norm. Treffer
        x = 1024+r_Max(6144)-(texSizeX>>1);
        y = 1024+r_Max(6144)-(texSizeY>>1);
    };

    ptr = View_Create(x, y, x+texSizeX, y+texSizeY);

	var int s; s = SB_New();
	
	SB ("BLOODSPLAT");
	SBi(r_Max(BLOODSPLAT_TEX));
	SB (".TGA");

    View_SetTexture(ptr, SB_ToString());
	
	SB_Destroy();
	
    View_Open(ptr);
	
	var int a8; a8 = Anim8_NewExt(255, _Bloodsplat_Handler, ptr, false);
	Anim8_RemoveIfEmpty(a8, true);
	Anim8_RemoveDataIfEmpty(a8, true);
	
	Anim8 (a8, 255,  300, A8_Wait);
	Anim8q(a8,   0, 2000, A8_SlowStart);
};

func void _Bloodsplat_Handler(var int h, var int val) {
	var zCView v; v = get(h);
	v.alpha = val;
};

//========================================
// Screen komplett vollpampen
//========================================
func void Bloodsplats_Rage() {
    var int i; i = 0;
    var int pos; pos = MEM_StackPos.position;
    if(i < BLOODSPLAT_NUM) {
        Bloodsplat(100);
        i += 1;
        MEM_StackPos.position = pos;
    };
};

//========================================
// [intern] Perception für den Helden
//========================================
func void _B_HeroDamage() {
    var int currDam; currDam = Hero_LastHP - hero.attribute[ATR_Hitpoints];
    if(currDam) {
        Bloodsplat(currDam);
        if (GOTHIC_BASE_VERSION == 2) {
            // Call by string for Gothic 1 parsing compatibility
            MEM_PushStringParam("HERO_HURT");
            MEM_CallByString("WLD_STOPEFFECT");

            // The effect flickers under Gothic 1
			Wld_PlayEffect("HERO_HURT", hero, hero, 0, 0, 0, 0);
		};
    };
};

//========================================
// [intern] FF Loop
//========================================
func void _Bloodsplats_Loop() {
    // PC_Hero is empty on level change, use hero instead
    Npc_PercEnable(hero, PERC_ASSESSDAMAGE, _B_HeroDamage); //Deaktiviert sich manchmal grundlos, deshalb lieber reinkloppen
    Hero_LastHP = hero.attribute[ATR_Hitpoints];
};
