library Pluger;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ShareMem,
  Windows,
  Forms,
  SysUtils,
  Classes,
  MessageDlg in 'MessageDlg.pas' {frmMessageDlg},
  MakeInvoice0701 in 'MakeInvoice0701.pas',
  GlobalDefine in '..\Public\GlobalDefine.pas',
  LDE32 in 'LDE32.pas';

{$R *.RES}

Exports
  PlugerVer;

type
  TPushRet = packed record
    _push: Byte;
    _Addr: DWORD;
    _retn: Byte; 
  end;
  PPushRet = ^TPushRet;
  
var
  oldCode: TPushRet;
  hookAddr: DWORD;
  nThreadId: DWORD;

procedure _MyCreateWndThread;
begin
  frmMessageDlg := TfrmMessageDlg.Create(nil);
  frmMessageDlg.Show;

  while not g_bUninjectDll do
  begin
    Sleep(1);
    Application.ProcessMessages;
  end;
end;

procedure _MyCreateWnd;
begin
  asm 
    pushad
    pushfd
  end;
  
  CopyMemory(Pointer(hookAddr), @oldCode, SizeOf(TPushRet));
  frmMessageDlg := TfrmMessageDlg.Create(nil);
  if frmMessageDlg.Debug then
    frmMessageDlg.Show;
  
  asm
    popfd
    popad
    
    push  hookAddr
    retn 
  end;
end;
  
procedure HookMsgLoop;
var
  PushRet: TPushRet;
  dwOldProtect: DWORD;
begin
  // 400F57BE                                                   57              push    edi
  // 400F57BF                                                   E8 48D0FBFF     call    <jmp.&user32.PeekMessageA>
  try
    hookAddr := GetModuleHandle('vcl60.bpl') + ($400F57BE - $400B0000);

    VirtualProtect(Pointer(hookAddr), SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dwOldProtect);
    CopyMemory(@oldCode, Pointer(hookAddr), SizeOf(TPushRet));
    PushRet._push := $68;
    PushRet._Addr := DWORD(@_MyCreateWnd);
    PushRet._retn := $C3;
    CopyMemory(Pointer(hookAddr), @PushRet, SizeOf(TPushRet));
  except
  end;
end;

procedure DLLHandler(Reason: Integer);
begin
  case Reason of
    DLL_PROCESS_ATTACH:
    begin
      g_bUninjectDll := False;

      HookMsgLoop;
      // CreateThread(nil, 0, @_MyCreateWndThread, nil, 0, nThreadId);
    end;
    
    DLL_PROCESS_DETACH:
    begin
      
    end;
  end;    
end;

begin
  DLLProc := @DLLHandler;
  DLLhandler(DLL_PROCESS_ATTACH);
end.
