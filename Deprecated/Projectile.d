const int P_TPS = 50; // Ticks per second


class Projectile {
	var int view; // zCView@
		var int radius; // vpixel / zBool
	var int velvec; // Vec2*
	var int onColl; // void (int coll1, int coll2)
	var int posvec; // Vec2*
	var int coll;
};

instance Projectile@(Projectile);

instance Projectile_Circle(Projectile);
instance Projectile_Rectangle(Projectile);

func int Projectile_Create(var int view, var int radius, var func onCollision) {
	var int h; h = new(Projectile@);
	Projectile@.radius = radius;
	Projectile@.view = view;
	Projectile@.onColl = MEM_GetFuncID(onCollision);
	var zCView v; v = get(view);
	var int midx; midx = v.vposx + (v.vsizex/2);
	var int midy; midy = v.vposy + (v.vsizey/2);
	Projectile@.posvec = Vec2_Create(midx, midy);
	Projectile@.velvec = Vec2_Create(0, 0);
	return +h;
};

func int Projectile_GetVeloX(var int hndl) {
	var Projectile p; p = get(hndl);
	return +Vec2_GetX(p.velvec);
};

func int Projectile_GetVeloY(var int hndl) {
	var Projectile p; p = get(hndl);
	return +Vec2_GetY(p.velvec);
};

func void Projectile_SetVeloX(var int hndl, var int vel) {
	var Projectile p; p = get(hndl);
	Vec2_SetX(p.velvec, vel);
};

func void Projectile_SetVeloY(var int hndl, var int vel) {
	var Projectile p; p = get(hndl);
	Vec2_SetY(p.velvec, vel);
};

func int Projectile_GetView(var int hndl) {
	var Projectile p; p = get(hndl);
	return +(p.view);
};

func void Projectile_SetView(var int hndl, var int view) {
	var Projectile p; p = get(hndl);
	p.view = view;
};

func int Projectile_IsCircle(var int hndl) {
	var Projectile p; p = get(hndl);
	return +(p.radius);
};



func void Projectile_CollideCircles(var int hndl, var int oth) {
	var Projectile this; this = get(hndl);
	var Projectile obj; obj = get(oth);
	
	var int ans; 
	MEM_PushIntParam(hndl);
	MEM_PushIntParam(oth);
	MEM_CallbyId(this.onColl);
	ans = !!MEMINT_PopInt();
	MEM_PushIntParam(oth);
	MEM_PushIntParam(hndl);
	MEM_CallById(obj.onColl);
	ans = ans & !!MEMINT_PopInt();
	if (!ans) {
		return;
	};
	
	var Vec2 p; p = _^(Vec2_SubVec(this.posvec, obj.posvec));
		     
	  var int cNorm; cNorm = atan2f(p.x, p.y);
	  var int nX; nX = cos(cNorm);
	  var int nY; nY = sin(cNorm);
	  
	  var int a1; a1 = addf(mulf(Vec2_GetX(this.velvec),nx), mulf(Vec2_GetY(this.velvec),nY));
	  var int a2; a2 = addf(mulf(Vec2_GetX(obj.velvec),nx), mulf(Vec2_GetY(obj.velvec),nY));
	  var int optimisedP; optimisedP = divf(mulf(mkf(2), subf(a1,a2)), mkf(2));
	  
	    Vec2_SetX(this.velvec, subf(Vec2_GetX(this.velvec), mulf(optimisedP, nX)));
		Vec2_SetY(this.velvec, subf(Vec2_GetY(this.velvec), mulf(optimisedP, nY)));
		Vec2_SetX(obj.velvec, addf(Vec2_GetX(obj.velvec), mulf(optimisedP, nX)));
		Vec2_SetY(obj.velvec, addf(Vec2_GetY(obj.velvec), mulf(optimisedP, nY)));
		
	MEM_Free(_@(p));
	
	
};


var int Projectile_CollisionX;
func void Projectile_CollideCircleRectangle(var int hndl, var int oth) {
	var Projectile this; this = get(hndl); // Kreis
	var Projectile obj; obj = get(oth);
	if (obj.radius) {
		var int tmp; tmp = oth;
		oth = hndl;
		hndl = tmp;
		this = get(hndl);
		obj = get(oth);
	};
/* 	
	var int dvx; dvx = this.velx - obj.velx;
	var int dvy; dvy = this.vely - obj.vely;
	
	if (Projectile_CollisionX == 1) {
		this.velx = -dvx/2;
		this.vely = dvy/2;
		obj.velx = dvx/2;
		obj.vely = -dvy/2;
	} else if (Projectile_CollisionX == 2) {
		this.velx = -dvx/2;
		this.vely = -dvy/2;
		obj.velx = dvx/2;
		obj.vely = dvy/2;
	} else {
		this.velx = dvx/2;
		this.vely = -dvy/2;
		obj.velx = -dvx/2;
		obj.vely = dvy/2;
	}; */
	
};

func void Projectile_CollideRectangles(var int hndl, var int oth) {

	var Projectile this; this = get(hndl);
	var Projectile obj; obj = get(oth);

	/* 
	var int dvx; dvx = this.velx - obj.velx;
	var int dvy; dvy = this.vely - obj.vely;
	
	if (Projectile_CollisionX == 1) {
		this.velx = -dvx/2;
		this.vely = dvy/2;
		obj.velx = dvx/2;
		obj.vely = -dvy/2;
	} else {
		this.velx = dvx/2;
		this.vely = -dvy/2;
		obj.velx = -dvx/2;
		obj.vely = dvy/2;
	}; */
	
};


var int _P_Curr;
func int _Projectile_CollDetCircleCircle(var int hndl) {
	if (hndl == _P_Curr) { // Mit sich selber kollidieren ist eher unsinnvoll
		return rContinue;
	};
	
	if (final()) {
		MEM_Free(_@(m));
		MEM_Free(_@(p));
	};
	
	var Projectile this; this = get(hndl);
	var Projectile obj; obj = get(_P_Curr);
		
	// We want local coordinates, we assume v1 to be stationary at the origin
		
	var Vec2 m; m = _^(Vec2_SubVec(this.posvec, obj.posvec)); // Position of v2
	var Vec2 p; p = _^(Vec2_SubVec(this.velvec, obj.velvec)); // Velocity of v2
	
	
	var int a; a = addf(mulf(p.x, p.x), mulf(p.y, p.y)); // |p|²
	var int b; b = mulf(mkf(2), Vec2_Dotproduct(_@(m), _@(p))); // 2 * m . p
	var int c; c = subf(addf(mulf(m.x, m.x), mulf(m.y, m.y)), mkf((this.radius+obj.radius)*(this.radius+obj.radius))); // |m|²-r²
		
	var int det; det = subf(mulf(b,b), mulf(mulf(mkf(4),a),c)); // b²-4ac
	
	if (lef(det, 0)) { // (x<=0) 
		/* this means no collision is going to occur if both projectiles carry on with this speed */
		return rContinue;
	} else  { // 2 Solutions -> there is a collision
		var int sol1; sol1 = divf(addf(negf(b), sqrtf(subf(mulf(b,b), mulf(mulf(mkf(4),c),a)))), mulf(mkf(2), a)); // (-b + sqrt(b²-4ac))/2a
		var int sol2; sol2 = divf(subf(negf(b), sqrtf(subf(mulf(b,b), mulf(mulf(mkf(4),c),a)))), mulf(mkf(2), a)); // (-b - sqrt(b²-4ac))/2a
		
		var int min; min = sol2;
		if (lf(sol2, sol1)) {
			sol2 = sol1;
			sol1 = min;
		};
		
		if (sol2 < 0) {
			return rContinue;
		};
		
		if (gf(min, invf(mkf(P_TPS)))) {
			/* The collision won't occur this tick/frame */
			return rContinue;
		};
		
		Projectile_CollideCircles(_P_Curr, hndl);
	
	};	
	return rContinue;
};

func int _Projectile_CollDetRectRect(var int hndl) {
	if (hndl == _P_Curr) { // Mit sich selber kollidieren ist eher unsinnvoll
		return rContinue;
	};
	var Projectile this; this = get(hndl);
	var Projectile obj; obj = get(_P_Curr);

	var zCView v1; v1 = get(this.view);
	var zCView v2; v2 = get(obj.view);
		
		
	// We want local coordinates, we assume v1/this to be stationary at the origin
	var Vec2 m; m = _^(Vec2_SubVec(this.posvec, obj.posvec)); // Position of v2
	var Vec2 p; p = _^(Vec2_SubVec(this.velvec, obj.velvec)); // Velocity of v2
	
	//obj.posx / obj.velx
	
	var int tx1; var int tx2;
	if (!p.x) { // Die Geschwindigkeit ist 0, also darf ich nicht dadurch teilen!
		if (subf(absf(m.x), mkf((v1.vsizex+v2.vsizex)/2)) >= 0) { 
			return rContinue;
		} else {
			tx1 = 0;
			tx2 = 1148846080; // 1000f
		};
	} else {
		tx1 = divf(subf(m.x,mkf((v1.vsizex+v2.vsizex)/2)), p.x); // distance/speed
		tx2 = divf(addf(m.x,mkf((v1.vsizex+v2.vsizex)/2)), p.x); // distance/speed
	};
	
	var int ty1; var int ty2;

	if (!p.x) { // Die Geschwindigkeit ist 0, also darf ich nicht dadurch teilen!
		if (subf(absf(m.x), mkf((v1.vsizex+v2.vsizex)/2)) >= 0) { 
			return rContinue;
		} else {
			ty1 = 0;
			ty2 = 1148846080; // 1000f
		};
	} else {
		ty1 = divf(subf(m.y,mkf((v1.vsizey+v2.vsizey)/2)), p.y); // distance/speed
		ty2 = divf(addf(m.y,mkf((v1.vsizey+v2.vsizey)/2)), p.y); // distance/speed
	};
	
	
	
	var int tmp; 
	if (m.x > 0) { // If m is approaching from the left/bottom, this is wrong way around
		tmp = tx1;
		tx1 = tx2;
		tx2 = tmp;
	};
	
	//Vec2_Print(Vec2_Createf(tx1, tx2));
	if (m.y > 0) { 
		tmp = ty1;
		ty1 = ty2;
		ty2 = tmp;
	};
	
	if (tx2 < 0 || ty2 < 0) { // This it when it leaves the correct coordinates! If it's negative, no collision will occur.
		Print("Not Yay");
		return rContinue;
	};
	
	if (gef(tx1, ty1)&&lef(tx1, ty2) || gef(ty1, tx1)&&lef(ty1, tx2)) {
		Print("YAY!");
	};
	
	

};
		
	
func int _Projectile_Loop_Sub(var int hndl) {
	var Projectile p; p = get(hndl);
 	Vec2_SetX(p.posvec, addf(Vec2_GetX(p.posvec), divf(Vec2_GetX(p.velvec), mkf(P_TPS))));
	Vec2_SetY(p.posvec, addf(Vec2_GetY(p.posvec), divf(Vec2_GetY(p.velvec), mkf(P_TPS)))); 
	var zCView v; v = get(p.view);
	
	var int x; x = roundf(Vec2_GetX(p.posvec)) - v.vsizex/2;
	var int y; y = roundf(Vec2_GetY(p.posvec)) - v.vsizey/2;
	
	View_MoveTo(p.view, x, y);
	_P_Curr = hndl;
	if (Projectile_IsCircle(hndl)) {
		ForEachHndl(Projectile@, _Projectile_CollDetCircleCircle);
		//ForEachHndl(Projectile_Rectangle, _Projectile_CollDetCircleRect);
	} else {
		//ForEachHndl(Projectile_Circle, _Projectile_CollDetRectCircle);
		ForEachHndl(Projectile@, _Projectile_CollDetRectRect);
	};
		
	return rContinue;
};

func void _Projectile_Loop() {
	ForEachHndl(Projectile@, _Projectile_Loop_Sub);
};

func void Projectile_Init() {
	FF_ApplyExt(_Projectile_Loop, 1000/P_TPS, -1);
};


