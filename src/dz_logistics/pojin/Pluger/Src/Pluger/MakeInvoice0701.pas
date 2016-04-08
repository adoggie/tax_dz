unit MakeInvoice0701;

interface

//{$DEFINE KpVer_0615}
//{$DEFINE KpVer_0710}
{$DEFINE KpVer_0723}



uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, GlobalDefine, LDE32, ShareMem, Db;

const
{$IFDEF         KpVer_0615}
   GA_GetMessageDialogFormObj_Offset      = ($00694988 - $00680000);
   GA_Hook_TInvQueryForm_Offset           = ($01285FB1 - $011A0000);
   GA_Hook_TSpecInvoiceForm_Create_Offset = ($01284D85 - $011A0000);
   GA_Hook_TMultiCommInvFrm_Create_Offset = ($01297F27 - $011A0000);
   GA_Hook_TInvDiscountForm_Create_Offset = ($011C5608 - $011A0000);

   GA_OpenInvoiceMgrWnd_ProcAddr          = $0041019C;
   GA_OpenInvoiceMgrWnd_Ebx               = $4017A9F8;  
   GA_ClickInvoiceFormMemu_ProcAddr       = $0040791C;
   GA_ClickSpecInvoicePrint_Offset        = ($011DD1E0 - $011A0000);
   GA_ClickSpecInvoiceTax_Offset          = ($011B6000 - $011A0000);
   GA_ClickSpecInvoiceList_Offset         = ($011B6E34 - $011A0000);
   GA_ClickSpecInvoiceDiscount_Offset     = ($011B6C80 - $011A0000);
   GA_ClickInvListFormExit_Offset         = ($011C00B8 - $011A0000);
   GA_ClickInvListFormDiscount_Offset     = ($011BF05C - $011A0000);
   
{$ELSE}{$IFDEF  KpVer_0710}
   GA_GetMessageDialogFormObj_Offset      = ($00694988 - $00680000);
   GA_Hook_TInvQueryForm_Offset           = ($0128BDCE - $011A0000);
   GA_Hook_TSpecInvoiceForm_Create_Offset = ($0128AE82 - $011A0000);
   GA_Hook_TMultiCommInvFrm_Create_Offset = ($012B3236 - $011A0000);
   GA_Hook_TInvDiscountForm_Create_Offset = ($011C452D - $011A0000);

   GA_OpenInvoiceMgrWnd_ProcAddr          = $00410858;
   GA_OpenInvoiceMgrWnd_Ebx               = $4017A9F8;
   GA_ClickInvoiceFormMemu_ProcAddr       = $00407A54;
   GA_ClickSpecInvoicePrint_Offset        = ($011DDD74 - $011A0000);
   GA_ClickSpecInvoiceTax_Offset          = ($011B6170 - $011A0000);
   GA_ClickSpecInvoiceList_Offset         = ($011B6D54 - $011A0000);
   GA_ClickSpecInvoiceDiscount_Offset     = ($011B6BE4 - $011A0000);

   GA_ClickMultiCommInvPrint_Offset       = ($012B3B1C - $011A0000);

   GA_ClickInvListFormExit_Offset         = ($011BF514 - $011A0000);
   GA_ClickInvListFormDiscount_Offset     = ($011BE64C - $011A0000);

   // eax: InvQueryForm
   GA_PrintInv_Offset                     = ($0127B4A0 - $011A0000);  // 打印_发票
   GA_PrintInvList_Offset                 = ($0127E0F8 - $011A0000);  // 打印_销货清单

{$ELSE}{$IFDEF  KpVer_0723}
   GA_GetMessageDialogFormObj_Offset      = ($00694988 - $00680000);  //*
   GA_Hook_TInvQueryForm_Offset           = ($01296E96 - $011A0000);  //*
   GA_Hook_TSpecInvoiceForm_Create_Offset = ($01295F4A - $011A0000);  //*
   GA_Hook_TMultiCommInvFrm_Create_Offset = ($012BE41A - $011A0000);  //*
   GA_Hook_TInvDiscountForm_Create_Offset = ($011C512D - $011A0000);  //*
                                              
   GA_OpenInvoiceMgrWnd_ProcAddr          = $00410884;   //*
   GA_OpenInvoiceMgrWnd_Ebx               = $4017A9F8;
   GA_ClickInvoiceFormMemu_ProcAddr       = $00407764;   //*   
   GA_ClickSpecInvoicePrint_Offset        = ($011DFC24 - $011A0000);  //* 
   GA_ClickSpecInvoiceTax_Offset          = ($011B6E2C - $011A0000);  //*
   GA_ClickSpecInvoiceList_Offset         = ($011B7A3C - $011A0000);  //*  
   GA_ClickSpecInvoiceDiscount_Offset     = ($011B78A0 - $011A0000);  //*  

   GA_ClickMultiCommInvPrint_Offset       = ($012BED34 - $011A0000);  //* 

   GA_ClickInvListFormExit_Offset         = ($011C026C - $011A0000);  //*
   GA_ClickInvListFormDiscount_Offset     = ($011BF3A4 - $011A0000);  //*

   // eax: InvQueryForm                       
   GA_PrintInv_Offset                     = ($012863B8 - $011A0000);  // 打印_发票
   GA_PrintInvList_Offset                 = ($01289010 - $011A0000);  // 打印_销货清单
{$ELSE}
   raise 'err_ver'
{$ENDIF}{$ENDIF}{$ENDIF}

type
  // xe2.Data.DB
  TFieldType = (ftUnknown, ftString, ftSmallint, ftInteger, ftWord, // 0..4
    ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate, ftTime, ftDateTime, // 5..11
    ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftGraphic, ftFmtMemo, // 12..18
    ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftFixedChar, ftWideString, // 19..24
    ftLargeint, ftADT, ftArray, ftReference, ftDataSet, ftOraBlob, ftOraClob, // 25..31
    ftVariant, ftInterface, ftIDispatch, ftGuid, ftTimeStamp, ftFMTBcd, // 32..37
    ftFixedWideChar, ftWideMemo, ftOraTimeStamp, ftOraInterval, // 38..41
    ftLongWord, ftShortint, ftByte, ftExtended, ftConnection, ftParams, ftStream, //42..48
    ftTimeStampOffset, ftObject, ftSingle); //49..51
type
  TObj = PDWORD;

function MI_IsMainOpen: Boolean;            // 主窗口是否打开
function MI_IsInvoiceMgrOpen: Boolean;      // [发票管理窗口]是否打开
function MI_IsInvoiceNumTipOpen: Boolean;   // [发票号码确认]是否打开
function MI_GetInvoiceNumTipWnd: THandle;   // 取[发票号码确认]窗口
function MI_IsInvQueryFormOpen: Boolean;    //
function MI_IsInvQryDialogFormOpen: Boolean;
function MI_IsInvQryDialogFormVisible: Boolean;
function MI_IsSpecInvoiceFormOpen: Boolean;
function MI_IsMultiCommInvFrmOpen: Boolean;
function MI_IsMessageDialogFormOpen: Boolean; // [确定对话框]
function MI_IsStartPrintInfoOpen: Boolean;  // 打印确认窗口
function MI_IsStartPrintListInfoOpen: Boolean;  // 打印清单确认窗口
function MI_IsInvListFormOpen: Boolean;
function MI_IsInvDiscountFormOpen: Boolean;
function MI_SureInfoDlgOpen: Boolean;
function MI_GetInvQryDialogForm: THandle;
function MI_GetSpecInvoiceFormWnd_Find: THandle;  // 取[增值税专用发票查询]窗口
function MI_GetMultiCommInvFrmWnd_Find: THandle;  // 取[增值税普通发票查询]窗口
function MI_GetStartPrintInfoWnd: THandle;  // 取[打印确认]窗口

procedure MI_OpenMain;
procedure MI_OpenInvoiceMgrWnd;             // 打开[发票管理窗口]
procedure MI_OpenMakeInvoiceWnd;            // 打开[发票填开窗口]
procedure MI_CloseInvoiceNumTipWnd(bCancel: Boolean);
function MI_Close_TLoginForm: Boolean;      // 关闭[操作员登录]窗口
procedure MI_Close_TMessageDlgForm_Warning; // 关闭[警告信息]窗口
procedure MI_Close_TMessageDlgForm_Error;   // 关闭[错误信息]窗口
function MI_Close_TInvQryDialogForm(bCancel: Boolean): Boolean;// [发票查询条件]
procedure MI_Close_TInvQueryForm;           // 关闭 [选择发票号码作废]/[选择发票号码查询]
procedure MI_Close_StartPrintInfo;          // 关闭 [打印确认]窗口
procedure MI_Print_StartPrintInfo;          // [打印确认]窗口点击[打印]按钮
procedure MI_Print_StartPrintList;          // [清单打印]窗口点击[打印]按钮
procedure MI_Close_MessageDialogForm;
procedure MI_Close_SpecInvoiceForm;
procedure MI_Close_MultiCommInvFrm;
procedure MI_Open_TInvQueryForm_List;
procedure MI_Open_TInvQueryForm_Cancel;
function MI_InvCancelDlg_OK: Boolean; // 点按[作废确认].[确认]
function MI_TipInfoDlg_OK: Boolean; // 点按[确定对话框].[确认]
function MI_SureInfoDlg_OK: Boolean; // 点按[确认对话框].[确认]

function MI_GetFaceFormObj: TObj;
function MI_GetMainFormObj: TObj;                         
function MI_GetMainFormMenuObj: TObj;
function MI_GetInvoiceFormObj: TObj;
function MI_GetTaxCardObj: TObj;
function MI_GetSysArgObj: TObj;
function MI_GetInvoiceFormMenuObj_MakeOutComInv: TObj;  // 普通发票填开
function MI_GetInvoiceFormMenuObj_MakeOutSInv: TObj;    // 专用发票填开
function MI_GetInvoiceFormMenuObj_SInvQry: TObj;        // 已开发票查询
function MI_GetInvoiceFormMenuObj_SInvCancel: TObj;     // 已开发票作废

function MI_GetSpecInvoiceFormBtnObj_Print: TObj; // 专用开票.打印按钮
function MI_GetMultiCommInvFrmBtnObj_Print: TObj; // 普通开票.打印按钮

function MI_GetConfirmInvNoFormObj: TObj;
function MI_GetTmpInvQueryFormObj: TObj; // [选择发票号码作废]/[选择发票号码查询]
function MI_GetTmpSpecInvoiceFormObj: TObj;
function MI_GetTmpMultiCommInvFrmObj: TObj;
function MI_GetTmpInvDiscountFormObj: TObj;       
function MI_GetInvQryDialogFormObj: TObj;
function MI_GetInvListFormObj: TObj;

function MI_GetSpecInvoiceFormObj: TObj;
function MI_GetMultiCommInvFrmObj: TObj;

procedure MI_ClickInvoiceFormMemu(menu: TObj);
procedure MI_ClickSpecInvoicePrint;    // 打印
procedure MI_ClickSpecInvoiceTax;      // 含税
procedure MI_ClickSpecInvoiceList;     // 清单
procedure MI_ClickSpecInvoiceDiscount; // 折扣
procedure MI_ClickMultiCommInvPrint;   // 打印
procedure MI_ClickMultiCommInvTax;     // 含税
procedure MI_ClickMultiCommInvList;    // 清单
procedure MI_ClickMultiCommInvDiscount; // 折扣
procedure MI_ClickInvListFormExit;
procedure MI_ClickInvListFormDiscount; // 折扣
function MI_GetMultiCommInvTaxIsDown: Boolean;  // 普票填开窗口,含税按钮是否已按下

procedure MI_EnabledCancelBtn;  // 激活[作废]按钮

procedure MI_QueryInvPrint; // 查询发票打印
procedure MI_QueryInvPrintList; // 查询发票打印清单


procedure SetHideKpWnd(bHide: Boolean);
function GetHideKpWnd: Boolean;


// BasicFuncMain.bpl
function BasicFuncMain_SeleInvField(Field: TObj): string;
// cdialog.bpl
function Cdialog_GetMessageDialogFormObj: TObj;
// vcl60.pbl
function Vcl60_TControl_GetText(obj: TObj): string;
procedure Vcl60_TControl_SetText(obj: TObj; Text: string);
procedure Vcl60_TControl_SetVisible(obj: TObj; Visible: Boolean);
procedure Vcl60_TControl_SetEnabled(obj: TObj; Visible: Boolean);
 
  // TDateTimePicker
procedure Vcl60_TCommonCalendar_SetDateTime(obj: TObj; dt: TDateTime);
  // TDBComboBox
procedure Vcl60_TCustomCombo_SetItemIndex(obj: TObj; Index: Integer);
function Vcl60_TCustomCombo_GetItemIndex(obj: TObj): Integer;
function Vcl60_TCustomComboBox_GetItemCount(obj: TObj): Integer;
function Vcl60_TCustomComboBoxStrings_Get(obj: TObj; Index: Integer): string;

function Vcl60_TWinControl_GetControlCount(obj: TObj): Integer;
function Vcl60_TWinControl_GetControl(obj: TObj; Index: Integer): TObj;
function Vcl60_TWinControl_FindChildControl(obj: TObj; ControlName: string): TObj;
function Vcl60_TComponent_GetName(obj: TObj): string;

// vcldb60.pbl
function Vcldb60_TDBComboBox_GetDataSource(obj: TObj): TObj;
function Vcldb60_TCustomDBGrid_GetDataSource(obj: TObj): TObj;
function Vcldb60_TDataSource_GetDataSet(obj: TObj): TObj;

function Vcldb60_TCustomDBGrid_GetFieldCount(obj: TObj): Integer;
function Vcldb60_TCustomDBGrid_GetFields(obj: TObj; Index: Integer): TObj;

function Vcldb60_TCustomDBGrid_GetBookmarkList(obj: TObj): TObj;
procedure Vcldb60_TBookmarkList_SetCurrentRowSelected(obj: TObj; Value: Boolean);


// rtl60.pbl
function Rtl60_TObject_ClassName(obj: TObj): string;

// dbrtl60.bpl
procedure Dbrtl60_TDataSet_Post(obj: TObj);
procedure Dbrtl60_TDataSet_Append(obj: TObj);
function Dbrtl60_TDataSet_GetActive(obj: TObj): Boolean;
function Dbrtl60_TDataSet_GetFieldCount(obj: TObj): Integer;
function Dbrtl60_TDataSet_GetFields(obj: TObj): TObj;
function Dbrtl60_TDataSet_FieldByName(obj: TObj; FieldName: string): TObj;

procedure Dbrtl60_TDataSet_DisableControls(obj: TObj);
procedure Dbrtl60_TDataSet_EnableControls(obj: TObj);

procedure Dbrtl60_TDataSet_First(obj: TObj);
procedure Dbrtl60_TDataSet_Next(obj: TObj);
function Dbrtl60_TDataSet_Eof(obj: TObj): Boolean;

function Dbrtl60_TFields_GetCount(obj: TObj): Integer;
function Dbrtl60_TFields_GetField(obj: TObj; Index: Integer): TObj;
function Dbrtl60_TField_GetFieldName(obj: TObj): string;
function Dbrtl60_TField_GetFieldType(obj: TObj): TFieldType;
function Dbrtl60_TField_GetIsNull(obj: TObj): Boolean;
procedure Dbrtl60_TField_SetEditText(obj: TObj; Value: string);

function Dbrtl60_TBooleanField_GetAsBoolean(obj: TObj): Boolean;
procedure Dbrtl60_TBooleanField_SetAsBoolean(obj: TObj; Value: Boolean);
function Dbrtl60_TFloatField_GetAsFloat(obj: TObj): Double;
procedure Dbrtl60_TFloatField_SetAsFloat(obj: TObj; Value: Double);
function Dbrtl60_TIntegerField_GetAsInteger(obj: TObj): Integer;
procedure Dbrtl60_TIntegerField_SetAsInteger(obj: TObj; Value: Integer);
function Dbrtl60_TStringField_GetAsString(obj: TObj): string;
procedure Dbrtl60_TStringField_SetAsString(obj: TObj; Value: string);


// hook

procedure Hook_cdialog_PromptDlg;
procedure Unhook_cdialog_PromptDlg;

procedure Hook_TInvQueryForm_Create;
procedure Unhook_TInvQueryForm_Create;

procedure Hook_TSpecInvoiceForm_Create;
procedure Unhook_TSpecInvoiceForm_Create;

procedure Hook_TMultiCommInvFrm_Create;
procedure Unhook_TMultiCommInvFrm_Create;

procedure Hook_TInvDiscountForm_Create;
procedure Unhook_TInvDiscountForm_Create;

procedure Hook_ShowWindow;
procedure Unhook_ShowWindow;


function PlugerVer: Integer; stdcall;

implementation

uses MessageDlg;

function PlugerVer: Integer; stdcall;
begin
{$IFDEF         KpVer_0615}
  Result := 0615;
{$ELSE}{$IFDEF  KpVer_0710}
  Result := 0710;    
{$ELSE}{$IFDEF  KpVer_0723}
  Result := 0723;
{$ELSE}
  Result := -1;
{$ENDIF}{$ENDIF}{$ENDIF}
end;

var
  IsHideKpWnd: Boolean = False;

var
  _PromptDlg: TObj = nil;
  _InvQueryForm: TObj = nil;
  _SpecInvoiceForm: TObj = nil;
  _MultiCommInvFrm: TObj = nil;
  _InvDiscountForm: TObj = nil;

var
  _cdialog_PromptDlg: TPushRet;
  _TInvQueryForm_Create: TPushRet;
  _TSpecInvoiceForm_Create: TPushRet;
  _TMultiCommInvFrm_Create: TPushRet;
  _TInvDiscountForm_Create: TPushRet;
const
  CodeSizeMax = 64;
var
  _ShowWindowEP: array [0..CodeSizeMax-1] of Byte;
  _ShowWindowEP_Len: Integer;  

function _BasicFuncMain_bpl: HMODULE; forward;
function _MakeOutInv_bpl: HMODULE; forward;
function _cdialog_bpl: HMODULE; forward;
function _vcl60_bpl: HMODULE; forward;
function _rtl60_bpl: HMODULE; forward;
function _vcldb60_bpl: HMODULE; forward;
function _dbrtl60_bpl: HMODULE; forward;


// ========================================================================== //

function _BasicFuncMain_bpl: HMODULE; 
begin
  Result := GetModuleHandle('BasicFuncMain.bpl');
end;

function _MakeOutInv_bpl: HMODULE; 
begin
  Result := GetModuleHandle('MakeOutInv.bpl');
end;

function _cdialog_bpl: HMODULE; 
begin
  Result := GetModuleHandle('cdialog.bpl');
  if Result = 0 then
    Result := LoadLibrary('cdialog.bpl');
end;

function _vcl60_bpl: HMODULE;
begin
  Result := GetModuleHandle('vcl60.bpl');
end;

function _rtl60_bpl: HMODULE; 
begin
  Result := GetModuleHandle('rtl60.bpl');
end;

function _vcldb60_bpl: HMODULE;
begin
  Result := GetModuleHandle('vcldb60.bpl');
end;

function _dbrtl60_bpl: HMODULE; 
begin
  Result := GetModuleHandle('dbrtl60.bpl');
end;

// ========================================================================== //
                                                                                                    
function MI_IsMainOpen: Boolean;
var
  hWnd: THandle;
begin
  Result := False;
  hWnd := GlobalDefine.FindWindow('TMainForm', '增值税防伪税控系统防伪开票子系统');
  if hWnd = 0 then
    Exit;
  Result := GetWindowVisible(hWnd);
end;

function MI_IsInvoiceMgrOpen: Boolean;
var
  hWnd: THandle;
begin
  Result := False;
  hWnd := GlobalDefine.FindWindow('TInvoiceForm', '发票管理');
  if hWnd = 0 then
    Exit;
  Result := GetWindowVisible(hWnd);
end;

function MI_IsInvoiceNumTipOpen: Boolean;
begin                                                              
  Result := GlobalDefine.FindWindow('TConfirmInvNoForm', '发票号码确认') <> 0;
end;

function MI_GetInvoiceNumTipWnd: THandle;
begin
  Result := GlobalDefine.FindWindow('TConfirmInvNoForm', '发票号码确认');
end;

function MI_IsInvQueryFormOpen: Boolean;
begin
  Result := GlobalDefine.FindWindow('TInvQueryForm', '') <> 0;
end;

function MI_IsInvQryDialogFormOpen: Boolean;
begin
  Result := GlobalDefine.FindWindow('TInvQryDialogForm', '发票查询') <> 0;
end;

function MI_IsInvQryDialogFormVisible: Boolean;
var
  h: THandle;
begin
  Result := False;
  h := GlobalDefine.FindWindow('TInvQryDialogForm', '发票查询');
  if h = 0 then
    Exit;

  Result := IsWindowVisible(h);  
end;

function MI_IsSpecInvoiceFormOpen: Boolean;
begin
  Result := True;

  if GlobalDefine.FindWindow('TSpecInvoiceForm', '增值税专用发票填开') <> 0 then
    Exit;

  Result := False;
end;

function MI_IsMultiCommInvFrmOpen: Boolean;
begin
  Result := True;

  if GlobalDefine.FindWindow('TMultiCommInvFrm', '增值税普通发票填开') <> 0 then
    Exit;

  Result := False;
end;

function MI_IsMessageDialogFormOpen: Boolean;
begin
  Result := GlobalDefine.FindWindow('TMessageDialogForm', '确定对话框') <> 0;
end;

function MI_IsStartPrintInfoOpen: Boolean;
var
  hWnd: THandle;
begin
  Result := False;
  hWnd := GlobalDefine.FindWindow('TFormStartPrintInfo', '发票打印');
  if hWnd = 0 then
    Exit;
  Result := True;//GlobalDefine.GetWindowVisible(hWnd);
end;

function MI_IsStartPrintListInfoOpen: Boolean;
var
  hWnd: THandle;
begin
  Result := False;
  hWnd := GlobalDefine.FindWindow('TFormStartPrintInfo', '清单打印');
  if hWnd = 0 then
    Exit;
  Result := True;//GlobalDefine.GetWindowVisible(hWnd);
end;

function MI_IsInvListFormOpen: Boolean;
var
  hWnd: THandle;
begin
  Result := False;
  hWnd := GlobalDefine.FindWindow('TInvListForm', '');
  if hWnd = 0 then
    Exit;

  Result := True;//GlobalDefine.GetWindowVisible(hWnd);   
end;

function MI_IsInvDiscountFormOpen: Boolean;
begin
  Result := GlobalDefine.FindWindow('TInvDiscountForm', '折扣') <> 0;
end;

function MI_SureInfoDlgOpen: Boolean;
begin                               
  Result := GlobalDefine.FindWindow('TMessageDialogForm', '确认对话框') <> 0;
end;

function MI_GetInvQryDialogForm: THandle;
begin
  Result := GlobalDefine.FindWindow('TInvQryDialogForm', '发票查询');
end;

function MI_GetSpecInvoiceFormWnd_Find: THandle;
begin
  Result := GlobalDefine.FindWindow('TSpecInvoiceForm', '增值税专用发票查询');
end;

function MI_GetMultiCommInvFrmWnd_Find: THandle;
begin
  Result := GlobalDefine.FindWindow('TMultiCommInvFrm', '增值税普通发票查询');
end;

function MI_GetStartPrintInfoWnd: THandle;
begin
  Result := GlobalDefine.FindWindow('TFormStartPrintInfo', '发票打印');
end;

function MI_GetStartPrintListInfoWnd: THandle;
begin
  Result := GlobalDefine.FindWindow('TFormStartPrintInfo', '清单打印');
end;

procedure MI_OpenMain;
var
  hWnd: THandle;
  l: Integer;
begin
  hWnd := GlobalDefine.FindWindow('TFaceForm', '增值税防伪税控系统开票子系统');
  if hWnd = 0 then
    Exit;
  hWnd := GlobalDefine.FindWindow('TPanel', '', hWnd);
  if hWnd = 0 then
    Exit;

  TMousePos(l).x := 377;
  TMousePos(l).y := 233;

  SendMessage(hWnd, WM_LBUTTONDOWN, 0, l);
  SendMessage(hWnd, WM_LBUTTONUP, 0, l);
end;

procedure MI_OpenInvoiceMgrWnd;
var
  proc: DWORD;
  dwEax: DWORD;
begin
  proc := GA_OpenInvoiceMgrWnd_ProcAddr;
  dwEax := PDWORD(GetProcAddress(GetModuleHandle('kp.exe'), '_MainForm'))^;
  asm
    mov   eax, dwEax
    mov   ecx, $21
    mov   edx, $09
    mov   ebx, dword ptr [GA_OpenInvoiceMgrWnd_Ebx]
    call  proc
  end;
end;

procedure MI_OpenMakeInvoiceWnd;
var
  h: THandle;
  l: Integer;
begin
  h := GlobalDefine.FindWindow('TInvoiceForm', '发票管理');

  TMousePos(l).x := 235;
  TMousePos(l).y := 135;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);
end;

procedure MI_CloseInvoiceNumTipWnd(bCancel: Boolean);
var
  h: THandle;
  l: Integer;
begin
  if not MI_IsInvoiceNumTipOpen then
    Exit;

  if bCancel then
    h := GlobalDefine.FindWindow('TBitBtn', '取 消', MI_GetInvoiceNumTipWnd)
  else
    h := GlobalDefine.FindWindow('TBitBtn', '确 认', MI_GetInvoiceNumTipWnd);

  TMousePos(l).x := 20;
  TMousePos(l).y := 20;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);
end;

function MI_Close_TLoginForm: Boolean;
var
  hWnd: THandle;
  l: Integer;
begin
  Result := False;
  Application.ProcessMessages;
  
  hWnd := GlobalDefine.FindWindow('TLoginForm', '操作员登录');
  if hWnd = 0 then
    Exit;    
  if not GetWindowVisible(hWnd) then
    Exit;
  hWnd := GlobalDefine.FindWindow('TBitBtn', '确 认', hWnd);
  if hWnd = 0 then
    Exit;    
  if not GetWindowVisible(hWnd) then
    Exit;
    
  TMousePos(l).x := 20;
  TMousePos(l).y := 20;

  SendMessage(hWnd, WM_LBUTTONDOWN, 0, l);
  SendMessage(hWnd, WM_LBUTTONUP, 0, l);

  Result := True;
end;

procedure MI_Close_TMessageDlgForm_Warning;
var
  hWnd: THandle;
  l: Integer;
begin
  Application.ProcessMessages;
  
  hWnd := GlobalDefine.FindWindow('TMessageDlgForm', '警告信息');
  hWnd := GlobalDefine.FindWindow('TBitBtn', '确 定', hWnd);

  TMousePos(l).x := 20;
  TMousePos(l).y := 20;

  SendMessage(hWnd, WM_LBUTTONDOWN, 0, l);
  SendMessage(hWnd, WM_LBUTTONUP, 0, l);
end;

procedure MI_Close_TMessageDlgForm_Error;
var
  hWnd: THandle;
  l: Integer;
begin
  Application.ProcessMessages;
  
  hWnd := GlobalDefine.FindWindow('TMessageDlgForm', '错误信息');
  hWnd := GlobalDefine.FindWindow('TBitBtn', '确 定', hWnd);

  TMousePos(l).x := 20;
  TMousePos(l).y := 20;

  SendMessage(hWnd, WM_LBUTTONDOWN, 0, l);
  SendMessage(hWnd, WM_LBUTTONUP, 0, l);
end;

function MI_Close_TInvQryDialogForm(bCancel: Boolean): Boolean;
var
  h: THandle;
  l: Integer;
begin
  Result := False;

  if not MI_IsInvQryDialogFormOpen then
    Exit;

  if bCancel then
    h := GlobalDefine.FindWindow('TBitBtn', '放 弃', MI_GetInvQryDialogForm)
  else
    h := GlobalDefine.FindWindow('TBitBtn', '确 认', MI_GetInvQryDialogForm);

  if h = 0 then
    Exit;

  TMousePos(l).x := 15;
  TMousePos(l).y := 15;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);

  Result := True;
end;

procedure MI_Close_TInvQueryForm;
var
  h: THandle;
  l: Integer;
begin
  h := GlobalDefine.FindWindow('TInvQueryForm', '');
  h := GlobalDefine.FindWindow('TBitBtn', '取  消', h);
  if h = 0 then
    Exit;
    
  TMousePos(l).x := 15;
  TMousePos(l).y := 15;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);    
end;

procedure MI_Close_StartPrintInfo;
begin
  SendMessage(GlobalDefine.FindWindow('TFormStartPrintInfo', '发票打印'), WM_CLOSE, 0, 0);
end;

procedure MI_Print_StartPrintInfo;
var
  h: THandle;
  l: Integer;
begin
  h := GlobalDefine.FindWindow('TBitBtn', '打 印', MI_GetStartPrintInfoWnd);
  if h = 0 then
    Exit;
    
  TMousePos(l).x := 15;
  TMousePos(l).y := 15;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);
end;

procedure MI_Print_StartPrintList;
var
  h: THandle;
  l: Integer;
begin
  h := GlobalDefine.FindWindow('TBitBtn', '打 印', MI_GetStartPrintListInfoWnd);
  if h = 0 then
    Exit;
    
  TMousePos(l).x := 15;
  TMousePos(l).y := 15;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);
end;

procedure MI_Close_MessageDialogForm;
begin
  SendMessage(GlobalDefine.FindWindow('TMessageDialogForm', '确定对话框'), WM_CLOSE, 0, 0);
end;

procedure MI_Close_SpecInvoiceForm;
begin
  SendMessage(GlobalDefine.FindWindow('TSpecInvoiceForm', '增值税专用发票填开'), WM_CLOSE, 0, 0);
end;

procedure MI_Close_MultiCommInvFrm;
begin                                  
  SendMessage(GlobalDefine.FindWindow('TMultiCommInvFrm', '增值税普通发票填开'), WM_CLOSE, 0, 0);
end;

procedure MI_Open_TInvQueryForm_List;
var
  h: THandle;
  l: Integer;
begin
  h := GlobalDefine.FindWindow('TInvQueryForm', '');
  h := GlobalDefine.FindWindow('TBitBtn', '查看明细', h);
  if h = 0 then
    Exit;

  TMousePos(l).x := 15;
  TMousePos(l).y := 15;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);
end;

procedure MI_Open_TInvQueryForm_Cancel;
var
  h: THandle;
  l: Integer;
begin
  h := GlobalDefine.FindWindow('TInvQueryForm', '');
  h := GlobalDefine.FindWindow('TBitBtn', '作  废', h);
  if h = 0 then
    Exit;

  TMousePos(l).x := 15;
  TMousePos(l).y := 15;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);
end;

function MI_InvCancelDlg_OK: Boolean;
var
  h, hP1, hP2: THandle;
  rect1, rect2: TRect;
  name: array [0..MAX_PATH-1] of Char;
  l: Integer;
begin
  Result := False;
  
  h := GlobalDefine.FindWindow('TMessageDialogForm', '作废确认');
  if h = 0 then
    Exit;

  hP1 := 0;
  hP2 := 0;
  
  h := GetWindow(h, GW_CHILD);
  while h <> 0 do
  begin
    if Windows.GetClassName(h, name, MAX_PATH) > 0 then
      if StrIComp(PChar(@name), 'TPanel') = 0 then
      begin
        if hP1 = 0 then
          hP1 := h
        else if hP2 = 0 then
          hP2 := h;

        if (hP1 <> 0) and (hP2 <> 0) then
          Break;
      end;
      
    h := GetWindow(h, GW_HWNDNEXT);
  end;

  if (hP1 = 0) or (hP2 = 0) then
    Exit;

  GetWindowRect(hP1, rect1);
  GetWindowRect(hP2, rect2); 
  
  if rect1.Top > rect2.Top then
    h := hP1
  else
    h := hP2;
    
  TMousePos(l).x := 145;
  TMousePos(l).y := 017;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);

  Result := True;
end;

function MI_TipInfoDlg_OK: Boolean;
var
  h, hP1, hP2: THandle;
  rect1, rect2: TRect;
  name: array [0..MAX_PATH-1] of Char;
  l: Integer;
begin
  Result := False;
  
  h := GlobalDefine.FindWindow('TMessageDialogForm', '确定对话框');
  if h = 0 then
    Exit;

  hP1 := 0;
  hP2 := 0;
  
  h := GetWindow(h, GW_CHILD);
  while h <> 0 do
  begin
    if Windows.GetClassName(h, name, MAX_PATH) > 0 then
      if StrIComp(PChar(@name), 'TPanel') = 0 then
      begin
        if hP1 = 0 then
          hP1 := h
        else if hP2 = 0 then
          hP2 := h;

        if (hP1 <> 0) and (hP2 <> 0) then
          Break;
      end;
      
    h := GetWindow(h, GW_HWNDNEXT);
  end;

  if (hP1 = 0) or (hP2 = 0) then
    Exit;

  GetWindowRect(hP1, rect1);
  GetWindowRect(hP2, rect2); 
  
  if rect1.Top > rect2.Top then
    h := hP1
  else
    h := hP2;
    
  TMousePos(l).x := 255;
  TMousePos(l).y := 017;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);

  Result := True;
end;

function MI_SureInfoDlg_OK: Boolean;
var
  h, hP1, hP2: THandle;
  rect1, rect2: TRect;
  name: array [0..MAX_PATH-1] of Char;
  l: Integer;
begin
  Result := False;
  
  h := GlobalDefine.FindWindow('TMessageDialogForm', '确认对话框');
  if h = 0 then
    Exit;

  hP1 := 0;
  hP2 := 0;
  
  h := GetWindow(h, GW_CHILD);
  while h <> 0 do
  begin
    if Windows.GetClassName(h, name, MAX_PATH) > 0 then
      if StrIComp(PChar(@name), 'TPanel') = 0 then
      begin
        if hP1 = 0 then
          hP1 := h
        else if hP2 = 0 then
          hP2 := h;

        if (hP1 <> 0) and (hP2 <> 0) then
          Break;
      end;
      
    h := GetWindow(h, GW_HWNDNEXT);
  end;

  if (hP1 = 0) or (hP2 = 0) then
    Exit;

  GetWindowRect(hP1, rect1);
  GetWindowRect(hP2, rect2); 
  
  if rect1.Top > rect2.Top then
    h := hP1
  else
    h := hP2;
    
  TMousePos(l).x := 165;//145;
  TMousePos(l).y := 017;

  SendMessage(h, WM_LBUTTONDOWN, 0, l);
  SendMessage(h, WM_LBUTTONUP, 0, l);

  Result := True;
end;

function MI_GetFaceFormObj: TObj;
begin
(*
0041E589   .  8BC3          mov     eax, ebx                                      ;  eax: FaceForm;
0041E58B   .  E8 8E680000   call    <jmp.&vcl60.Forms::TCustomForm::Hide>

0043AC78  0043AC4C  kp.0043AC4C
0043AC7C  0043AD54  offset kp._SysInfo
0043AC80  0043AD3C  offset kp._DuringDeltForm
0043AC84  0043AD2C  offset kp._DataInterfaceForm
0043AC88  0043AD34  offset kp._InvoiceForm
0043AC8C  0043AD44  offset kp._SysSetForm
0043AC90  0043AD5C  offset kp._MainForm
0043AC94  0043AD60  offset kp._TaxCard
0043AC98  0043AD64  offset kp._SysArg
0043AC9C  0043AD4C  offset kp._AboutForm
0043ACA0  0043AD7C  offset kp._ModifyPassword
0043ACA4  0043AD84  offset kp._OperatorData
0043ACA8  0043AD8C  offset kp._ModuleForm
0043ACAC  0043ADBC  offset kp._SysMaintForm
0043ACB0  0043ADCC  offset kp._TeleDataForm
0043ACB4  0043ADD4  offset kp._FaceForm
0043ACB8  0043AD6C  offset kp._LoginForm
0043ACBC  0043ADA4  offset kp._SuperMaintForm
*)
  Result := TObj(PDWORD(GetProcAddress(GetModuleHandle(nil), '_FaceForm'))^); 
end;

function MI_GetMainFormObj: TObj;
begin
  Result := TObj(PDWORD(GetProcAddress(GetModuleHandle(nil), '_MainForm'))^);
end;

function MI_GetMainFormMenuObj: TObj;
begin
  Result := MI_GetMainFormObj;
  if Assigned(Result) then
    Result := TObj(PDWORD(DWORD(Result) + $03D0)^);
end;

function MI_GetInvoiceFormObj: TObj;
begin
  Result := TObj(PDWORD(GetProcAddress(GetModuleHandle(nil), '_InvoiceForm'))^);
end;

function MI_GetTaxCardObj: TObj;
begin
  Result := TObj(PDWORD(GetProcAddress(GetModuleHandle(nil), '_TaxCard'))^);
end;

function MI_GetSysArgObj: TObj;
begin
  Result := TObj(PDWORD(GetProcAddress(GetModuleHandle(nil), '_SysArg'))^);
end;

function MI_GetInvoiceFormMenuObj_MakeOutComInv: TObj;
begin
  Result := TObj(PDWORD(DWORD(MI_GetInvoiceFormObj) + $03C0)^);
end;

function MI_GetInvoiceFormMenuObj_MakeOutSInv: TObj;
begin
  Result := TObj(PDWORD(DWORD(MI_GetInvoiceFormObj) + $03BC)^);
end;

function MI_GetInvoiceFormMenuObj_SInvQry: TObj;
begin
  Result := TObj(PDWORD(DWORD(MI_GetInvoiceFormObj) + $0324)^);
end;

function MI_GetInvoiceFormMenuObj_SInvCancel: TObj;
begin
  Result := TObj(PDWORD(DWORD(MI_GetInvoiceFormObj) + $0328)^);
end;

function MI_GetSpecInvoiceFormBtnObj_Print: TObj;
begin
 Result := TObj(PDWORD(DWORD(MI_GetSpecInvoiceFormObj) + $0328)^);
end;

function MI_GetMultiCommInvFrmBtnObj_Print: TObj;
begin
 Result := TObj(PDWORD(DWORD(MI_GetTmpMultiCommInvFrmObj) + $0328)^);
end;

function MI_GetConfirmInvNoFormObj: TObj;
begin
(*
01359D1C MakeOutI._BrowseForm                    00000000
01359D24 MakeOutI._InvoiceFaceForm               00000000
01359D2C MakeOutI._InvListForm                   00000000
01359D34 MakeOutI._ChooseInvTypeCodeForm         00000000
01359D3C MakeOutI._CommInvFaceForm               00000000
01359D44 MakeOutI._ConfirmInvNoForm              08C1EE30
01359D4C MakeOutI._CopyData                      00000000
01359D54 MakeOutI._PrintDlgF                     00000000
01359D5C MakeOutI._InvDiscountForm               00000000
01359D64 MakeOutI._InvInfoSetForm                00000000
01359D6C MakeOutI._ChooseInvTypeForm             00000000
01359D74 MakeOutI._SpecInvFaceForm               00000000
01359D7C MakeOutI._InvoiceData                   00000000
01359D84 MakeOutI._InvoiceMsgForm                00000000
01359D8C MakeOutI._InvQueryFaceForm              00000000
01359D94 MakeOutI._InvoiceCopyForm               00000000
01359D9C MakeOutI._ChooseInvVolumeForm           00000000
01359DA4 MakeOutI._InvQryDialogForm              00000000
01359DAC MakeOutI._ChPosiInvForm                 00000000
01359DB4 MakeOutI._ChPosiInvDlgForm              00000000
01359DBC MakeOutI._SpecInvoiceForm               0393742C
01359DC4 MakeOutI._RySpecInvForm                 00000000
01359DCC MakeOutI._PFShowForm                    00000000
01359DD4 MakeOutI._InvQueryForm                  00000000
01359DDC MakeOutI._RyInvQueryForm                00000000
01359DE4 MakeOutI._InvQryFindForm                00000000
01359DEC MakeOutI._CustCommCodeForm              00000000
01359DF4 MakeOutI._InvCQueryForm                 00000000
01359DFC MakeOutI._PlusColDefForm                00000000
01359E04 MakeOutI._InvKgCQueryForm               00000000
01359E0C MakeOutI._AddColuSetForm                00000000
01359E14 MakeOutI._SetInvSendInfoForm            00000000
01359E1C MakeOutI._CommInvoiceForm               00000000
01359E24 MakeOutI._LsxsCommInvFaceForm           00000000
01359E2C MakeOutI._CInvCarForm                   00000000
01359E34 MakeOutI._CInvJsfsForm                  00000000
01359E3C MakeOutI._CInvNoCancelFrm               00000000
01359E44 MakeOutI._CInvXsmForm                   00000000
01359E4C MakeOutI._CkhwCommInvFaceForm           00000000
01359E54 MakeOutI._CpyCommInvoiceForm            00000000
01359E5C MakeOutI._FjwzCommInvFaceForm           00000000
01359E64 MakeOutI._GyjgCommInvFaceForm           00000000
01359E6C MakeOutI._HwCommInvFaceForm             00000000
01359E74 MakeOutI._JdcwxCommInvFaceForm          00000000
01359E7C MakeOutI._JzclCommInvFaceForm           00000000
01359E84 MakeOutI._CInvAddrForm                  00000000
01359E8C MakeOutI._ZbmCommInvoiceForm            00000000
01359E94 MakeOutI._SwdkCommInvoiceForm           00000000
01359E9C MakeOutI._JdcCommInvoiceForm            00000000
01359EA4 MakeOutI._FrmUpDownSet                  00000000
01359EAC MakeOutI._CmpJSMXEditFrm                00000000
01359EB4 MakeOutI._CmpJSMXInfoFrm                00000000
01359EBC MakeOutI._GetTaxCodeWSPZFrm             00000000
01359EC4 MakeOutI._JSMXQryFrm                    00000000
01359ECC MakeOutI._ChCmpJSMXInfoFrm              00000000
01359ED4 MakeOutI._SwdkSpecInvForm               00000000
01359EDC MakeOutI._MultiCommInvFrm               00000000
01359EE4 MakeOutI._FjsgZbCInvFaceForm            00000000
01359EEC MakeOutI._UserDefinedInvForm            00000000
01359EF4 MakeOutI._AddColuSetNewForm             00000000
01359EFC MakeOutI._InvDkTypeSetFrm               00000000
01359F04 MakeOutI._InvDkBillChFrm                00000000
01359F0C MakeOutI._BarcodePrintMainKP            00000000
*)

  Result := TObj(PDWORD(GetProcAddress(GetModuleHandle('MakeOutInv.bpl'), '_ConfirmInvNoForm'))^);
end;

function MI_GetTmpInvQueryFormObj: TObj;
begin
  Result := _InvQueryForm;
end;

function MI_GetTmpSpecInvoiceFormObj: TObj;
begin
  Result := _SpecInvoiceForm;
end;

function MI_GetTmpMultiCommInvFrmObj: TObj;
begin
  Result := _MultiCommInvFrm;
end;

function MI_GetTmpInvDiscountFormObj: TObj;
begin
  Result := _InvDiscountForm;
end;

function MI_GetInvQryDialogFormObj: TObj;
begin
  Result := TObj(PDWORD(GetProcAddress(GetModuleHandle('MakeOutInv.bpl'), '_InvQryDialogForm'))^);  
end;

function MI_GetInvListFormObj: TObj;
begin
  Result := TObj(PDWORD(GetProcAddress(GetModuleHandle('MakeOutInv.bpl'), '_InvListForm'))^);  
end;

function MI_GetSpecInvoiceFormObj: TObj;
begin
(*
                  // baseAddr : 0x011A0000
0123B519       .  8B15 309C3501    mov     edx, dword ptr [1359C30]                                     ;  MakeOutI._SpecInvoiceForm
0123B51F       .  8B02             mov     eax, dword ptr [edx]
0123B521       .  8B10             mov     edx, dword ptr [eax]
0123B523       .  FF92 E8000000    call    dword ptr [edx+E8]                                           ;  <jmp.&vcl60.Forms::TCustomForm::ShowModal>
*)

  Result := TObj(PDWORD(GetProcAddress(GetModuleHandle('MakeOutInv.bpl'), '_SpecInvoiceForm'))^);
end;

function MI_GetMultiCommInvFrmObj: TObj;
begin
  Result := TObj(PDWORD(GetProcAddress(GetModuleHandle('MakeOutInv.bpl'), '_MultiCommInvFrm'))^);
end;

procedure MI_ClickInvoiceFormMemu(menu: TObj);
var
  Proc: DWORD;
  dwEax, dwEdx: DWORD;
begin
  // 00407A54   .  55            push    ebp       ;  OnMenuClick [专用发票]
  Proc := GA_ClickInvoiceFormMemu_ProcAddr;
  dwEax := DWORD(MI_GetInvoiceFormObj);
  dwEdx := DWORD(menu);

  asm
    mov   eax, dwEax
    mov   edx, dwEdx
    call  Proc
  end;
end;

procedure MI_ClickSpecInvoicePrint;
var
  Proc: DWORD;
  dwEax, dwEdx: DWORD;
begin
  Proc := _MakeOutInv_bpl + GA_ClickSpecInvoicePrint_Offset;
  dwEax := DWORD(MI_GetSpecInvoiceFormObj);
  dwEdx := DWORD(MI_GetSpecInvoiceFormBtnObj_Print);
  asm
    mov   eax, dwEax
    mov   edx, dwEdx
    call  Proc
  end; 
end;

procedure MI_ClickSpecInvoiceTax;
var
  Proc: DWORD;
  dwEax: DWORD;
begin        
  Proc := _MakeOutInv_bpl + GA_ClickSpecInvoiceTax_Offset;
  dwEax := DWORD(MI_GetSpecInvoiceFormObj);
  asm
    mov   eax, dwEax
    call  Proc
  end;
end;

procedure MI_ClickSpecInvoiceList;
var
  Proc: DWORD;
  dwEax: DWORD;
begin        
  Proc := _MakeOutInv_bpl + GA_ClickSpecInvoiceList_Offset;
  dwEax := DWORD(MI_GetTmpSpecInvoiceFormObj);
  asm
    mov   eax, dwEax
    call  Proc
  end;
end;

procedure MI_ClickSpecInvoiceDiscount; // 折扣
var
  Proc: DWORD;
  dwEax: DWORD;
begin                                
  Proc := _MakeOutInv_bpl + GA_ClickSpecInvoiceDiscount_Offset;
  dwEax := DWORD(MI_GetTmpSpecInvoiceFormObj);
  asm
    mov   eax, dwEax
    call  Proc
  end;
end;

procedure MI_ClickMultiCommInvPrint;
var
  Proc: DWORD;
  dwEax, dwEdx: DWORD;
begin
  Proc := _MakeOutInv_bpl + GA_ClickMultiCommInvPrint_Offset;
  dwEax := DWORD(MI_GetTmpMultiCommInvFrmObj);
  dwEdx := DWORD(MI_GetMultiCommInvFrmBtnObj_Print);
  asm
    mov   eax, dwEax
    mov   edx, dwEdx
    call  Proc
  end; 
end;

procedure MI_ClickMultiCommInvTax;
var
  Proc: DWORD;
  dwEax: DWORD;
begin
  Proc := _MakeOutInv_bpl + GA_ClickSpecInvoiceTax_Offset;
  dwEax := DWORD(MI_GetTmpMultiCommInvFrmObj);
  asm
    mov   eax, dwEax
    call  Proc
  end;
end;

procedure MI_ClickMultiCommInvList;
var
  Proc: DWORD;
  dwEax: DWORD;
begin
  Proc := _MakeOutInv_bpl + GA_ClickSpecInvoiceList_Offset;
  dwEax := DWORD(MI_GetTmpMultiCommInvFrmObj);
  asm
    mov   eax, dwEax
    call  Proc
  end;
end;

procedure MI_ClickMultiCommInvDiscount;
var
  Proc: DWORD;
  dwEax: DWORD;
begin
  Proc := _MakeOutInv_bpl + GA_ClickSpecInvoiceDiscount_Offset;
  dwEax := DWORD(MI_GetTmpMultiCommInvFrmObj);
  asm
    mov   eax, dwEax
    call  Proc
  end;
end;

procedure MI_ClickInvListFormExit;
var
  Proc: DWORD;
  dwEax, dwEdx: DWORD;
begin  
  Proc := _MakeOutInv_bpl + GA_ClickInvListFormExit_Offset;
  dwEax := DWORD(MI_GetInvListFormObj);
  dwEdx := PDWORD(dwEax + $030C)^;   // btn.ASCII "Confirm"
  asm
    mov   eax, dwEax
    mov   edx, dwEdx
    call  Proc
  end;
end;

procedure MI_ClickInvListFormDiscount;
var
  Proc: DWORD;
  dwEax: DWORD;
begin                        
  Proc := _MakeOutInv_bpl + GA_ClickInvListFormDiscount_Offset;
  dwEax := DWORD(MI_GetInvListFormObj);
  asm
    mov   eax, dwEax
    call  Proc
  end;
end;

function MI_GetMultiCommInvTaxIsDown: Boolean;  //
var
  dwEax: DWORD;
begin
(*
011B6170   .  8B90 04040000     mov     edx, dword ptr [eax+404]
011B6176   .  33C9              xor     ecx, ecx
011B6178   .  8A8A 5C1B0000     mov     cl, byte ptr [edx+1B5C]
011B617E   .  83F9 01           cmp     ecx, 1
011B6181   .  1BC9              sbb     ecx, ecx
011B6183   .  F7D9              neg     ecx
011B6185   .  888A 5C1B0000     mov     byte ptr [edx+1B5C], cl
011B618B   .  E8 04000000       call    011B6194
011B6190   .  C3                retn
*)
  dwEax := DWORD(MI_GetTmpMultiCommInvFrmObj);
  if PByte(PDWORD(dwEax + $404)^ + $1B5C)^ = 0 then
    Result := False
  else
    Result := True;
end;

procedure MI_EnabledCancelBtn;
var
  obj: TObj;
begin
  obj := MI_GetTmpInvQueryFormObj;
  obj := TObj(PDWORD(DWORD(obj) + $370)^);
  Vcl60_TControl_SetEnabled(obj, True);
end;

procedure MI_QueryInvPrint; // 查询发票打印
var
  Proc: DWORD;
  dwEax: DWORD;
begin
  dwEax := DWORD(MI_GetTmpInvQueryFormObj);
  Proc := _MakeOutInv_bpl + GA_PrintInv_Offset;
  asm
    mov   eax, dwEax
    call  Proc
  end;
end;

procedure MI_QueryInvPrintList; // 查询发票打印清单
var
  Proc: DWORD;
  dwEax: DWORD;
begin
  dwEax := DWORD(MI_GetTmpInvQueryFormObj);
  Proc := _MakeOutInv_bpl + GA_PrintInvList_Offset;
  asm
    mov   eax, dwEax
    call  Proc
  end;
end;

procedure SetHideKpWnd(bHide: Boolean);
begin
  IsHideKpWnd := bHide;
end;

function GetHideKpWnd: Boolean;
begin
  Result := IsHideKpWnd;
end;

function BasicFuncMain_SeleInvField(Field: TObj): string;
var
  pProc, pText: Pointer;
  _TaxCard, _SysArg: TObj;
begin
  pProc := GetProcAddress(_BasicFuncMain_bpl, '@SeleInvField$qp15TSystemArgumentp8TTaxCardp9Db@TField');

  _TaxCard := MI_GetTaxCardObj;
  _SysArg := MI_GetSysArgObj;
  asm
    push  Field
    push  _TaxCard
    push  _SysArg
    mov   pText, 0
    lea   edx, pText
    push  edx
    call  pProc
    add   esp, $10  
  end;

  Result :=  string(PChar(pText));
end;

function Cdialog_GetMessageDialogFormObj: TObj;
begin
  Result := TObj(_cdialog_bpl + GA_GetMessageDialogFormObj_Offset);
end;

function Vcl60_TControl_GetText(obj: TObj): string;
var
  pProc, pText: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Controls@TControl@GetText$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    mov   pText, 0
    lea   edx, pText
    call  pProc
  end;

  Result := string(PChar(pText));
end;

procedure Vcl60_TControl_SetText(obj: TObj; Text: string);
var
  pProc: Pointer;
  dwEbx, dwEdx: DWORD;
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Controls@TControl@SetText$qqrx17System@AnsiString');
  dwEbx := DWORD(obj);
  dwEdx := DWORD(PChar(Text));
  asm
    mov   eax, dwEbx
    mov   edx, dwEdx
    call  pProc
  end;
end;

procedure Vcl60_TControl_SetVisible(obj: TObj; Visible: Boolean);
var
  pProc: Pointer;
  dwEbx, dwEdx: DWORD;
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Controls@TControl@SetVisible$qqro');
  dwEbx := DWORD(obj);
  dwEdx := DWORD(Visible);
  asm
    mov   eax, dwEbx
    mov   edx, dwEdx
    call  pProc
  end;
end;

procedure Vcl60_TControl_SetEnabled(obj: TObj; Visible: Boolean);
var
  pProc: Pointer;
  dwEbx, dwEdx: DWORD;
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Controls@TControl@SetEnabled$qqro');
  dwEbx := DWORD(obj);
  dwEdx := DWORD(Visible);
  asm
    mov   eax, dwEbx
    mov   edx, dwEdx
    call  pProc
  end;
end;

procedure Vcl60_TCommonCalendar_SetDateTime(obj: TObj; dt: TDateTime);
type
  TDateTimeEx = packed record
  case Integer of
    1: (
      dt: TDateTime;
      );
    2: (
      ldw: DWORD;
      hdw: DWORD;
      );
  end;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ldw, hdw: DWORD;  
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Comctrls@TCommonCalendar@SetDateTime$qqr16System@TDateTime');
  dwEbx := DWORD(obj);

  ldw := TDateTimeEx(dt).ldw;
  hdw := TDateTimeEx(dt).hdw;
  asm
    push  hdw
    push  ldw
    mov   eax, dwEbx
    call  pProc
  end;
end;

procedure Vcl60_TCustomCombo_SetItemIndex(obj: TObj; Index: Integer);
var
  pProc: Pointer;
  dwEbx: DWORD;                                    
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Stdctrls@TCustomCombo@SetItemIndex$qqrxi');
  dwEbx := DWORD(obj);
  asm
    mov   edx, Index
    mov   eax, dwEbx
    call  pProc    
  end;
end;

function Vcl60_TCustomCombo_GetItemIndex(obj: TObj): Integer;
var
  pProc: Pointer;
  dwEbx: DWORD;
  n: Integer;
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Stdctrls@TCustomCombo@GetItemIndex$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   n, eax
  end;

  Result := n;
end;

function Vcl60_TCustomComboBox_GetItemCount(obj: TObj): Integer;
var
  pProc: Pointer;
  dwEbx: DWORD;
  n: Integer;
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Stdctrls@TCustomComboBox@GetItemCount$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   n, eax
  end;

  Result := n;
end;

function Vcl60_TCustomComboBoxStrings_Get(obj: TObj; Index: Integer): string; 
var
  pProc, pText: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Stdctrls@TCustomComboBoxStrings@Get$qqri');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    mov   eax, dword ptr [eax + $023C]  // ComboBox.FItems
    
    mov   pText, 0
    mov   edx, Index
    lea   ecx, pText
    call  pProc
  end;

  Result := string(PChar(pText));        
end;

function Vcl60_TWinControl_GetControlCount(obj: TObj): Integer;
var
  pProc: Pointer;
  dwEbx: DWORD;
  n: Integer;
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Controls@TWinControl@GetControlCount$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   n, eax
  end;

  Result := n;
end;

function Vcl60_TWinControl_GetControl(obj: TObj; Index: Integer): TObj;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultObj: TObj;
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Controls@TWinControl@GetControl$qqri');
  dwEbx := DWORD(obj);  
  asm
    mov   edx, Index
    mov   eax, dwEbx
    call  pProc
    mov   ResultObj, eax
  end;

  Result := ResultObj;
end;

function Vcl60_TWinControl_FindChildControl(obj: TObj; ControlName: string): TObj;
var
  pProc: Pointer;
  dwEbx, dwEdx: DWORD;
  ResultObj: TObj;
begin
  pProc := GetProcAddress(_vcl60_bpl, '@Controls@TWinControl@FindChildControl$qqrx17System@AnsiString');
  dwEbx := DWORD(obj);
  dwEdx := DWORD(PChar(ControlName));
  asm
    mov   edx, dwEdx
    mov   eax, dwEbx
    call  pProc
    mov   ResultObj, eax  
  end;

  Result := ResultObj;
end;

function Vcl60_TComponent_GetName(obj: TObj): string;
begin
  Result := string(PChar(PDWORD(DWORD(obj) + 8)^));
end;

function Vcldb60_TDBComboBox_GetDataSource(obj: TObj): TObj;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultObj: TObj;
begin
  pProc := GetProcAddress(_vcldb60_bpl, '@Dbctrls@TDBComboBox@GetDataSource$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   ResultObj, eax
  end;

  Result := ResultObj;
end;

function Vcldb60_TCustomDBGrid_GetDataSource(obj: TObj): TObj;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultObj: TObj;
begin
  pProc := GetProcAddress(_vcldb60_bpl, '@Dbgrids@TCustomDBGrid@GetDataSource$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   ResultObj, eax
  end;

  Result := ResultObj;
end;

function Vcldb60_TDataSource_GetDataSet(obj: TObj): TObj;
begin
  Result := TObj(PDWORD(DWORD(obj) + $30)^);
end;

function Vcldb60_TCustomDBGrid_GetFieldCount(obj: TObj): Integer;
var
  pProc: Pointer;
  dwEbx: DWORD;
  n: Integer;
begin
  pProc := GetProcAddress(_vcldb60_bpl, '@Dbgrids@TCustomDBGrid@GetFieldCount$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   n, eax
  end;

  Result := n;
end;

function Vcldb60_TCustomDBGrid_GetFields(obj: TObj; Index: Integer): TObj;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultValue: TObj;
begin
  pProc := GetProcAddress(_vcldb60_bpl, '@Dbgrids@TCustomDBGrid@GetFields$qqri');
  dwEbx := DWORD(obj);
  asm
    mov   edx, Index
    mov   eax, dwEbx
    call  pProc
    mov   ResultValue, eax
  end;

  Result := ResultValue;
end;

function Vcldb60_TCustomDBGrid_GetBookmarkList(obj: TObj): TObj;
begin
  Result := TObj(PDWORD(DWORD(obj) + $2EC)^);
end;

procedure Vcldb60_TBookmarkList_SetCurrentRowSelected(obj: TObj; Value: Boolean);
var
  pProc: Pointer;
  dwEbx, dwEdx: DWORD;
begin
  pProc := GetProcAddress(_vcldb60_bpl, '@Dbgrids@TBookmarkList@SetCurrentRowSelected$qqro');
  dwEbx := DWORD(obj);
  dwEdx := DWORD(Value);
  asm
    mov   eax, dwEbx
    mov   edx, dwEdx
    call  pProc
  end;
end;

function Rtl60_TObject_ClassName(obj: TObj): string;
var
  pProc: Pointer;
  dwEbx: DWORD;
  pText: array [0..MAX_PATH-1] of Char;
begin
  pProc := GetProcAddress(_rtl60_bpl, '@System@TObject@ClassName$qqrp17System@TMetaClass');
  dwEbx := obj^;
  asm
    lea   edx, pText
    mov   eax, dwEbx
    call  pProc
  end;
  pText[Ord(pText[0])+1] := #0;
  Result := string(PChar(@pText[1]));
end;

procedure Dbrtl60_TDataSet_Post(obj: TObj);
var
  pProc: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TDataSet@Post$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
  end;
end;

procedure Dbrtl60_TDataSet_Append(obj: TObj);
var
  pProc: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TDataSet@Append$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
  end;
end;

function Dbrtl60_TDataSet_GetActive(obj: TObj): Boolean;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultValue: Boolean;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TDataSet@GetActive$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   ResultValue, al
  end;

  Result := ResultValue;
end;

function Dbrtl60_TDataSet_GetFieldCount(obj: TObj): Integer;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultValue: Integer;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TDataSet@GetFieldCount$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   ResultValue, eax
  end;

  Result := ResultValue;
end;

function Dbrtl60_TDataSet_GetFields(obj: TObj): TObj;
begin
  //TDataSet = class(TComponent, IProviderSupport)
  //private
  //  FFields: TFields;             +0x30
  //  FAggFields: TFields;          +0x34
  //  FFieldDefs: TFieldDefs;       +0x38
  //  FFieldDefList: TFieldDefList; +0x3C
  //  ...
  Result := TObj(PDWORD(DWORD(obj) + $30)^);
end;

function Dbrtl60_TDataSet_FieldByName(obj: TObj; FieldName: string): TObj;
var
  pProc: Pointer;
  dwEbx: DWORD;
  dwEdx: DWORD;
  ResultValue: TObj;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TDataSet@FieldByName$qqrx17System@AnsiString');
  dwEbx := DWORD(obj);
  dwEdx := DWORD(PChar(FieldName));  
  asm
    mov   edx, dwEdx
    mov   eax, dwEbx
    call  pProc
    mov   ResultValue, eax
  end;

  Result := ResultValue;
end;

procedure Dbrtl60_TDataSet_DisableControls(obj: TObj);
var
  pProc: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TDataSet@DisableControls$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
  end;
end;

procedure Dbrtl60_TDataSet_EnableControls(obj: TObj);
var
  pProc: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TDataSet@EnableControls$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
  end;
end;

procedure Dbrtl60_TDataSet_First(obj: TObj);
var
  pProc: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TDataSet@First$qqrv');
  dwEbx := DWORD(obj);

  asm
    mov   eax, dwEbx
    call  pProc
  end;
end;

procedure Dbrtl60_TDataSet_Next(obj: TObj);
var
  pProc: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TDataSet@Next$qqrv');
  dwEbx := DWORD(obj);

  asm
    mov   eax, dwEbx
    call  pProc
  end;
end;

function Dbrtl60_TDataSet_Eof(obj: TObj): Boolean;
type
  PBoolean = ^Boolean;
begin
  Result := PBoolean(DWORD(obj) + $0A1)^;
end;

function Dbrtl60_TFields_GetCount(obj: TObj): Integer;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultValue: Integer;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TFields@GetCount$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   ResultValue, eax
  end;

  Result := ResultValue;
end;

function Dbrtl60_TFields_GetField(obj: TObj; Index: Integer): TObj;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultValue: TObj;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TFields@GetField$qqri');
  dwEbx := DWORD(obj);
  asm
    mov   edx, Index
    mov   eax, dwEbx
    call  pProc
    mov   ResultValue, eax
  end;

  Result := ResultValue; 
end;

function Dbrtl60_TField_GetFieldName(obj: TObj): string;
begin
  //TField = class(TComponent)
  //private
  //  FAutoGenerateValue: TAutoRefreshFlag;   +0x30
  //  FDataSet: TDataSet;                     +0x34
  //  FFieldName: string;                     +0x38
  //  FFields: TFields;                       +0x3C
  //  ...

  Result := string(PChar(PDWORD(DWORD(obj) + $38)^));
end;

function Dbrtl60_TField_GetFieldType(obj: TObj): TFieldType;
type
  PFieldType = ^TFieldType;
begin
  //TField = class(TComponent)
  //private
  //  FAutoGenerateValue: TAutoRefreshFlag;   +0x30
  //  FDataSet: TDataSet;                     +0x34
  //  FFieldName: string;                     +0x38
  //  FFields: TFields;                       +0x3C
  //  FDataType: TFieldType;                  +0x40
  //  ...

  Result := PFieldType(DWORD(obj) + $40)^;
end;

function Dbrtl60_TField_GetIsNull(obj: TObj): Boolean;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultValue: Boolean;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TField@GetIsNull$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   ResultValue, al
  end;

  Result := ResultValue;
end;

procedure Dbrtl60_TField_SetEditText(obj: TObj; Value: string);
var
  pProc: Pointer;
  dwEbx, dwEdx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TField@SetEditText$qqrx17System@AnsiString');
  dwEbx := DWORD(obj);
  dwEdx := DWORD(PChar(Value));
  asm
    mov   eax, dwEbx
    mov   edx, dwEdx 
    call  pProc
  end;
end;

function Dbrtl60_TBooleanField_GetAsBoolean(obj: TObj): Boolean;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultValue: Boolean;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TBooleanField@GetAsBoolean$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   ResultValue, al
  end;

  Result := ResultValue;
end;

procedure Dbrtl60_TBooleanField_SetAsBoolean(obj: TObj; Value: Boolean);
var
  pProc: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TBooleanField@SetAsBoolean$qqro');
  dwEbx := DWORD(obj);
  asm
    xor   edx, edx
    mov   dl, Value
    mov   eax, dwEbx
    call  pProc
  end;
end;

function Dbrtl60_TFloatField_GetAsFloat(obj: TObj): Double;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultValue: Double;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TFloatField@GetAsFloat$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    fstp  ResultValue
    wait
  end;

  Result := ResultValue;
end;

procedure Dbrtl60_TFloatField_SetAsFloat(obj: TObj; Value: Double);
type
  TDoubleEx = packed record
  case Integer of
    1: (
      d: Double;
      );
    2: (
      ld: DWORD;
      hd: DWORD;
      );
  end;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ld: DWORD;
  hd: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TFloatField@SetAsFloat$qqrd');
  dwEbx := DWORD(obj);
  ld := TDoubleEx(Value).ld;
  hd := TDoubleEx(Value).hd;
  dwEbx := DWORD(obj);
  asm
    push  hd
    push  ld
    mov   eax, dwEbx
    call  pProc
  end;  
end;

function Dbrtl60_TIntegerField_GetAsInteger(obj: TObj): Integer;
var
  pProc: Pointer;
  dwEbx: DWORD;
  ResultValue: Integer;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TIntegerField@GetAsInteger$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   eax, dwEbx
    call  pProc
    mov   ResultValue, eax
  end;

  Result := ResultValue;
end;

procedure Dbrtl60_TIntegerField_SetAsInteger(obj: TObj; Value: Integer);
var
  pProc: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TIntegerField@SetAsInteger$qqri');
  dwEbx := DWORD(obj);
  asm
    mov   edx, Value
    mov   eax, dwEbx
    call  pProc
  end;
end;


 function Dbrtl60_TStringField_GetAsString(obj: TObj): string;
var
  pProc, pText: Pointer;
  dwEbx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TStringField@GetAsString$qqrv');
  dwEbx := DWORD(obj);
  asm
    mov   pText, 0
    lea   edx, pText
    mov   eax, dwEbx
    call  pProc
  end;

  Result := string(PChar(pText));
end;

procedure Dbrtl60_TStringField_SetAsString(obj: TObj; Value: string);
var
  pProc: Pointer;
  dwEbx, dwEdx: DWORD;
begin
  pProc := GetProcAddress(_dbrtl60_bpl, '@Db@TStringField@SetAsString$qqrx17System@AnsiString');
  dwEbx := DWORD(obj);
  dwEdx := DWORD(PChar(Value));
  asm
    mov   eax, dwEbx
    mov   edx, dwEdx
    call  pProc
  end;
end;

  var
    _My_cdialog_PromptDlg_Ret: DWORD;
  procedure _My_cdialog_PromptDlg;
  asm
    pushad
    pushfd

    mov   _PromptDlg, eax    
    
    popfd
    popad

    push    ebp
    mov     ebp, esp
    add     esp, -$2C
        
    push  _My_cdialog_PromptDlg_Ret
    ret
  end;
procedure Hook_cdialog_PromptDlg;
var
  dw: DWORD;
  p: Pointer;
  pushRet: TPushRet;
begin
  p := GetProcAddress(_cdialog_bpl, '@PromptDlg$q17System@AnsiStringt1it1');
  VirtualProtect(p, SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dw);

  _My_cdialog_PromptDlg_Ret := DWORD(p)+6;
  
  _cdialog_PromptDlg := PPushRet(p)^;
  pushRet := InitPushRet(@_My_cdialog_PromptDlg);
  PPushRet(p)^ := pushRet;    
end;

procedure Unhook_cdialog_PromptDlg;
var
  dw: DWORD;
  p: Pointer;
begin
  p := GetProcAddress(_cdialog_bpl, '@PromptDlg$q17System@AnsiStringt1it1');
  VirtualProtect(p, SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dw);
  PPushRet(p)^ := _cdialog_PromptDlg;
end;

  var
    _My_TInvQueryForm_Create_Ret: DWORD;
  procedure _My_TInvQueryForm_Create;
  asm
    pushad
    pushfd

    mov   _InvQueryForm, eax    
    
    popfd
    popad

{$IFDEF         KpVer_0615}

    mov     esp, ebp
    pop     ebp
    retn    $0C

{$ELSE}{$IFDEF  KpVer_0710}

    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp

    push  _My_TInvQueryForm_Create_Ret
    ret
    
{$ELSE}{$IFDEF  KpVer_0723}

    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp

    push  _My_TInvQueryForm_Create_Ret
    ret

{$ELSE}
   raise 'err_ver'
{$ENDIF}{$ENDIF}{$ENDIF}

  end;
procedure Hook_TInvQueryForm_Create;
var
  dw: DWORD;
  p: Pointer;
  pushRet: TPushRet;
begin
  p := Pointer(_MakeOutInv_bpl + GA_Hook_TInvQueryForm_Offset);
  VirtualProtect(p, SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dw);

{$IFDEF         KpVer_0615}
  _My_TInvQueryForm_Create_Ret := 0;

{$ELSE}{$IFDEF  KpVer_0710}
  _My_TInvQueryForm_Create_Ret := DWORD(p)+6;

{$ELSE}{$IFDEF  KpVer_0723}
  _My_TInvQueryForm_Create_Ret := DWORD(p)+6;
  
{$ELSE}
   raise 'err_ver'
{$ENDIF}{$ENDIF}{$ENDIF}


  _TInvQueryForm_Create := PPushRet(p)^;
  pushRet := InitPushRet(@_My_TInvQueryForm_Create);
  PPushRet(p)^ := pushRet;    
end;

procedure Unhook_TInvQueryForm_Create;
var
  dw: DWORD;
  p: Pointer;
begin
  p := Pointer(_MakeOutInv_bpl + GA_Hook_TInvQueryForm_Offset);
  VirtualProtect(p, SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dw);
  PPushRet(p)^ := _TInvQueryForm_Create;
end;

  var
    _My_TSpecInvoiceForm_Create_Ret: DWORD;
  procedure _My_TSpecInvoiceForm_Create;
  asm
    pushad
    pushfd

    mov   _SpecInvoiceForm, eax    
    
    popfd
    popad

{$IFDEF         KpVer_0615}
    
    mov     esp, ebp
    pop     ebp
    retn    $0C

{$ELSE}{$IFDEF  KpVer_0710}

    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp

    push  _My_TSpecInvoiceForm_Create_Ret
    ret

{$ELSE}{$IFDEF  KpVer_0723}

    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp

    push  _My_TSpecInvoiceForm_Create_Ret
    ret

{$ELSE}
   raise 'err_ver'
{$ENDIF}{$ENDIF}{$ENDIF}
  end;
procedure Hook_TSpecInvoiceForm_Create;
var
  dw: DWORD;
  p: Pointer;
  pushRet: TPushRet;
begin  
  p := Pointer(_MakeOutInv_bpl + GA_Hook_TSpecInvoiceForm_Create_Offset);
  VirtualProtect(p, SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dw);
                                 
{$IFDEF         KpVer_0615}
  _My_TSpecInvoiceForm_Create_Ret := 0;

{$ELSE}{$IFDEF  KpVer_0710}
  _My_TSpecInvoiceForm_Create_Ret := DWORD(p)+6;

{$ELSE}{$IFDEF  KpVer_0723}
  _My_TSpecInvoiceForm_Create_Ret := DWORD(p)+6;
   
{$ELSE}
   raise 'err_ver'
{$ENDIF}{$ENDIF}{$ENDIF}  

  _TSpecInvoiceForm_Create := PPushRet(p)^;
  pushRet := InitPushRet(@_My_TSpecInvoiceForm_Create);
  PPushRet(p)^ := pushRet; 
end;

procedure Unhook_TSpecInvoiceForm_Create;
var
  dw: DWORD;
  p: Pointer;
begin
  p := Pointer(_MakeOutInv_bpl + GA_Hook_TSpecInvoiceForm_Create_Offset);
  VirtualProtect(p, SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dw);
  PPushRet(p)^ := _TSpecInvoiceForm_Create;
end;


  var
    _My_TMultiCommInvFrm_Create_Ret: DWORD;
  procedure _My_TMultiCommInvFrm_Create;
  asm
    pushad
    pushfd

    mov   _MultiCommInvFrm, eax    
    
    popfd
    popad

{$IFDEF         KpVer_0615}

    mov     esp, ebp
    pop     ebp
    retn    $0C

{$ELSE}{$IFDEF  KpVer_0710}

    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp

    push  _My_TMultiCommInvFrm_Create_Ret
    ret

{$ELSE}{$IFDEF  KpVer_0723}

    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp

    push  _My_TMultiCommInvFrm_Create_Ret
    ret

{$ELSE}
   raise 'err_ver'
{$ENDIF}{$ENDIF}{$ENDIF}    
  end;
procedure Hook_TMultiCommInvFrm_Create;
var
  dw: DWORD;
  p: Pointer;
  pushRet: TPushRet;
begin
  p := Pointer(_MakeOutInv_bpl + GA_Hook_TMultiCommInvFrm_Create_Offset);
  VirtualProtect(p, SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dw);

{$IFDEF         KpVer_0615}
  _My_TMultiCommInvFrm_Create_Ret := 0;

{$ELSE}{$IFDEF  KpVer_0710}
  _My_TMultiCommInvFrm_Create_Ret := DWORD(p)+6;

{$ELSE}{$IFDEF  KpVer_0723}
  _My_TMultiCommInvFrm_Create_Ret := DWORD(p)+6;
   
{$ELSE}
   raise 'err_ver'
{$ENDIF}{$ENDIF}{$ENDIF}


  _TMultiCommInvFrm_Create := PPushRet(p)^;
  pushRet := InitPushRet(@_My_TMultiCommInvFrm_Create);
  PPushRet(p)^ := pushRet; 
end;

procedure Unhook_TMultiCommInvFrm_Create;
var
  dw: DWORD;
  p: Pointer;
begin
  p := Pointer(_MakeOutInv_bpl + GA_Hook_TMultiCommInvFrm_Create_Offset);
  VirtualProtect(p, SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dw);
  PPushRet(p)^ := _TMultiCommInvFrm_Create;
end;

  procedure _My_TInvDiscountForm_Create;
  asm
    pushad
    pushfd

    mov   _InvDiscountForm, eax    
    
    popfd
    popad

    // 不跳回原处，直接执行完函数尾
{$IFDEF         KpVer_0615}

    mov     esp, ebp
    pop     ebp
    retn    $04

{$ELSE}{$IFDEF  KpVer_0710}

    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    retn    4

{$ELSE}{$IFDEF  KpVer_0723}

    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    retn    4

{$ELSE}
   raise 'err_ver'
{$ENDIF}{$ENDIF}{$ENDIF}
  end;
procedure Hook_TInvDiscountForm_Create;
var
  dw: DWORD;
  p: Pointer;
  pushRet: TPushRet;
begin
  p := Pointer(_MakeOutInv_bpl + GA_Hook_TInvDiscountForm_Create_Offset);
  VirtualProtect(p, SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dw);
  
  _TInvDiscountForm_Create := PPushRet(p)^;
  pushRet := InitPushRet(@_My_TInvDiscountForm_Create);
  PPushRet(p)^ := pushRet; 
end;

procedure Unhook_TInvDiscountForm_Create;
var
  dw: DWORD;
  p: Pointer;
begin     
  p := Pointer(_MakeOutInv_bpl + GA_Hook_TInvDiscountForm_Create_Offset);
  VirtualProtect(p, SizeOf(TPushRet), PAGE_EXECUTE_READWRITE, dw);
  PPushRet(p)^ := _TInvDiscountForm_Create;    
end;

  type
    TShowWindow = function (hWnd: HWND; nCmdShow: Integer): BOOL; stdcall;
  function _My_ShowWindow(hWnd: HWND; nCmdShow: Integer): BOOL; stdcall;
  var
    dwWndStyle: DWORD;
    name: array [0..MAX_PATH-1] of Char;
    IsPrintWnd: Boolean;
  begin
    if IsHideKpWnd then
      if hWnd <> frmMessageDlg.Handle then
      begin
        if Windows.GetParent(hWnd) = 0 then
        begin
          nCmdShow := SW_HIDE;
        end else
        begin
          dwWndStyle := GetWindowLong(hWnd, GWL_STYLE);
          if (dwWndStyle and WS_POPUPWINDOW) = WS_POPUPWINDOW then
          begin
            //Windows.SetParent(hWnd, frmMessageDlg.PanelHide.Handle);
            nCmdShow := SW_HIDE;            
          end;
        end;
      end;

    Result := TShowWindow(@_ShowWindowEP)(hWnd, nCmdShow);
  end;
procedure Hook_ShowWindow;
var
  dw: DWORD;
  p: Pointer;

  ptr: Pointer;
  OpcodeLen: DWORD;
  pushRet: TPushRet;
begin
  p := GetProcAddress(GetModuleHandle('user32.dll'), 'ShowWindow');  
  VirtualProtect(p, CodeSizeMax, PAGE_EXECUTE_READWRITE, dw);

  // 按指令对齐,计算要取出多少个字节
  _ShowWindowEP_Len := 0;
  ptr := p;
  while _ShowWindowEP_Len < SizeOf(TPushRet) do
  begin
    LDE32.GetInstLenght(ptr, @OpcodeLen);
    Inc(PByte(ptr), OpcodeLen);
    Inc(_ShowWindowEP_Len, OpcodeLen);
  end;
  CopyMemory(@_ShowWindowEP, p, _ShowWindowEP_Len); // 保存原指令

  // 在取出的指令后面加上push_ret,使其跳回原始函数继续执行
  PushRet := InitPushRet(DWORD(p) + DWORD(_ShowWindowEP_Len));
  CopyMemory(@_ShowWindowEP[_ShowWindowEP_Len], @PushRet, SizeOf(TPushRet));

  // 将push_ret写入原始函数地址,使其转跳到新的函数地址
  PushRet := InitPushRet(@_My_ShowWindow);
  CopyMemory(p, @PushRet, SizeOf(TPushRet)); 
end;

procedure Unhook_ShowWindow;
var
  p: Pointer;
begin
  p := GetProcAddress(GetModuleHandle('user32.dll'), 'ShowWindow');
  CopyMemory(p, @_ShowWindowEP, _ShowWindowEP_Len); // 还原原指令
end;

end.




