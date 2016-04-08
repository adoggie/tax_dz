
typedef __stdcall int (*TInitPluger)();
typedef __stdcall int (*TFreePluger)();

typedef __stdcall int (*Tinv_reset)();
typedef __stdcall int (*Tinv_open)();
typedef __stdcall int (*Tinv_close)();
typedef __stdcall int (*Tinv_lock)();
typedef __stdcall int (*Tinv_unlock)();

typedef __stdcall int (*Tinv_taxinfo) 	(
										int invoice_type, char* code, char* number, char* stock, char* taxcode, char* limit
										);
typedef __stdcall int (*Tinv_create) 	(
										int invoice_type, int tax_flag, int mode, int ntype, float discount,
										char* bill, int bill_bufsize,
										char* invoice_code, char* invoice_number, char* date, char* amount, char* tax
										);
typedef __stdcall int (*Tinv_cancel)	(
										int invoice_type, char* invoice_number, char* invoice_code
										);
typedef __stdcall int (*Tinv_getinfo)	(
										int invoice_type, char* invoice_number, char* invoice_code, char* buff, int* bufsize
										);
typedef __stdcall int (*Tinv_getinfo_all)(
										char* buff, int* bufsize
										);

