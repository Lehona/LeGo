/*******************
 * Queue
 *******************/


class Queue {
	var int listHandle;
	var int empty; 
};
instance Queue@(Queue);

func int Q_Create() {
	var int h; h = new(Queue@);
	var Queue q; q = get(h);
	q.empty = true;
	q.listHandle = new(zClist@);
	return h;
};

func void Q_Enqueue(var int queue, var int data) {	
	var Queue Q; Q = get(queue);
		
	var zCList list; list = get(Q.listHandle);
	if (Q.empty) {
		list.data = data;
		Q.empty = false;
	} else {
		List_Add(getPtr(Q.listHandle), data);
	};
};

func int Q_IsEmpty(var int queue) {
	if (!Hlp_IsValidHandle(queue)) {
		MEM_Info("Q_IsEmpty: invalid queue handle");
		return -1;
	};
	var Queue Q; Q = get(queue);
	return Q.empty;
};

func int Q_Advance(var int queue) {
	
	if (!Hlp_IsValidHandle(queue)) {
		MEM_Info("Q_Advance: invalid queue handle");
		return 0;
	};
	
	var Queue Q; Q = get(queue);
	
	if (Q_IsEmpty(queue)) {
		MEM_Info("Q_Advance: Advanced an empty queue. Use Q_IsEmpty()");
		return 0;
	};
	
	if (!Hlp_IsValidHandle(Q.listHandle)) {
		MEM_Info("Q_Advance: invalid list handle");
		return 0; 
	};
	var zCList list; list = get(Q.listHandle);
	
	var int result; result = list.data;
	
	var zCList list_next; 
	if (list.next)  {
		list_next = _^(list.next);
		list.data = list_next.data;
		list.next = list_next.next;
		free(_@(list_next), zCList@);
	} else {
		list.data = 0;
		Q.empty = true;
	};
	
	return result;	
};

func void Q_For(var int queue, var int funcID) {
	if (!Hlp_IsValidHandle(queue)) {
		MEM_Info("Q_For: invalid queue handle");
		return;
	};
	var Queue Q; Q = get(queue);
	List_ForI(getPtr(Q.listHandle), funcID);
};

func void Q_ForF(var int queue, var func f) {
	Q_For(queue, MEM_GetFuncID(f));
};


/*******************
 * CallbackQueue
 *******************/

class callbackData {
	var int funcID;
	var int userData;
	var int hasData;
};

instance callbackData@(callbackData);

/*
func void callbackData_Archiver(var callbackData this) {
	PM_SaveFuncID("func", this.funcID);
	PM_SaveInt("userData", this.userData);
	PM_SaveInt("hasData", this.hasData);
};

func void callbackData_Unarchiver(var callbackData this) {
	this.funcID = PM_Load("func");
	this.userData = PM_Load("userData");
	this.hasData = PM_Load("hasData");
};
*/
func int _CQ_CBData(var int ID, var int uData, var int hData) {
	var int h; h = new(callbackData@);
	var callbackData cbd; cbd = get(h);
	
	cbd.funcID = ID;
	cbd.userData = uData;
	cbd.hasData = hData;
	
	return h;
};

instance callbackQueue@(Queue);

func int CQ_Create() {
	/* A callbackQueue is no different from a normal Queue */
	return Q_Create(); 
};

func void CQ_Enqueue(var int CQhandle, var int funcID, var int userData, var int hasData) {
	var int cbdh; cbdh = _CQ_CBData(funcID, userData, hasData);
		
	Q_Enqueue(CQhandle, cbdh);
};

func void CQ_EnqueueData(var int CQhandle, var func f, var int userData) {
	CQ_Enqueue(CQhandle, MEM_GetFuncID(f), userdata, true);
};

func void CQ_EnqueueNoData(var int CQhandle, var func f) {
	CQ_Enqueue(CQhandle, MEM_GetFuncID(f), 0, false);
};

func int CQ_IsEmpty(var int CQhandle) {
	return Q_IsEmpty(CQhandle);
};

func void CQ_Advance(var int CQhandle) {
	if (!Hlp_IsValidHandle(CQhandle)) {
		MEM_Info("CQ_Advance: Invalid queue");
		return;
	};
	
	if (CQ_IsEmpty(CQhandle)) {
		MEM_Info("CQ_Advance: Advanced an empty queue. Use CQ_IsEmpty()");
		return;
	};
	
	var int cbdh; cbdh = Q_Advance(CQhandle);
	
	if (!Hlp_IsValidHandle(cbdh)) {
		/* This could have serious effects, so a
		 * warning seems appropriate 
		 */
		 
		MEM_Warn("CQ_Advance: invalid data");
		return;
	};
	var callbackData CBD; CBD = get(cbdh);
	
	var int ID;		ID 		= CBD.funcID;
	var int hData; 	hData 	= CBD.hasData;
	var int uData; 	uData 	= CBD.userData;
	
	delete(cbdh);
		
	if (hData) {
		MEM_PushIntParam(uData);
	};
	
	MEM_CallByID(ID);
};
	
func void CQ_Exhaust(var int CQhandle) {
	if (!Hlp_IsValidHandle(CQhandle)) {
		MEM_Info("CQ_Exhaust: Invalid queue");
		return;
	};
	
	while(!CQ_IsEmpty(CQhandle));
		CQ_Advance(CQhandle);
	end;
};
		
		