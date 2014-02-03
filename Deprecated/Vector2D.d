class Vec2 {
	var int x; //float
	var int y;
};

class Vec2D { // Wer Arrays lieber mag. Ich werde Vec2 nutzen.
	var int p[2];
};

instance Vec2@(Vec2);
instance Vec2D@(Vec2D);

func int Vec2_Create(var int x, var int y) {
	var int ptr; ptr = MEM_Alloc(8); 
	var Vec2 v; v = _^(ptr);
	v.x = mkf(x);
	v.y = mkf(y); 
	return +ptr;
};

func int Vec2_Createf(var int x, var int y) {
	var Vec2 v; v = _^(MEM_Alloc(8));
	v.x = x;
	v.y = y;
	return _@(v);
};

func int Vec2_GetX(var int vec) {
	var Vec2 v; v = _^(vec);
	return +v.x;
};

func int Vec2_GetY(var int vec) {
	var Vec2 v; v = _^(vec);
	return +v.y;
};

func int Vec2_SetX(var int vec, var int xVal) {
	var Vec2 v; v = _^(vec);
	v.x = xVal;
};

func int Vec2_SetY(var int vec, var int yVal) {
	var Vec2 v; v = _^(vec);
	v.y = yVal;
};

func int Vec2_magnitude(var int vec) {
	var Vec2 v; v = _^(vec);
	// mag = sqrt(x²+y²);
	return +sqrtf(addf(mulf(v.x, v.x), mulf(v.y, v.y)));
};
func void Vec2_normalize(var int vecPtr) {
	var Vec2 v; v = _^(vecPtr);
	var int mag; mag = Vec2_magnitude(vecPtr);
	v.x = divf(v.x, mag);
	v.y = divf(v.y, mag);
};

func int Vec2_Dotproduct(var int vec1, var int vec2) {
	var Vec2 v1; v1 = _^(vec1);
	var Vec2 v2; v2 = _^(vec2);
	// return x1*x2+y1*y2;
	return +addf(mulf(v1.x, v2.x), mulf(v1.y, v2.y));
};

func int Vec2_AddVec(var int vec1, var int vec2) {
	var Vec2 v1; v1 = _^(vec1);
	var Vec2 v2; v2 = _^(vec2);
	
	return +Vec2_Createf(addf(v1.x, v2.x), addf(v1.y, v2.y));
};

func int Vec2_SubVec(var int vec1, var int vec2) {
	var Vec2 v1; v1 = _^(vec1);
	var Vec2 v2; v2 = _^(vec2);
	
	return +Vec2_Createf(subf(v1.x, v2.x), subf(v1.y, v2.y));
};

func void Vec2_AddConst(var int vec, var int con) {
	var Vec2 v; v = _^(vec);
	v.x = addf(v.x, mkf(con));
	v.y = addf(v.y, mkf(con));
};

func void Vec2_SubConst(var int vec, var int con) {
	var Vec2 v; v = _^(vec);
	v.x = subf(v.x, mkf(con));
	v.y = subf(v.y, mkf(con));
};

func void Vec2_MulConst(var int vec, var int con) {
	var Vec2 v; v = _^(vec);
	v.x = mulf(v.x, mkf(con));
	v.y = mulf(v.y, mkf(con));
};

func void Vec2_DivConst(var int vec, var int con) {
	var Vec2 v; v = _^(vec);
	v.x = divf(v.x, mkf(con));
	v.y = divf(v.y, mkf(con));
};

func void Vec2_AddConstf(var int vec, var int con) {
	var Vec2 v; v = _^(vec);
	v.x = addf(v.x, con);
	v.y = addf(v.y, con);
};

func void Vec2_SubConstf(var int vec, var int con) {
	var Vec2 v; v = _^(vec);
	v.x = subf(v.x, con);
	v.y = subf(v.y, con);
};

func void Vec2_MulConstf(var int vec, var int con) {
	var Vec2 v; v = _^(vec);
	v.x = mulf(v.x, con);
	v.y = mulf(v.y, con);
};

func void Vec2_DivConstf(var int vec, var int con) {
	var Vec2 v; v = _^(vec);
	v.x = divf(v.x, con);
	v.y = divf(v.y, con);
};

func int Vec2_Arc(var int vec1, var int vec2) {
	var Vec2 v1; v1 = _^(vec1);
	var Vec2 v2; v2 = _^(vec2);
	return atan2f(subf(v2.y, v1.y), subf(v2.x, v1.x));
};	


func void Vec2_Print(var int vec) {
	var Vec2 v; v = _^(vec);
	var string s; s = toStringf(v.x);
	s = ConcatStrings("X: ", s);
	s = ConcatStrings(s, " Y: ");
	s = ConcatStrings(s, toStringf(v.y));
	print(s);
};

