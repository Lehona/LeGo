/***********************************\
              READ-ONLY
\***********************************/
// Folgende Konstanten dürfen NICHT verändert, nur verwendet werden.

//========================================
// Anim8
//========================================
// Bewegungsformen
const int A8_Constant  = 1;
const int A8_SlowEnd   = 2;
const int A8_SlowStart = 3;
const int A8_Wait      = 4;

//========================================
// Buttons
//========================================
const int BUTTON_ACTIVE = 1;
const int BUTTON_ENTERED = 2;

//========================================
// Interface
//========================================
//                        R           G          B          A           R G B
const int COL_Aqua    =             (255<<8) | (255<<0) | (255<<24); //#00FFFF
const int COL_Black   =                                   (255<<24); //#000000
const int COL_Blue    =                        (255<<0) | (255<<24); //#0000FF
const int COL_Fuchsia = (255<<16) |            (255<<0) | (255<<24); //#FF00FF
const int COL_Gray    = (128<<16) | (128<<8) | (128<<0) | (255<<24); //#808080
const int COL_Green   =             (128<<8) |            (255<<24); //#008000
const int COL_Lime    =             (255<<8) |            (255<<24); //#00FF00
const int COL_Maroon  = (128<<16) |                       (255<<24); //#800000
const int COL_Navy    =                        (128<<0) | (255<<24); //#000080
const int COL_Olive   = (128<<16) | (128<<8) |            (255<<24); //#808000
const int COL_Purple  = (128<<16) |            (128<<0) | (255<<24); //#800080
const int COL_Red     = (255<<16) |                       (255<<24); //#FF0000
const int COL_Silver  = (192<<16) | (192<<8) | (192<<0) | (255<<24); //#C0C0C0
const int COL_Teal    =             (128<<8) | (128<<0) | (255<<24); //#008080
const int COL_White   = (255<<16) | (255<<8) | (255<<0) | (255<<24); //#FFFFFF
const int COL_Yellow  = (255<<16) | (255<<8) |            (255<<24); //#FFFF00

const int PS_X = 0;
const int PS_Y = 1;

const int PS_VMax = 8192;








/***********************************\
               MODIFY
\***********************************/
// Folgende Konstanten dienen nicht als Parameter sondern als Vorgaben.
// Sie dürfen frei verändert werden.

//========================================
// Bloodsplats
//========================================
const int BLOODSPLAT_NUM = 15; // Maximale Anzahl auf dem Screen
const int BLOODSPLAT_TEX = 6;  // Maximale Anzahl an Texturen ( "BLOODSPLAT" + texID + ".TGA" )
const int BLOODSPLAT_DAM = 7;  // Schadensmultiplikator bzgl. der Texturgröße ( damage * 2^BLOODSPLAT_DAM )

//========================================
// Cursor
//========================================
const string Cursor_Symbol = "A";                     // Genutzter Buchstabe

const string Cursor_Font   = "CURSOR.TGA"; // Genutzte Schriftart [Cursor.tga wird von LeGo bereitgestellt und enthält nur den Buchstaben 'A']

const int    Cursor_Alpha  = 255;                     // Alpha (0..255; 0 = unsichtbar)

//========================================
// Interface
//========================================
const string Print_LineSeperator = "~";

/* ==== PrintS ==== */
// <<Virtuelle Positionen>>
const int    PF_PrintX      = 200;     // Startposition X
const int    PF_PrintY      = 5000;    // Startposition Y
const int    PF_TextHeight  = 170;     // Abstand zwischen einzelnen Zeilen

// <<Milisekunden>>
const int    PF_FadeInTime  = 300;     // Zeit zum einblenden der Textzeilen 
const int    PF_FadeOutTime = 1000;    // Zeit zum ausblenden der Textzeilen
const int    PF_MoveYTime   = 300;     // Zeit zum verschieben einer Zeile
const int    PF_WaitTime    = 3000;    // Zeit die gewartet wird, bis wieder ausgeblendet wird

const string PF_Font       = "FONT_OLD_10_WHITE.TGA"; //Verwendete Schriftart

//========================================
// Names
//========================================
const int AIV_Name = 89; // Genutzte AI-Var

//========================================
// Quickslots
//========================================
const int zCVob_bitfield4_posInQs = ((1 << 5) - 1) << 7;
const int zCVob_bitfield4_amount = ((1 << 16) - 1) << 12;

const int    QS_SlotSize       = 90;                        // Größe des Renders auf dem Bildschirm
const int    QS_DigitMarginX   = 2;                         // Abstand der Nummerierungen vom Rand des Slots
const int    QS_DigitMarginY   = 12;                        // Abstand der Nummerierungen vom Boden des Slots
const int    QS_DigitCol0      = COL_White;                 // Schriftfarbe
const int    QS_DigitCol1      = COL_White;                 // Schriftfarbe
const string QS_DigitFont      = "FONT_OLD_10_WHITE.TGA";   // Schriftart der Nummerierung
const string QS_SlotBackTex    = "QUICKSLOTS.TGA";          // Hintergrundtextur
const int    QS_SlotBackX      = 512;                       // Breite der Hintergrundtextur
const int    QS_SlotBackY      = 128;                       // Höhe der Hintergrundtextur
const int    QS_SlotBackMargin = 45;                        // Abstand der Mitte des Balkens zum unteren Bildschirmrand
const int    QS_SlotDist       = 50;                        // Abstand der einzelnen Slots horizontal zueinander
const int    QS_SlotDistSep    = 10;                        // Zusatzabstand zwischen Standardwaffen und Zusatzslots

//========================================
// Shields
//========================================
const int    Shield_AIVar0    = 97;             // Eine freie AI-Var
const int    Shield_AIVar1    = 98;             // Eine weitere freie AI-Var
const int    Shield_AIVar2    = 99;             // Und noch eine freie AI-Var  |  Bei Gelegenheit wird das durch ein weiteres Savegame ersetzt.
const string Shield_WP        = "TOT";          // Irgendein Waypoint der in jeder Welt existiert (TOT zB.)

const string Shield_SlotEquip = "ZS_LONGSWORD"; // Wohin wenn das Schild equipped wird?
const string Shield_SlotDrawn = "ZS_LEFTHAND";  // Wohin wenn das Schild gezogen wird?
const int    Shield_Slot      = 4;              // Genutzter Model-Slot
