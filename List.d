/***********************************\
                LIST
\***********************************/

//************************************
//        Warum?
/* ***********************************

-Der (größere) Umgang mit Listen ist zuteils nervig, gerade weil man ganz fix Fehler einbaut
 oder viel tippen darf (dutzende Instanzzuweisungen). Da es noch keine Funktionen für Listen
 gibt habe ich einfach mal ein paar geschrieben... Es sollte eigentlich alles abgedeckt sein
 was man so braucht und auch noch vieles mehr...

//************************************
//        Was ist zu beachten?
//************************************

-Ich verwende gerne das Wort 'node', es meint ein Listenelement.
-List_Init() in der Init_Global() aufrufen, ansonten ist List_CopyTo() bzw. List_CopyToS() nicht nutzbar!
-Den Anfang einer Liste solltet ihr nicht "wegschmeißen", man kommt an den Anfang nicht wieder ran!
-Nicht alle Funktionen sind "sicher" und auch die, die es sind kann ich nicht ausreichend absichern,
 weil ich anhand eines Pointer nicht die Validität einer Liste erschließen kann.
-Ihr müsst zwischen zCList und zCListSort unterscheiden. Bei letzteren enden alle Funktionen einfach
 mit einem 'S'.
-Ab und an verlange ich direkt eine Node (Listenelement), ab und an eine Nummer... Im Normalfall die
 Nummer, aber es erschien mir bei bestimmten Funktionen auch für den Nutzer praktischer, wenn ich
 direkt nach der Node frage.

//************************************
//        Benutzung der Funktionen:
//************************************

/**********
//  Listen
/**********

func void List_Add(var int list, var int data)
// Hängt eine Node, die den Wert 'data' hält, ans Ende der Liste 'list' an.

func void List_AddOffset(var int list, var int offset, var int data)
// Fügt eine Node zwischen der Node Nr. offset und Node Nr. offset + 1 mit dem Wert 'data' ein.

func void List_Set(var int node, var int data)
// Setz den Wert der Node 'node' auf 'data'.

func int List_Get(var int list, var int nr)
// Gibt den Wert der Node mit der Nummer 'nr' zurück.

func int List_Node(var int list, var int nr)
// Gibt die Node mit der Nummer 'nr' zurück.

func int List_Length(var int list)
// Gibt die Länge der Liste zurück (Anzahl aller Elemente)

func int List_End(var int list)
// Gibt die letzte Node der Liste zurück.

func int List_Contains(var int list, var int data)
// Gibt die letzte Node mit dem Wert 'data' zurück.

func int List_For(var int list, var string function)
// Ruft die Funktion 'function' für jede Listenelement auf,
// die einzelne Node wird dabei als Parameter (Pointer) übergeben.

func void List_Delete(var int list, var int nr)
// Löscht die Node mit der Nummer 'nr'.

func void List_Destroy(var int list)
// Zerstört die komplette Liste.

func int List_ToArray(var int list)
// Gibt einen Pointer auf einen Speicherbereich frei, in dem der gehaltene
// Wert der Listenelemente wie in einem Array aneinandergereiht steht.

func int List_CopyTo(var int list, var int array)
// Kopiert die Werte der Liste in ein statisches Array (Gothic-Array).

func int List_Sort(var int list, var int valueOffset)
// Sortiert die Liste nach dem Wert, der in der valueOffset Bytes hinter dem Anfang
// des gehaltenen Objekts steht (Bei oCNPCs und einem valueOffset von 432 würde nach
// dem NPC-Type sortiert werden).
// Dank hierfür geht an Gottfried weil ich mal wieder zu faul war (Und keine Ahnung
// von Sortier-Algorythmen habe).

func void List_MoveUp(var int list, var int nr)
// Rückt die Node mit der Nummer 'nr' um eins näher
// an den Beginn der Liste.
// Ergab sich als Nebenprodukt der Sortierfunktion,
// Dank geht also an Gottfried.

func void List_MoveDown(var int list, var int nr)
// Rückt die Node mit der Nummer 'nr' um eins weiter
// vom Beginn der Liste weg.
// Ergab sich als Nebenprodukt der Sortierfunktion,
// Dank geht also an Gottfried.



/* * * * * * * * * * * * * * * * * * * * * * * * */
// INTERNA! DO NOT CHANGE! INTERNA! DO NOT CHANGE!
/* * * * * * * * * * * * * * * * * * * * * * * * */


// Get the end of the list
func int List_EndSub(var int list)    {    // subfunction to provide usersafety
    if MEM_ReadInt(list+4)    {
        return List_EndSub(MEM_ReadInt(list+4));
    };
    return list;
};
func int List_End(var int list)    {
    if (!list)    {
        MEM_Error("List_End: no valid pointer");
    };
    return List_EndSub(list);
};

func int List_EndSubS(var int list)    {
    if MEM_ReadInt(list+8)    {
        return List_End(MEM_ReadInt(list+8));
    };
    return list;
};
func int List_EndS(var int list)    {
    if (!list)    {
        MEM_Error("List_EndS: no valid pointer");
    };
    return List_EndSubS(list);
};


// Get the Length of the list
func int List_LengthSub(var int list, var int nr)    { // subfunction to provide usersafety
    if MEM_ReadInt(list+4)    {
        return List_LengthSub(MEM_ReadInt(list+4), nr+1);
    };
    return nr;
};
func int List_Length(var int list)    {
    if (!list)    {
        MEM_Error("List_Length: no valid pointer");
        return -1;
    };
    return List_LengthSub(list, 1);
};

func int List_LengthSubS(var int list, var int nr)    {
    if MEM_ReadInt(list+8)    {
        return List_LengthSubS(MEM_ReadInt(list+8), nr+1);
    };
    return nr;
};
func int List_LengthS(var int list)    {
    if (!list)    {
        MEM_Error("List_LengthS: no valid pointer");
    };
    return List_LengthSubS(list, 1);
};


// Get a specific node of the list by number
func int List_NodeSub(var int list, var int nr)    { // subfunction to provide usersafety
    nr -= 1;
    if (!nr)    {
        return list;
    };
    return List_NodeSub(MEM_ReadInt(list+4), nr);
};
func int List_Node(var int list, var int nr)    {
    if nr > List_Length(list)    {
        MEM_Error("List_Node: nr is greater than the list");
    };
    return List_NodeSub(list, nr);
};

func int List_NodeSubS(var int list, var int nr)    {
    nr -= 1;
    if (!nr)    {
        return list;
    };
    return List_NodeSubS(MEM_ReadInt(list+8), nr);
};
func int List_NodeS(var int list, var int nr)    {
    if nr > List_LengthS(list)    {
        MEM_Error("List_Node: nr is greater than the list");
    };
    return List_NodeSubS(list, nr);
};


// add a node to a list
func void List_Add(var int list, var int data)    {
    if (!list)    {
        MEM_Error("List_Add: not valid list");
        return;
    };
    var int ptr; ptr = MEM_Alloc(8);
    MEM_WriteInt(List_End(list)+4, ptr);
    MEM_WriteInt(ptr, data);
};

func void List_AddS(var int list, var int data)    {
    if (!list)    {
        MEM_Error("List_AddS: not valid list");
        return;
    };
    var int ptr; ptr = MEM_Alloc(12);
    MEM_WriteInt(List_End(list)+8, ptr);
    MEM_WriteInt(ptr+4, data);
};

func void List_Concat(var int list, var int list2) {
	if ((!list)||(!list2)) {
        MEM_Error("List_Concat: not valid list");
        return;
    };
	var zCList l; l = MEM_PtrToInst(List_End(list));
	l.next = list2;
};

func void List_ConcatS(var int list, var int list2) {
	if ((!list)||(!list2)) {
        MEM_Error("List_ConcatS: not valid list");
        return;
    };
	var zCListSort l; l = MEM_PtrToInst(List_EndS(list));
	l.next = list2;
};

// delete a node of a list by number
func void List_Delete(var int list, var int nodeNr)    {
    var int prev; prev = List_Node(list, nodeNr-1);
    var int del; del = MEM_ReadInt(prev+4);
    MEM_WriteInt(prev+4, MEM_ReadInt(del+4));
    MEM_Free(del);
};

func void List_DeleteS(var int list, var int nodeNr)    {
    var int prev; prev = List_NodeS(list, nodeNr-1);
    var int del; del = MEM_ReadInt(prev+8);
    MEM_WriteInt(prev+8, MEM_ReadInt(del+8));
    MEM_Free(del);
};


// delete a complete list
func void List_Destroy(var int list)    {
    if (!list)    {
        MEM_Error("List_Destroy: invalid list");
        return;
    };
    var int pos; pos = MEM_StackPos.position;
    if (!MEM_ReadInt(list+4))    {
        MEM_Free(list);
        return;
    };
    List_Delete(list, 2);
    MEM_StackPos.position = pos;
};

func void List_DestroyS(var int list)    {
    if (!list)    {
        MEM_Error("List_DestroyS: invalid list");
        return;
    };
    var int pos; pos = MEM_StackPos.position;
    if (!MEM_ReadInt(list+8))    {
        MEM_Free(list);
        return;
    };
    List_DeleteS(list, 2);
    MEM_StackPos.position = pos;
};


// Call a function for every node and pass the node with it
func void List_For(var int list, var string function)    {
    function = STR_Upper(function);
    var int pos; pos = MEM_StackPos.position;
    if (list)    {
        MEM_PushIntParam(list);
        MEM_CallByString(function);
        list = MEM_ReadInt(list+4);
        MEM_StackPos.position = pos;
    };
};

func void List_ForS(var int list, var string function) {
    function = STR_Upper(function);
    var int pos; pos = MEM_StackPos.position;
    if (list) {
        MEM_PushIntParam(list);
        MEM_CallByString(function);
        list = MEM_ReadInt(list+8);
        MEM_StackPos.position = pos;
    };
};


// copys a list to an array (memory of the size 4*nodes Bytes, contains the data in every word)

func int List_ToArray(var int list)    {
    var int ptr; ptr = MEM_Alloc(List_Length(list)*4);
    var int count; count = 0;
    var int pos; pos = MEM_StackPos.position;

    MEM_WriteInt(ptr+(4*count), MEM_ReadInt(list));
    count += 1;
    if MEM_ReadInt(list+4)    {
        list = MEM_ReadInt(list+4);
        MEM_StackPos.position = pos;
    };

    return ptr;
};


func int List_ToArrayS(var int list)    {
    var int ptr; ptr = MEM_Alloc(List_Length(list)*4);
    var int count; count = 0;
    var int pos; pos = MEM_StackPos.position;

    MEM_WriteInt(ptr+(4*count), MEM_ReadInt(list+4));
    count += 1;
    if MEM_ReadInt(list+8)    {
        list = MEM_ReadInt(list+8);
        MEM_StackPos.position = pos;
    };

    return ptr;
};


// copys a list to an static array
func int List_CopyToINT()    {
    MEMINT_StackPopInst();
    MEMINT_StackPushInst(zPAR_TOK_PUSHINT);

      var int ptr; ptr = MEMINT_StackPopInt();
    var int list; list = MEMINT_StackPopInt();
    var int count; count = 0;
    var int pos; pos = MEM_StackPos.position;

    MEM_WriteInt(ptr+(4*count), MEM_ReadInt(list));
    count += 1;
    if MEM_ReadInt(list+4)    {
        list = MEM_ReadInt(list+4);
        MEM_StackPos.position = pos;
    };
    return ptr;
};
func int List_CopyTo(var int list, var int statArr)    {
     MEM_Error ("List_CopyTo was called before List_Init");
};

func int List_CopyToINTS()    {
    MEMINT_StackPopInst();
    MEMINT_StackPushInst(zPAR_TOK_PUSHINT);

    var int ptr; ptr = MEMINT_StackPopInt ();
    var int list; list = MEMINT_StackPopInt ();
    var int count; count = 0;
    var int pos; pos = MEM_StackPos.position;

    MEM_WriteInt(ptr+(4*count), MEM_ReadInt(list+4));
    count += 1;
    if MEM_ReadInt(list+8)    {
        list = MEM_ReadInt(list+8);
        MEM_StackPos.position = pos;
    };

    return ptr;
};
func int List_CopyToS()    {
 MEM_Error ("List_CopyToS was called before List_Init");
};


func int List_Init()    {
     MEM_ReplaceFunc(List_CopyTo,  List_CopyToINT);
     MEM_ReplaceFunc(List_CopyToS, List_CopyToINTS);
};

// gets the data of node nr 'nodeNr'
func int List_Get(var int list, var int nr)    {
    return MEM_ReadInt (List_Node(list, nr));
};

func int List_GetS(var int list, var int nr)    {
    return MEM_ReadInt(List_NodeS(list, nr)+4);
};


// sets the data 'data' of node 'node'
func void List_Set(var int node, var int data)    {
    MEM_WriteInt(node, data);
};

func void List_SetS(var int node, var int data)    {
    MEM_WriteInt(node+4, data);
};


// returns  the last node which contains the pointer 'data'
func int List_Contains(var int list, var int data)    {
    var int node; node = 0;
    var int pos; pos = MEM_StackPos.position;
        if (data == MEM_ReadInt(list))    {
        node = list;
    };
    list = MEM_ReadInt(list+4);
    if (list) {
        MEM_StackPos.position = pos;
    };
    return node;
};


func int List_ContainsS(var int list, var int data)    {
    var int node; node = 0;
    var int pos; pos = MEM_StackPos.position;
        if data == MEM_ReadInt(list+4)    {
        node = list;
    };
    list = MEM_ReadInt(list+8);
    if (list) {
        MEM_StackPos.position = pos;
    };
    return node;
};

// adds a node between node nr. 'offset' and node nr. 'offset + 1'
func void List_AddOffset(var int list, var int offset, var int data)    {
    var int prev; prev = List_Node(list, offset);
    var int next; next = MEM_ReadInt(prev+4);
    var int ptr; ptr = MEM_Alloc(8);
    MEM_WriteInt(prev+4, ptr);
    MEM_WriteInt(ptr+4, next);
    MEM_WriteInt(ptr, data);
};
func void List_AddOffsetS(var int list, var int offset, var int data)    {
    var int prev; prev = List_NodeS(list, offset);
    var int next; next = MEM_ReadInt(prev+8);
    var int ptr; ptr = MEM_Alloc(12);
    MEM_WriteInt(prev+8, ptr);
    MEM_WriteInt(ptr+8, next);
    MEM_WriteInt(ptr+4, data);
};


func void List_MoveDownS(var int list, var int offset) {
    var int prev;   prev = List_NodeS(list, offset-1);
    var int prev_s; prev_s = MEM_ReadInt(prev+4);
    var int act_s;  act_s  = MEM_ReadInt(list+4);
    MEM_WriteInt(prev+4, act_s);
    MEM_WriteInt(list+4, prev_s);
};

func void List_MoveUpS(var int list, var int offs) {
    var int next;   next  = MEM_ReadInt(list+8);
    var int next_s; next_s = MEM_ReadInt(next+4);
    var int act_s;  act_s  = MEM_ReadInt(list+4);
    MEM_WriteInt(next+4, act_s);
    MEM_WriteInt(list+4, next_s);
};

func void List_SortS(var int list, var int offsval) {
    var int list_len; list_len = List_EndS(list);
    var int i; i = 0;
    var int c; c = 1;
    var int prev;
    var int node;
    var int prev_val;
    var int node_val;
    var int pos0; pos0 = MEM_StackPos.position;
    if(c) {
        c = 0;
        var int pos1; pos1 = MEM_StackPos.position;
        if(i < list_len) {
            prev = List_NodeS(list, i-1);
            node = List_NodeS(list, i);
            prev_val = MEM_ReadInt(MEM_ReadInt(prev+4)+offsval);
            node_val = MEM_ReadInt(MEM_ReadInt(node+4)+offsval);
            if(node_val<prev_val) {
                c = 1;
                List_MoveDownS(list, i);
            };
            i += 1;
            MEM_StackPos.position = pos1;
        };
        MEM_StackPos.position = pos0;
    };
};

func void List_MoveDown(var int list, var int offset) {
    var int prev;   prev = List_Node(list, offset-1);
    var int prev_s; prev_s = MEM_ReadInt(prev);
    var int act_s;  act_s  = MEM_ReadInt(list);
    MEM_WriteInt(prev, act_s);
    MEM_WriteInt(list, prev_s);
};

func void List_MoveUp(var int list, var int offs) {
    var int next;   next  = MEM_ReadInt(list+4);
    var int next_s; next_s = MEM_ReadInt(next);
    var int act_s;  act_s  = MEM_ReadInt(list);
    MEM_WriteInt(next, act_s);
    MEM_WriteInt(list, next_s);
};

func void List_Sort(var int list, var int offsval) {
    var int list_len; list_len = List_End(list);
    var int i; i = 0;
    var int c; c = 1;
    var int prev;
    var int node;
    var int prev_val;
    var int node_val;
    var int pos0; pos0 = MEM_StackPos.position;
    if(c) {
        c = 0;
        var int pos1; pos1 = MEM_StackPos.position;
        if(i < list_len) {
            prev = List_Node(list, i-1);
            node = List_Node(list, i);
            prev_val = MEM_ReadInt(MEM_ReadInt(prev)+offsval);
            node_val = MEM_ReadInt(MEM_ReadInt(node)+offsval);
            if(node_val<prev_val) {
                c = 1;
                List_MoveDown(list, i);
            };
            i += 1;
            MEM_StackPos.position = pos1;
        };
        MEM_StackPos.position = pos0;
    };
};

//***********************/
//  Listen erstellen
//***********************/
/* Um eigene Listen zu erstellen noch zwei kleine Funktiönchen:
 * (Einmal für eine  normale List und noch einmal mit einem angehängten 'S'
 * für eine ListSort)

func int List_Create(int data)
// Erstellt eine neue Liste und beschreibt Node 0 direkt mit 'data'

*/

func int List_Create(var int data) {
    var int ptr; ptr = MEM_Alloc(8);
    MEM_WriteInt(ptr, data);
    return ptr;
};

func int List_CreateS(var int data) {
    var int ptr; ptr = MEM_Alloc(12);
    MEM_WriteInt(ptr+4, data);
    return ptr;
};

//***********************/
//  Inkludierende Listen
//***********************/

/* Vorab  ein  Beispiel um den  Unterschied zwischen  einer List  und einer
 * Inkludierenden  Liste  zu verdeutlichen: (Die  Liste 'list'  sei bereits
 * gegeben)

 var string str;
 str = "Hallo01";
 List_Add(list, STRINT_toChar(str));
 str = "Hallo02";
 List_Add(list, STRINT_toChar(str));

 * Man würde vermutlich zwei Items wünschen: Eines dass  Hallo01 als string
 * beinhaltet  und eines  dass Hallo02 als string beinhaltet.. Problem  ist
 * nur, dass für beide Operationen der selbe string verwendet wurde -> Also
 * auch der selbe Pointer, folglich steht nun in beiden Hallo02.
 * Inkludierende Listen hingegen legen eine Kopie von dem Inhalt an auf den
 * 'data' zeigt,  allerdings muss dafür manchmal  die größe des Inhaltes in
 * Bytes  gegeben sein. (Dafür  würde  ich eine  Konstante verwenden, damit
 * nichts schief geht) Abgesehen von  den fünf folgenden Funktionen können
 * alle übrigen normal verwendet werden.
 * INFO: Vor  allem bei Delete und Destroy  sollten UNBEDINGT die passenden
 * Funktionen  verwendet  werden.  Wenn  auf  eine Inkludierende Liste  die
 * normale Destroy Funktion angewendet, bleiben alle Kopien der Daten nutz-
 * los im Speicher liegen.. Das sollte man möglichst vermeiden.

 * Info: Es handelt sich nicht wirklich  um eine andere Klasse, sondern nur
 * um die Handhabung vom Hinzufügen/Entfernen der Daten in der Liste.
 * Sprich: Bei den Listen die  von der Engine benutzt  werden, können diese
 * Funktionen auch verwendet werden, dabei sollte man aber höchste Vorsicht
 * walten  lassen: Wenn  man versucht Incl_Delete auf  ein Item anzuwenden,
 * dass NICHT  mit Incl_Add,  Incl_AddOffset oder  Incl_Set  bereitgestellt
 * wurde (oder  von  der  Engine persönlich stammt)  kann es  zu  unschönen
 * Nebenwirkungen kommen...
 * (Da  Incl_Destroy Incl_Delete  nur mehrfach aufruft sollte  man bei  der
 * Verwendung dieser Funktion noch besser aufpassen)

 * (Auch bei den folgenden Funktionen wird zwischen List und ListSort
 * separiert)

func void List_Incl_Add(int list, int data, int size)
// Hängt eine Node, die den Wert 'data' hält, ans Ende der Liste 'list' an.

func void List_Incl_AddOffset(int list, int offset, int data, int size)
// Fügt eine Node zwischen der Node Nr. offset und Node Nr. offset + 1
// mit dem Wert 'data' ein.

func void List_Incl_Set(var int node, var int data, var int size)
// Setz den Wert der Node 'node' auf 'data'.

func void List_Incl_Delete(var int list, var int nr)
// Löscht die Node mit der Nummer 'nr'.

func void List_Incl_Destroy(var int list)
// Zerstört die komplette Liste.

func int List_Incl_Create(var int data, var int size)
// Erstellt eine neue Liste und beschreibt Node 0 direkt mit 'data'

*/

func int List_Incl_Create(var int data, var int size) {
    var int nptr; nptr = MEM_Alloc(8);
    var int dptr; dptr = MEM_Alloc(size);
    MEM_CopyBytes(data, dptr, size);
    MEM_WriteInt(nptr, dptr);
    return nptr;
};
func int List_Incl_CreateS(var int data, var int size) {
    var int nptr; nptr = MEM_Alloc(12);
    var int dptr; dptr = MEM_Alloc(size);
    MEM_CopyBytes(data, dptr, size);
    MEM_WriteInt(nptr+4, dptr);
    return nptr;
};

func void List_Incl_Add(var int list, var int data, var int size) {
    var int nptr; nptr = MEM_Alloc(8);
    var int dptr; dptr = MEM_Alloc(size);
    MEM_CopyBytes(data, dptr, size);
    MEM_WriteInt(List_End(list)+4, nptr);
    MEM_WriteInt(nptr, dptr);
};
func void List_Incl_AddS(var int list, var int data, var int size) {
    var int nptr; nptr = MEM_Alloc(12);
    var int dptr; dptr = MEM_Alloc(size);
    MEM_CopyBytes(data, dptr, size);
    MEM_WriteInt(List_EndS(list)+8, nptr);
    MEM_WriteInt(nptr, dptr);
};

// delete a node of a list by number
func void List_Incl_Delete(var int list, var int nodeNr) {
    var int prev; prev = List_Node(list, nodeNr-1);
    var int del; del = MEM_ReadInt(prev+4);
    MEM_WriteInt(prev+4, MEM_ReadInt(del+4));
    MEM_Free(MEM_ReadInt(del));
    MEM_Free(del);
};
func void List_Incl_DeleteS(var int list, var int nodeNr) {
    var int prev; prev = List_NodeS(list, nodeNr-1);
    var int del; del = MEM_ReadInt(prev+8);
    MEM_WriteInt(prev+8, MEM_ReadInt(del+8));
    MEM_Free(MEM_ReadInt(del+4));
    MEM_Free(del);
};

// delete a complete list
func void List_Incl_Destroy(var int list) {
    if (!list)    {
        MEM_Error("List_Incl_Destroy: invalid list");
        return;
    };
    var int pos; pos = MEM_StackPos.position;
    if (!MEM_ReadInt(list+4))    {
        List_Incl_Delete(list, 0);
        return;
    };
    List_Incl_Delete(list, 1);
    MEM_StackPos.position = pos;
};
func void List_Incl_DestroyS(var int list) {
    if (!list)    {
        MEM_Error("List_Incl_DestroyS: invalid list");
        return;
    };
    var int pos; pos = MEM_StackPos.position;
    if (!MEM_ReadInt(list+8))    {
        List_Incl_DeleteS(list, 0);
        return;
    };
    List_Incl_DeleteS(list, 1);
    MEM_StackPos.position = pos;
};

// sets the data 'data' of node 'node'
func void List_Incl_Set(var int node, var int data, var int size) {
    var int odat; odat = MEM_ReadInt(node);
    if(odat) {
                        // Man könnte auch direkt überschreiben, aber
        MEM_Free(odat); // man weiß ja nie was der User alles treibt,
                        // deswegen lieber ein Reset :p
    };
    var int dptr; dptr = MEM_Alloc(size);
    MEM_CopyBytes(data, dptr, size);
    MEM_WriteInt(node, dptr);
};
func void List_Incl_SetS(var int node, var int data, var int size) {
    var int odat; odat = MEM_ReadInt(node+4);
    if(odat) {
        MEM_Free(odat);
    };
    var int dptr; dptr = MEM_Alloc(size);
    MEM_CopyBytes(data, dptr, size);
    MEM_WriteInt(node+4, dptr);
};

// adds a node between node nr. 'offset' and node nr. 'offset + 1'
func void List_Incl_AddOffset(var int list, var int offset, var int data, var int size) {
    var int prev; prev = List_Node(list, offset);
    var int next; next = MEM_ReadInt(prev+4);
    var int ptr; ptr = MEM_Alloc(8);
    MEM_WriteInt(prev+4, ptr);
    MEM_WriteInt(ptr+4, next);
    var int dptr; dptr = MEM_Alloc(size);
    MEM_CopyBytes(data, dptr, size);
    MEM_WriteInt(ptr, dptr);
};
func void List_Incl_AddOffsetS(var int list, var int offset, var int data, var int size) {
    var int prev; prev = List_NodeS(list, offset);
    var int next; next = MEM_ReadInt(prev+8);
    var int ptr; ptr = MEM_Alloc(12);
    MEM_WriteInt(prev+8, ptr);
    MEM_WriteInt(ptr+8, next);
    var int dptr; dptr = MEM_Alloc(size);
    MEM_CopyBytes(data, dptr, size);
    MEM_WriteInt(ptr+4, dptr);
};