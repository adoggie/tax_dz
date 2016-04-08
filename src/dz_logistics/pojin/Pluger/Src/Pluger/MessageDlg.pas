unit MessageDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Math, 
  StdCtrls, MakeInvoice0701, ExtCtrls, ComCtrls, ShareMem, IniFiles, GlobalDefine;

type
  TfrmMessageDlg = class(TForm)
    btnFreeSelf: TButton;
    TimerWork: TTimer;
    PageControl1: TPageControl;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    btnRefreshControls: TButton;
    MemoControl: TMemo;
    btnFindControl: TButton;
    btnGetControlText: TButton;
    edtSetControlText: TEdit;
    btnSetControlText: TButton;
    btnSetControlVisible: TButton;
    cmbSetControlVisible: TComboBox;
    btnSetControlData: TButton;
    dtSetControlDateTime: TDateTimePicker;
    cmbControlName: TComboBox;
    btnSetControlItemIndex: TButton;
    cmbSetControlItemIndex: TComboBox;
    btnGetControlItemCount: TButton;
    btnGetDbGridDataSet: TButton;
    edtDataSetObj: TEdit;
    Label1: TLabel;
    btnDataSetPos: TButton;
    btnGetDataSetClass: TButton;
    btnDataSetAppend: TButton;
    btnDatSetGetActive: TButton;
    btnDataSetGetFields: TButton;
    edtFieldName: TEdit;
    Label2: TLabel;
    btnGetFieldValue: TButton;
    Label3: TLabel;
    edtFieldValue: TEdit;
    btnSetFieldValue: TButton;
    MemoCtrl: TMemo;
    TabSheet4: TTabSheet;
    chkAutoInvoiceNumTip: TCheckBox;
    chkAutoClose_TLoginForm: TCheckBox;
    cmbRootObj: TComboBox;
    btnDataSet_First: TButton;
    btnDataSet_Next: TButton;
    Button1: TButton;
    TabSheet5: TTabSheet;
    PanelHide: TPanel;
    Button3: TButton;
    Button2: TButton;
    btnSetEditText: TButton;
    procedure btnFreeSelfClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerWorkTimer(Sender: TObject);
    procedure btnRefreshControlsClick(Sender: TObject);
    procedure btnFindControlClick(Sender: TObject);
    procedure btnGetControlTextClick(Sender: TObject);
    procedure btnSetControlTextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSetControlVisibleClick(Sender: TObject);
    procedure btnSetControlDataClick(Sender: TObject);
    procedure btnSetControlItemIndexClick(Sender: TObject);
    procedure btnGetControlItemCountClick(Sender: TObject);
    procedure btnGetDbGridDataSetClick(Sender: TObject);
    procedure btnDataSetPosClick(Sender: TObject);
    procedure btnGetDataSetClassClick(Sender: TObject);
    procedure btnDataSetAppendClick(Sender: TObject);
    procedure btnDatSetGetActiveClick(Sender: TObject);
    procedure btnDataSetGetFieldsClick(Sender: TObject);
    procedure btnGetFieldValueClick(Sender: TObject);
    procedure btnSetFieldValueClick(Sender: TObject);
    procedure btnDataSet_FirstClick(Sender: TObject);
    procedure btnDataSet_NextClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnSetEditTextClick(Sender: TObject);
  private
    bDebug: Boolean;
    hSyncMsg: THandle;
    WaitFace_InvoiceInterval: DWORD;
    WaitFace_PrintInterval: DWORD;
    WaitFace_CreateInvInterval: DWORD;
    
    procedure _Init;
    procedure _Free;

  public
    { Public declarations }
    function _vcl60_bpl: HMODULE;
    function _MakeOutInv_bpl: HMODULE;
    
  public // inv_taxinfo
    bWait_InvTaxInfo: Boolean;
    invoice_type: Integer;

  public // inv_getinfo_all2
    bWait_InvGetInfoAll2: Boolean;
    bDataReady_InvGetInfoAll2: Boolean;

    GetInfoFilter: TGetInfoAll2;
    bEof_InvGetInfoAll2: Boolean;

    bGetInvQryListIndex: Boolean;

    toInvQryListIndex: Integer;

    procedure GetInvQryInfo2;
    function GetInvQryListIndex(MonthCombo: TObj; pText: PChar): Integer;
      
  public // inv_getinfo_all
    bWait_InvGetInfoAll: Boolean;
    strInvGetInfoAll: string;    
    bDataReady_InvGetInfoAll: Boolean;
    bEof_InvGetInfoAll: Boolean;

    bGetInvQryInfo: Boolean;    // 主表
    strInvQryInfo: string;

    QryInfoListType: string;        
    bGetInvQryInfoList: Boolean;// 明细
    strInvQryInfoList: string;

    bGetDataList: Boolean;

    procedure GetInvQryInfo;
    procedure GetInvQryInfoList;
    procedure GetInvDataList;
    procedure NetxInvQryInfo;

  public // inv_getinfo
    FindInfo: TGetInfo;
    
    bWait_InvGetInfo: Boolean;
    strInvGetInfo: string;
    bDataReady_InvGetInfo: Boolean;
    bEof_InvGetInfo: Boolean;

    procedure FindInvQryInfo;

  public  // inv_cancel
    CancelInfo: TCancelInfo;
    
    bWait_InvCancel: Boolean;
    bInvCancelResult: Boolean;
    bDataReady_InvCancel: Boolean;

    bFindCancelInv: Boolean;
    bClickCancelBtn: Boolean;

    procedure CancelInv;

  public  // inv_print
    PrintInfo: TPrintInfo;
    bWait_InvPrint: Boolean;
    bDataReady_InvPrint: Boolean;
    bFindPrintInv: Boolean;

    InvPrintResult: Integer;

    procedure InvPrint;

  public
    bHikKpWnd: Boolean;
    procedure ReshowKpWnds;
    procedure HideKpWnds;
  public
    //
    bAuto_InvQryDialogForm: Boolean;
    bCloseInvQryDialogParam: Boolean; // true: 放弃; false: 确认; 
    
  public // inv_create
    InvCreateResult: Integer;
    InvCreateOutResult: TCreateInvResult;
    bIsAlreadyPrint_InvCreate: Boolean; // 是否已经弹出打印窗口, 在出打印窗口出现之前 不返回,直到超时
    
    bWait_InvCreate: Boolean;
    bDataReady_InvGreate: Boolean;
    bInsertData: Boolean;
    bCloseInvSpec: Boolean;
    bInsertList: Boolean;
    bInvDiscount: Boolean;
    createInv: TCreateInv;
    MakeInvInfo: TMakeInvInfo; // 主表
    MakeInvList: TList; // 明细

    TimerInvCreate: TTimer;

    procedure AddMakeInvList(item_name, item_unit, spec: string; price, qty, amount: Double);
    procedure ClearMakeInvList;
                 
    function CheckMakeInvInfo(bill: string): Boolean;
    procedure MakeInvSpec;  // 开专用发票
    procedure MakeInvComm;  // 开普通发票

    procedure InsertDataList; // 插入清单
    procedure InvDiscount;    // 折扣

    procedure OnTimerInvCreate(Sender: TObject);
    
  public //
    procedure OnCopyData(var msg:TMessage); message WM_COPYDATA;
    procedure OnIsmShowInjectWnd(w: Integer; buf: Pointer; len: Integer);
    procedure OnIsmHideInjectWnd(w: Integer; buf: Pointer; len: Integer);
    procedure OnIsmFreeInjectWnd(w: Integer; buf: Pointer; len: Integer);

    procedure OnIsmInvReset(w: Integer; buf: Pointer; len: Integer);  //
    procedure OnIsmInvTaxInfo(w: Integer; buf: Pointer; len: Integer);  //
    procedure OnIsmInvGetInfo(w: Integer; buf: Pointer; len: Integer);  //
    procedure OnIsmInvGetInfoAll(w: Integer; buf: Pointer; len: Integer);  //
    procedure OnIsmInvGetInfoAll2(w: Integer; buf: Pointer; len: Integer);  //
    procedure OnIsmInvCreate(w: Integer; buf: Pointer; len: Integer);  //
    procedure OnIsmInvCancel(w: Integer; buf: Pointer; len: Integer);  //
    procedure OnIsmInvLock(w: Integer; buf: Pointer; len: Integer);  //
    procedure OnIsmInvUnlock(w: Integer; buf: Pointer; len: Integer);  //
    procedure OnIsmInvPrint(w: Integer; buf: Pointer; len: Integer);  //
  public
    procedure ProcessSendResult;  // 处理回包
            
  public
    procedure IsmSendMessage(MSG: DWORD; w: WPARAM = 0; buf: Pointer = nil; len: Integer = 0);
    procedure IsmSetInjectWndHandle;
    
    procedure IsmInvTaxInfoResult(errcode: Integer; code, number: string); 
    
  public
    function GetRootObj: TObj;
    function FindControlObj(RootObj: TObj; Find: string): TObj;
    function GetCustomDataSetObj: TObj;
    function FieldTypeToStr(ft: TFieldType): string;
    function GetFieldValue(obj: TObj): string;
    procedure SetFieldValue(obj: TObj);
    function BooleanToStr(v: Boolean): string;
    function GetCustomDataSetField: TObj;
    procedure SetFieldValueString(objDateSet: TObj; FieldName, Value: string);
    procedure SetFieldValueFloat(objDateSet: TObj; FieldName: string; Value: Double);
    procedure SetFieldValueText(objDateSet: TObj; FieldName: string; Value: string);
    procedure SetFieldValueBoolean(objDateSet: TObj; FieldName: string; Value: Boolean);
    function GetFieldValueBoolean(objDateSet: TObj; FieldName: string): Boolean;


  public  // 操作超时
    bWaitFace_Invoice: Boolean;
    bWaitFace_Print: Boolean;
    bWaitFace_CreateInv: Boolean;
    WaitFace_InvoiceTick: DWORD;
    WaitFace_PrintTick: DWORD;
    WaitFace_CreateInvTick: DWORD;
    procedure CheckWaitFaceTimeout; // 检测等待界面超时
    function CheckPrintErrorWnd: Boolean;

  public
    procedure OutputLog(s: string);

  public
    property Debug: Boolean read bDebug;
    procedure test_InvQueryForm;
    procedure test_MakeInvInfo;
  end;

var
  frmMessageDlg: TfrmMessageDlg;
  g_bUninjectDll: Boolean = False;

implementation

procedure FreeBeginAddress; begin end;

procedure FreeSelfProc; stdcall;
asm
  // Handle                 //
  nop                       // +0
  nop                       // +1
  nop                       // +2
  nop                       // +3

  // FreeLibrary address
  nop                       // +4
  nop                       // +5
  nop                       // +6
  nop                       // +7

  call  @_Self              // 
@_Self:
  pop   ecx                 // 
  sub   ecx, $05            // -5 is :call self

@_RealProc:

  // push Handle
  mov  eax, ecx
  sub  eax, $08
  mov  eax, dword ptr [eax]
  push eax

  // call FreeLibrary
  sub  ecx, $04
  mov  ecx, dword ptr [ecx]
  Call ecx

  ret
end;

procedure FreeEndAddress; begin FreeSelfProc end;

procedure FreeSelf;
var
  pFreeFunc: Pointer;
  dwFuncSize: DWORD;
  dwFuncProcOffset: DWORD;
  dwOldProtect: DWORD;
  lpThreadID: DWORD;
begin
  if not g_bUninjectDll then
    Exit;
    
  // unhookaip
  Unhook_cdialog_PromptDlg;
  Unhook_TInvQueryForm_Create;
  Unhook_TSpecInvoiceForm_Create;
  Unhook_TMultiCommInvFrm_Create;
  Unhook_TInvDiscountForm_Create;
  Unhook_ShowWindow;

  frmMessageDlg.Close;
  frmMessageDlg.Free;

  // free self
  dwFuncSize := DWORD(@FreeEndAddress) - DWORD(@FreeBeginAddress);
  dwFuncProcOffset := DWORD(@FreeSelfProc) - DWORD(@FreeBeginAddress);
  pFreeFunc := Pointer(GlobalAlloc(GPTR, dwFuncSize));
  if VirtualProtect(pFreeFunc, dwFuncSize, PAGE_EXECUTE_READWRITE, dwOldProtect) then
  begin
    CopyMemory(pFreeFunc, @FreeBeginAddress, dwFuncSize);

    // pFreeFunc := FreeSelfProc
    Inc(PByte(pFreeFunc), dwFuncProcOffset);

    // write Handle
    PDWORD(pFreeFunc)^ := GetModuleHandle('Pluger.dll');// HInstance;
    
    // write FreeLibary address
    PDWORD(DWORD(pFreeFunc)+$04)^ := DWORD(GetProcAddress(GetModuleHandle('kernel32.dll'), 'FreeLibrary'));

    // pFreeFunc := @_RealProc
    Inc(PByte(pFreeFunc), $08);

    CreateThread(nil, 0, pFreeFunc, nil, 0, lpThreadID);
  end;
end;

{$R *.DFM}

procedure TfrmMessageDlg.btnFreeSelfClick(Sender: TObject);
begin
  g_bUninjectDll := True;
  FreeSelf;
end;

procedure TfrmMessageDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if not g_bUninjectDll then
    Action := caNone;
end;

procedure TfrmMessageDlg.TimerWorkTimer(Sender: TObject);
var
  obj: TObj;
  n: Integer;
begin
  TTimer(Sender).Enabled := False;
  try
    Caption := DateTimeToStr(Now);

    if CheckPrintErrorWnd then
    begin
      TTimer(Sender).Enabled := True;
      Exit;
    end;
  
    // 检测等待界面超时
    CheckWaitFaceTimeout;

    // 关闭[警告信息]窗口
    MI_Close_TMessageDlgForm_Warning;
    // 关闭[错误信息]窗口
    MI_Close_TMessageDlgForm_Error;

    // 发票号码确认 ----------------------------------------------------------- //
    if MI_IsInvoiceNumTipOpen then
    begin
      // 取发票号信息
      if bWait_InvTaxInfo then
      begin
        IsmInvTaxInfoResult(
          ERROR_SUCCESS,
          Vcl60_TControl_GetText(FindControlObj(MI_GetConfirmInvNoFormObj, 'KindLabel')),
          Vcl60_TControl_GetText(FindControlObj(MI_GetConfirmInvNoFormObj, 'NoLabel'))
          );
        MI_CloseInvoiceNumTipWnd(True); // 取消窗口
        bWait_InvTaxInfo := False;
      end;
    end;

    // 选择查询月份 ----------------------------------------------------------- //
    if MI_IsInvQryDialogFormOpen then
    begin
      TTimer(Sender).Enabled := True;
      if bAuto_InvQryDialogForm then // 自动选择查询条件
      begin
        obj := FindControlObj(MI_GetInvQryDialogFormObj, 'MonthCombo');

        if bWait_InvGetInfoAll2 or bWait_InvPrint then
        begin
          // 取 GetInfoFilter.list 的ItemIndex
          if bGetInvQryListIndex then
          begin
            if bWait_InvGetInfoAll2 then
              toInvQryListIndex := GetInvQryListIndex(obj, PChar(@GetInfoFilter.list))
            else if bWait_InvPrint then
              toInvQryListIndex := GetInvQryListIndex(obj, PChar(@PrintInfo.list));

            bGetInvQryListIndex := False;

          // 查询月份不匹配
          end else if toInvQryListIndex = -1 then
          begin
            bAuto_InvQryDialogForm := False;
            
            bDataReady_InvGetInfoAll2 := True;

            InvPrintResult := ERROR_INVALID_FIND_MONTH;  // 查份月份 不匹配
            bDataReady_InvPrint := True;

            MI_Close_TInvQryDialogForm(True);
            ProcessSendResult;

          // 选择月份
          end else if toInvQryListIndex <> Vcl60_TCustomCombo_GetItemIndex(obj) then
          begin
            Vcl60_TCustomCombo_SetItemIndex(
              obj,
              toInvQryListIndex);
          
          end else if MI_Close_TInvQryDialogForm(False) then  // 确认窗口
          begin
            bAuto_InvQryDialogForm := False;
          end;

        end else
        begin
          n := Vcl60_TCustomCombo_GetItemIndex(obj);
          if n <> Vcl60_TCustomComboBox_GetItemCount(obj)-1 then
            Vcl60_TCustomCombo_SetItemIndex(
              obj,
              Vcl60_TCustomComboBox_GetItemCount(obj)-1)
          else if MI_Close_TInvQryDialogForm(False) then  // 确认窗口
              bAuto_InvQryDialogForm := False;

        end;
      
      end else
      begin
        // 查询功能正在执行
        if
          bWait_InvGetInfoAll2 or
          bWait_InvGetInfoAll or
          bWait_InvGetInfo or
          (bWait_InvPrint and bFindPrintInv)  // 正在执行打印功能,并且还没有开妈查询记录集
          then
        begin
          if MI_IsMessageDialogFormOpen then  // 没有数据
          begin
            MI_Close_MessageDialogForm;

          end else if MI_IsInvQryDialogFormVisible then
          begin
            if MI_Close_TInvQryDialogForm(True) then
            begin
              bDataReady_InvGetInfoAll2 := True;
              bDataReady_InvGetInfoAll := True;
              bDataReady_InvGetInfo := True;
              InvPrintResult := ERROR_INVALID_INV_CODE;  // 发票代码不存在
              bDataReady_InvPrint := True;
              ProcessSendResult;
            end;
          end;
        end;
      end;
    end;

    // 打印 ----------------------------------------------------------------- //
    if bWait_InvPrint then
    begin
      if not bDataReady_InvPrint then
      begin
        if MI_IsInvQueryFormOpen then
        begin
          if bFindPrintInv then
            InvPrint

          else
          begin
            // 普通打印
            if PrintInfo.PrintType = pt_Print then
            begin
              // 打印确认对话框
              if MI_SureInfoDlgOpen then
              begin
                MI_SureInfoDlg_OK;

              // 打印窗口
              end else if MI_IsStartPrintInfoOpen then
              begin
                MI_Print_StartPrintInfo;
                MI_Close_MessageDialogForm;
                bDataReady_InvPrint := True;
                ProcessSendResult;  
              end;

            // 打印清单
            end else if PrintInfo.PrintType = pt_PrintList then
            begin
              // 确定窗口[该张发票没有清单]
              if MI_IsMessageDialogFormOpen then
              begin
                MI_Close_MessageDialogForm;
                InvPrintResult := ERROR_INVALID_PRINT_LIST;

              // 没有清单 关闭查询窗口,结束
              end else if InvPrintResult = ERROR_INVALID_PRINT_LIST then
              begin
                MI_Close_TInvQueryForm;
                bDataReady_InvPrint := True;
                ProcessSendResult;

              // 打印窗口
              end else if MI_IsStartPrintListInfoOpen then
              begin
                // 打印
                MI_Print_StartPrintList;
                bDataReady_InvPrint := True;
                ProcessSendResult;
              end;
            end;
          end;
        end;  // end if MI_IsInvQueryFormOpen then
      end;  // end end if not bDataReady_InvPrint then
    end;  // end if bWait_InvPrint then

    // 开票 ----------------------------------------------------------------- //
    if bWait_InvCreate then
    begin
      if not bDataReady_InvGreate then
      begin
        (*
        if MI_IsStartPrintInfoOpen then
        begin
          if createInv.make_inv_mode = mim_MakeInvPrint then // 开票并打印
          begin
            SetHideKpWnd(False);
            if not Windows.IsWindowVisible(MI_GetStartPrintInfoWnd) then
              ShowWindow(MI_GetStartPrintInfoWnd, SW_SHOW);
          end;
        end else
          SetHideKpWnd(bHikKpWnd);
        *)        
        
        // 打印窗口
        if MI_IsStartPrintInfoOpen then
        begin
          bIsAlreadyPrint_InvCreate := True;
          if createInv.make_inv_mode = mim_MakeInv then // 开票
          begin
            MI_Close_StartPrintInfo;
          end;

          if createInv.make_inv_mode = mim_MakeInvPrint then // 开票并打印
          begin                                   
            // 打印
            MI_Print_StartPrintInfo;
          
            (*
            if not Windows.IsWindowVisible(MI_GetStartPrintInfoWnd) then
            begin
              SetHideKpWnd(False);
              ShowWindow(MI_GetStartPrintInfoWnd, SW_SHOW);
              SetHideKpWnd(bHikKpWnd);
            end;
            *)
          end;

        // 发票号码确认窗口
        end else if MI_IsInvoiceNumTipOpen then
        begin
          MI_CloseInvoiceNumTipWnd(not bInsertData) 

        // 确定对话框
        end else if MI_IsMessageDialogFormOpen then
        begin
           MI_Close_MessageDialogForm;

        // 播入数据
        end else if bInsertData then
        begin
          if createInv.invoice_type = it_Normal then
            MakeInvComm;

          if createInv.invoice_type = it_Special then
            MakeInvSpec;
          
          Exit;

        // 插入清单
        end else if bInsertList then
          InsertDataList

        // 折扣
        else if bInvDiscount then
          InvDiscount;      
      
      end else
      begin
        if MI_IsInvoiceNumTipOpen then
        begin
          MI_CloseInvoiceNumTipWnd(True)

        end else if MI_SureInfoDlgOpen then
        begin
          MI_SureInfoDlg_OK

        end else if MI_IsSpecInvoiceFormOpen then
        begin
          if bCloseInvSpec then
          begin
            bCloseInvSpec := False;
            MI_Close_SpecInvoiceForm;
            
          end else if (InvCreateResult = ERROR_TIMEOUT_SAVE_INVOICE) or (InvCreateResult = ERROR_TIMEOUT_CREATE_INVOICE_ALL) then // 超时返回
            ProcessSendResult;

        end else if MI_IsMultiCommInvFrmOpen then
        begin
          if bCloseInvSpec then
          begin
            bCloseInvSpec := False;
            MI_Close_MultiCommInvFrm;
          end else if (InvCreateResult = ERROR_TIMEOUT_SAVE_INVOICE) or (InvCreateResult = ERROR_TIMEOUT_CREATE_INVOICE_ALL) then // 超时返回
            ProcessSendResult;

        end else
        begin
          if not InSendMessage then
            ProcessSendResult
          else
            OutputLog('InSendMessage');
        end;
      end;

    end;

    // 查询发票记录 ----------------------------------------------------------- //
    if bWait_InvGetInfoAll2 then
    begin
      (*
      if MI_IsMessageDialogFormOpen then
      begin
        if MI_TipInfoDlg_OK then
        begin
          strInvGetInfoAll := '';
          bDataReady_InvGetInfoAll2 := True;
          SendMessage(MI_GetInvQryDialogForm, WM_CLOSE, 0, 0);
          ProcessSendResult;
        end;
      end;
      *)

      if MI_IsInvQueryFormOpen then
      begin
        if not bEof_InvGetInfoAll then
        begin
          if bGetDataList then  // 取清单
            GetInvDataList
          
          else if bGetInvQryInfo then // 取主表
          begin
            GetInvQryInfo2
          
          end else if bGetInvQryInfoList then // 取明细
          begin
            GetInvQryInfoList
          
          end else // 下一条
          begin
            NetxInvQryInfo;
          end;

        end else
        begin
          // 没有数据了
          // 应答
          MI_Close_TInvQueryForm;
          bDataReady_InvGetInfoAll2 := True;
          ProcessSendResult;
        end;
      end;    
    end;

    // 取所有发票记录 --------------------------------------------------------- //
    if bWait_InvGetInfoAll then
    begin
      (*
      if MI_IsMessageDialogFormOpen then
      begin
        if MI_TipInfoDlg_OK then
        begin
          strInvGetInfoAll := '';
          bDataReady_InvGetInfoAll := True;
          SendMessage(MI_GetInvQryDialogForm, WM_CLOSE, 0, 0);
          ProcessSendResult;
        end;
      end;
      *)

      if MI_IsInvQueryFormOpen then
      begin
        if not bEof_InvGetInfoAll then
        begin
          if bGetDataList then  // 取清单
            GetInvDataList
          
          else if bGetInvQryInfo then // 取主表
          begin
            GetInvQryInfo
          end else if bGetInvQryInfoList then // 取明细
          begin
            GetInvQryInfoList
          end else // 下一条
          begin
            NetxInvQryInfo;
          end;

        end else
        begin
          // 没有数据了
          // 应答
          MI_Close_TInvQueryForm;
          bDataReady_InvGetInfoAll := True;
          ProcessSendResult;
        end;
      end;
    end;

    // 取指定发票记录 --------------------------------------------------------- //
    if bWait_InvGetInfo then
    begin
      (*
      if MI_IsMessageDialogFormOpen then
      begin
        if MI_TipInfoDlg_OK then
        begin
          strInvGetInfo := '';
          bDataReady_InvGetInfo := True;
          SendMessage(MI_GetInvQryDialogForm, WM_CLOSE, 0, 0);
          ProcessSendResult;
        end;
      end;
      *)
    
      if MI_IsInvQueryFormOpen then
      begin
        if not bEof_InvGetInfo then
        begin
          if bGetDataList then  // 取清单
            GetInvDataList
          
          else if bGetInvQryInfo then // 取主表
          begin
            FindInvQryInfo
          end else if bGetInvQryInfoList then // 取明细
          begin
            GetInvQryInfoList
          end else
          begin
            strInvGetInfo := strInvGetInfo + GC_SeparatorL3 + strInvQryInfoList;
            bEof_InvGetInfo := True;
          end;
        
        end else
        begin
          // 没有数据了
          // 应答
          MI_Close_TInvQueryForm;
          bDataReady_InvGetInfo := True;
          ProcessSendResult;
        end;
      end;
    end;

    // 发票作废
    if bWait_InvCancel then
    begin
      if MI_IsMessageDialogFormOpen then
      begin
        if MI_TipInfoDlg_OK then
        begin
          bInvCancelResult := False;
          bDataReady_InvCancel := True;
          ProcessSendResult;
        end;
      end;
    
      if MI_IsInvQueryFormOpen then
      begin
        if not bDataReady_InvCancel then
        begin
          if bFindCancelInv then
          begin
            CancelInv

          end else if bClickCancelBtn then
          begin
            bClickCancelBtn := False;
            TTimer(Sender).Enabled := True;
            MI_Open_TInvQueryForm_Cancel;
            Exit;

          end else
          begin
            if MI_InvCancelDlg_OK then
              bDataReady_InvCancel := True;
          end;
        
        end else
          MI_Close_TInvQueryForm;

      end else
      begin
        if bDataReady_InvCancel then
        begin
          MI_Close_TInvQueryForm;
          ProcessSendResult;
        end;
      end;
    end;

  
    if chkAutoInvoiceNumTip.Checked then
    begin
      MI_CloseInvoiceNumTipWnd(False);
    end;

    if chkAutoClose_TLoginForm.Checked then
    begin
      if MI_Close_TLoginForm then
        chkAutoClose_TLoginForm.Checked := False;
    end;

    if not InSendMessage then
    begin
      //ProcessSendResult;
    end;

  finally
    TTimer(Sender).Enabled := True;
  end;
end;

function TfrmMessageDlg._vcl60_bpl: HMODULE;
begin
  Result := GetModuleHandle('vcl60.bpl');
end;

function TfrmMessageDlg._MakeOutInv_bpl: HMODULE;
begin
  Result := GetModuleHandle('MakeOutInv.bpl');
end;

procedure TfrmMessageDlg.btnRefreshControlsClick(Sender: TObject);
var
  n, count: Integer;
  objRoot, obj: TObj;

  i, iCount: Integer;
  iObj: TObj;

  s: string;
begin
  objRoot := GetRootObj;
  n := 0;
  count := Vcl60_TWinControl_GetControlCount(objRoot);
  while n < count do
  begin
    obj := Vcl60_TWinControl_GetControl(objRoot, n);

    s := Vcl60_TComponent_GetName(obj) + ': '+ Rtl60_TObject_ClassName(obj);

    if Rtl60_TObject_ClassName(obj) = 'TLabel' then
      s := s+' : '+Vcl60_TControl_GetText(obj);
    MemoControl.Lines.Add(s); 

    if Rtl60_TObject_ClassName(obj) = 'TPanel' then
    begin
      i := 0;
      iCount := Vcl60_TWinControl_GetControlCount(obj);
      while i < iCount do
      begin
        iObj := Vcl60_TWinControl_GetControl(obj, i);

        s := '  '+Vcl60_TComponent_GetName(iobj) + ': '+ Rtl60_TObject_ClassName(iobj);
        if Rtl60_TObject_ClassName(iobj) = 'TLabel' then
          s := s+' : '+Vcl60_TControl_GetText(iobj);
        MemoControl.Lines.Add(s);

        Inc(i);
      end;
    end;

    Inc(n);
  end;
end;

procedure TfrmMessageDlg.btnFindControlClick(Sender: TObject);
var
  obj: TObj;
begin
  //obj := GetRootObj;
  //obj := Vcl60_TWinControl_FindChildControl(obj, cmbControlName.Text);

  obj := FindControlObj(GetRootObj, cmbControlName.Text);
  MemoControl.Lines.Add('Find ['+cmbControlName.Text+'] : '+IntToHex(DWORD(obj), 8));
end;

procedure TfrmMessageDlg.btnGetControlTextClick(Sender: TObject);
var
  obj: TObj;
begin
  //obj := GetRootObj;
  //obj := Vcl60_TWinControl_FindChildControl(obj, cmbControlName.Text);
  obj := FindControlObj(GetRootObj, cmbControlName.Text);

  if Assigned(obj) then
    MemoControl.Lines.Add('GetText ['+cmbControlName.Text+'] : ' + Vcl60_TControl_GetText(obj))
  else
   MemoControl.Lines.Add('Control ['+cmbControlName.Text+'] not find');
end;

procedure TfrmMessageDlg.btnSetControlTextClick(Sender: TObject);
var
  obj: TObj;
begin
  //obj := GetRootObj;
  //obj := Vcl60_TWinControl_FindChildControl(obj, cmbControlName.Text);
  obj := FindControlObj(GetRootObj, cmbControlName.Text);
  
  if Assigned(obj) then
    Vcl60_TControl_SetText(obj, edtSetControlText.Text)
  else
    MemoControl.Lines.Add('Control ['+cmbControlName.Text+'] not find');
end;

procedure TfrmMessageDlg.FormCreate(Sender: TObject);
begin
  _Init;
end;

procedure TfrmMessageDlg.btnSetControlVisibleClick(Sender: TObject);
var
  obj: TObj;
begin
  //obj := GetRootObj;
  //obj := Vcl60_TWinControl_FindChildControl(obj, cmbControlName.Text);
  obj := FindControlObj(GetRootObj, cmbControlName.Text);
  
  if Assigned(obj) then
    Vcl60_TControl_SetVisible(obj, Boolean(cmbSetControlVisible.ItemIndex))
  else
    MemoControl.Lines.Add('Control ['+cmbControlName.Text+'] not find');
end;

procedure TfrmMessageDlg.btnSetControlDataClick(Sender: TObject);
var
  obj: TObj;
begin
  //obj := GetRootObj;
  //obj := Vcl60_TWinControl_FindChildControl(obj, cmbControlName.Text);
  obj := FindControlObj(GetRootObj, cmbControlName.Text);
  
  if Assigned(obj) then
  begin
    if Rtl60_TObject_ClassName(obj) = 'TDateTimePicker' then
      Vcl60_TCommonCalendar_SetDateTime(obj, dtSetControlDateTime.DateTime)
    else
      MemoControl.Lines.Add('Control ['+cmbControlName.Text+'] type not [TDateTimePicker]');
  end else
    MemoControl.Lines.Add('Control ['+cmbControlName.Text+'] not find');
end;

procedure TfrmMessageDlg.btnSetControlItemIndexClick(Sender: TObject);
var
  obj: TObj;
  i: Integer;
begin
  try
    i := StrToInt(cmbSetControlItemIndex.Text);
  except
    cmbSetControlItemIndex.SetFocus;
    cmbSetControlItemIndex.SelectAll;
    MemoControl.Lines.Add('Invalid Index value');
    Exit;
  end;
  
  //obj := GetRootObj;
  //obj := Vcl60_TWinControl_FindChildControl(obj, cmbControlName.Text);
  obj := FindControlObj(GetRootObj, cmbControlName.Text);

  if Assigned(obj) then
  begin
    Vcl60_TCustomCombo_SetItemIndex(obj, i);
  end else
    MemoControl.Lines.Add('Control ['+cmbControlName.Text+'] not find');
end;

procedure TfrmMessageDlg.btnGetControlItemCountClick(Sender: TObject);
var
  obj: TObj;
begin
  //obj := GetRootObj;
  //obj := Vcl60_TWinControl_FindChildControl(obj, cmbControlName.Text);
  obj := FindControlObj(GetRootObj, cmbControlName.Text);

  if Assigned(obj) then
    MemoControl.Lines.Add('GetItemCount ['+cmbControlName.Text+']: '+IntToStr(Vcl60_TCustomComboBox_GetItemCount(obj)))
  else
    MemoControl.Lines.Add('Control ['+cmbControlName.Text+'] not find');  
end;

procedure TfrmMessageDlg.btnGetDbGridDataSetClick(Sender: TObject);
var
  obj: TObj;
begin
  //obj := GetRootObj;
  //obj := Vcl60_TWinControl_FindChildControl(obj, cmbControlName.Text);
  obj := FindControlObj(GetRootObj, cmbControlName.Text);
  if Assigned(obj) then                                                              
  begin
    obj := Vcldb60_TCustomDBGrid_GetDataSource(obj);
    obj := Vcldb60_TDataSource_GetDataSet(obj);
    MemoControl.Lines.Add('GetDataSource ['+cmbControlName.Text+']: '+IntToHex(DWORD(obj), 8));
    edtDataSetObj.Text := '$'+IntToHex(DWORD(obj), 8);
  end else
    MemoControl.Lines.Add('Control ['+cmbControlName.Text+'] not find');
end;

function TfrmMessageDlg.GetCustomDataSetObj: TObj;
begin
  try
    Result := TObj(DWORD(StrToInt(edtDataSetObj.Text)));
  except
    MemoControl.Lines.Add('Invalid DataSet obj');
    edtDataSetObj.SetFocus;
    edtDataSetObj.SelectAll;
    Result := nil;
  end;
end;

procedure TfrmMessageDlg.btnDataSetPosClick(Sender: TObject);
var
  obj: TObj;
begin
  obj := GetCustomDataSetObj;
  if not Assigned(obj) then
    Exit;
            
  Dbrtl60_TDataSet_Post(obj);    
end;

procedure TfrmMessageDlg.btnGetDataSetClassClick(Sender: TObject);
var
  obj: TObj;
begin
  obj := GetCustomDataSetObj;
  if not Assigned(obj) then
    Exit;
  
  MemoControl.Lines.Add('obj ['+edtDataSetObj.Text+'] class name : '+Rtl60_TObject_ClassName(obj));
end;

procedure TfrmMessageDlg.btnDataSetAppendClick(Sender: TObject);
var
  obj: TObj;
begin
  obj := GetCustomDataSetObj;
  if not Assigned(obj) then
    Exit;

  Dbrtl60_TDataSet_Append(obj);
end;

procedure TfrmMessageDlg.btnDatSetGetActiveClick(Sender: TObject);
var
  obj: TObj;
begin
  obj := GetCustomDataSetObj;
  if not Assigned(obj) then
    Exit;

  if Dbrtl60_TDataSet_GetActive(obj) then
    MemoControl.Lines.Add('obj ['+edtDataSetObj.Text+'] GetActive : True')
  else
    MemoControl.Lines.Add('obj ['+edtDataSetObj.Text+'] GetActive : False');
end;

procedure TfrmMessageDlg.btnDataSetGetFieldsClick(Sender: TObject);
var
  obj, Field: TObj;
  n, count: Integer;
begin
  obj := GetCustomDataSetObj;
  if not Assigned(obj) then
    Exit;

  obj := Dbrtl60_TDataSet_GetFields(obj);
  count := Dbrtl60_TFields_GetCount(obj);

  MemoControl.Lines.Add('obj ['+edtDataSetObj.Text+'] Field Count: '+IntToStr(count));

  n := 0;
  while n < count do
  begin
    Field := Dbrtl60_TFields_GetField(obj, n);
    MemoControl.Lines.Add(
      '  Field: '+IntToHex(DWORD(Field), 8) +
      ' | ' + Dbrtl60_TField_GetFieldName(Field) +
      ' | ' + FieldTypeToStr(TFieldType(Dbrtl60_TField_GetFieldType(Field))) +
      ' | ' + GetFieldValue(Field)
      );

    Inc(n);
  end;
end;

function TfrmMessageDlg.FieldTypeToStr(ft: TFieldType): string;
begin
  case ft of
    ftUnknown         : Result := 'ftUnknown        ';
    ftString          : Result := 'ftString         ';
    ftSmallint        : Result := 'ftSmallint       ';
    ftInteger         : Result := 'ftInteger        ';
    ftWord            : Result := 'ftWord           ';
    ftBoolean         : Result := 'ftBoolean        ';
    ftFloat           : Result := 'ftFloat          ';
    ftCurrency        : Result := 'ftCurrency       ';
    ftBCD             : Result := 'ftBCD            ';
    ftDate            : Result := 'ftDate           ';
    ftTime            : Result := 'ftTime           ';
    ftDateTime        : Result := 'ftDateTime       ';
    ftBytes           : Result := 'ftBytes          ';
    ftVarBytes        : Result := 'ftVarBytes       ';
    ftAutoInc         : Result := 'ftAutoInc        ';
    ftBlob            : Result := 'ftBlob           ';
    ftMemo            : Result := 'ftMemo           ';
    ftGraphic         : Result := 'ftGraphic        ';
    ftFmtMemo         : Result := 'ftFmtMemo        ';
    ftParadoxOle      : Result := 'ftParadoxOle     ';
    ftDBaseOle        : Result := 'ftDBaseOle       ';
    ftTypedBinary     : Result := 'ftTypedBinary    ';
    ftCursor          : Result := 'ftCursor         ';
    ftFixedChar       : Result := 'ftFixedChar      ';
    ftWideString      : Result := 'ftWideString     ';
    ftLargeint        : Result := 'ftLargeint       ';
    ftADT             : Result := 'ftADT            ';
    ftArray           : Result := 'ftArray          ';
    ftReference       : Result := 'ftReference      ';
    ftDataSet         : Result := 'ftDataSet        ';
    ftOraBlob         : Result := 'ftOraBlob        ';
    ftOraClob         : Result := 'ftOraClob        ';
    ftVariant         : Result := 'ftVariant        ';
    ftInterface       : Result := 'ftInterface      ';
    ftIDispatch       : Result := 'ftIDispatch      ';
    ftGuid            : Result := 'ftGuid           ';
    ftTimeStamp       : Result := 'ftTimeStamp      ';
    ftFMTBcd          : Result := 'ftFMTBcd         ';
    ftFixedWideChar   : Result := 'ftFixedWideChar  ';
    ftWideMemo        : Result := 'ftWideMemo       ';
    ftOraTimeStamp    : Result := 'ftOraTimeStamp   ';
    ftOraInterval     : Result := 'ftOraInterval    ';
    ftLongWord        : Result := 'ftLongWord       ';
    ftShortint        : Result := 'ftShortint       ';
    ftByte            : Result := 'ftByte           ';
    ftExtended        : Result := 'ftExtended       ';
    ftConnection      : Result := 'ftConnection     ';
    ftParams          : Result := 'ftParams         ';
    ftStream          : Result := 'ftStream         ';
    ftTimeStampOffset : Result := 'ftTimeStampOffset';
    ftObject          : Result := 'ftObject         ';
    ftSingle          : Result := 'ftSingle         ';

  else
    Result := '???(0x'+IntToHex(Integer(ft), 2)+')';
  end;
end;

function TfrmMessageDlg.GetFieldValue(obj: TObj): string;
var
  ft: TFieldType;
begin
  if Dbrtl60_TField_GetIsNull(obj) then
    Result := 'Null'
  else
  begin
    ft := TFieldType(Dbrtl60_TField_GetFieldType(obj));
    case ft of
      ftString          : Result := Dbrtl60_TStringField_GetAsString(obj);
      ftSmallint        ,
      ftInteger         : Result := IntToStr(Dbrtl60_TIntegerField_GetAsInteger(obj));

      ftBoolean         : Result := BooleanToStr(Dbrtl60_TBooleanField_GetAsBoolean(obj));
      ftFloat           ,
      ftCurrency        : Result := FloatToStr(Dbrtl60_TFloatField_GetAsFloat(obj));

  //    ftDate            : Result := 'ftDate           ';
  //    ftTime            : Result := 'ftTime           ';
  //    ftDateTime        : Result := 'ftDateTime       ';
    else
      Result := '???(!@#$%)';
    end;
  end;
end;

function TfrmMessageDlg.BooleanToStr(v: Boolean): string;
begin
  if v then
    Result := 'True'
  else
    Result := 'False';
end;

function TfrmMessageDlg.GetCustomDataSetField: TObj;
var
  obj: TObj;
begin
  Result := nil;

  obj := GetCustomDataSetObj;
  if not Assigned(obj) then
    Exit;

  obj := Dbrtl60_TDataSet_FieldByName(obj, edtFieldName.Text);
  if not Assigned(obj) then
  begin
    MemoControl.Lines.Add('FieldName ['+edtFieldName.Text+'] not find.');
    edtFieldName.SetFocus;
    edtFieldName.SelectAll;
    Exit;
  end;

  Result := obj;
end;

procedure TfrmMessageDlg.btnGetFieldValueClick(Sender: TObject);
var
  obj: TObj;
begin
  obj := GetCustomDataSetField;
  if not Assigned(obj) then
    Exit;

  MemoControl.Lines.Add('FieldName ['+edtFieldName.Text+'] Value : ' + GetFieldValue(obj));
end;

procedure TfrmMessageDlg.btnSetFieldValueClick(Sender: TObject);
var
  obj: TObj;
begin
  obj := GetCustomDataSetField;
  if not Assigned(obj) then
    Exit;

  SetFieldValue(obj);
end;

procedure TfrmMessageDlg.SetFieldValue(obj: TObj);
var
  ft: TFieldType;
  i: Integer;
  f: Double;
begin
    ft := TFieldType(Dbrtl60_TField_GetFieldType(obj));
    case ft of
      ftString          : Dbrtl60_TStringField_SetAsString(obj, edtFieldValue.Text);//Result := Dbrtl60_TStringField_GetAsString(obj);

      ftSmallint        ,
      ftInteger         :
                        begin
                          try
                            i := StrToInt(edtFieldValue.Text);
                          except
                            MemoControl.Lines.Add('Invalid field value, field type : '+FieldTypeToStr(TFieldType(Dbrtl60_TField_GetFieldType(obj))));
                            Exit;
                          end;
                          Dbrtl60_TIntegerField_SetAsInteger(obj, i);
                        end;
      
      ftBoolean         :
                        begin
                          if (edtFieldValue.Text = 'True') or (edtFieldValue.Text = 'true') then
                            Dbrtl60_TBooleanField_SetAsBoolean(obj, True)
                          else if (edtFieldValue.Text = 'False') or (edtFieldValue.Text = 'false') then
                            Dbrtl60_TBooleanField_SetAsBoolean(obj, False)
                          else
                          begin
                            MemoControl.Lines.Add('Invalid field value, field type : '+FieldTypeToStr(TFieldType(Dbrtl60_TField_GetFieldType(obj))));
                            Exit;
                          end;
                            
                        end;

      ftFloat           ,
      ftCurrency        :
                        begin
                          try
                            f := StrToFloat(edtFieldValue.Text);
                          except
                            MemoControl.Lines.Add('Invalid field value, field type : '+FieldTypeToStr(TFieldType(Dbrtl60_TField_GetFieldType(obj))));
                            Exit;
                          end;
                          Dbrtl60_TFloatField_SetAsFloat(obj, f);
                        end;


  //    ftDate            : Result := 'ftDate           ';
  //    ftTime            : Result := 'ftTime           ';
  //    ftDateTime        : Result := 'ftDateTime       ';
    else
      MemoControl.Lines.Add('SetFieldValue ['+edtFieldName.Text+'], field type is unsettled : ' + FieldTypeToStr(TFieldType(Dbrtl60_TField_GetFieldType(obj))));
    end;

end;

procedure TfrmMessageDlg._Init;
var
  iniF: TIniFile;
begin
  TimerInvCreate := TTimer.Create(Self);
  TimerInvCreate.Enabled := False;
  TimerInvCreate.Interval := 100;
  TimerInvCreate.OnTimer := OnTimerInvCreate;

  bHikKpWnd := False;
  MakeInvList := TList.Create;

  // hook
  Hook_cdialog_PromptDlg;
  Hook_TInvQueryForm_Create;
  Hook_TSpecInvoiceForm_Create;
  Hook_TMultiCommInvFrm_Create;
  Hook_TInvDiscountForm_Create;
  Hook_ShowWindow;

  iniF := TIniFile.Create(ExtractFilePath(GetModuleName(HInstance))+GC_IniFileName);
  try
    hSyncMsg := iniF.ReadInteger(GC_SessionName, GC_ProxyHandle, 0);
    bDebug := iniF.ReadBool(GC_SessionName, GC_DEBUG, False);    
    WaitFace_InvoiceInterval := iniF.ReadInteger(GC_SessionName, GC_WaitFace_InvoiceInterval, Default_WaitFace_InvoiceInterval);
    WaitFace_PrintInterval := iniF.ReadInteger(GC_SessionName, GC_WaitFace_PrintInterval, Default_WaitFace_PrintInterval);
    WaitFace_CreateInvInterval := iniF.ReadInteger(GC_SessionName, GC_WaitFace_CreateInv, Default_WaitFace_CreateInvInterval);

    iniF.WriteInteger(GC_SessionName, GC_WaitFace_InvoiceInterval, WaitFace_InvoiceInterval);
    iniF.WriteInteger(GC_SessionName, GC_WaitFace_PrintInterval, WaitFace_PrintInterval);
    iniF.WriteInteger(GC_SessionName, GC_WaitFace_CreateInv, WaitFace_CreateInvInterval);
  finally
    iniF.Free;
  end;

  WaitFace_InvoiceTick := 0;
  WaitFace_PrintTick := 0;
  WaitFace_CreateInvTick := 0;
  bWaitFace_Invoice := False;
  bWaitFace_Print := False;
  bWaitFace_CreateInv := False;

  cmbSetControlVisible.ItemIndex := 1;
  cmbRootObj.ItemIndex := 0;

  IsmSetInjectWndHandle;
end;

procedure TfrmMessageDlg._Free;
begin
  ClearMakeInvList;
  MakeInvList.Free;
end;

procedure TfrmMessageDlg.IsmSendMessage(MSG: DWORD; w: WPARAM; buf: Pointer; len: Integer);
var
  cds: TCOPYDATASTRUCT;
begin
  FillChar(cds, Sizeof(cds), 0);
  cds.dwData := MSG;
  cds.cbData := len;
  cds.lpData := buf;
  SendMessage(hSyncMsg, WM_COPYDATA, w, LPARAM(@cds));
end;

procedure TfrmMessageDlg.IsmSetInjectWndHandle;
begin
  IsmSendMessage(ISM_SetInjectWndHandle, Handle, nil, 0);
end;

procedure TfrmMessageDlg.OnCopyData(var msg: TMessage);
var
  pCDStruct: PCOPYDATASTRUCT;
  pData: Pointer;
  DataLen: Integer;
begin
  // 默认功能被调用的,查询月份对话框选择[确认]
  bCloseInvQryDialogParam := False;
  
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

  // 确定 TimerWork 开启
  TimerWork.Enabled := True;

  case pCDStruct^.dwData of
    ISM_ShowInjectWnd:  OnIsmShowInjectWnd(msg.WParam, pData, DataLen);
    ISM_HideInjectWnd:  OnIsmHideInjectWnd(msg.WParam, pData, DataLen);
    ISM_FreeInjectWnd:  OnIsmFreeInjectWnd(msg.WParam, pData, DataLen);

    ISM_INV_RESET:              OnIsmInvReset(msg.WParam, pData, DataLen);
    ISM_INV_TAXINFO:            OnIsmInvTaxInfo(msg.WParam, pData, DataLen);
    ISM_INV_GETINFO:            OnIsmInvGetInfo(msg.WParam, pData, DataLen);
    ISM_INV_GETINFO_ALL:        OnIsmInvGetInfoAll(msg.WParam, pData, DataLen);
    ISM_INV_GETINFO_ALL2:       OnIsmInvGetInfoAll2(msg.WParam, pData, DataLen);
    ISM_INV_CREATE:             OnIsmInvCreate(msg.WParam, pData, DataLen);
    ISM_INV_CANCEL:             OnIsmInvCancel(msg.WParam, pData, DataLen);
    ISM_INV_LOCK:               OnIsmInvLock(msg.WParam, pData, DataLen);
    ISM_INV_UNLOCK:             OnIsmInvUnlock(msg.WParam, pData, DataLen);
    ISM_INV_PRINT:              OnIsmInvPrint(msg.WParam, pData, DataLen);
  end;
end;

procedure TfrmMessageDlg.OnIsmHideInjectWnd(w: Integer; buf: Pointer;
  len: Integer);
begin
  Hide;
end;

procedure TfrmMessageDlg.OnIsmShowInjectWnd(w: Integer; buf: Pointer;
  len: Integer);
begin
  Show;
end;

procedure TfrmMessageDlg.OnIsmFreeInjectWnd(w: Integer; buf: Pointer;
  len: Integer);
begin
  btnFreeSelf.Click;
end;

procedure TfrmMessageDlg.OnIsmInvReset(w: Integer; buf: Pointer; len: Integer);
begin
  OutputLog('OnIsmInvReset');

  (*
  while not MI_IsMainOpen do
  begin
    Application.ProcessMessages;
    Sleep(1);
  end;
  *)

  if not MI_IsInvoiceMgrOpen then
    MI_OpenInvoiceMgrWnd;    
end;

procedure TfrmMessageDlg.OutputLog(s: string);
begin
  if Debug then
    MemoCtrl.Lines.Add(DateTimeToStr(Now)+': '+s);  
end;

function TfrmMessageDlg.GetRootObj: TObj;
begin
  case cmbRootObj.ItemIndex of
    0: Result := MI_GetSpecInvoiceFormObj;
    1: Result := MI_GetFaceFormObj;
    2: Result := MI_GetMainFormObj;
    3: Result := MI_GetInvoiceFormObj;
    4: Result := MI_GetConfirmInvNoFormObj;
    5: Result := MI_GetTmpInvQueryFormObj;
    6: Result := MI_GetInvQryDialogFormObj;
    7: Result := MI_GetTmpSpecInvoiceFormObj;
    8: Result := MI_GetTmpMultiCommInvFrmObj;
    9: Result := MI_GetInvListFormObj;
    10: Result := MI_GetTmpInvDiscountFormObj;
    11: Result := MI_GetMultiCommInvFrmObj;
  else
    Result := nil;
  end;
end;

function TfrmMessageDlg.FindControlObj(RootObj: TObj; Find: string): TObj;
var
  n, count: Integer;
  obj: TObj;

  i, iCount: Integer;
  iObj: TObj;
begin
  Result := nil;
  n := 0;
  count := Vcl60_TWinControl_GetControlCount(RootObj);
  while n < count do
  begin
    obj := Vcl60_TWinControl_GetControl(RootObj, n);

    if StrIComp(PChar(Vcl60_TComponent_GetName(obj)), PChar(Find)) = 0 then
    begin
      Result := obj;
      Break;
    end;    

    if Rtl60_TObject_ClassName(obj) = 'TPanel' then
    begin
      i := 0;
      iCount := Vcl60_TWinControl_GetControlCount(obj);
      while i < iCount do
      begin
        iObj := Vcl60_TWinControl_GetControl(obj, i);

        if StrIComp(PChar(Vcl60_TComponent_GetName(iobj)), PChar(Find)) = 0 then
        begin
          Result := iobj;
          Break;
        end;
        
        Inc(i);
      end;
    end;

    if Assigned(Result) then
      Break;

    Inc(n);
  end;
end;

procedure TfrmMessageDlg.OnIsmInvTaxInfo(w: Integer; buf: Pointer; len: Integer);
begin
  bWait_InvTaxInfo := True;
  invoice_type := w;

  WaitFace_InvoiceTick := GetTickCount;
  bWaitFace_Invoice := True;
  
  if invoice_type = it_Normal then
  begin
    OutputLog('OnIsmInvTaxInfo : 普通;');
    MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_MakeOutComInv);
    OutputLog('OnIsmInvTaxInfo : 普通; end');
  end;

  if invoice_type = it_Special then
  begin
    OutputLog('OnIsmInvTaxInfo : 专用;');
    MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_MakeOutSInv);
    OutputLog('OnIsmInvTaxInfo : 专用; end');    
  end;  
end;

procedure TfrmMessageDlg.OnIsmInvGetInfo(w: Integer; buf: Pointer;
  len: Integer);
begin
  OutputLog('OnIsmInvGetInfo : ');
  bGetDataList := False;
  bWait_InvGetInfo := True;
  bAuto_InvQryDialogForm := True;
  bDataReady_InvGetInfo := False;
  bEof_InvGetInfo := False;

  bGetInvQryInfo := True;    // 主表
  strInvQryInfo := '';
  bGetInvQryInfoList := False;// 明细
  strInvQryInfoList := '';

  CopyMemory(@FindInfo, buf, len); 
  //  

  MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_SInvQry);
end;

procedure TfrmMessageDlg.OnIsmInvGetInfoAll(w: Integer; buf: Pointer;
  len: Integer);
begin
  OutputLog('OnIsmInvGetInfoAll : ');
  bGetDataList := False;
  bWait_InvGetInfoAll := True;
  bAuto_InvQryDialogForm := True;
  bDataReady_InvGetInfoAll := False;
  bEof_InvGetInfoAll := False;

  bGetInvQryInfo := True;    // 主表
  strInvQryInfo := '';
  //bGetInvQryInfoList := True;// 明细
  strInvQryInfoList := '';
  strInvGetInfoAll := '';

  MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_SInvQry);
end;

procedure TfrmMessageDlg.OnIsmInvGetInfoAll2(w: Integer; buf: Pointer; len: Integer);
begin
  OutputLog('OnIsmInvGetInfoAll2 : ');
  bGetDataList := False;
  bWait_InvGetInfoAll2 := True;
  bAuto_InvQryDialogForm := True;
  bDataReady_InvGetInfoAll2 := False;
  bEof_InvGetInfoAll := False;

  bGetInvQryInfo := True;
  strInvQryInfo := '';
  bGetInvQryInfoList := False;
  strInvQryInfoList := '';  
  strInvGetInfoAll := '';

  GetInfoFilter := PGetInfoAll2(buf)^;

  bGetInvQryListIndex := True;
  MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_SInvQry);
end;

procedure TfrmMessageDlg.OnIsmInvCreate(w: Integer; buf: Pointer;
  len: Integer);
var
  bill: string;
begin
  createInv := PCreateInv(buf)^;

  bIsAlreadyPrint_InvCreate := False;

  WaitFace_CreateInvTick := GetTickCount;
  bWaitFace_CreateInv := True;

  InvCreateResult := ERROR_SUCCESS;
  bDataReady_InvGreate := False;
  bInsertList := False;

  bill := Copy(PChar(DWORD(buf)+SizeOf(TCreateInv)), 1, createInv.bill_bufsize);
  bWait_InvCreate := True;
  
  // 检查/记录参数
  if not CheckMakeInvInfo(bill) then
  begin
    // 直接返回参数错误
    OutputLog('OnIsmInvCreate(): 参数错误');
    InvCreateResult := ERROR_INVALID_PARAMETER;
    bDataReady_InvGreate := True;

  end else
  begin
    bInsertData := True;

    WaitFace_InvoiceTick := GetTickCount;
    bWaitFace_Invoice := True;

    OutputLog('  开票: TimerInvCreate.Enabled := True;  1');
    TimerInvCreate.Enabled := True;
    OutputLog('  开票: TimerInvCreate.Enabled := True;  2');
    (*
    if createInv.invoice_type = it_Normal then
      MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_MakeOutComInv)
    else if createInv.invoice_type = it_Special then
      MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_MakeOutSInv);
    *)
  end;  
end;

procedure TfrmMessageDlg.OnIsmInvCancel(w: Integer; buf: Pointer; len: Integer);
begin
  OutputLog('OnIsmInvCancel : ');
  bWait_InvCancel := True;
  bDataReady_InvCancel := False;
  bFindCancelInv := True;
  bClickCancelBtn := False;

  CopyMemory(@CancelInfo, buf, len); 

  MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_SInvCancel);
end;

procedure TfrmMessageDlg.IsmInvTaxInfoResult(errcode: Integer; code, number: string);
var
  TaxInfoResult: TTaxInfoResult;
begin
  FillChar(TaxInfoResult, SizeOf(TaxInfoResult), 0);
  CopyMemory(@TaxInfoResult.code, PChar(code), Min(SizeOf(TaxInfoResult.code), Length(code)));
  CopyMemory(@TaxInfoResult.number, PChar(number), Min(SizeOf(TaxInfoResult.number), Length(number)));  
  IsmSendMessage(ISM_INV_TAXINFO_RESULT, errcode, @TaxInfoResult, SizeOf(TaxInfoResult));

  OutputLog('IsmInvTaxInfoResult : '+code+'; '+number+';');
end;

procedure TfrmMessageDlg.test_InvQueryForm;
var
  obj, DataSet, Fields, Field, dbGrid: TObj;
  n, count, i: Integer;
begin
  obj := MI_GetTmpInvQueryFormObj;
  dbGrid := FindControlObj(obj, 'DBGridE');
  DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));
  Fields := Dbrtl60_TDataSet_GetFields(DataSet);
  count := Vcldb60_TCustomDBGrid_GetFieldCount(dbGrid);
  i := 0;
  Dbrtl60_TDataSet_First(DataSet);
  while not Dbrtl60_TDataSet_Eof(DataSet) do
  begin
    OutputLog('------------------- '+IntToStr(i)+' ---------------------------');

    n := 0;
    while n < count do
    begin
      Field := Dbrtl60_TFields_GetField(Fields, n);
      OutputLog(
        '  Field: '+IntToHex(DWORD(Field), 8) +
        ' | ' + Format('%20s',[Dbrtl60_TField_GetFieldName(Field)]) +
        ' | ' + FieldTypeToStr(TFieldType(Dbrtl60_TField_GetFieldType(Field))) +
        ' | ' + BasicFuncMain_SeleInvField(Field)
        );
      Inc(n);
    end;


    Inc(i);
    Dbrtl60_TDataSet_Next(DataSet);
  end;


  MI_Close_TInvQueryForm;
end;

procedure TfrmMessageDlg.btnDataSet_FirstClick(Sender: TObject);
var
  obj: TObj;
begin
  obj := GetCustomDataSetObj;
  if not Assigned(obj) then
    Exit;

  Dbrtl60_TDataSet_First(obj);
end;

procedure TfrmMessageDlg.btnDataSet_NextClick(Sender: TObject);
var
  obj: TObj;
begin
  obj := GetCustomDataSetObj;
  if not Assigned(obj) then
    Exit;

  Dbrtl60_TDataSet_Next(obj);
end;

procedure TfrmMessageDlg.ProcessSendResult;
begin
  //
  if bWait_InvGetInfoAll2 then
    if bDataReady_InvGetInfoAll2 then
    begin
      if toInvQryListIndex = -1 then
        IsmSendMessage(ISM_INV_GETINFO_ALL_RESULT2, ERROR_INVALID_FIND_MONTH, nil, 0)
      else
        IsmSendMessage(ISM_INV_GETINFO_ALL_RESULT2, ERROR_SUCCESS, PChar(strInvGetInfoAll), Length(strInvGetInfoAll)*SizeOf(Char)); 

      bDataReady_InvGetInfoAll2 := False;
      bWait_InvGetInfoAll2 := False;
    end;
  //
  if bWait_InvGetInfoAll then
    if bDataReady_InvGetInfoAll then
    begin
      IsmSendMessage(ISM_INV_GETINFO_ALL_RESULT, 0, PChar(strInvGetInfoAll), Length(strInvGetInfoAll)*SizeOf(Char));
      bDataReady_InvGetInfoAll := False;
      bWait_InvGetInfoAll := False;
    end;

  // 
  if bWait_InvGetInfo then
    if bDataReady_InvGetInfo then
    begin
      IsmSendMessage(ISM_INV_GETINFO_RESULT, 0, PChar(strInvGetInfo), Length(strInvGetInfo)*SizeOf(Char));
      bDataReady_InvGetInfo := False;
      bWait_InvGetInfo := False;
    end;

  //
  if bWait_InvCancel then
    if bDataReady_InvCancel then
    begin
      IsmSendMessage(ISM_INV_CANCEL_RESULT, Integer(bInvCancelResult), nil, 0);
      bWait_InvCancel := False;
      bDataReady_InvCancel := False;
    end;

  //
  if bWait_InvCreate then
    if bDataReady_InvGreate then
    begin
      // 已经弹出打印窗口 或 失败, 可以返回
      if (
        bIsAlreadyPrint_InvCreate or
        (InvCreateResult <> ERROR_SUCCESS)
        ) then
      begin
        // 如果 已经弹出打印窗口,则认为已经开票,反回成功
        if bIsAlreadyPrint_InvCreate then
          InvCreateResult := ERROR_SUCCESS;

        IsmSendMessage(ISM_INV_CREATE_RESULT, InvCreateResult, @InvCreateOutResult, SizeOf(InvCreateOutResult));
        bWait_InvCreate := False;
        bDataReady_InvGreate := False;
      end;
    end;

  if bWait_InvPrint then
    if bDataReady_InvPrint then
    begin
      IsmSendMessage(ISM_INV_PRINT_RESULT, InvPrintResult, nil, 0);
      bDataReady_InvPrint := False;
      bWait_InvPrint := False;
    end;
end;

procedure TfrmMessageDlg.GetInvQryInfo;
var
  obj, DataSet, dbGrid: TObj;
  
  function _GetFieldValue(FieldName: string): string;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := BasicFuncMain_SeleInvField(objField);    
  end;

  function _GetFieldValueStr(FieldName: string): string;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := Dbrtl60_TStringField_GetAsString(objField);    
  end;

begin
  obj := MI_GetTmpInvQueryFormObj;
  dbGrid := FindControlObj(obj, 'DBGridE');
  DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));

  if Length(strInvGetInfoAll) = 0 then
    ;//Dbrtl60_TDataSet_First(DataSet);;

  strInvQryInfo := '';
  strInvQryInfo := strInvQryInfo + _GetFieldValue('发票种类') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('类别代码') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('发票号码') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('开票机号') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('购方名称') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('购方税号') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('购方地址电话') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('购方银行帐号') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('加密版本号') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('密文') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('开票日期') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('所属月份') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('合计金额') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('税率') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('合计税额') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('主要商品名称') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('商品税目') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValueStr('备注') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('开票人') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('收款人') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('复核人') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('打印标志') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('作废标志') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('清单标志') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('修复标志') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('登记标志') + GC_SeparatorL1;
  strInvQryInfo := strInvQryInfo + _GetFieldValue('外开标志');

  MI_Open_TInvQueryForm_List;
  bGetInvQryInfo := False;
  
  QryInfoListType := _GetFieldValue('发票种类');
  bGetInvQryInfoList := True;
end;

procedure TfrmMessageDlg.GetInvQryInfoList;
var
  obj, DataSet, dbGrid: TObj;

  function _GetFieldValue(FieldName: string): string;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := BasicFuncMain_SeleInvField(objField);    
  end;
var
  hWnd: THandle;
  _frmType: (_Spec, _Multi);
begin
  obj := nil;
  _frmType := _Spec;

  hWnd := MI_GetSpecInvoiceFormWnd_Find;
  if hWnd <> 0 then
    //if GetWindowVisible(hWnd) then
    if QryInfoListType = 's' then
    begin
      obj := MI_GetTmpSpecInvoiceFormObj;
      _frmType := _Spec;
    end;


  hWnd := MI_GetMultiCommInvFrmWnd_Find;
  if hWnd <> 0 then
    //if GetWindowVisible(hWnd) then
    if QryInfoListType = 'c' then
    begin
      obj := MI_GetTmpMultiCommInvFrmObj;
      _frmType := _Multi;
    end;

  if obj = nil then
    Exit;
                                 
  dbGrid := FindControlObj(obj, 'DBGridE');
  DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));

  strInvQryInfoList := '';
  Dbrtl60_TDataSet_First(DataSet);

  if StrIComp(PChar(_GetFieldValue('商品名称')), '(详见销货清单)') = 0 then
  begin
    bGetDataList := True;
    TimerWork.Enabled := True;
    MI_ClickSpecInvoiceList;
    
  end else
  begin
    while not Dbrtl60_TDataSet_Eof(DataSet) do
    begin
      if Length(strInvQryInfoList) > 0 then
        strInvQryInfoList := strInvQryInfoList + GC_SeparatorL2;

      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('发票种类') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('类别代码') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('发票号码') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('销售单据编号') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('金额') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('税率') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('税额') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('商品名称') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('商品税目') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('规格型号') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('计量单位') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('数量') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('单价') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('含税价标志') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('发票行性质') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('发票明细序号') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('商品编号') + GC_SeparatorL1;
      strInvQryInfoList := strInvQryInfoList + _GetFieldValue('单据明细序号');

      Dbrtl60_TDataSet_Next(DataSet);
    end;
  end;

  case _frmType of
    _Spec: SendMessage(MI_GetSpecInvoiceFormWnd_Find, WM_CLOSE, 0, 0);
    _Multi: SendMessage(MI_GetMultiCommInvFrmWnd_Find, WM_CLOSE, 0, 0);
  end;
  
  bGetInvQryInfoList := False;
end;

procedure TfrmMessageDlg.NetxInvQryInfo;
var
  obj, DataSet, dbGrid: TObj;
  s: string;
begin
  if bGetInvQryInfo or bGetInvQryInfoList then
    Exit;

  if Length(strInvGetInfoAll) = 0 then
    s := ''
  else
    s := GC_SeparatorL4;

  if Length(strInvQryInfo) > 0 then
  begin
    strInvGetInfoAll :=
      strInvGetInfoAll + s +
      strInvQryInfo + GC_SeparatorL3 +
      strInvQryInfoList;
  end;

  obj := MI_GetTmpInvQueryFormObj;
  dbGrid := FindControlObj(obj, 'DBGridE');
  DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));
  Dbrtl60_TDataSet_Next(DataSet);  
  bEof_InvGetInfoAll := Dbrtl60_TDataSet_Eof(DataSet);
  bGetInvQryInfo := True;
  //bGetInvQryInfoList := True;
end;

procedure TfrmMessageDlg.FindInvQryInfo;
var
  obj, DataSet, dbGrid: TObj;
  
  function _GetFieldValue(FieldName: string): string;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := BasicFuncMain_SeleInvField(objField);    
  end;

  function _GetFieldValueStr(FieldName: string): string;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := Dbrtl60_TStringField_GetAsString(objField);    
  end;
  
var
  strCode, strNumber: string;
begin
  bGetInvQryInfo := False;
  bGetInvQryInfoList := False;
  strInvGetInfo := '';
  obj := MI_GetTmpInvQueryFormObj;
  dbGrid := FindControlObj(obj, 'DBGridE');
  DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));

  Dbrtl60_TDataSet_First(DataSet);
  while not Dbrtl60_TDataSet_Eof(DataSet) do
  begin

    strCode := _GetFieldValue('类别代码');
    strNumber := _GetFieldValue('发票号码');

    if (
      (StrIComp(PChar(Trim(PChar(@FindInfo.code))), PChar(Trim(strCode))) = 0) and
      (StrIComp(PChar(Trim(PChar(@FindInfo.number))), PChar(Trim(strNumber))) = 0)
      ) then
    begin
      // 找到了
      strInvGetInfo := strInvGetInfo + _GetFieldValue('发票种类') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('类别代码') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('发票号码') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('开票机号') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('购方名称') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('购方税号') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('购方地址电话') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('购方银行帐号') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('加密版本号') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('密文') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('开票日期') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('所属月份') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('合计金额') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('税率') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('合计税额') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('主要商品名称') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('商品税目') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValueStr('备注') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('开票人') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('收款人') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('复核人') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('打印标志') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('作废标志') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('清单标志') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('修复标志') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('登记标志') + GC_SeparatorL1;
      strInvGetInfo := strInvGetInfo + _GetFieldValue('外开标志');

      QryInfoListType := _GetFieldValue('发票种类');
      bGetInvQryInfoList := True;
      MI_Open_TInvQueryForm_List;
      Break;
    end;    

    Dbrtl60_TDataSet_Next(DataSet);
  end;

  if not bGetInvQryInfoList then
  begin
    // 找不到数据
    bEof_InvGetInfo := True;
    bDataReady_InvGetInfo := True;
  end;
end;

procedure TfrmMessageDlg.CancelInv;
var
  obj, DataSet, dbGrid: TObj;
  
  function _GetFieldValue(FieldName: string): string;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := BasicFuncMain_SeleInvField(objField);    
  end;

  function _GetFieldInt(FieldName: string): Integer;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := Dbrtl60_TIntegerField_GetAsInteger(objField);    
  end;
  
var
  strCode: string;
  fCode, fNumber: Int64;
  nCode, nNumber: Int64;    
begin
  bFindCancelInv := False;
  bInvCancelResult := False;
  obj := MI_GetTmpInvQueryFormObj;
  dbGrid := FindControlObj(obj, 'DBGridE');
  DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));

  Dbrtl60_TDataSet_DisableControls(DataSet);

  fCode := StrToInt64(PChar(@CancelInfo.code));
  fNumber := StrToInt64(PChar(@CancelInfo.number));

  Dbrtl60_TDataSet_First(DataSet);
  while not Dbrtl60_TDataSet_Eof(DataSet) do
  begin

    nNumber := _GetFieldInt('发票号码');
    if (nNumber = fNumber) then
    begin
      strCode := _GetFieldValue('类别代码');
      nCode := StrToInt64(strCode);
      if (nCode = fCode) then
      begin
        // 找到了
        bInvCancelResult := True;
        Vcldb60_TBookmarkList_SetCurrentRowSelected(
          Vcldb60_TCustomDBGrid_GetBookmarkList(dbGrid),
          True);
        MI_EnabledCancelBtn;
        bClickCancelBtn := True;  // 等待点击作废按钮
        Break;
      end;
    end;

    Dbrtl60_TDataSet_Next(DataSet);
  end;

  Dbrtl60_TDataSet_EnableControls(DataSet);

  // 找不到要作废的发票,结束功能
  if not bInvCancelResult then
    bDataReady_InvCancel := True;
end;

  function _EnumWndProc_Hide(hWnd: THandle; lParam: LPARAM): BOOL; stdcall;
  var
    dwPID: DWORD;
  begin
    Result := True;

    if hWnd = frmMessageDlg.Handle then
      Exit;

    dwPID := 0;
    GetWindowThreadProcessId(hWnd, @dwPID);

    if dwPID <> Windows.GetCurrentProcessId then  // 开票软件的窗口
      Exit;

    if not Windows.IsWindowVisible(hWnd) then // 可视
      Exit;

    if Windows.GetParent(hWnd) <> 0 then // 没有父
      Exit;

    Windows.SetParent(hWnd, frmMessageDlg.PanelHide.Handle);
  end;
procedure TfrmMessageDlg.HideKpWnds;
begin
  EnumWindows(@_EnumWndProc_Hide, 0);
end;

procedure TfrmMessageDlg.ReshowKpWnds;
var
  hWnd: THandle;
begin
  hWnd := Windows.GetWindow(frmMessageDlg.PanelHide.Handle, GW_CHILD);
  while hWnd <> 0 do
  begin
    Windows.SetParent(hWnd, 0);

    hWnd := Windows.GetWindow(frmMessageDlg.PanelHide.Handle, GW_CHILD);//GW_HWNDNEXT);
  end;  
end;

function TfrmMessageDlg.CheckMakeInvInfo(bill: string): Boolean;
var
  v, Rec: string;

  function AddList(InvList: string): Boolean;
  var
    item_name,        // 商品名称
    item_unit,        // 计量单位
    spec: string;     // 规格
    price,            // 单价
    qty,              // 数量
    amount: Double;   // 金额

    v: string;
  begin
    Result := False;

    // 商品名称
    if not SeparatorStr(InvList, GC_SeparatorL1, v, InvList) then Exit;
    item_name := v;

    // 计量单位
    if not SeparatorStr(InvList, GC_SeparatorL1, v, InvList) then Exit;
    item_unit := v;

    // 规格
    if not SeparatorStr(InvList, GC_SeparatorL1, v, InvList) then Exit;
    spec      := v;

    // 单价
    if not SeparatorStr(InvList, GC_SeparatorL1, v, InvList) then Exit;
    try
      price   := StrToFloat(v);
    except
      Exit;
    end;

    // 数量
    if not SeparatorStr(InvList, GC_SeparatorL1, v, InvList) then Exit;
    try
      qty     := StrToFloat(v);
    except
      Exit;
    end;

    // 金额
    try
      amount  := StrToFloat(InvList);
    except
      Exit;
    end;

    AddMakeInvList(item_name, item_unit, spec, price, qty, amount);
    Result := True;  
  end;
  
begin
  Result := False;

  // 取主表 ----------------------------------------------------------------- //
  if not SeparatorStr(bill, GC_SeparatorL3, Rec, bill) then Exit;
  
    // 税率
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    try
      MakeInvInfo.tax_rate := StrToFloat(v);
    except
      Exit;
    end;
    // 客户名称
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.cust_name := v;
    // 客户税号
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.cust_tax_code := v;
    // 客户地址电话
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.cust_address_tel := v;
    // 客户银行帐号
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.cust_bank_account := v;
    // 备注
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.memo := v;
    // 销方银行帐号
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.seller_bank_account := v;
    // 复核人
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.checker := v;
    // 收款人
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.payee := v;
    // 负数红冲号
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.red_nr := v;
    // 负数开票相关的原始发票代码
    if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.region_inv_code := v;
    // 负数开票相关的原始
    //if not SeparatorStr(Rec, GC_SeparatorL1, v, Rec) then Exit;
    MakeInvInfo.region_inv_number := Rec;

  // 取明细 ----------------------------------------------------------------- //
  ClearMakeInvList;

  while SeparatorStr(bill, GC_SeparatorL2, Rec, bill) do
  begin
    if not AddList(Rec) then
      Exit;
  end;

  if not AddList(bill) then
    Exit;

  Result := True;
end;

procedure TfrmMessageDlg.MakeInvComm;
var
  obj, objRoot, dbGrid, DataSet: TObj;
  ListCount: Integer;
  n, count: Integer;
  pInvList: PMakeInvList;
  bMatch: Boolean;
  bTax: Boolean;
  s: string;
begin
  if not MI_IsMultiCommInvFrmOpen then
    Exit;
    
  bInsertData := False;
  TimerWork.Enabled := True;

  objRoot := MI_GetTmpMultiCommInvFrmObj;

  // 主表 ------------------------------------------------------------------- //
  obj := Self.FindControlObj(objRoot, 'CustnameCombo'); // 客户名称
  Vcl60_TControl_SetText(obj, MakeInvInfo.cust_name);
  if Length(Trim(MakeInvInfo.cust_tax_code)) <> 0 then  // 普通发票填nil可过,填空串不可过
  begin
    obj := Self.FindControlObj(objRoot, 'CustTaxCodeCombo');  // 客户税号
    Vcl60_TControl_SetText(obj, MakeInvInfo.cust_tax_code);
  end;
  obj := Self.FindControlObj(objRoot, 'CustTelCombo');  // 客户地址电话
  Vcl60_TControl_SetText(obj, MakeInvInfo.cust_address_tel);
  obj := Self.FindControlObj(objRoot, 'CustAccCombo');  // 客户银行帐号
  Vcl60_TControl_SetText(obj, MakeInvInfo.cust_bank_account);
  obj := Self.FindControlObj(objRoot, 'MemoEdit');  // 备注
  Vcl60_TControl_SetText(obj, MakeInvInfo.memo);

  // 含税 
  if createInv.tax_flag = tf_WithTax then
  begin
    if not MI_GetMultiCommInvTaxIsDown then    
      MI_ClickMultiCommInvTax;
          
  // 不含税
  end else
  begin
    if MI_GetMultiCommInvTaxIsDown then
      MI_GetMultiCommInvTaxIsDown
  end;

  obj := Self.FindControlObj(objRoot, 'SellAccCombo');  // 销方银行帐号
  bMatch := False;
  count := Vcl60_TCustomComboBox_GetItemCount(obj);
  n := 0;
  while n < count do
  begin
    Vcl60_TCustomCombo_SetItemIndex(obj, n);
    if StrIComp(PChar(Vcl60_TControl_GetText(obj)), PChar(MakeInvInfo.seller_bank_account)) = 0 then
    begin
      bMatch := True;
      Break;
    end;  
    Inc(n);
  end;

  // 销方银行帐号 不匹配
  if not bMatch then
  begin
    bCloseInvSpec := True;
    InvCreateResult := ERROR_INVALID_SELLER_BANK_ACCOUNT;
    bDataReady_InvGreate := True;
    Exit;
  end; 

  obj := Self.FindControlObj(objRoot, 'CheckerCombo');  // 复核人 // 收款人
  obj := Vcldb60_TDBComboBox_GetDataSource(obj);
  obj := Vcldb60_TDataSource_GetDataSet(obj);

  Dbrtl60_TStringField_SetAsString(
    Dbrtl60_TDataSet_FieldByName(obj, '复核人'),
    MakeInvInfo.checker);
  Dbrtl60_TStringField_SetAsString(
    Dbrtl60_TDataSet_FieldByName(obj, '收款人'),
    MakeInvInfo.payee);

  // 明细 ------------------------------------------------------------------- //
  if createInv.discount > 0 then
    ListCount := 1
  else
    ListCount := 0;

  Inc(ListCount, MakeInvList.Count);

  if ListCount > 8 then
  begin
    // 在清单中输入
    OutputLog('日清单...');

    bInsertList := True;
    MI_ClickMultiCommInvList;

  end else
  begin
    // 直接输入
    dbGrid := FindControlObj(objRoot, 'DBGridE');
    DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));

    bTax := createInv.tax_flag = tf_WithTax;
    
    n := 0;
    while n < MakeInvList.Count do
    begin
      pInvList := PMakeInvList(MakeInvList[n]);

      Dbrtl60_TDataSet_Append(DataSet);

      SetFieldValueFloat(DataSet, '税率', MakeInvInfo.tax_rate);
      SetFieldValueString(DataSet, '商品名称', pInvList^.item_name);
      SetFieldValueString(DataSet, '规格型号', pInvList^.spec);
      SetFieldValueString(DataSet, '计量单位', pInvList^.item_unit);

      SetFieldValueBoolean(DataSet, '含税价标志', bTax);

      if pInvList^.qty <> 0 then
        SetFieldValueText(DataSet, '数量', FloatToStr(pInvList^.qty));
      if pInvList^.price <> 0 then
        SetFieldValueText(DataSet, '单价', FloatToStr(pInvList^.price));
      if pInvList^.amount <> 0 then
        SetFieldValueText(DataSet, '金额', FloatToStr(pInvList^.amount));

      outputLog('数量: '+ FloatToStr(Dbrtl60_TFloatField_GetAsFloat(Dbrtl60_TDataSet_FieldByName(DataSet, '数量'))));
      outputLog('单价: '+ FloatToStr(Dbrtl60_TFloatField_GetAsFloat(Dbrtl60_TDataSet_FieldByName(DataSet, '单价'))));
      outputLog('金额: '+ FloatToStr(Dbrtl60_TFloatField_GetAsFloat(Dbrtl60_TDataSet_FieldByName(DataSet, '金额'))));

      try
      Dbrtl60_TDataSet_Post(DataSet);
      except
        OutputLog('Except: Dbrtl60_TDataSet_Post(DataSet);');
      end;                                                   

      Inc(n);
    end;

    // 插入折扣
    if createInv.discount > 0 then
    begin
      bInvDiscount := True;
      MI_ClickMultiCommInvDiscount;
    end;
  end;

  obj := Self.FindControlObj(objRoot, 'CheckerCombo');
  obj := Vcldb60_TDBComboBox_GetDataSource(obj);
  obj := Vcldb60_TDataSource_GetDataSet(obj);
  FillChar(InvCreateOutResult, SizeOf(InvCreateOutResult), 0);
  // 发票代码
  s := Dbrtl60_TStringField_GetAsString(Dbrtl60_TDataSet_FieldByName(obj, '类别代码'));
  CopyMemory(PChar(@InvCreateOutResult.code), PChar(s), Length(s));
  // 发票号码
  s := IntToStr(Dbrtl60_TIntegerField_GetAsInteger(Dbrtl60_TDataSet_FieldByName(obj, '发票号码')));
  CopyMemory(PChar(@InvCreateOutResult.number), PChar(s), Length(s));
  // 总金额 价税合计
  s := Format('%.2f', [Dbrtl60_TFloatField_GetAsFloat(Dbrtl60_TDataSet_FieldByName(obj, 'Due'))]);
  CopyMemory(PChar(@InvCreateOutResult.amount), PChar(s), Length(s));
  // 税额
  s := Format('%.2f', [Dbrtl60_TFloatField_GetAsFloat(Dbrtl60_TDataSet_FieldByName(obj, '合计税额'))]);
  CopyMemory(PChar(@InvCreateOutResult.tax), PChar(s), Length(s));

  // 开票日期
  s := Vcl60_TControl_GetText(FindControlObj(objRoot, 'DatePick'));
  CopyMemory(PChar(@InvCreateOutResult.date), PChar(s), Length(s));
  
  // 保存%打印
  WaitFace_PrintTick := GetTickCount;
  bWaitFace_Print := True;
  MI_ClickMultiCommInvPrint;

  bDataReady_InvGreate := True;
  bInsertData := False;  
end;

procedure TfrmMessageDlg.MakeInvSpec;
var
  obj, objRoot, dbGrid, DataSet: TObj;
  ListCount: Integer;
  n, count: Integer;
  pInvList: PMakeInvList;
  bMatch: Boolean;
  bTax: Boolean;
  s: string;
begin
  if not MI_IsSpecInvoiceFormOpen then
    Exit;

  bInsertData := False;
  TimerWork.Enabled := True;
        
  objRoot := MI_GetSpecInvoiceFormObj;

  // 主表 ------------------------------------------------------------------- //
  obj := Self.FindControlObj(objRoot, 'CustnameCombo'); // 客户名称
  Vcl60_TControl_SetText(obj, MakeInvInfo.cust_name);
  obj := Self.FindControlObj(objRoot, 'CustTaxCodeCombo');  // 客户税号
  Vcl60_TControl_SetText(obj, MakeInvInfo.cust_tax_code);
  obj := Self.FindControlObj(objRoot, 'CustTelCombo');  // 客户地址电话
  Vcl60_TControl_SetText(obj, MakeInvInfo.cust_address_tel);
  obj := Self.FindControlObj(objRoot, 'CustAccCombo');  // 客户银行帐号
  Vcl60_TControl_SetText(obj, MakeInvInfo.cust_bank_account);
  obj := Self.FindControlObj(objRoot, 'MemoEdit');  // 备注
  Vcl60_TControl_SetText(obj, MakeInvInfo.memo);

  // 含税 
  if createInv.tax_flag = tf_WithTax then
  begin
    MI_ClickSpecInvoiceTax;
  end;  

  obj := Self.FindControlObj(objRoot, 'SellAccCombo');  // 销方银行帐号
  bMatch := False;
  count := Vcl60_TCustomComboBox_GetItemCount(obj);
  n := 0;
  while n < count do
  begin
    Vcl60_TCustomCombo_SetItemIndex(obj, n);
    if StrIComp(PChar(Vcl60_TControl_GetText(obj)), PChar(MakeInvInfo.seller_bank_account)) = 0 then
    begin
      bMatch := True;
      Break;
    end;  
    Inc(n);
  end;

  // 销方银行帐号 不匹配
  if not bMatch then
  begin
    bCloseInvSpec := True;
    InvCreateResult := ERROR_INVALID_SELLER_BANK_ACCOUNT;
    bDataReady_InvGreate := True;
    Exit;
  end; 

  obj := Self.FindControlObj(objRoot, 'CheckerCombo');  // 复核人 // 收款人
  obj := Vcldb60_TDBComboBox_GetDataSource(obj);
  obj := Vcldb60_TDataSource_GetDataSet(obj);

  Dbrtl60_TStringField_SetAsString(
    Dbrtl60_TDataSet_FieldByName(obj, '复核人'),
    MakeInvInfo.checker);
  Dbrtl60_TStringField_SetAsString(
    Dbrtl60_TDataSet_FieldByName(obj, '收款人'),
    MakeInvInfo.payee);

  // 明细 ------------------------------------------------------------------- //
  if createInv.discount > 0 then
    ListCount := 1
  else
    ListCount := 0;

  Inc(ListCount, MakeInvList.Count);

  if ListCount > 8 then
  begin
    // 在清单中输入
    OutputLog('日清单...');

    bInsertList := True;
    MI_ClickSpecInvoiceList;

  end else
  begin
    // 直接输入
    dbGrid := FindControlObj(objRoot, 'DBGridE');
    DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));

    bTax := createInv.tax_flag = tf_WithTax;
    
    n := 0;
    while n < MakeInvList.Count do
    begin
      pInvList := PMakeInvList(MakeInvList[n]);

      Dbrtl60_TDataSet_Append(DataSet);

      SetFieldValueFloat(DataSet, '税率', MakeInvInfo.tax_rate);
      SetFieldValueString(DataSet, '商品名称', pInvList^.item_name);
      SetFieldValueString(DataSet, '规格型号', pInvList^.spec);
      SetFieldValueString(DataSet, '计量单位', pInvList^.item_unit);

      SetFieldValueBoolean(DataSet, '含税价标志', bTax);

      if pInvList^.qty <> 0 then
        SetFieldValueText(DataSet, '数量', FloatToStr(pInvList^.qty));
      if pInvList^.price <> 0 then
        SetFieldValueText(DataSet, '单价', FloatToStr(pInvList^.price));
      if pInvList^.amount <> 0 then
        SetFieldValueText(DataSet, '金额', FloatToStr(pInvList^.amount));

      outputLog('数量: '+ FloatToStr(Dbrtl60_TFloatField_GetAsFloat(Dbrtl60_TDataSet_FieldByName(DataSet, '数量'))));
      outputLog('单价: '+ FloatToStr(Dbrtl60_TFloatField_GetAsFloat(Dbrtl60_TDataSet_FieldByName(DataSet, '单价'))));
      outputLog('金额: '+ FloatToStr(Dbrtl60_TFloatField_GetAsFloat(Dbrtl60_TDataSet_FieldByName(DataSet, '金额'))));

      try
        Dbrtl60_TDataSet_Post(DataSet);
      except
        OutputLog('Except: Dbrtl60_TDataSet_Post(DataSet);');
      end;                                                   

      Inc(n);
    end;

    // 插入折扣
    if createInv.discount > 0 then
    begin
      bInvDiscount := True;
      MI_ClickSpecInvoiceDiscount;
    end;
  end;

  //objRoot := MI_GetSpecInvoiceFormObj;
  obj := Self.FindControlObj(objRoot, 'CheckerCombo');
  obj := Vcldb60_TDBComboBox_GetDataSource(obj);
  obj := Vcldb60_TDataSource_GetDataSet(obj);
  FillChar(InvCreateOutResult, SizeOf(InvCreateOutResult), 0);
  // 发票代码
  s := Dbrtl60_TStringField_GetAsString(Dbrtl60_TDataSet_FieldByName(obj, '类别代码'));
  CopyMemory(PChar(@InvCreateOutResult.code), PChar(s), Length(s));
  // 发票号码
  s := IntToStr(Dbrtl60_TIntegerField_GetAsInteger(Dbrtl60_TDataSet_FieldByName(obj, '发票号码')));
  CopyMemory(PChar(@InvCreateOutResult.number), PChar(s), Length(s));
  // 总金额 价税合计
  s := Format('%.2f', [Dbrtl60_TFloatField_GetAsFloat(Dbrtl60_TDataSet_FieldByName(obj, 'Due'))]);
  CopyMemory(PChar(@InvCreateOutResult.amount), PChar(s), Length(s));
  // 税额
  s := Format('%.2f', [Dbrtl60_TFloatField_GetAsFloat(Dbrtl60_TDataSet_FieldByName(obj, '合计税额'))]);
  CopyMemory(PChar(@InvCreateOutResult.tax), PChar(s), Length(s));

  // 开票日期
  s := Vcl60_TControl_GetText(FindControlObj(objRoot, 'DatePick'));
  CopyMemory(PChar(@InvCreateOutResult.date), PChar(s), Length(s));
  
  // 保存%打印
  WaitFace_PrintTick := GetTickCount;
  bWaitFace_Print := True;
  MI_ClickSpecInvoicePrint;

  bDataReady_InvGreate := True;
  bInsertData := False;  
end;

procedure TfrmMessageDlg.test_MakeInvInfo;
begin
  with MakeInvInfo do
  begin
    OutputLog('税率                        : '+FloatToStr(tax_rate));
    OutputLog('客户名称                    : '+cust_name);
    OutputLog('客户税号                    : '+cust_tax_code);
    OutputLog('客户地址电话                : '+cust_address_tel);
    OutputLog('客户银行帐号                : '+cust_bank_account);
    OutputLog('备注                        : '+memo);
    OutputLog('销方银行帐号                : '+seller_bank_account);
    OutputLog('复核人                      : '+checker);
    OutputLog('收款人                      : '+payee);
    OutputLog('负数红冲号                  : '+red_nr);
    OutputLog('负数开票相关的原始发票代码  : '+region_inv_code);
    OutputLog('负数开票相关的原始          : '+region_inv_number);
  end;
end;

procedure TfrmMessageDlg.SetFieldValueString(objDateSet: TObj; FieldName, Value: string);
var
  obj: TObj;
begin
  obj := Dbrtl60_TDataSet_FieldByName(objDateSet, FieldName);
  Dbrtl60_TStringField_SetAsString(obj, Value);
end;

procedure TfrmMessageDlg.SetFieldValueFloat(objDateSet: TObj;
  FieldName: string; Value: Double);
var
  obj: TObj;
begin
  obj := Dbrtl60_TDataSet_FieldByName(objDateSet, FieldName);
  Dbrtl60_TFloatField_SetAsFloat(obj, Value);
end;

procedure TfrmMessageDlg.SetFieldValueBoolean(objDateSet: TObj;
  FieldName: string; Value: Boolean);
var
  obj: TObj;
begin
  obj := Dbrtl60_TDataSet_FieldByName(objDateSet, FieldName);
  Dbrtl60_TBooleanField_SetAsBoolean(obj, Value);
end;

procedure TfrmMessageDlg.AddMakeInvList(item_name, item_unit, spec: string;
  price, qty, amount: Double);
var
  p: PMakeInvList;
begin
  GetMem(p, SizeOf(TMakeInvList));
  FillChar(p^, SizeOf(TMakeInvList), 0);
  p^.item_name := item_name;
  p^.item_unit := item_unit;
  p^.spec := spec;
  p^.price := price;
  p^.qty := qty;
  p^.amount := amount;

  MakeInvList.Add(p);
end;

procedure TfrmMessageDlg.ClearMakeInvList;
var
  p: PMakeInvList;
begin
  while MakeInvList.Count > 0 do
  begin
    p := MakeInvList.Items[0];
    p^.item_name := '';
    p^.item_unit := '';
    p^.spec := '';
    FreeMem(p, SizeOf(TMakeInvList));

    MakeInvList.Delete(0);
  end;
end;

procedure TfrmMessageDlg.FormDestroy(Sender: TObject);
begin
  _Free;
end;

procedure TfrmMessageDlg.Button1Click(Sender: TObject);
var
  obj: TObj;
begin
  //obj := GetRootObj;
  //obj := Vcl60_TWinControl_FindChildControl(obj, cmbControlName.Text);
  obj := FindControlObj(GetRootObj, cmbControlName.Text);
  if Assigned(obj) then                                                              
  begin
    obj := Vcldb60_TDBComboBox_GetDataSource(obj);
    obj := Vcldb60_TDataSource_GetDataSet(obj);
    MemoControl.Lines.Add('GetDataSource ['+cmbControlName.Text+']: '+IntToHex(DWORD(obj), 8));
    edtDataSetObj.Text := '$'+IntToHex(DWORD(obj), 8);
  end else
    MemoControl.Lines.Add('Control ['+cmbControlName.Text+'] not find');
end;

procedure TfrmMessageDlg.InsertDataList;
var
  dbGrid, DataSet: TObj;
  n: Integer;
  pInvList: PMakeInvList;
  bTax: Boolean;
begin
  if not MI_IsInvListFormOpen then
    Exit;
    
  bInsertList := False;

  dbGrid := FindControlObj(MI_GetInvListFormObj, 'DBGridE');
  DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));

  bTax := createInv.tax_flag = tf_WithTax;
  
  n := 0;
  while n < MakeInvList.Count do
  begin
    pInvList := PMakeInvList(MakeInvList[n]);

    Dbrtl60_TDataSet_Append(DataSet);
    
    SetFieldValueBoolean(DataSet, '含税价标志', bTax);
      
    SetFieldValueFloat(DataSet, '税率', MakeInvInfo.tax_rate);
    SetFieldValueString(DataSet, '商品名称', pInvList^.item_name);
    SetFieldValueString(DataSet, '规格型号', pInvList^.spec);
    SetFieldValueString(DataSet, '计量单位', pInvList^.item_unit);

    if pInvList^.qty <> 0 then
      SetFieldValueText(DataSet, '数量', FloatToStr(pInvList^.qty));
    if pInvList^.price <> 0 then
      SetFieldValueText(DataSet, '单价', FloatToStr(pInvList^.price));
    if pInvList^.amount <> 0 then
      SetFieldValueText(DataSet, '金额', FloatToStr(pInvList^.amount));

    Dbrtl60_TDataSet_Post(DataSet);

    Inc(n);
  end;

  // 插入折扣
  if createInv.discount > 0 then
  begin
    bInvDiscount := True;
    TimerWork.Enabled := True;
    MI_ClickInvListFormDiscount;
  end;

  MI_ClickInvListFormExit;
end;

function TfrmMessageDlg.GetFieldValueBoolean(objDateSet: TObj;
  FieldName: string): Boolean;
var
  obj: TObj;
begin
  obj := Dbrtl60_TDataSet_FieldByName(objDateSet, FieldName);
  Result := Dbrtl60_TBooleanField_GetAsBoolean(obj);
end;

procedure TfrmMessageDlg.GetInvDataList;
var
  dbGrid, DataSet: TObj;

  function _GetFieldValue(FieldName: string): string;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := BasicFuncMain_SeleInvField(objField);    
  end;
  
begin
  if not MI_IsInvListFormOpen then
    Exit;

  bGetDataList := False;

  dbGrid := FindControlObj(MI_GetInvListFormObj, 'DBGridE');
  DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));

  strInvQryInfoList := '';
  Dbrtl60_TDataSet_First(DataSet);

  while not Dbrtl60_TDataSet_Eof(DataSet) do
  begin
    if Length(strInvQryInfoList) > 0 then
      strInvQryInfoList := strInvQryInfoList + GC_SeparatorL2;

    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('发票种类') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('类别代码') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('发票号码') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('销售单据编号') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('金额') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('税率') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('税额') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('商品名称') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('商品税目') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('规格型号') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('计量单位') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('数量') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('单价') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('含税价标志') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('发票行性质') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('序号') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('商品编号') + GC_SeparatorL1;
    strInvQryInfoList := strInvQryInfoList + _GetFieldValue('单据明细序号');

    Dbrtl60_TDataSet_Next(DataSet);
  end;

  MI_ClickInvListFormExit;
  TimerWork.Enabled := False;
end;

procedure TfrmMessageDlg.InvDiscount;
var
  objRoot: TObj;
  hWnd: THandle;
  l: Integer;
begin
  if not MI_IsInvDiscountFormOpen then
    Exit;

  bInvDiscount := False;

  objRoot := MI_GetTmpInvDiscountFormObj;
  // 行数
  Vcl60_TControl_SetText(
    FindControlObj(objRoot, 'DisRowEdit'),
    IntToStr(MakeInvList.Count));

  // 折扣率
  if CreateInv.discount < 1 then
  begin
    Vcl60_TControl_SetText(
      FindControlObj(objRoot, 'DisRateEdit'),
      Format('%.2f', [CreateInv.discount*100]));

  // 折扣金
  end else
  begin
    Vcl60_TControl_SetText(
      FindControlObj(objRoot, 'DisCountEdit'),
      Format('%.2f', [CreateInv.discount]));
  end;

  hWnd := GlobalDefine.FindWindow('TInvDiscountForm', '折扣');
  hWnd := GlobalDefine.FindWindow('TBitBtn', '确 认', hWnd);

  TMousePos(l).x := 20;
  TMousePos(l).y := 20;
                                    
  SendMessage(hWnd, WM_LBUTTONDOWN, 0, l);
  SendMessage(hWnd, WM_LBUTTONUP, 0, l);   
end;

procedure TfrmMessageDlg.OnIsmInvLock(w: Integer; buf: Pointer;
  len: Integer);
begin
  bHikKpWnd := True;
  SetHideKpWnd(True);
  HideKpWnds;
end;

procedure TfrmMessageDlg.OnIsmInvUnlock(w: Integer; buf: Pointer;
  len: Integer);
begin
  bHikKpWnd := False;
  SetHideKpWnd(False);
  ReshowKpWnds;
end;

procedure TfrmMessageDlg.GetInvQryInfo2;
var
  obj, DataSet, dbGrid: TObj;
  
  function _GetFieldValue(FieldName: string): string;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := BasicFuncMain_SeleInvField(objField);    
  end;

  function _GetFieldValueStr(FieldName: string): string;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := Dbrtl60_TStringField_GetAsString(objField);    
  end;
var
  invDate: TDateTime;
  s: string;
begin
  obj := MI_GetTmpInvQueryFormObj;
  dbGrid := FindControlObj(obj, 'DBGridE');
  DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));

  if Length(strInvGetInfoAll) = 0 then
    ;//Dbrtl60_TDataSet_First(DataSet);

  s := _GetFieldValue('开票日期');
  invDate := EncodeDate(
      StrToInt(s[1]+s[2]+s[3]+s[4]),
      StrToInt(s[6]+s[7]),
      StrToInt(s[9]+s[10]));

  outputlog('invDate   : '+datetostr(invDate));
  outputlog('beginDate : '+datetostr(GetInfoFilter.beginDate));
  outputlog('endDate   : '+datetostr(GetInfoFilter.endDate));

  strInvQryInfo := '';
  if ((GetInfoFilter.beginDate <= invDate) and (GetInfoFilter.endDate >= invDate)) then
  begin
    strInvQryInfo := strInvQryInfo + _GetFieldValue('发票种类') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('类别代码') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('发票号码') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('开票机号') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('购方名称') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('购方税号') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('购方地址电话') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('购方银行帐号') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('加密版本号') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('密文') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('开票日期') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('所属月份') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('合计金额') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('税率') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('合计税额') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('主要商品名称') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('商品税目') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValueStr('备注') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('开票人') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('收款人') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('复核人') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('打印标志') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('作废标志') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('清单标志') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('修复标志') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('登记标志') + GC_SeparatorL1;
    strInvQryInfo := strInvQryInfo + _GetFieldValue('外开标志');

    if GetInfoFilter.flag = 0 then
    begin
      QryInfoListType := _GetFieldValue('发票种类');
      bGetInvQryInfoList := True;
      MI_Open_TInvQueryForm_List;
    end;
  end;

  bGetInvQryInfo := False;
end;

function TfrmMessageDlg.GetInvQryListIndex(MonthCombo: TObj; pText: PChar): Integer;
var
  n, Count: Integer;
  text: string;
begin
  Result := -1;
  Count := Vcl60_TCustomComboBox_GetItemCount(MonthCombo);
  n := 0;
  while n < Count do
  begin
    text := Vcl60_TCustomComboBoxStrings_Get(MonthCombo, n);

    if StrIComp(PChar(Trim(pText)), PChar(Trim(text))) = 0 then
    begin
      Result := n;
      Break;
    end;

    Inc(n);
  end;  
end;

procedure TfrmMessageDlg.Button3Click(Sender: TObject);
var
  obj: TObj;
  i: Integer;
begin
  try
    i := StrToInt(cmbSetControlItemIndex.Text);
  except
    cmbSetControlItemIndex.SetFocus;
    cmbSetControlItemIndex.SelectAll;
    MemoControl.Lines.Add('Invalid Index value');
    Exit;
  end;
  
  obj := FindControlObj(GetRootObj, cmbControlName.Text);

  if Assigned(obj) then
  begin
    MemoControl.Lines.Add('ItemText: '+ Vcl60_TCustomComboBoxStrings_Get(obj, i));
  end else
    MemoControl.Lines.Add('Control ['+cmbControlName.Text+'] not find');
end;

procedure TfrmMessageDlg.CheckWaitFaceTimeout;
begin
  // 等待开票号码窗口
  if bWaitFace_Invoice then
  begin
    // 等到了
    if MI_IsInvoiceNumTipOpen then
      bWaitFace_Invoice := False    
    // 超时
    else if GetTickCount - WaitFace_InvoiceTick > WaitFace_InvoiceInterval then
    begin
      bWaitFace_Invoice := False;
      
      // 取发票号信息
      if bWait_InvTaxInfo then
      begin
        bWait_InvTaxInfo := False;
        IsmInvTaxInfoResult(ERROR_TIMEOUT_CREATE_INVOICE, '','');
      // 开票
      end else if bWait_InvCreate then
      begin
        InvCreateResult := ERROR_TIMEOUT_CREATE_INVOICE;
        bDataReady_InvGreate := True;
      end;
    end;

  // 等待打印窗口
  end else if bWaitFace_Print then
  begin
    // 等到了
    if MI_IsStartPrintInfoOpen then
      bWaitFace_Print := False
    // 超时
    else if GetTickCount - WaitFace_PrintTick > WaitFace_PrintInterval then
    begin
      bWaitFace_Print := False;

      // 开票
      if bWait_InvCreate then
      begin
        InvCreateResult := ERROR_TIMEOUT_SAVE_INVOICE;
        bDataReady_InvGreate := True;
      end;
    end;
  end;

  // 开票总超时
  if bWaitFace_CreateInv then
  begin
    // 正在开票
    if bWait_InvCreate then
    begin
      // 已超时
      if GetTickCount - WaitFace_CreateInvTick > WaitFace_CreateInvInterval then
      begin
        InvCreateResult := ERROR_TIMEOUT_CREATE_INVOICE_ALL;
        bDataReady_InvGreate := True;
      end;
    end;    
  end;
end;

function TfrmMessageDlg.CheckPrintErrorWnd: Boolean;
var
  h: THandle;
begin
  Result := False;
  
  h := GlobalDefine.FindWindow('#32770', '错误', 0, GetCurrentProcessId);
  if h = 0 then
    Exit;

  SendMessage(h, WM_CLOSE, 0, 0);
  Result := True;
end;

procedure TfrmMessageDlg.OnTimerInvCreate(Sender: TObject);
begin
  TimerInvCreate.Enabled := False;

  if createInv.invoice_type = it_Normal then
    MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_MakeOutComInv)
  else if createInv.invoice_type = it_Special then
    MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_MakeOutSInv);
end;

procedure TfrmMessageDlg.OnIsmInvPrint(w: Integer; buf: Pointer; len: Integer);
begin
  OutputLog('OnIsmInvPrint : ');
  bWait_InvPrint := True;
  bDataReady_InvPrint := False;
  InvPrintResult := ERROR_UNKNOWN;
  
  CopyMemory(@PrintInfo, buf, len);

  bAuto_InvQryDialogForm := True;
  bGetInvQryListIndex := True;
  bFindPrintInv := True;
  MI_ClickInvoiceFormMemu(MI_GetInvoiceFormMenuObj_SInvQry);
end;

procedure TfrmMessageDlg.InvPrint;
var
  obj, DataSet, dbGrid: TObj;
  
  function _GetFieldValue(FieldName: string): string;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := BasicFuncMain_SeleInvField(objField);    
  end;

  function _GetFieldInt(FieldName: string): Integer;
  var
    objField: TObj;
  begin
    objField := Dbrtl60_TDataSet_FieldByName(DataSet, FieldName);
    Result := Dbrtl60_TIntegerField_GetAsInteger(objField);    
  end;
  
var
  strCode: string;
  fCode, fNumber: Int64;
  nCode, nNumber: Int64;
begin
  bFindPrintInv := False;
  
  obj := MI_GetTmpInvQueryFormObj;
  dbGrid := FindControlObj(obj, 'DBGridE');
  DataSet := Vcldb60_TDataSource_GetDataSet(Vcldb60_TCustomDBGrid_GetDataSource(dbGrid));

  Dbrtl60_TDataSet_DisableControls(DataSet);

  InvPrintResult := ERROR_INVALID_INV_CODE;

  fCode := StrToInt64(PChar(@PrintInfo.code));
  fNumber := StrToInt64(PChar(@PrintInfo.number));

  Dbrtl60_TDataSet_First(DataSet);
  while not Dbrtl60_TDataSet_Eof(DataSet) do
  begin
    nNumber := _GetFieldInt('发票号码');
    if (nNumber = fNumber) then
    begin
      strCode := _GetFieldValue('类别代码');
      nCode := StrToInt64(strCode);
      if (nCode = fCode) then
      begin
        // 找到了
        InvPrintResult := ERROR_SUCCESS;

        if PrintInfo.PrintType = pt_Print then
        begin
          MI_QueryInvPrint;

        end else if PrintInfo.PrintType = pt_PrintList then
        begin
          MI_QueryInvPrintList
        end;
      
        Break;
      end;
    end;

    Dbrtl60_TDataSet_Next(DataSet);
  end;

  Dbrtl60_TDataSet_EnableControls(DataSet);

  MI_Close_TInvQueryForm;
  bDataReady_InvPrint := True;
  ProcessSendResult;
end;

procedure TfrmMessageDlg.Button2Click(Sender: TObject);
begin
  MI_ClickSpecInvoiceTax;
//  MI_ClickSpecInvoiceTax;
end;

procedure TfrmMessageDlg.btnSetEditTextClick(Sender: TObject);
var
  obj: TObj;
begin
  obj := GetCustomDataSetField;
  if not Assigned(obj) then
    Exit;

  Dbrtl60_TField_SetEditText(obj, edtFieldValue.Text);
end;

procedure TfrmMessageDlg.SetFieldValueText(objDateSet: TObj; FieldName: string; Value: string);
var
  obj: TObj;
begin
  obj := Dbrtl60_TDataSet_FieldByName(objDateSet, FieldName);
  Dbrtl60_TField_SetEditText(obj, Value);
end;

end.
