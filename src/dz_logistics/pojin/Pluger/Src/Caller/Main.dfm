object frmMain: TfrmMain
  Left = 451
  Top = 174
  Width = 863
  Height = 521
  Caption = 'frmMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 104
    Top = 120
    Width = 24
    Height = 13
    Caption = '˰��'
  end
  object Label2: TLabel
    Left = 104
    Top = 144
    Width = 48
    Height = 13
    Caption = '�ͻ�����'
  end
  object Label3: TLabel
    Left = 104
    Top = 168
    Width = 48
    Height = 13
    Caption = '�ͻ�˰��'
  end
  object Label4: TLabel
    Left = 104
    Top = 192
    Width = 48
    Height = 13
    Caption = '��ַ�绰'
  end
  object Label5: TLabel
    Left = 104
    Top = 216
    Width = 48
    Height = 13
    Caption = '�����ʺ�'
  end
  object Label6: TLabel
    Left = 104
    Top = 240
    Width = 24
    Height = 13
    Caption = '��ע'
  end
  object Label7: TLabel
    Left = 104
    Top = 292
    Width = 48
    Height = 13
    Caption = '��������'
  end
  object Label8: TLabel
    Left = 104
    Top = 317
    Width = 36
    Height = 13
    Caption = '������'
  end
  object Label9: TLabel
    Left = 104
    Top = 341
    Width = 36
    Height = 13
    Caption = '�տ���'
  end
  object Label10: TLabel
    Left = 104
    Top = 399
    Width = 48
    Height = 13
    Caption = '��Ʊ����'
  end
  object Label11: TLabel
    Left = 104
    Top = 423
    Width = 48
    Height = 13
    Caption = '��Ʊ����'
  end
  object Label12: TLabel
    Left = 104
    Top = 365
    Width = 24
    Height = 13
    Caption = '�ۿ�'
  end
  object btn_inv_reset: TButton
    Left = 8
    Top = 40
    Width = 75
    Height = 25
    Caption = 'inv_reset'
    TabOrder = 0
    OnClick = btn_inv_resetClick
  end
  object btn_inv_open: TButton
    Left = 8
    Top = 72
    Width = 75
    Height = 25
    Caption = 'inv_open'
    Enabled = False
    TabOrder = 1
    OnClick = btn_inv_openClick
  end
  object btn_inv_close: TButton
    Left = 8
    Top = 104
    Width = 75
    Height = 25
    Caption = 'inv_close'
    Enabled = False
    TabOrder = 2
    OnClick = btn_inv_closeClick
  end
  object btn_inv_lock: TButton
    Left = 8
    Top = 136
    Width = 75
    Height = 25
    Caption = 'inv_lock'
    TabOrder = 3
    OnClick = btn_inv_lockClick
  end
  object btn_inv_unlock: TButton
    Left = 8
    Top = 168
    Width = 75
    Height = 25
    Caption = 'inv_unlock'
    TabOrder = 4
    OnClick = btn_inv_unlockClick
  end
  object btn_inv_taxinfo: TButton
    Left = 104
    Top = 40
    Width = 75
    Height = 25
    Caption = 'inv_taxinfo'
    TabOrder = 5
    OnClick = btn_inv_taxinfoClick
  end
  object btn_inv_create: TButton
    Left = 104
    Top = 72
    Width = 75
    Height = 25
    Caption = 'inv_create'
    TabOrder = 6
    OnClick = btn_inv_createClick
  end
  object btn_inv_cancel: TButton
    Left = 8
    Top = 415
    Width = 75
    Height = 23
    Caption = 'inv_cancel'
    TabOrder = 7
    OnClick = btn_inv_cancelClick
  end
  object btn_inv_getinfo: TButton
    Left = 8
    Top = 391
    Width = 75
    Height = 23
    Caption = 'inv_getinfo'
    TabOrder = 8
    OnClick = btn_inv_getinfoClick
  end
  object btn_inv_getinfo_all: TButton
    Left = 8
    Top = 367
    Width = 75
    Height = 23
    Caption = 'inv_getinfo_all'
    TabOrder = 9
    OnClick = btn_inv_getinfo_allClick
  end
  object btn_InitPluger: TButton
    Left = 8
    Top = 8
    Width = 169
    Height = 25
    Caption = 'InitPluger'
    TabOrder = 10
    OnClick = btn_InitPlugerClick
  end
  object btn_FreePluger: TButton
    Left = 192
    Top = 8
    Width = 169
    Height = 25
    Caption = 'FreePluger'
    TabOrder = 11
    OnClick = btn_FreePlugerClick
  end
  object MemoLog: TMemo
    Left = 368
    Top = 8
    Width = 471
    Height = 467
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 12
  end
  object cmbInvoiceType: TComboBox
    Left = 192
    Top = 40
    Width = 169
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 13
    Items.Strings = (
      '��ͨ��Ʊ'
      'ר�÷�Ʊ')
  end
  object cmb_tax_flag: TComboBox
    Left = 192
    Top = 64
    Width = 169
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 14
    Items.Strings = (
      '����˰'
      '��˰')
  end
  object cmb_mode: TComboBox
    Left = 192
    Top = 88
    Width = 169
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 15
    Items.Strings = (
      '��Ʊ'
      '��ӡ'
      '��Ʊ����ӡ')
  end
  object edt_tax_rate: TEdit
    Left = 160
    Top = 116
    Width = 49
    Height = 21
    TabOrder = 16
    Text = '0.17'
  end
  object edt_cust_name: TEdit
    Left = 160
    Top = 139
    Width = 201
    Height = 21
    TabOrder = 17
    Text = 'Զ����˾���̲�'
  end
  object edt_cust_tax_code: TEdit
    Left = 160
    Top = 163
    Width = 201
    Height = 21
    TabOrder = 18
    Text = '420101300198696'
  end
  object edt_cust_address_tel: TEdit
    Left = 160
    Top = 187
    Width = 201
    Height = 21
    TabOrder = 19
    Text = '�人������·һ��'
  end
  object edt_cust_bank_account: TEdit
    Left = 160
    Top = 211
    Width = 201
    Height = 21
    TabOrder = 20
    Text = '����Ӫҵ��123��5102-65428'
  end
  object Memo_memo: TMemo
    Left = 160
    Top = 235
    Width = 201
    Height = 49
    Lines.Strings = (
      'Memo_memo')
    TabOrder = 21
  end
  object cmb_seller_bank_account: TComboBox
    Left = 160
    Top = 288
    Width = 201
    Height = 21
    ItemHeight = 13
    TabOrder = 22
    Text = 'cmb_seller_bank_account'
    Items.Strings = (
      '����123455668-234222256111'
      '����345678901-123')
  end
  object edt_checker: TEdit
    Left = 160
    Top = 312
    Width = 201
    Height = 21
    TabOrder = 23
    Text = 'Ҷ���'
  end
  object edt_payee: TEdit
    Left = 160
    Top = 336
    Width = 201
    Height = 21
    TabOrder = 24
    Text = '���޼�'
  end
  object edtInvCode: TEdit
    Left = 160
    Top = 395
    Width = 97
    Height = 21
    TabOrder = 25
    Text = '0000000'
  end
  object edtInvNumber: TEdit
    Left = 160
    Top = 419
    Width = 97
    Height = 21
    TabOrder = 26
    Text = '0000000'
  end
  object CheckBox1: TCheckBox
    Left = 272
    Top = 381
    Width = 73
    Height = 17
    Caption = '����8��'
    TabOrder = 27
  end
  object edtDiscount: TEdit
    Left = 160
    Top = 360
    Width = 201
    Height = 21
    TabOrder = 28
    Text = '0.15'
  end
  object btn_inv_getinfo_all2: TButton
    Left = 8
    Top = 447
    Width = 75
    Height = 23
    Caption = 'inv_getinfo_all2'
    TabOrder = 29
    OnClick = btn_inv_getinfo_all2Click
  end
  object chkGetInfoFlag: TCheckBox
    Left = 288
    Top = 450
    Width = 73
    Height = 17
    Caption = '��������ϸ'
    Checked = True
    State = cbChecked
    TabOrder = 30
  end
  object dtpBegin: TDateTimePicker
    Left = 104
    Top = 448
    Width = 89
    Height = 21
    CalAlignment = dtaLeft
    Date = 41338.9107066088
    Time = 41338.9107066088
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkDate
    ParseInput = False
    TabOrder = 31
  end
  object dtpEnd: TDateTimePicker
    Left = 192
    Top = 448
    Width = 89
    Height = 21
    CalAlignment = dtaLeft
    Date = 41338.9107066088
    Time = 41338.9107066088
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkDate
    ParseInput = False
    TabOrder = 32
  end
  object Button1: TButton
    Left = 8
    Top = 264
    Width = 75
    Height = 25
    Caption = 'PlugerVer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    TabOrder = 33
    OnClick = Button1Click
  end
  object btn_inv_print: TButton
    Left = 272
    Top = 416
    Width = 91
    Height = 21
    Caption = 'inv_print'
    TabOrder = 34
    OnClick = btn_inv_printClick
  end
  object CheckBox2: TCheckBox
    Left = 272
    Top = 397
    Width = 73
    Height = 17
    Caption = '��ӡ�嵥'
    TabOrder = 35
  end
  object Button2: TButton
    Left = 8
    Top = 224
    Width = 89
    Height = 25
    Caption = '100��ѽ100��'
    TabOrder = 36
    OnClick = Button2Click
  end
end
