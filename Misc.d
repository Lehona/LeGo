const int phi = 1070141312; // PI/2

func int atan2f(var int x, var int y) {
	const int call = 0;
	var int ret;
	if (Call_Begin(call)) {
		CALL_FloatParam(_@(x));
		CALL_FloatParam(_@(y));
		CALL_RetValisFloat();
		CALL_PutRetValTo(_@(ret));
		CALL__cdecl(_atan2f);
		
		call = CALL_End();
	};
	return +ret;
};

func int distance2Df(var int x1, var int x2, var int y1, var int y2) {
	var int dx; dx = subf(x1, x2); 
	var int dy; dy = subf(y1, y2);

	return +(sqrtf(addf(mulf(dx, dx), mulf(dy, dy))));
};
func int distance2D(var int x1, var int x2, var int y1, var int y2) {
	return +roundf(distance2Df(mkf(x1), mkf(x2), mkf(y1), mkf(y2)));
};

func int sin(var int angle) {
	const int call = 0;
	var int ret;
	if (Call_Begin(call)) {
		CALL_FloatParam(_@(angle));
		CALL_RetValisFloat();
		CALL_PutRetValTo(_@(ret));
		CALL__cdecl(_sinf);
		
		call = CALL_End();
	};
	return +ret;
};

func int acos(var int cosine) {
	const int call = 0;
	var int ret;
	if (Call_Begin(call)) {
		CALL_FloatParam(_@(cosine));
		CALL_RetValisFloat();
		CALL_PutRetValTo(_@(ret));
		CALL__cdecl(_acosf);
		
		call = CALL_End();
	};
	return +ret;
};

func int asin(var int sine) {
	return +subf(phi, acos(sine));
};


func int cos(var int angle) {
	return +sin(subf(phi, angle));
};

func int tan(var int x) {
	return +divf(sin(x), cos(x));
};