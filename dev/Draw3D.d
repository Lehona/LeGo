/***********************************\
                DRAW3D
\***********************************/

//========================================
// [intern] PM-Classes
//========================================
class Line {
    var int start[3];
    var int end[3];
    var int color;
};
instance Line@(Line);

class Sphere {
//class zTBSphere3D {
   var int center[3];      //0x00 zPOINT3
   var int radius;         //0x0C zVALUE
//}
   var int color;
};
instance Sphere@(Sphere);

class BBox { // Same as zTBBox3D, but with color
//class zTBBox3D {
    var int mins[3];
    var int maxs[3];
//}
    var int color;
};
instance BBox@(BBox);

class OBBox { // Same as zCOBBox3D, but with color
//class zCOBBox3D {
    var int center[3];     //0x00 zVEC3
    var int axis[9];       //0x0C zVEC3[3]
    var int extent[3];     //0x30 zVEC3
  //zCList<zCOBBox3D> children;
    var int children_data; //0x3C zCOBBox3D*
    var int children_next; //0x40 zCListSort<zCOBBox3D>*
  //}
//}
    var int color;
};
instance OBBox@(OBBox);


//========================================
// Update line
//========================================
func void UpdateLine(var int hndl, var int startPosPtr, var int endPosPtr, var int color) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var int itmPtr; itmPtr = getPtr(hndl);
    var Line itm; itm = _^(itmPtr);

    if (startPosPtr) {
        MEM_CopyBytes(startPosPtr, itmPtr,    12);
    };
    if (endPosPtr) {
        MEM_CopyBytes(endPosPtr,   itmPtr+12, 12);
    };
    if (color >= 0) {
        itm.color = color;
    };
};
func void UpdateLine3(var int hndl,
                      var int x1, var int y1, var int z1,
                      var int x2, var int y2, var int z2,
                      var int color) {
    var int startPos[3]; var int endPos[3];
    startPos[0] = x1; endPos[0] = x2;
    startPos[1] = y1; endPos[1] = y2;
    startPos[2] = z1; endPos[2] = z2;
    UpdateLine(hndl, _@(startPos), _@(endPos), color);
};
func void UpdateLineAddr(var int hndl, var int linePtr, var int color) {
    UpdateLine(hndl, linePtr, linePtr+12, color);
};

//========================================
// Add line
//========================================
func int DrawLine(var int startPosPtr, var int endPosPtr, var int color) {
    var int hndl; hndl = new(Line@);
    UpdateLine(hndl, startPosPtr, endPosPtr, color);
    return hndl;
};
func int DrawLine3(var int x1, var int y1, var int z1,
                   var int x2, var int y2, var int z2,
                   var int color) {
    var int startPos[3]; var int endPos[3];
    startPos[0] = x1; endPos[0] = x2;
    startPos[1] = y1; endPos[1] = y2;
    startPos[2] = z1; endPos[2] = z2;
    return DrawLine(_@(startPos), _@(endPos), color);
};
func int DrawLineAddr(var int linePtr, var int color) {
    if (linePtr) {
        return DrawLine(linePtr, linePtr+12, color);
    } else {
        return DrawLine(0, 0, color);
    };
};

//========================================
// Remove line
//========================================
func void EraseLine(var int hndl) {
    delete(hndl);
};

//========================================
// Is line visible
//========================================
func int LineVisible(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return FALSE;
    };

    var Line itm; itm = get(hndl);
    return (itm.color >= 0);
};

//========================================
// Toggle visibility of line
//========================================
func void ToggleLine(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var Line itm; itm = get(hndl);
    itm.color = -itm.color;
};

//========================================
// Show line
//========================================
func void ShowLine(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var Line itm; itm = get(hndl);
    if (itm.color < 0) {
        itm.color = -itm.color;
    };
};

//========================================
// Hide line
//========================================
func void HideLine(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var Line itm; itm = get(hndl);
    if (itm.color >= 0) {
        itm.color = -itm.color;
    };
};


//========================================
// Spheres
//========================================


//========================================
// Update sphere
//========================================
func void UpdateSphere(var int hndl, var int centerPosPtr, var int radius, var int color) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var int itmPtr; itmPtr = getPtr(hndl);
    var Sphere itm; itm = _^(itmPtr);

    if (centerPosPtr) {
        MEM_CopyBytes(centerPosPtr, itmPtr, 12);
    };
    if (gef(radius, FLOATNULL)) {
        itm.radius = radius;
    };
    if (color >= 0) {
        itm.color = color;
    };
};
func void UpdateSphere3(var int hndl,
                        var int x, var int y, var int z,
                        var int radius,
                        var int color) {
    var int centerPos[3];
    centerPos[0] = x;
    centerPos[1] = y;
    centerPos[2] = z;
    UpdateSphere(hndl, _@(centerPos), radius, color);
};
func void UpdateSphereAddr(var int hndl, var int spherePtr, var int color) {
    if (spherePtr) {
        UpdateSphere(hndl, spherePtr, MEM_ReadInt(spherePtr+12), color);
    } else {
        UpdateSphere(hndl, 0, 0, color);
    };
};

//========================================
// Add sphere
//========================================
func int DrawSphere(var int centerPosPtr, var int radius, var int color) {
    var int hndl; hndl = new(Sphere@);
    UpdateSphere(hndl, centerPosPtr, radius, color);
    return hndl;
};
func int DrawSphere3(var int x, var int y, var int z,
                     var int radius,
                     var int color) {
    var int centerPos[3];
    centerPos[0] = x;
    centerPos[1] = y;
    centerPos[2] = z;
    return DrawSphere(_@(centerPos), radius, color);
};
func int DrawSphereAddr(var int spherePtr, var int color) {
    if (spherePtr) {
        return DrawSphere(spherePtr, MEM_ReadInt(spherePtr+12), color);
    } else {
        return DrawSphere(0, 0, color);
    };
};

//========================================
// Remove sphere
//========================================
func void EraseSphere(var int hndl) {
    delete(hndl);
};

//========================================
// Is sphere visible
//========================================
func int SphereVisible(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return FALSE;
    };

    var Sphere itm; itm = get(hndl);
    return (itm.color >= 0);
};

//========================================
// Toggle visibility of sphere
//========================================
func void ToggleSphere(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var Sphere itm; itm = get(hndl);
    itm.color = -itm.color;
};

//========================================
// Show sphere
//========================================
func void ShowSphere(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var Sphere itm; itm = get(hndl);
    if (itm.color < 0) {
        itm.color = -itm.color;
    };
};

//========================================
// Hide sphere
//========================================
func void HideSphere(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var Sphere itm; itm = get(hndl);
    if (itm.color >= 0) {
        itm.color = -itm.color;
    };
};


//========================================
// Bounding boxes
//========================================


//========================================
// Update bounding box
//========================================
func void UpdateBBox(var int hndl, var int startPosPtr, var int endPosPtr, var int color) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var int itmPtr; itmPtr = getPtr(hndl);
    var BBox itm; itm = _^(itmPtr);

    if (startPosPtr) {
        MEM_CopyBytes(startPosPtr, itmPtr,    12);
    };
    if (endPosPtr) {
        MEM_CopyBytes(endPosPtr,   itmPtr+12, 12);
    };
    if (color >= 0) {
        itm.color = color;
    };
};
func void UpdateBBox3(var int hndl,
                      var int x1, var int y1, var int z1,
                      var int x2, var int y2, var int z2,
                      var int color) {
    var int startPos[3]; var int endPos[3];
    startPos[0] = x1; endPos[0] = x2;
    startPos[1] = y1; endPos[1] = y2;
    startPos[2] = z1; endPos[2] = z2;
    UpdateBBox(hndl, _@(startPos), _@(endPos), color);
};
func void UpdateBBoxAddr(var int hndl, var int bboxPtr, var int color) {
    if (bboxPtr) {
        UpdateBBox(hndl, bboxPtr, bboxPtr+12, color);
    } else {
        UpdateBBox(hndl, 0, 0, color);
    };
};

//========================================
// Add bounding box
//========================================
func int DrawBBox(var int startPosPtr, var int endPosPtr, var int color) {
    var int hndl; hndl = new(BBox@);
    UpdateBBox(hndl, startPosPtr, endPosPtr, color);
    return hndl;
};
func int DrawBBox3(var int x1, var int y1, var int z1,
                   var int x2, var int y2, var int z2,
                   var int color) {
    var int startPos[3]; var int endPos[3];
    startPos[0] = x1; endPos[0] = x2;
    startPos[1] = y1; endPos[1] = y2;
    startPos[2] = z1; endPos[2] = z2;
    return DrawBBox(_@(startPos), _@(endPos), color);
};
func int DrawBBoxAddr(var int bboxPtr, var int color) {
    if (bboxPtr) {
        return DrawBBox(bboxPtr, bboxPtr+12, color);
    } else {
        return DrawBBox(0, 0, color);
    };
};

//========================================
// Remove bounding box
//========================================
func void EraseBBox(var int hndl) {
    delete(hndl);
};

//========================================
// Is bounding box visible
//========================================
func int BBoxVisible(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return FALSE;
    };

    var BBox itm; itm = get(hndl);
    return (itm.color >= 0);
};

//========================================
// Toggle visibility of bounding box
//========================================
func void ToggleBBox(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var BBox itm; itm = get(hndl);
    itm.color = -itm.color;
};

//========================================
// Show bounding box
//========================================
func void ShowBBox(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var BBox itm; itm = get(hndl);
    if (itm.color < 0) {
        itm.color = -itm.color;
    };
};

//========================================
// Hide bounding box
//========================================
func void HideBBox(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var BBox itm; itm = get(hndl);
    if (itm.color >= 0) {
        itm.color = -itm.color;
    };
};



//========================================
// Oriented bounding boxes
//========================================


//========================================
// Update oriented bounding box
//========================================
func void UpdateOBBoxAddr(var int hndl, var int obboxPtr, var int color) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var int itmPtr; itmPtr = getPtr(hndl);
    var OBBox itm; itm = _^(itmPtr);

    if (obboxPtr) {
        MEM_CopyBytes(obboxPtr, itmPtr, sizeof(OBBox@)-4); // Exclude color
    };
    if (color >= 0) {
        itm.color = color;
    };
};

//========================================
// Add oriented bounding box
//========================================
func int DrawOBBoxAddr(var int obboxPtr, var int color) {
    var int hndl; hndl = new(OBBox@);
    UpdateOBBoxAddr(hndl, obboxPtr, color);
    return hndl;
};

//========================================
// Remove oriented bounding box
//========================================
func void EraseOBBox(var int hndl) {
    delete(hndl);
};

//========================================
// Is oriented bounding box visible
//========================================
func int OBBoxVisible(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return FALSE;
    };

    var OBBox itm; itm = get(hndl);
    return (itm.color >= 0);
};

//========================================
// Toggle visibility of OBBox
//========================================
func void ToggleOBBox(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var OBBox itm; itm = get(hndl);
    itm.color = -itm.color;
};

//========================================
// Show oriented bounding box
//========================================
func void ShowOBBox(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var OBBox itm; itm = get(hndl);
    if (itm.color < 0) {
        itm.color = -itm.color;
    };
};

//========================================
// Hide oriented bounding box
//========================================
func void HideOBBox(var int hndl) {
    if (!Hlp_IsValidHandle(hndl)) {
        return;
    };

    var OBBox itm; itm = get(hndl);
    if (itm.color >= 0) {
        itm.color = -itm.color;
    };
};


//========================================
// Erase all draw elements
//========================================
func void EraseAll() {
    foreachHndl(Line@,   EraseLine);
    foreachHndl(Sphere@, EraseSphere);
    foreachHndl(BBox@,   EraseBBox);
    foreachHndl(OBBox@,  EraseOBBox);
};

//========================================
// [intern] Enginehook
//========================================
func void _DrawHook() {
    if (!Hlp_IsValidNpc(hero)) 
    || (MEM_Game.pause_screen) {
        return;
    };

    foreachHndl(Line@,   _DrawAllLines);
    foreachHndl(Sphere@, _DrawAllSpheres);
    foreachHndl(BBox@,   _DrawAllBBoxes);
    foreachHndl(OBBox@,  _DrawAllOBBoxes);
};
func int _DrawAllLines(var int hndl) {
    var Line itm; itm = get(hndl);

    // Skip hidden lines
    if (itm.color < 0) {
        return rContinue;
    };

    var int pos1Ptr; pos1Ptr = _@(itm.start);
    var int pos2Ptr; pos2Ptr = _@(itm.end);
    var int color;   color   = itm.color;

    const int call = 0; var int zero;
    if (CALL_Begin(call)) {
        CALL_IntParam(_@(zero));
        CALL_IntParam(_@(color));   // zCOLOR
        CALL_PtrParam(_@(pos2Ptr)); // zVEC3*
        CALL_PtrParam(_@(pos1Ptr)); // zVEC3*
        CALL__thiscall(_@(zlineCache), zCLineCache__Line3D);
        call = CALL_End();
    };

    return rContinue;
};
func int _DrawAllSpheres(var int hndl) {
    var int itmPtr; itmPtr = getPtr(hndl);
    var Sphere itm; itm = _^(itmPtr);

    // Skip hidden lines
    if (itm.color < 0) {
        return rContinue;
    };

    var int cPtr; cPtr = _@(itm.color);

    const int call = 0;
    if (CALL_Begin(call)) {
        CALL_IntParam(_@(cPtr)); // zCOLOR*
        CALL__thiscall(_@(itmPtr), zTBSphere3D__Draw);
        call = CALL_End();
    };

    return rContinue;
};
func int _DrawAllBBoxes(var int hndl) {
    var int itmPtr; itmPtr = getPtr(hndl);
    var BBox itm; itm = _^(itmPtr);

    // Skip hidden BBoxes
    if (itm.color < 0) {
        return rContinue;
    };

    var int cPtr; cPtr = _@(itm.color);

    const int call = 0;
    if (CALL_Begin(call)) {
        CALL_PtrParam(_@(cPtr)); // zCOLOR*
        CALL__thiscall(_@(itmPtr), zTBBox3D__Draw);
        call = CALL_End();
    };

    return rContinue;
};
func int _DrawAllOBBoxes(var int hndl) {
    var int itmPtr; itmPtr = getPtr(hndl);
    var OBBox itm; itm = _^(itmPtr);

    // Skip hidden OBBoxes
    if (itm.color < 0) {
        return rContinue;
    };

    var int color; color = itm.color;

    const int call = 0; const int one = 1;
    if (CALL_Begin(call)) {
        CALL_PtrParam(_@(color)); // zCOLOR
        CALL_IntParam(_@(one));   // Do not draw child boxes
        CALL__thiscall(_@(itmPtr), zCOBBox3D__Draw);
        call = CALL_End();
    };

    return rContinue;
};
