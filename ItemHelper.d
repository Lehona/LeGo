const string ITEMHELPER_WAYPOINT = "TOT"; //Daedalus kann keine Konstanten als Wert von Konstanten nehmen... // Ikarus' Waypoint

//--------------------------------------
//  MEM_Helper
//--------------------------------------

INSTANCE ITEM_HELPER_INST (C_NPC)
{
    name = "Itemhelper";
    id = 54;

    /* unsterblich: */
    flags = 2;
    attribute   [ATR_HITPOINTS_MAX] = 2;
    attribute   [ATR_HITPOINTS]     = 2;

    /* irgendein Visual: */
    Mdl_SetVisual           (self,  "Meatbug.mds");
};

var oCNpc Item_Helper;

func void GetItemHelper() {
    Item_Helper = Hlp_GetNpc (ITEM_HELPER_INST);

    if (!Hlp_IsValidNpc (Item_Helper)) {
        //self zwischenspeichern
        var C_NPC selfBak;
        selfBak = Hlp_GetNpc (self);
        Wld_InsertNpc (ITEM_HELPER_INST, ITEMHELPER_WAYPOINT);
        Item_Helper = Hlp_GetNpc (self);
        self = Hlp_GetNpc (selfBak);
    };
};

func int Itm_GetPtr(var int instance) {	
	GetItemHelper();
	if (!Npc_HasItems(Item_Helper, instance)) {
		CreateInvItem(Item_Helper, instance);
	};
	Npc_GetInvItem(Item_Helper, instance);
	return _@(item);
};
