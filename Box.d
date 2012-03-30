class _InfoBox {
    var int view; // zCView@
    var int btn; // Button@

    var string title;
    var string title_font;
    var string text;
    var string text_font;
    var string button_text;
    var string button_font;
    // Position ist nicht enthalten! User könnten Probleme bekommen, weil beim Berechnen der Position oftmals die Instanz gewechselt wird.
};

prototype InfoBox(_InfoBox) {
    title_font  = "FONT_OLD_10_WHITE.TGA";
    text_font   = "FONT_OLD_10_WHITE.TGA";
    button_font = "FONT_OLD_10_WHITE.TGA";
    text        = "N/A";
    title       = "N/A";
    button_text = "Okay";
};

// Beispiel:
instance InfoBox@(InfoBox) {
    title = "Ich bin eine Infobox";
    text = "The Game ~~~~~You just lost it!";
    button_text = "Okay :-(";
    // Die Fonts haben einen Default-Wert und sind somit optional
};

const string BOX_BACKGROUND = "INV_BACK_SELL.TGA";
const int BOX_SIDE_DIST = 1;
const int BOX_START_TITLE_DIST = 1;
const int BOX_TITLE_TEXT_DIST = 2; // * (Print_GetFontHeight(InfoBox.text_font));
const int BOX_TEXT_BTN_DIST = 3;
const int BOX_BTN_END_DIST = 1;

func int InfoBox_Create(var int x, var int y, var int InfoBox_Inst, var func okay) {
    var int hndl; hndl = new(InfoBox_Inst);
    var _InfoBox box; box = get(hndl);
    var int len; len = Print_GetStringWidth(box.title, box.title_font);
    var int tmp; tmp = Print_LongestLineLength(box.text, box.text_font);
    if (tmp > len) {
        len = tmp;
    };
    tmp = Print_LongestLineLength(box.button_text, box.text_font);
    if (tmp > len) {
        len = tmp;
    };

    len = Print_ToVirtual(len, PS_X) + (2*BOX_SIDE_DIST);


    var int height; height = Print_GetFontHeight(box.text_font);


    var int hi; hi = height*(STR_SplitCount(box.text, Print_LineSeperator)+STR_SplitCount(box.button_text, Print_LineSeperator)+1);
    hi = Print_ToVirtual(hi+(height*(BOX_TITLE_TEXT_DIST + BOX_TEXT_BTN_DIST + BOX_BTN_END_DIST)), PS_Y);

    box.view = View_Create(x, y, len+x, y+hi);
    View_SetTexture(box.view, BOX_BACKGROUND);

    View_Open(box.view);

    View_AddText(box.view, Print_ToVirtual(height*BOX_SIDE_DIST, hi), Print_ToVirtual(height*(BOX_START_TITLE_DIST+BOX_TITLE_TEXT_DIST)+Print_GetFontHeight(box.title_font), hi), box.text, box.text_font);
    View_AddText(box.view, (1<<12)-(Print_ToVirtual(Print_GetStringWidth(box.title, box.title_font)/2, Print_ToPixel(len, PS_X))), Print_ToVirtual(height*BOX_START_TITLE_DIST, hi), box.title, box.title_font);



    /*var int width; width = Print_ToVirtual(30*2+Print_GetStringWidth(STR_Split(btn_text, Print_LineSeperator, 0), font), PS_X)
    var int height; height = Print_ToVirtual(Print_GetFontHeight(font) + 2*20, PS_Y);
    box.btn = Button_Create(1<<13>>1-width/2, y+BOX_START_TITLE_DIST+BOX_START_TITLE_DIST+BOX_TEXT_BTN_DIST*/
};

