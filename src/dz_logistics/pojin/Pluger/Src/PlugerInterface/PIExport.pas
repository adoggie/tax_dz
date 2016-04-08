unit PIExport;

interface

uses Windows, Forms, Dialogs, SysUtils, GlobalDefine;

function inv_reset: Integer; stdcall;
function inv_open: Integer; stdcall;
function inv_close: Integer; stdcall;
function inv_lock: Integer; stdcall;
function inv_unlock: Integer; stdcall;
function inv_taxinfo(invoice_type: Integer; code, number, stock, taxcode, limit: PChar): Integer; stdcall;
function inv_create(invoice_type, tax_flag, mode, ntype: Integer; discount: Single;
  bill: PChar; bill_bufsize: Integer;
  invoice_code, invoice_number, date, amount, tax: PChar): Integer; stdcall;
function inv_cancel(invoice_type: Integer; invoice_number, invoice_code: PChar): Integer; stdcall;
function inv_getinfo(invoice_type: Integer; invoice_number, invoice_code, buf: PChar; bufsize: PInteger): Integer; stdcall;
function inv_getinfo_all(buf: PChar; bufsize: PInteger): Integer; stdcall;
function inv_getinfo_all2(list: PChar; buf: PChar; bufsize: PInteger; startdate, enddate: PChar; flag: Integer): Integer; stdcall;
function inv_print(list, invoice_number, invoice_code: PChar; ntype: Integer): Integer; stdcall;								


implementation

uses SyncMsg;

function IsSafePluger: Integer; forward;

// -------------------------------------------------------------------------- //

function IsSafePluger: Integer;
  function _IsMainOpen: Boolean;
  var
    hWnd: THandle;
  begin
    Result := False;
    hWnd := GlobalDefine.FindWindow('TMainForm', '增值税防伪税控系统防伪开票子系统'); 
    if hWnd = 0 then
      Exit;

    if GetWindowMinimize(hWnd) then
    begin
      Result := True;
      Exit;
    end;
                   
    Result := GetWindowVisible(hWnd);
  end;
begin
  if not Assigned(frmSyncMsg) then
  begin
    Result := ERROR_PLUGER_UNINITIALIZED;
    Exit;
  end;

  if frmSyncMsg.InjectWnd = 0 then
  begin
    Result := ERROR_PLUGER_UNINITIALIZED;
    Exit;
  end;

  if StrIComp(PChar(GetClassName(frmSyncMsg.InjectWnd)), 'TfrmMessageDlg') <> 0 then
  begin
    Result := ERROR_KP_CLOSED;
    Exit;
  end;

  if IsDisableWindow(GlobalDefine.FindWindow('TMainForm', '增值税防伪税控系统防伪开票子系统')) then
  begin
    Result := ERROR_KP_DISABLE;
    Exit;
  end;
  (*
  if not _IsMainOpen then
  begin
    Result := ERROR_KP_NOT_LOGGED_IN;
    Exit;
  end;
  *)

  Result := ERROR_SUCCESS;
end;

function inv_reset: Integer; stdcall;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;

  frmSyncMsg.IsmSendMessage(ISM_INV_RESET);
        
  Result := ERROR_SUCCESS;
end;

function inv_open: Integer; stdcall;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;
  
  Result := ERROR_UNKNOWN;
end;

function inv_close: Integer; stdcall;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;
  
  Result := ERROR_UNKNOWN;
end;

function inv_lock: Integer; stdcall;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;

  frmSyncMsg.IsmSendMessage(ISM_INV_LOCK, 0);

  Result := ERROR_SUCCESS;
end;

function inv_unlock: Integer; stdcall;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;

  frmSyncMsg.IsmSendMessage(ISM_INV_UNLOCK, 0);
  
  Result := ERROR_SUCCESS;
end;

function inv_taxinfo(invoice_type: Integer; code, number, stock, taxcode, limit: PChar): Integer; stdcall;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;

  if (invoice_type <> it_Normal) and (invoice_type <> it_Special) then
  begin
    Result := ERROR_INVALID_PARAMETER;
    Exit;
  end;

  frmSyncMsg.bWait_InvTaxInfo := True;
  frmSyncMsg.IsmSendMessage(ISM_INV_TAXINFO, invoice_type);

  while frmSyncMsg.bWait_InvTaxInfo do
  begin
    Application.ProcessMessages;
    Sleep(1);
  end;

  FillMemory(code, 40, 0);
  CopyMemory(code, @frmSyncMsg.TaxInfoResult.code, 40);
  FillMemory(number, 40, 0);
  CopyMemory(number, @frmSyncMsg.TaxInfoResult.number, 40);

  Result := frmSyncMsg.InvTaxInfoResultErrCode;
end;

function inv_create(invoice_type, tax_flag, mode, ntype: Integer; discount: Single;
  bill: PChar; bill_bufsize: Integer;
  invoice_code, invoice_number, date, amount, tax: PChar): Integer; stdcall;
var
  p: Pointer;
  size: Integer;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;

  // invoice_type
  if (invoice_type <> it_Normal) and (invoice_type <> it_Special) then
  begin
    Result := ERROR_INVALID_PARAMETER;
    Exit;
  end;

  // tax_flag
  if tax_flag = tf_WithoutTax then  // 不含税

  else if tax_flag = tf_WithTax then // 含税

  else
  begin
    Result := ERROR_INVALID_PARAMETER;
    Exit;
  end;

  // mode
  if mode = mim_MakeInv then

  else if mode = mim_MakeInvPrint then  // 打印
  begin

  end else
  begin
    Result := ERROR_INVALID_PARAMETER;
    Exit;
  end;

  // ntype
  if ntype = mit_Normal then

  else if ntype = mit_Negative then // 负数发票
  begin
    Result := ERROR_RESERVED;
    Exit;
  end else
  begin
    Result := ERROR_INVALID_PARAMETER;
    Exit;
  end;

  if discount <> 0 then
  begin
    //Result := ERROR_RESERVED;
    //Exit;
  end;

  // .....    
  size := SizeOf(TCreateInv) + bill_bufsize;
  GetMem(p, size);
  try
    PCreateInv(p)^.invoice_type := invoice_type;
    PCreateInv(p)^.tax_flag := tax_flag;
    PCreateInv(p)^.make_inv_mode := mode;
    PCreateInv(p)^.make_inv_type := ntype;
    PCreateInv(p)^.discount := discount;
    PCreateInv(p)^.bill_bufsize := bill_bufsize;
    CopyMemory(
      Pointer(DWORD(p)+SizeOf(TCreateInv)),
      PChar(bill),
      bill_bufsize);

    frmSyncMsg.bWait_InvCreate := True;
    frmSyncMsg.IsmSendMessage(ISM_INV_CREATE, 0, p, size);


    while frmSyncMsg.bWait_InvCreate do
    begin
      Application.ProcessMessages;
      Sleep(1);
    end;
  
    Result := frmSyncMsg.InvCreateResult;

    if Result = ERROR_SUCCESS then
    begin
      CopyMemory(invoice_code, PChar(@frmSyncMsg.InvCreateOutResult.code), Length(PChar(@frmSyncMsg.InvCreateOutResult.code))+1);
      CopyMemory(invoice_number, PChar(@frmSyncMsg.InvCreateOutResult.number), Length(PChar(@frmSyncMsg.InvCreateOutResult.number))+1);
      CopyMemory(date, PChar(@frmSyncMsg.InvCreateOutResult.date), Length(PChar(@frmSyncMsg.InvCreateOutResult.date))+1);
      CopyMemory(amount, PChar(@frmSyncMsg.InvCreateOutResult.amount), Length(PChar(@frmSyncMsg.InvCreateOutResult.amount))+1);
      CopyMemory(tax, PChar(@frmSyncMsg.InvCreateOutResult.tax), Length(PChar(@frmSyncMsg.InvCreateOutResult.tax))+1);
    end;
    
  finally
    FreeMem(p, size);
  end;
end;

function inv_cancel(invoice_type: Integer; invoice_number, invoice_code: PChar): Integer; stdcall;
var
  Info: TCancelInfo;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;
  
  frmSyncMsg.bWait_InvCancel := True;
  FillChar(Info, SizeOf(Info), 0);
  CopyMemory(@Info.code, invoice_code, Length(invoice_code)); 
  CopyMemory(@Info.number, invoice_number, Length(invoice_number));
  frmSyncMsg.IsmSendMessage(ISM_INV_CANCEL, 0, @Info, SizeOf(TGetInfo));


  while frmSyncMsg.bWait_InvCancel do
  begin
    Application.ProcessMessages;
    Sleep(1);
  end;

  if frmSyncMsg.bInvCancelResult then
    Result := ERROR_SUCCESS
  else
    Result := ERROR_INVALID_INV_CODE;
end;

function inv_getinfo(invoice_type: Integer; invoice_number, invoice_code, buf: PChar; bufsize: PInteger): Integer; stdcall;
var
  needsize: Integer;
  Info: TGetInfo;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;

  frmSyncMsg.bWait_InvGetInfo := True;
  FillChar(Info, SizeOf(Info), 0);
  CopyMemory(@Info.code, invoice_code, Length(invoice_code)); 
  CopyMemory(@Info.number, invoice_number, Length(invoice_number));
  frmSyncMsg.IsmSendMessage(ISM_INV_GETINFO, 0, @Info, SizeOf(TGetInfo));
  
  while frmSyncMsg.bWait_InvGetInfo do
  begin
    Application.ProcessMessages;
    Sleep(1);
  end;

  needsize := Length(frmSyncMsg.InvGetInfoResult)*SizeOf(Char);
  if needsize > bufsize^ then
  begin
    bufsize^ := needsize;
    Result := ERROR_BUFFER_TOO_SMALL;
    Exit;
  end;

  if needsize = 0 then
  begin
    bufsize^ := needsize;
    Result := ERROR_INVALID_INV_CODE;
    Exit;
  end;

  FillMemory(buf, bufsize^, 0);
  CopyMemory(buf, PChar(frmSyncMsg.InvGetInfoResult), needsize);
  bufsize^ := needsize;
  
  Result := ERROR_SUCCESS;
end;

function inv_getinfo_all(buf: PChar; bufsize: PInteger): Integer; stdcall;
var
  needsize: Integer;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;

  frmSyncMsg.bWait_InvGetInfoAll := True;
  frmSyncMsg.IsmSendMessage(ISM_INV_GETINFO_ALL);

  while frmSyncMsg.bWait_InvGetInfoAll do
  begin
    Application.ProcessMessages;
    Sleep(1);
  end;

  needsize := Length(frmSyncMsg.InvGetInfoAllResult)*SizeOf(Char);
  if needsize > bufsize^ then
  begin
    bufsize^ := needsize;
    Result := ERROR_BUFFER_TOO_SMALL;
    Exit;
  end;

  FillMemory(buf, bufsize^, 0);
  CopyMemory(buf, PChar(frmSyncMsg.InvGetInfoAllResult), needsize);
  bufsize^ := needsize;
  
  Result := ERROR_SUCCESS;
end;

function inv_getinfo_all2(list: PChar; buf: PChar; bufsize: PInteger; startdate, enddate: PChar; flag: Integer): Integer; stdcall;
var
  needsize: Integer;

  Info: TGetInfoAll2;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;

  if (flag<>0) and (flag<>1) then
  begin
    Result := ERROR_INVALID_PARAMETER;
    Exit;
  end;
                            
  if (
    (Length(list) = 0) or
    (Length(list)*SizeOf(Char) >= SizeOf(Info.list))
    ) then
  begin
    Result := ERROR_INVALID_FIND_MONTH;
    Exit;
  end;

  if (Length(startdate) < Length('yyyy-mm-dd')) or (Length(enddate) < Length('yyyy-mm-dd')) then
  begin
    Result := ERROR_INVALID_PARAMETER;
    Exit;
  end;

  FillChar(Info, SizeOf(Info), 0);
  CopyMemory(@Info.list, list, Length(list)*SizeOf(Char));

  try
    Info.beginDate := EncodeDate(
      StrToInt(startdate[0]+startdate[1]+startdate[2]+startdate[3]),
      StrToInt(startdate[5]+startdate[6]),
      StrToInt(startdate[8]+startdate[9]));
    Info.endDate := EncodeDate(
      StrToInt(enddate[0]+enddate[1]+enddate[2]+enddate[3]),
      StrToInt(enddate[5]+enddate[6]),
      StrToInt(enddate[8]+enddate[9]));
    if Info.beginDate > Info.endDate then
      raise Exception.Create('if Info.beginDate > Info.endDate then');  
  except
    Result := ERROR_INVALID_PARAMETER + 2;
    Exit;    
  end;

  Info.flag := flag;

  frmSyncMsg.bWait_InvGetInfoAll2 := True;
  frmSyncMsg.IsmSendMessage(ISM_INV_GETINFO_ALL2, 0, @Info, SizeOf(Info));

  while frmSyncMsg.bWait_InvGetInfoAll2 do
  begin
    Application.ProcessMessages;
    Sleep(1);
  end;

  if frmSyncMsg.InvGetInfoAllResult2Code <> ERROR_SUCCESS then
  begin
    Result := frmSyncMsg.InvGetInfoAllResult2Code;
    Exit;
  end;

  needsize := Length(frmSyncMsg.InvGetInfoAllResult2)*SizeOf(Char);
  if needsize > bufsize^ then
  begin
    bufsize^ := needsize;
    Result := ERROR_BUFFER_TOO_SMALL;
    Exit;
  end;

  FillMemory(buf, bufsize^, 0);
  CopyMemory(buf, PChar(frmSyncMsg.InvGetInfoAllResult2), needsize);
  bufsize^ := needsize;

  Result := ERROR_SUCCESS;
end;

function inv_print(list, invoice_number, invoice_code: PChar; ntype: Integer): Integer; stdcall;
var
  Info: TPrintInfo;
begin
  Result := IsSafePluger;
  if Result <> ERROR_SUCCESS then
    Exit;

  if (ntype <> pt_Print) and (ntype <> pt_PrintList) then
  begin
    Result := ERROR_INVALID_PARAMETER;
    Exit;
  end;

  frmSyncMsg.bWait_InvPrint := True;
  FillChar(Info, SizeOf(Info), 0);
  CopyMemory(@Info.code, invoice_code, Length(invoice_code));
  CopyMemory(@Info.number, invoice_number, Length(invoice_number));
  CopyMemory(@Info.list, list, Length(list));
  Info.PrintType := ntype;
  
  frmSyncMsg.IsmSendMessage(ISM_INV_PRINT, 0, @Info, SizeOf(Info));

  while frmSyncMsg.bWait_InvPrint do
  begin
    Application.ProcessMessages;
    Sleep(1);
  end;
 
  Result := frmSyncMsg.InvPrintResult;
end;

end.
