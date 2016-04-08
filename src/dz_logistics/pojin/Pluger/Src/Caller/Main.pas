unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PIImport, StdCtrls, GlobalDefine, ComCtrls;

type
  TfrmMain = class(TForm)
    btn_inv_reset: TButton;
    btn_inv_open: TButton;
    btn_inv_close: TButton;
    btn_inv_lock: TButton;
    btn_inv_unlock: TButton;
    btn_inv_taxinfo: TButton;
    btn_inv_create: TButton;
    btn_inv_cancel: TButton;
    btn_inv_getinfo: TButton;
    btn_inv_getinfo_all: TButton;
    btn_InitPluger: TButton;
    btn_FreePluger: TButton;
    MemoLog: TMemo;
    cmbInvoiceType: TComboBox;
    cmb_tax_flag: TComboBox;
    cmb_mode: TComboBox;
    Label1: TLabel;
    edt_tax_rate: TEdit;
    edt_cust_name: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    edt_cust_tax_code: TEdit;
    Label4: TLabel;
    edt_cust_address_tel: TEdit;
    Label5: TLabel;
    edt_cust_bank_account: TEdit;
    Memo_memo: TMemo;
    Label6: TLabel;
    Label7: TLabel;
    cmb_seller_bank_account: TComboBox;
    Label8: TLabel;
    edt_checker: TEdit;
    Label9: TLabel;
    edt_payee: TEdit;
    Label10: TLabel;
    edtInvCode: TEdit;
    Label11: TLabel;
    edtInvNumber: TEdit;
    CheckBox1: TCheckBox;
    Label12: TLabel;
    edtDiscount: TEdit;
    btn_inv_getinfo_all2: TButton;
    chkGetInfoFlag: TCheckBox;
    dtpBegin: TDateTimePicker;
    dtpEnd: TDateTimePicker;
    Button1: TButton;
    btn_inv_print: TButton;
    CheckBox2: TCheckBox;
    Button2: TButton;
    procedure btn_inv_resetClick(Sender: TObject);
    procedure btn_inv_openClick(Sender: TObject);
    procedure btn_inv_closeClick(Sender: TObject);
    procedure btn_inv_lockClick(Sender: TObject);
    procedure btn_inv_unlockClick(Sender: TObject);
    procedure btn_inv_taxinfoClick(Sender: TObject);
    procedure btn_inv_createClick(Sender: TObject);
    procedure btn_inv_cancelClick(Sender: TObject);
    procedure btn_InitPlugerClick(Sender: TObject);
    procedure btn_FreePlugerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn_inv_getinfo_allClick(Sender: TObject);
    procedure btn_inv_getinfoClick(Sender: TObject);
    procedure btn_inv_getinfo_all2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btn_inv_printClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }

    procedure Init;
    
  public
    { Public declarations }
    procedure MakeInvList(item_name, item_unit, spec, price, qty, amount: string; var OutDest: string);
    procedure OutputInfo(s: string); 
  end;

var
  frmMain: TfrmMain;

implementation

function PlugerVer: Integer; stdcall; external 'Pluger.dll' name 'PlugerVer';

{$R *.DFM}

procedure TfrmMain.btn_inv_resetClick(Sender: TObject);
var
  errcode: Integer;
begin
  errcode := inv_reset;
  OutputInfo('inv_reset: '+IntToStr(errcode));  
end;

procedure TfrmMain.btn_inv_openClick(Sender: TObject);
begin
  inv_open;
end;

procedure TfrmMain.btn_inv_closeClick(Sender: TObject);
begin
  inv_close;
end;

procedure TfrmMain.btn_inv_lockClick(Sender: TObject);
begin
  inv_lock;
end;

procedure TfrmMain.btn_inv_unlockClick(Sender: TObject);
begin
  inv_unlock;
end;

procedure TfrmMain.btn_inv_taxinfoClick(Sender: TObject);
var
  code, number: array [0..40-1] of Char;
  errcode: Integer;
begin
  errcode := inv_taxinfo(cmbInvoiceType.ItemIndex, @code, @number, nil, nil, nil);
  OutputInfo('inv_taxinfo: '+IntToStr(errcode));

  if errcode = ERROR_SUCCESS then
  begin
    OutputInfo('    code   : '+PChar(@code));
    OutputInfo('    number : '+PChar(@number));    
  end;  
end;

procedure TfrmMain.btn_inv_createClick(Sender: TObject);
var
  inv_code, inv_num, date, amout, tax: array [0..40-1] of Char;
  errcode: Integer;
  bill: string;
  InvList: string;
begin
  // 明细
  InvList := '';
  MakeInvList('红茶2L', '包', '2L-A', '15.80', '2', '31.6', InvList);
  MakeInvList('统一奶茶', '瓶', '500ml', '4.5', '3', '13.5', InvList);
  MakeInvList('手机',   '部', 'x302', '888.0', '1', '888.0', InvList);

  if CheckBox1.Checked then
  begin
    MakeInvList('打火机', '个', 'R', '3.0', '1', '0', InvList);
    MakeInvList('打火机', '个', 'R', '3.0', '1', '0', InvList);
    MakeInvList('打火机', '个', 'R', '3.0', '1', '0', InvList);
    MakeInvList('打火机', '个', 'R', '3.0', '1', '0', InvList);
    MakeInvList('打火机', '个', 'R', '3.0', '1', '0', InvList);
    MakeInvList('打火机', '个', 'R', '3.0', '1', '0', InvList);
    MakeInvList('打火机', '个', 'R', '3.0', '1', '0', InvList);
    MakeInvList('打火机', '个', 'R', '3.0', '1', '0', InvList);
    MakeInvList('手机',   '部', 'x302', '888.0', '1', '0', InvList);
    MakeInvList('手机',   '部', 'x302', '888.0', '1', '0', InvList);
  end;

  bill :=
    // 主表
    edt_tax_rate.Text + GC_SeparatorL1 +              // 税率
    edt_cust_name.Text + GC_SeparatorL1 +             // 客户名称
    edt_cust_tax_code.Text + GC_SeparatorL1 +         // 客户税号
    edt_cust_address_tel.Text + GC_SeparatorL1 +      // 客户地址电话
    edt_cust_bank_account.Text + GC_SeparatorL1 +     // 客户银行帐号
    Memo_memo.Text + GC_SeparatorL1 +                 // 备注
    cmb_seller_bank_account.Text + GC_SeparatorL1 +   // 销方银行帐号
    edt_checker.Text + GC_SeparatorL1 +               // 复核人
    edt_payee.Text + GC_SeparatorL1 +                 // 收款人
    'TnT' + GC_SeparatorL1 +                          // 红冲号
    'TnT' + GC_SeparatorL1 +                          // 负数开票相关的原始发票代码
    'TnT' +                                           // 负数开票相关的原始
    GC_SeparatorL3 +
    // 明细
    InvList;

  errcode := inv_create(
    cmbInvoiceType.ItemIndex, // 0 - 普通发票； 1 - 专用发票
    cmb_tax_flag.ItemIndex,   // 0 -不含税 ； 1 - 含税
    cmb_mode.ItemIndex+1,     // 1 - 开票； 2 - 打印 ； 3 - 开票并打印 不存在单独 为 2的情况
    0,                        // 0 -普通开票 ；1 - 负数发票；
    StrToFloat(edtDiscount.Text),   // 小于1， 表示折扣率； 大于等于1表示折扣金额
    PChar(bill),
    Length(bill)*SizeOf(Char),
    @inv_code, @inv_num, @date, @amout, @tax);
  OutputInfo('inv_create: '+IntToStr(errcode));
  if errcode = ERROR_SUCCESS then
  begin
    OutputInfo('    inv_code : '+PChar(@inv_code));
    OutputInfo('    inv_num  : '+PChar(@inv_num));
    OutputInfo('    date     : '+PChar(@date));
    OutputInfo('    amout    : '+PChar(@amout));
    OutputInfo('    tax      : '+PChar(@tax));
  end;   
end;

procedure TfrmMain.btn_inv_cancelClick(Sender: TObject);
var
  errcode: Integer;
begin
  errcode := inv_cancel(cmbInvoiceType.ItemIndex, PChar(edtInvNumber.Text), PChar(edtInvCode.Text));
  OutputInfo('inv_create: '+IntToStr(errcode));
end;

procedure TfrmMain.btn_InitPlugerClick(Sender: TObject);
var
  errcode: Integer;
begin
  errcode := InitPluger;
  OutputInfo('InitPluger: '+IntToStr(errcode));
end;

procedure TfrmMain.btn_FreePlugerClick(Sender: TObject);
var
  errcode: Integer;
begin
  errcode := FreePluger;
  OutputInfo('FreePluger: '+IntToStr(errcode));
end;

procedure TfrmMain.OutputInfo(s: string);
begin
  MemoLog.Lines.Add(DateTimeToStr(Now)+': '+s);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Init;
end;

procedure TfrmMain.Init;
begin
  cmbInvoiceType.ItemIndex := 1;
  cmb_tax_flag.ItemIndex := 0;
  cmb_mode.ItemIndex := 0;
  AdjustProcessPrivilege(SeDebugPrivilege, True);
end;

procedure TfrmMain.btn_inv_getinfo_allClick(Sender: TObject);
var
  errcode: Integer;
  buf: Pointer;
  bufsize: Integer;
  ioSize: Integer;

  All, Value: string;
  procedure _Show(sRecord: string);
  var
    v, s, sv: string;
  begin
    SeparatorStr(sRecord, GC_SeparatorL3, v, s);

    OutputInfo('  -----------------------------------------------------------');
    OutputInfo('  发票信息:');
    OutputInfo('      '+v);
    OutputInfo('  发票明细:');
    while SeparatorStr(s, GC_SeparatorL2, sv, s) do
      OutputInfo('      '+sv);
    OutputInfo('      '+s);
  end;
begin
  bufsize := 1024 * 1024;
  GetMem(buf, bufsize);
  try
    ioSize := bufsize;
    errcode := inv_getinfo_all(buf, @ioSize);
    OutputInfo('inv_getinfo_all: '+IntToStr(errcode));
    if errcode = ERROR_BUFFER_TOO_SMALL then
    begin
      OutputInfo('  need buffer size: '+IntToStr(ioSize));

    end else if errcode = ERROR_SUCCESS then
    begin
      //{
      if ioSize = 0 then
      begin
        OutputInfo('  no record.');
      end else
      begin
        All := Copy(PChar(buf), 1, ioSize);

        while SeparatorStr(All, GC_SeparatorL4, Value, All) do
        begin
          _Show(Value);
          //OutputInfo('  发票信息:');
          //OutputInfo('    '+Value);
        end;

        _Show(All);
        //OutputInfo('  发票信息:');
        //OutputInfo('    '+All);
      end;
      //}
      //OutputInfo('  '+Copy(PChar(buf), 1, ioSize));
    end;
  finally
    FreeMem(buf, bufsize);
  end;
end;

procedure TfrmMain.MakeInvList(item_name, item_unit, spec, price, qty, amount: string; var OutDest: string);
begin
  if Length(OutDest) > 0 then
    OutDest := OutDest + GC_SeparatorL2;

  OutDest := OutDest +
    item_name + GC_SeparatorL1 +    // 商品名称
    item_unit + GC_SeparatorL1 +    // 计量单位
    spec      + GC_SeparatorL1 +    // 规格
    price     + GC_SeparatorL1 +    // 单价
    qty       + GC_SeparatorL1 +    // 数量
    amount;                         // 金额
end;

procedure TfrmMain.btn_inv_getinfoClick(Sender: TObject);
var
  errcode: Integer;
  buf: Pointer;
  bufsize: Integer;
  ioSize: Integer;
var
  v, s: string;
begin
  bufsize := 1024 * 1024;
  GetMem(buf, bufsize);
  try
    ioSize := bufsize;
    errcode := inv_getinfo(cmbInvoiceType.ItemIndex, PChar(edtInvNumber.Text), PChar(edtInvCode.Text), buf, @ioSize);
    OutputInfo('inv_getinfo: '+IntToStr(errcode));
    if errcode = ERROR_BUFFER_TOO_SMALL then
    begin
      OutputInfo('  need buffer size: '+IntToStr(ioSize));

    end else if errcode = ERROR_SUCCESS then
    begin

      s := Copy(PChar(buf), 1, ioSize);

      SeparatorStr(s, GC_SeparatorL3, v, s);
      OutputInfo('  -----------------------------------------------------------');
      OutputInfo('  发票信息:');
      OutputInfo('      '+v);
      OutputInfo('  发票明细:');
      while SeparatorStr(s, GC_SeparatorL2, v, s) do
        OutputInfo('      '+v);
      OutputInfo('      '+s);
  end;

  finally
    FreeMem(buf, bufsize);
  end;
end;

procedure TfrmMain.btn_inv_getinfo_all2Click(Sender: TObject);
var
  errcode: Integer;
  buf: Pointer;
  bufsize, ioSize: Integer;
  flag: Integer;
  beginData, endData: string;

  Year, Month, Day: Word;

  All, Value: string;
  procedure _Show(sRecord: string);
  var
    v, s, sv: string;
  begin
    SeparatorStr(sRecord, GC_SeparatorL3, v, s);

    OutputInfo('  -----------------------------------------------------------');
    OutputInfo('  发票信息:');
    OutputInfo('      '+v);
    OutputInfo('  发票明细:');
    while SeparatorStr(s, GC_SeparatorL2, sv, s) do
      OutputInfo('      '+sv);
    OutputInfo('      '+s);
  end;
begin
  bufsize := 1024 * 1024;
  GetMem(buf, bufsize);
  try
    ioSize := bufsize;

    if chkGetInfoFlag.Checked then
      flag := 1
    else
      flag := 0;

    DecodeDate(dtpBegin.DateTime, Year, Month, Day);
    beginData := Format('%.4d-%.2d-%.2d', [Year, Month, Day]);
    DecodeDate(dtpEnd.DateTime, Year, Month, Day);
    endData := Format('%.4d-%.2d-%.2d', [Year, Month, Day]);
    errcode := inv_getinfo_all2('全年度数据', buf, @ioSize, PChar(beginData), PChar(endData), flag);
    OutputInfo('inv_getinfo_all2: '+IntToStr(errcode));

    if errcode = ERROR_BUFFER_TOO_SMALL then
    begin
      OutputInfo('  need buffer size: '+IntToStr(ioSize));

    end else if errcode = ERROR_SUCCESS then
    begin
      if ioSize = 0 then
      begin
        OutputInfo('  no record.');
      end else
      begin
        All := Copy(PChar(buf), 1, ioSize);

        while SeparatorStr(All, GC_SeparatorL4, Value, All) do
          _Show(Value);
        _Show(All);
        
      end;
    end;

  
  finally
    FreeMem(buf, bufsize);
  end;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  OutputInfo('PlugerVer: '+IntToStr(PlugerVer));
end;

procedure TfrmMain.btn_inv_printClick(Sender: TObject);
var
  errcode: Integer;
begin
  errcode := inv_print('全年度数据', PChar(edtInvNumber.Text), PChar(edtInvCode.Text), Integer(CheckBox2.Checked));
  OutputInfo('inv_print: '+IntToStr(errcode));
end;

procedure TfrmMain.Button2Click(Sender: TObject);
var
  n: Integer;
begin
  n := 0;
  while n < 1000 do
  begin
    OutputInfo('搞第 '+IntToStr(n+1)+' 次');
    btn_inv_reset.Click;
    btn_inv_taxinfo.Click;

    Sleep(1000);
    Inc(n);    
  end;

  OutputInfo('搞完了搞完了');
end;

end.
