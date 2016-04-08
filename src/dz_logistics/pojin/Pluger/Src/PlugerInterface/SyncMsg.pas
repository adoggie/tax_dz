unit SyncMsg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, GlobalDefine, ExtCtrls;

type
  TfrmSyncMsg = class(TForm)
    btn_InjectKPSystem: TButton;
    btnIsmShow: TButton;
    btnIsmHide: TButton;
    btnIsmFree: TButton;
    TimerLock: TTimer;
    PanelHide: TPanel;
    chkLock: TCheckBox;
    Memo1: TMemo;
    procedure btn_InjectKPSystemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnIsmShowClick(Sender: TObject);
    procedure btnIsmHideClick(Sender: TObject);
    procedure TimerLockTimer(Sender: TObject);
    procedure chkLockClick(Sender: TObject);
  private
    bDebug: Boolean;
    hInjectWnd: THandle;

    procedure _Init;
    procedure SetLock(const Value: Boolean);
  public
    // inv_taxinfo

    bWait_InvTaxInfo: Boolean;
    TaxInfoResult: TTaxInfoResult;
    InvTaxInfoResultErrCode: Integer;

    // inv_getinfo_all2
    bWait_InvGetInfoAll2: Boolean;
    InvGetInfoAllResult2: string;
    InvGetInfoAllResult2Code: Integer;

    // inv_getinfo_all
    bWait_InvGetInfoAll: Boolean;
    InvGetInfoAllResult: string;
    
    // inv_getinfo
    bWait_InvGetInfo: Boolean;
    InvGetInfoResult: string;

    // inv_cancel
    bWait_InvCancel: Boolean;
    bInvCancelResult: Boolean;

    // inv_create
    bWait_InvCreate: Boolean;
    InvCreateResult: Integer;
    InvCreateOutResult: TCreateInvResult;

    // inv_print
    bWait_InvPrint: Boolean;
    InvPrintResult: Integer;
    
    procedure OnCopyData(var msg:TMessage); message WM_COPYDATA;
    procedure OnIsmSetInjectWndHandle(w: Integer; buf: Pointer; len: Integer);

    procedure OnIsmInvTaxInfoResult(w: Integer; buf: Pointer; len: Integer);
    procedure OnIsmInvGetInfoResult(w: Integer; buf: Pointer; len: Integer);
    procedure OnIsmInvGetInfoAllResult(w: Integer; buf: Pointer; len: Integer);
    procedure OnIsmInvGetInfoAllResult2(w: Integer; buf: Pointer; len: Integer);
    procedure OnIsmInvCancelResult(w: Integer; buf: Pointer; len: Integer);
    procedure OnIsmInvCreateResult(w: Integer; buf: Pointer; len: Integer);
    procedure OnIsmInvPrint(w: Integer; buf: Pointer; len: Integer);


  public
    function IsmSendMessage(MSG: DWORD; w: WPARAM = 0; buf: Pointer = nil; len: Integer = 0): Boolean;
    procedure IsmShowInjectWnd;
    procedure IsmHideInjectWnd;
    procedure IsmFreeInjectWnd;
    
  public
    { Public declarations }
    property Debug: Boolean read bDebug;
    function GetKpSystemPid(phWnd: PHandle): DWORD;
    function InjectKPSystem(var errcode: Integer): Boolean;

    property InjectWnd: THandle read hInjectWnd;

  public  // lock/unlock    
    FLock: Boolean;
    procedure ReshowKpWnds;
    procedure HideKpWnds;
    property Lock: Boolean read FLock write SetLock;

  public
    procedure AddLog(s: string);
  end;

var
  frmSyncMsg: TfrmSyncMsg = nil;
  bInitialization: Boolean;
  g_bFree: Boolean;
  nThreadID: DWORD = 0;

function InitPluger: Integer; stdcall;
function FreePluger: Integer; stdcall;

implementation

uses PIExport;

procedure CreateWnd; stdcall;
begin
  frmSyncMsg := TfrmSyncMsg.Create(nil);
  if frmSyncMsg.Debug then
    frmSyncMsg.Show;
  bInitialization := True;

  while not g_bFree do
  begin
    Sleep(1);
    Application.ProcessMessages;
  end;

  frmSyncMsg.Free;
  frmSyncMsg := nil;

  nThreadID := 0;
end;

function InitPluger: Integer;
var
  errcode: Integer;
begin
  Result := ERROR_UNKNOWN;
  
  if nThreadID = 0 then
  begin
    g_bFree := False;
    bInitialization := False;
    if CreateThread(nil, 0, @CreateWnd, nil, 0, nThreadID) = 0 then
      Exit;

    while not bInitialization do
    begin
      Application.ProcessMessages;
      Sleep(1);
    end;
  end;
  
  if not frmSyncMsg.InjectKPSystem(errcode) then
  begin
    Result := errcode;
    Exit;
  end;

  Sleep(10);           

  Result := ERROR_SUCCESS;
end;

function FreePluger: Integer;
begin
  inv_unlock;
  
  if Assigned(frmSyncMsg) then
    frmSyncMsg.IsmFreeInjectWnd;
     
  g_bFree := True;
  while nThreadID <> 0 do
    Application.ProcessMessages;

  Result := ERROR_SUCCESS;
end;

{$R *.DFM}

{ TfrmSyncMsg }

procedure TfrmSyncMsg.btn_InjectKPSystemClick(Sender: TObject);
var
  errcode: Integer;
begin
  InjectKPSystem(errcode);
end;

function TfrmSyncMsg.InjectKPSystem(var errcode: Integer): Boolean;
var
  hWnd: THandle;
  dwPID: DWORD;
begin
  Result := False;

  if hInjectWnd <> 0 then
  begin
    if StrIComp(PChar(GetClassName(hInjectWnd)), 'TfrmMessageDlg') = 0 then
    begin
      errcode := ERROR_SUCCESS;
      Result := True;
      Exit;
    end else
      hInjectWnd := 0;
  end;

  errcode := ERROR_KP_NOT_FIND;  
  dwPID := GetKpSystemPid(@hWnd);
  if dwPID = 0 then
    Exit;
  
  if not InjectDll(
    dwPID,
    ExtractFilePath(GetModuleName(HInstance))+'Pluger.dll') then
  begin
    errcode := ERROR_INJECT_FAIL;    
    Exit;
  end;

  SendMessage(hWnd, 0, 0, 0);

  errcode := ERROR_SUCCESS;
  Result := True;
end;

procedure TfrmSyncMsg.FormCreate(Sender: TObject);
begin
  _Init;
end;

procedure TfrmSyncMsg._Init;
var
  iniF: TIniFile;
begin
  iniF := TIniFile.Create(ExtractFilePath(GetModuleName(HInstance))+'Pluger.ini');
  try
    iniF.WriteInteger(GC_SessionName, GC_ProxyHandle, Handle);
    bDebug := iniF.ReadBool(GC_SessionName, GC_DEBUG, False);
  finally
    iniF.Free;
  end;

  hInjectWnd := 0;

  FLock := False;
  TimerLock.Enabled := True;
end;

procedure TfrmSyncMsg.OnCopyData(var msg: TMessage);
var
  pCDStruct: PCOPYDATASTRUCT;
  pData: Pointer;
  DataLen: Integer;
begin
  pCDStruct := PCOPYDATASTRUCT(Msg.LParam);
  if Assigned(pCDStruct) then
  begin
    pData := pCDStruct^.lpData;
    DataLen := pCDStruct^.cbData;
  end else
  begin
    pData := nil;
    DataLen := 0;
  end;

  case pCDStruct^.dwData of
    ISM_SetInjectWndHandle:       OnIsmSetInjectWndHandle(msg.WParam, pData, DataLen);

    ISM_INV_TAXINFO_RESULT:       OnIsmInvTaxInfoResult(msg.WParam, pData, DataLen);
    ISM_INV_GETINFO_RESULT:       OnIsmInvGetInfoResult(msg.WParam, pData, DataLen);
    ISM_INV_GETINFO_ALL_RESULT:   OnIsmInvGetInfoAllResult(msg.WParam, pData, DataLen);
    ISM_INV_GETINFO_ALL_RESULT2:  OnIsmInvGetInfoAllResult2(msg.WParam, pData, DataLen);
    ISM_INV_CANCEL_RESULT:        OnIsmInvCancelResult(msg.WParam, pData, DataLen);
    ISM_INV_CREATE_RESULT:        OnIsmInvCreateResult(msg.WParam, pData, DataLen);
    ISM_INV_PRINT_RESULT:         OnIsmInvPrint(msg.WParam, pData, DataLen);
  end;
end;

procedure TfrmSyncMsg.OnIsmSetInjectWndHandle(w: Integer; buf: Pointer;
  len: Integer);
begin
  hInjectWnd := w;
end;

procedure TfrmSyncMsg.IsmHideInjectWnd;
begin
  IsmSendMessage(ISM_HideInjectWnd);
end;

procedure TfrmSyncMsg.IsmShowInjectWnd;
begin
  IsmSendMessage(ISM_ShowInjectWnd);
end;

procedure TfrmSyncMsg.IsmFreeInjectWnd;
begin
  IsmSendMessage(ISM_FreeInjectWnd);  
end;

function TfrmSyncMsg.IsmSendMessage(MSG: DWORD; w: WPARAM; buf: Pointer;
  len: Integer): Boolean;
var
  cds: TCOPYDATASTRUCT;
begin
  FillChar(cds, Sizeof(cds), 0);
  cds.dwData := MSG;
  cds.cbData := len;
  cds.lpData := buf;
  SendMessage(hInjectWnd, WM_COPYDATA, w, LPARAM(@cds));
  Result := IsWindow(hInjectWnd);
end;

procedure TfrmSyncMsg.btnIsmShowClick(Sender: TObject);
begin
  IsmShowInjectWnd;
end;

procedure TfrmSyncMsg.btnIsmHideClick(Sender: TObject);
begin
  IsmHideInjectWnd;
end;

procedure TfrmSyncMsg.OnIsmInvTaxInfoResult(w: Integer; buf: Pointer; len: Integer);
begin
  InvTaxInfoResultErrCode := w;
  CopyMemory(@TaxInfoResult, buf, SizeOf(TaxInfoResult));
  bWait_InvTaxInfo := False;  
end;

procedure TfrmSyncMsg.OnIsmInvGetInfoResult(w: Integer; buf: Pointer;
  len: Integer);
begin
  InvGetInfoResult := Copy(PChar(buf), 1, len);  
  bWait_InvGetInfo := False;
end;

procedure TfrmSyncMsg.OnIsmInvGetInfoAllResult(w: Integer; buf: Pointer;
  len: Integer);
begin
  InvGetInfoAllResult := Copy(PChar(buf), 1, len);  
  bWait_InvGetInfoAll := False;
end;


procedure TfrmSyncMsg.OnIsmInvCancelResult(w: Integer; buf: Pointer; len: Integer);
begin
  bInvCancelResult := Boolean(w);
  bWait_InvCancel := False;
end;

procedure TfrmSyncMsg.OnIsmInvCreateResult(w: Integer; buf: Pointer;
  len: Integer);
begin
  InvCreateResult := w;
  CopyMemory(@InvCreateOutResult, buf, len);
  bWait_InvCreate := False;
end;

procedure TfrmSyncMsg.TimerLockTimer(Sender: TObject);
begin
  TTimer(Sender).Enabled := False;

  if Lock then
    HideKpWnds
  else
    ReshowKpWnds;
  
  TTimer(Sender).Enabled := True;
end;

function TfrmSyncMsg.GetKpSystemPid(phWnd: PHandle): DWORD;
var
  hWnd: THandle;
  dwPID: DWORD;
begin
  Result := 0;
  if Assigned(phWnd) then
    phWnd^ := 0;
  hWnd := FindWindow('TFaceForm', '增值税防伪税控系统开票子系统');
  if hWnd = 0 then
    Exit;

  if Assigned(phWnd) then
    phWnd^ := hWnd;
  dwPID := 0;
  GetWindowThreadProcessId(hWnd, @dwPID);
  Result := dwPID;
end;

procedure TfrmSyncMsg.SetLock(const Value: Boolean);
begin
  (*
  if (not Value) and FLock then
  begin
    FLock := False;
    ReshowKpWnds;
  end;
  *)
    
  FLock := Value;
end;

procedure TfrmSyncMsg.chkLockClick(Sender: TObject);
begin
  Lock := chkLock.Checked;
end;

// ========================================================================== //
var
  kpPID: DWORD;

  function _EnumWndProc_Hide(hWnd: THandle; lParam: LPARAM): BOOL; stdcall;
  var
    dwPID: DWORD;
  begin
    Result := True;

    dwPID := 0;
    GetWindowThreadProcessId(hWnd, @dwPID);

    if dwPID <> kpPID then  // 开票软件的窗口
      Exit;

    if not Windows.IsWindowVisible(hWnd) then // 可视
      Exit;

    if Windows.GetParent(hWnd) <> 0 then // 没有父
      Exit;

    Windows.SetParent(hWnd, frmSyncMsg.PanelHide.Handle);
  end;
procedure TfrmSyncMsg.HideKpWnds;
begin
  kpPID := GetKpSystemPid(nil);

  EnumWindows(@_EnumWndProc_Hide, 0);
end;

procedure TfrmSyncMsg.ReshowKpWnds;
var
  hWnd: THandle;
begin
  hWnd := Windows.GetWindow(frmSyncMsg.PanelHide.Handle, GW_CHILD);
  while hWnd <> 0 do
  begin
    Windows.SetParent(hWnd, 0);

    hWnd := Windows.GetWindow(frmSyncMsg.PanelHide.Handle, GW_CHILD);//GW_HWNDNEXT);
  end;
end;

procedure TfrmSyncMsg.OnIsmInvGetInfoAllResult2(w: Integer; buf: Pointer;
  len: Integer);
begin
  InvGetInfoAllResult2Code := w;
  InvGetInfoAllResult2 := Copy(PChar(buf), 1, len);  
  bWait_InvGetInfoAll2 := False;
end;

procedure TfrmSyncMsg.AddLog(s: string);
begin
  Memo1.Lines.Add(DateTimeToStr(Now)+': '+s);
end;

procedure TfrmSyncMsg.OnIsmInvPrint(w: Integer; buf: Pointer; len: Integer);
begin
  InvPrintResult := w;
  bWait_InvPrint := False;
end;

end.

