unit GlobalDefine;

interface

uses Windows, Sysutils;

const
  GC_IniFileName              = 'Pluger.ini';
  GC_SessionName              = 'config';
  GC_ProxyHandle              = 'ProxyHandle';
  GC_DEBUG                    = 'Debug';
  GC_WaitFace_InvoiceInterval = '��Ʊ�ȴ�ʱ��';
  GC_WaitFace_PrintInterval   = '��ӡ�ȴ�ʱ��';
  GC_WaitFace_CreateInv       = '��Ʊ��ʱ'; // ��Ʊ���ܵ� �ܹ� ��ʱ

  Default_WaitFace_InvoiceInterval    = 1000 * 5;
  Default_WaitFace_PrintInterval      = 1000 * 20;
  Default_WaitFace_CreateInvInterval  = 1000 * 60;

const
  // Inject Sync Message
  ISM_ShowInjectWnd                   = $0001;    // s->c
  ISM_HideInjectWnd                   = $0002;    // s->c
  ISM_SetInjectWndHandle              = $0003;    // c->s :  w: hInjectWnd;
  ISM_FreeInjectWnd                   = $0004;    // s->c
  
  ISM_INV_RESET                       = $0101;    // s->c
  ISM_INV_TAXINFO                     = $0102;    // s->c :  w: invoice_type
  ISM_INV_TAXINFO_RESULT              = $0103;    // c->s :  w: errcode; l: TTaxInfoResult

  ISM_INV_GETINFO_ALL2                = $0104;    // s->c    w: 0; l: Info: TGetInfoAll2
  ISM_INV_GETINFO_ALL_RESULT2         = $0105;    // c->s

  ISM_INV_GETINFO_ALL                 = $0106;    // s->c
  ISM_INV_GETINFO_ALL_RESULT          = $0107;    // c->s

  ISM_INV_GETINFO                     = $0108;    // s->c :  w: 0; l: Info: TGetInfo
  ISM_INV_GETINFO_RESULT              = $0109;    // c->s :

  ISM_INV_CANCEL                      = $010A;    // s->c :  w: 0; l: Info: TCancelInfo
  ISM_INV_CANCEL_RESULT               = $010B;    // c->s :  w: v: boolean

  ISM_INV_PRINT                       = $010C;    // s->c :  w: 0; l: TPrintInfo;
  ISM_INV_PRINT_RESULT                = $010D;    // c->s :  w: error_code;

  ISM_INV_LOCK                        = $010E;
  ISM_INV_UNLOCK                      = $010F;

  ISM_INV_CREATE                      = $0200;    // s->c :  w: 0; l: TCreateInv
  ISM_INV_CREATE_RESULT               = $0201;    // c->s :  w: error_code; l: TCreateInvResult
  

const
  GC_SeparatorL1                      = '~+f1+~';
  GC_SeparatorL2                      = '~+f2+~';
  GC_SeparatorL3                      = '~+f3+~';
  GC_SeparatorL4                      = '~+f4+~';
  
type
  TTaxInfoResult = packed record
    code, number: array [0..40-1] of Char;
  end;
  PTaxInfoResult = ^TTaxInfoResult;

  TGetInfo = TTaxInfoResult;
  TCancelInfo = TTaxInfoResult;
  TPrintInfo = packed record
    code, number, list: array [0..40-1] of Char;
    PrintType: Integer;
  end;

  TGetInfoAll2 = packed record
    beginDate,
    endDate: TDateTime;
    flag: Integer;
    list: array [0..40-1] of Char; 
  end;
  PGetInfoAll2 = ^TGetInfoAll2;

  TCreateInvResult = packed record
    code,
    number,
    date,
    amount, //�ܽ��
    tax: array [0..40-1] of Char;  // ˰��
  end;
  
  TCreateInv = packed record
    invoice_type,
    tax_flag,
    make_inv_mode,
    make_inv_type: Integer;
    discount: Single;
    bill_bufsize: Integer;
    // bill: PChar; ...
  end;
  PCreateInv = ^TCreateInv;

  TMakeInvInfo = record
    tax_rate: Single;             // ˰��
    cust_name: string;            // �ͻ�����
    cust_tax_code: string;        // �ͻ�˰��
    cust_address_tel: string;     // �ͻ���ַ�绰
    cust_bank_account: string;    // �ͻ������ʺ�
    memo: string;                 // ��ע
    seller_bank_account: string;  // ���������ʺ�
    checker: string;              // ������
    payee: string;                // �տ���
    red_nr: string;               // ��������
    region_inv_code: string;      // ������Ʊ��ص�ԭʼ��Ʊ����
    region_inv_number: string;    // ������Ʊ��ص�ԭʼ
  end;

  TMakeInvList = record
    item_name,        // ��Ʒ����
    item_unit,        // ������λ
    spec: string;     // ���
    price,            // ����
    qty,              // ����
    amount: Double;   // ���
  end;
  PMakeInvList = ^TMakeInvList;

const
  // invoice type
  it_Normal   = 0;  // ��ͨ��Ʊ
  it_Special  = 1;  // ר�÷�Ʊ
  // tax flag
  tf_WithoutTax = 0; // ����˰
  tf_WithTax    = 1; // ��˰
  // make inv mode
  mim_MakeInv      = 1;  // ��Ʊ
  mim_Print        = 2;  // ��ӡ
  mim_MakeInvPrint = 3;  // ��Ʊ����ӡ
  // make inv type
  mit_Normal   = 0;  // ��ͨ��Ʊ
  mit_Negative = 1;  // ������Ʊ

  // print type
  pt_Print      = 0;
  pt_PrintList  = 1; 
  
const
  // error code
  ERROR_SUCCESS                       = 00000;  // �ɹ�
  ERROR_INVALID_INV_CODE              = 00201;  // ��Ʊ���벻���� 
  ERROR_BUFFER_TOO_SMALL              = 00202;  // buffer̫С
  ERROR_INVALID_SELLER_BANK_ACCOUNT   = 00301;  // ���������ʺ� ��ƥ��
  ERROR_INVALID_FIND_MONTH            = 00401;  // ����·� ��ƥ��
  ERROR_TIMEOUT_CREATE_INVOICE        = 00501;  // ��Ʊ(�ȴ���Ʊ����)��ʱ
  ERROR_TIMEOUT_SAVE_INVOICE          = 00502;  // ����(��ӡ)��Ʊ��ʱ
  ERROR_TIMEOUT_CREATE_INVOICE_ALL    = 00503;  // ��Ʊ��ʱ(������Ʊ����) 
  ERROR_INVALID_PRINT_LIST            = 00601;  // ��ӡ��Ʊ�嵥[���ŷ�Ʊû���嵥]
  ERROR_INVALID_PARAMETER             = 00888;  // ��������
  ERROR_UNKNOWN                       = 00999;  // δ֪����
  ERROR_PLUGER_UNINITIALIZED          = 10000;  // δ��ʼ��
  ERROR_KP_NOT_FIND                   = 10001;  // ��Ʊ���û������
  ERROR_INJECT_FAIL                   = 10002;  // ע��ʧ��
  ERROR_KP_CLOSED                     = 10003;  // �ڳ�ʼ��֮��,��Ʊ������ر���
  ERROR_KP_NOT_LOGGED_IN              = 10004;  // ��Ʊ���δ��¼
  ERROR_KP_DISABLE                    = 10005;  // ��Ʊ�������Ĭ�Ͻ���
  ERROR_RESERVED                      = 20000;  // Ԥ����,δʵ�ֵ�


type
  TPushRet = packed record
    _push: Byte;  // $68
    _Addr: DWORD;
    _retn: Byte;  // $C3
  end;
  PPushRet = ^TPushRet;
  
  TMousePos = packed record
    x: WORD;
    y: WORD;
  end;
const
  //PROCESS_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $FFFF);  // x64
  PROCESS_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $0FFF);  // x86
type
  TSePrivilegeName = (
    SeChangeNotifyPrivilege,          // �����������
    SeSecurityPrivilege,	            // ������˺Ͱ�ȫ��־
    SeBackupPrivilege,	              // �����ļ���Ŀ¼
    SeRestorePrivilege,	              // ��ԭ�ļ���Ŀ¼
    SeSystemtimePrivilege,	          // ����ϵͳʱ��
    SeShutdownPrivilege,	            // �ر�ϵͳ
    SeRemoteShutdownPrivilege,	      // ��Զ��ϵͳǿ�ƹػ�
    SeTakeOwnershipPrivilege,	        // ȡ���ļ����������������Ȩ
    SeDebugPrivilege,	                // ���Գ���
    SeSystemEnvironmentPrivilege,	    // �޸Ĺ̼�����ֵ
    SeSystemProfilePrivilege,	        // ����ϵͳ����
    SeProfileSingleProcessPrivilege,	// ���õ�һ����
    SeIncreaseBasePriorityPrivilege,	// ���ӽ������ȼ�
    SeLoadDriverPrivilege,	          // װ�غ�ж���豸��������
    SeCreatePagefilePrivilege,	      // ����ҳ���ļ�
    SeIncreaseQuotaPrivilege,	        // ������
    SeUndockPrivilege                 // �Ӳ�ӹ���վ��ȡ�������
  );

function AdjustProcessPrivilege(SePrivilegeName: TSePrivilegeName; bEnabled: Boolean; PID: DWORD=0): Boolean;
function FindWindow(lpClassName, lpWindowName: string; hRoot: THandle = 0; processid: DWORD = 0): THandle;
function GetModuleName(Module: HMODULE): string;
function GetClassName(hWnd: THandle): string;
function InjectDll(PID: DWORD; DllPath: string): Boolean;
function GetWindowVisible(hWnd: THandle): Boolean;
function GetWindowMinimize(hWnd: THandle): Boolean;
function InitPushRet(Addr: DWORD): TPushRet; overload;
function InitPushRet(Addr: Pointer): TPushRet; overload;
function SeparatorStr(Src, Separator: string; var Value, Dest: string): Boolean;
function BitInValue(Value, Bit: DWORD): Boolean;
function IsTopWindow(hWnd: THandle): Boolean;
function IsDisableWindow(hWnd: THandle): Boolean;

implementation

function AdjustProcessPrivilege(SePrivilegeName: TSePrivilegeName; bEnabled: Boolean; PID: DWORD=0): Boolean;
var
  strPrivilegeName: string;
  hProcess, hToken: THandle;
  ReturnLength: DWORD;
  Privileges: TOKEN_PRIVILEGES;
begin
  Result := False;

  case SePrivilegeName of
    SeChangeNotifyPrivilege        : strPrivilegeName := 'SeChangeNotifyPrivilege';
    SeSecurityPrivilege	           : strPrivilegeName := 'SeSecurityPrivilege';
    SeBackupPrivilege	             : strPrivilegeName := 'SeBackupPrivilege';
    SeRestorePrivilege	           : strPrivilegeName := 'SeRestorePrivilege';
    SeSystemtimePrivilege	         : strPrivilegeName := 'SeSystemtimePrivilege';
    SeShutdownPrivilege	           : strPrivilegeName := 'SeShutdownPrivilege';
    SeRemoteShutdownPrivilege	     : strPrivilegeName := 'SeRemoteShutdownPrivilege';
    SeTakeOwnershipPrivilege	     : strPrivilegeName := 'SeTakeOwnershipPrivilege';
    SeDebugPrivilege 	             : strPrivilegeName := 'SeDebugPrivilege';
    SeSystemEnvironmentPrivilege	 : strPrivilegeName := 'SeSystemEnvironmntPrivilege';
    SeSystemProfilePrivilege	     : strPrivilegeName := 'SeSystemProfilePrivilege';
    SeProfileSingleProcessPrivilege: strPrivilegeName := 'SeProfileSingleProcessPrivilege';
    SeIncreaseBasePriorityPrivilege: strPrivilegeName := 'SeIncreaseBasePriorityPrivilege';
    SeLoadDriverPrivilege	         : strPrivilegeName := 'SeLoadDriverPrivilege';
    SeCreatePagefilePrivilege	     : strPrivilegeName := 'SeCreatePagefilePrivilege';
    SeIncreaseQuotaPrivilege	     : strPrivilegeName := 'SeIncreaseQuotaPrivilege';
    SeUndockPrivilege              : strPrivilegeName := 'SeUndockPrivilege';
  else
    Exit;
  end;

  if PID = 0 then
    PID := GetCurrentProcessID;
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, PID);
  if hProcess = 0 then
    Exit;
  try

    if OpenProcessToken(GetCurrentProcess(),TOKEN_ADJUST_PRIVILEGES,hToken) then
    try

      Privileges.PrivilegeCount := 1;
      LookupPrivilegeValue(nil, PChar(strPrivilegeName), Privileges.Privileges[0].Luid);
      if bEnabled then
        Privileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
      else
        Privileges.Privileges[0].Attributes := 0;

      if AdjustTokenPrivileges(hToken, False, Privileges, Sizeof(Privileges),
        nil, ReturnLength) then
        Result := True;

    finally
      CloseHandle(hToken);
    end;

  finally
    CloseHandle(hProcess);
  end;
end;

function FindWindow(lpClassName, lpWindowName: string; hRoot: THandle; processid: DWORD): THandle;
  function _IsMatchClassName(h: THandle): Boolean;
  var
    name: array [0..MAX_PATH-1] of Char;
    s: string;
  begin
    if Length(lpClassName) = 0 then
    begin
      Result := True;
      Exit;
    end;

    Result := False;
    if Windows.GetClassName(h, name, MAX_PATH) = 0 then
      Exit;
    s := LowerCase(name);
    if s = lpClassName then
      Result := True;      
  end;

  function _IsMatchWindowName(h: THandle): Boolean;
  var
    name: array [0..MAX_PATH-1] of Char;
    s: string;
  begin
    if Length(lpWindowName) = 0 then
    begin
      Result := True;
      Exit;
    end;
                                  
    Result := False;
    if GetWindowText(h, name, MAX_PATH) = 0 then
      Exit;
    s := LowerCase(name);
    if s = lpWindowName then
      Result := True;      
  end;

  function _IsMatchProcessId(h: THandle): Boolean;
  var
    dwPID: DWORD;
  begin
    Result := True;
    
    if processid = 0 then
      Exit;

    dwPID := 0;
    GetWindowThreadProcessId(h, @dwPID);

    if ((dwPID <> 0) and (dwPID <> processid)) then
      Result := False;
  end;

  function _IsMatchWnd(h: THandle): Boolean;
  begin
    Result := False;
    
    if _IsMatchClassName(h) then
      if _IsMatchWindowName(h) then
        if _IsMatchProcessId(h) then
          Result := True;
  end;

var
  ResultValue: THandle;
  
  function _EmunWnd(hWnd: THandle): Boolean;
  begin
    Result := False;
    
    hWnd := GetWindow(hWnd, GW_CHILD);
    while hWnd <> 0 do
    begin
      if _IsMatchWnd(hWnd) then
      begin
        ResultValue := hWnd;
        Result := True;
        Break;
      end;

      if _EmunWnd(hWnd) then
      begin
        Result := True;
        Break;
      end;
      
      hWnd := GetWindow(hWnd, GW_HWNDNEXT);
    end;
  end;
  
var
  hWnd: THandle;
begin
  Result := 0;
  ResultValue := 0;

  try
    lpClassName := LowerCase(lpClassName);
    lpWindowName := LowerCase(lpWindowName);

    if (Length(lpClassName) = 0) and (Length(lpWindowName) = 0) then
      Exit;

    if hRoot = 0 then
      hWnd := GetDesktopWindow
    else
      hWnd := hRoot;
    
    if _IsMatchWnd(hWnd) then
      ResultValue := hWnd
    else
      _EmunWnd(hWnd);

  finally
    Result := ResultValue;
  end;
end;

function GetModuleName(Module: HMODULE): string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, Windows.GetModuleFileName(Module, ModName, SizeOf(ModName)));
end;

function GetClassName(hWnd: THandle): string;
var
  ClassName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ClassName, Windows.GetClassName(hWnd, ClassName, SizeOf(ClassName)));
end;

function InjectDll(PID: DWORD; DllPath: string): Boolean;
var
  hProcess, hRemoteThread: THandle;
  RemoteMemSize, NumberOfBytesWritten: DWORD;
  pRemoteMem, pLoadLibrary: Pointer;
  ThreadId: DWORD;

  {$IFDEF WIN64}
  PeFile: TPuPeFile;
  Mods: TPuModules;
  ProcOffset: UInt64;
  n: Integer;
  {$ENDIF}
begin
  Result := False;

  hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, PID);
  if hProcess = 0 then
    Exit;
  try
    // ��Ŀ������з���ռ�,������ʹ��
    RemoteMemSize := (Length(DllPath)+1) * SizeOf(Char);
    pRemoteMem := VirtualAllocEx(hProcess, nil, RemoteMemSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    if not Assigned(pRemoteMem) then
      Exit;
    try
      if not WriteProcessMemory(hProcess, pRemoteMem, PChar(DllPath), RemoteMemSize, NumberOfBytesWritten) then
        Exit;

      // û��ȡ����ȷ��LoadLibrary()��ַ
      pLoadLibrary := GetProcAddress(GetModuleHandle('Kernel32'), 'LoadLibraryA');
      if not Assigned(pLoadLibrary) then
        Exit;

      // ����Զ���߳�
      hRemoteThread := CreateRemoteThread(hProcess, nil, 0, pLoadLibrary, pRemoteMem, 0, ThreadId);
      if hRemoteThread = 0 then
        Exit;

      Result := True;

      // �ȴ�Զ���߳̽���
      WaitForSingleObject(hRemoteThread, INFINITE);
    finally
      VirtualFreeEx(hProcess, pRemoteMem, RemoteMemSize, MEM_COMMIT);
    end;
  finally
    CloseHandle(hProcess);
  end;
end;

function GetWindowVisible(hWnd: THandle): Boolean;
var
  dwWndStyle: DWORD;
begin
  dwWndStyle := GetWindowLong(hWnd, GWL_STYLE);
  Result := (dwWndStyle and WS_VISIBLE) <> 0;
end;

function GetWindowMinimize(hWnd: THandle): Boolean;
var
  dwWndStyle: DWORD;
begin
  dwWndStyle := GetWindowLong(hWnd, GWL_STYLE);
  Result := (dwWndStyle and WS_MINIMIZE) <> 0;
end;

function InitPushRet(Addr: DWORD): TPushRet;
begin
  Result._push := $68;
  Result._Addr := Addr;
  Result._retn := $C3;
end;

function InitPushRet(Addr: Pointer): TPushRet;
begin
  Result := InitPushRet(DWORD(Addr));
end;

function SeparatorStr(Src, Separator: string; var Value, Dest: string): Boolean;
var
  n: Integer;
begin
  Result := False;
  Dest := Src;
  Value := '';
  n := Pos(Separator, Src);
  if n > 0 then
  begin
    Result := False;
    Value := Copy(Src, 1, n-1);
    Dest := Copy(Src, n+Length(Separator)*SizeOf(Char), Length(Src));
    Result := True; 
  end;
end;

function BitInValue(Value, Bit: DWORD): Boolean;
begin
  Result := (value and Bit) = Bit;
end;

function IsTopWindow(hWnd: THandle): Boolean;
var
  WndLong: DWORD;
begin
  WndLong := GetWindowLong(hWnd, GWL_EXSTYLE);
  Result := BitInValue(WndLong, WS_EX_TOPMOST);
end;

function IsDisableWindow(hWnd: THandle): Boolean;
var
  WndLong: DWORD;
begin
  WndLong := GetWindowLong(hWnd, GWL_STYLE);
  Result := BitInValue(WndLong, WS_DISABLED);
end;

end.
