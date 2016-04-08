object frmMessageDlg: TfrmMessageDlg
  Left = 258
  Top = 281
  Width = 688
  Height = 501
  Caption = 'frmMessageDlg'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnFreeSelf: TButton
    Left = 14
    Top = 446
    Width = 71
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'FreeSelf'
    TabOrder = 0
    OnClick = btnFreeSelfClick
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 680
    Height = 442
    ActivePage = TabSheet2
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    object TabSheet2: TTabSheet
      Caption = '控件'
      ImageIndex = 1
      object Label1: TLabel
        Left = 11
        Top = 248
        Width = 65
        Height = 13
        Caption = 'DataSet obj : '
      end
      object Label2: TLabel
        Left = 11
        Top = 351
        Width = 59
        Height = 13
        Caption = 'FieldName : '
      end
      object Label3: TLabel
        Left = 11
        Top = 375
        Width = 58
        Height = 13
        Caption = 'FieldValue : '
      end
      object btnRefreshControls: TButton
        Left = 8
        Top = 30
        Width = 281
        Height = 23
        Caption = 'Refresh'
        TabOrder = 0
        OnClick = btnRefreshControlsClick
      end
      object MemoControl: TMemo
        Left = 296
        Top = 0
        Width = 377
        Height = 410
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = '宋体'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 1
      end
      object btnFindControl: TButton
        Left = 8
        Top = 62
        Width = 75
        Height = 22
        Caption = 'Find Control'
        TabOrder = 2
        OnClick = btnFindControlClick
      end
      object btnGetControlText: TButton
        Left = 8
        Top = 92
        Width = 75
        Height = 22
        Caption = 'Get Text'
        TabOrder = 3
        OnClick = btnGetControlTextClick
      end
      object edtSetControlText: TEdit
        Left = 176
        Top = 93
        Width = 113
        Height = 21
        TabOrder = 4
        Text = 'edtSetControlText'
      end
      object btnSetControlText: TButton
        Left = 96
        Top = 92
        Width = 75
        Height = 22
        Caption = 'Set Text'
        TabOrder = 5
        OnClick = btnSetControlTextClick
      end
      object btnSetControlVisible: TButton
        Left = 96
        Top = 124
        Width = 75
        Height = 22
        Caption = 'Set Visible'
        TabOrder = 6
        OnClick = btnSetControlVisibleClick
      end
      object cmbSetControlVisible: TComboBox
        Left = 176
        Top = 125
        Width = 113
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 7
        Items.Strings = (
          'False'
          'True')
      end
      object btnSetControlData: TButton
        Left = 96
        Top = 154
        Width = 75
        Height = 22
        Caption = 'Set Data'
        TabOrder = 8
        OnClick = btnSetControlDataClick
      end
      object dtSetControlDateTime: TDateTimePicker
        Left = 176
        Top = 155
        Width = 114
        Height = 21
        CalAlignment = dtaLeft
        Date = 41291
        Time = 41291
        DateFormat = dfShort
        DateMode = dmComboBox
        Kind = dtkDate
        ParseInput = False
        TabOrder = 9
      end
      object cmbControlName: TComboBox
        Left = 96
        Top = 61
        Width = 193
        Height = 21
        ItemHeight = 13
        TabOrder = 10
        Text = 'cmbControlName'
        Items.Strings = (
          'DatePick'
          'CustnameCombo'
          'GatheringerCombo'
          'CustAccCombo'
          'CustTelCombo'
          'CustTaxCodeCombo'
          'SellAccCombo'
          'CheckerCombo'
          'DBGridE')
      end
      object btnSetControlItemIndex: TButton
        Left = 96
        Top = 184
        Width = 75
        Height = 22
        Caption = 'Set Item Index'
        TabOrder = 11
        OnClick = btnSetControlItemIndexClick
      end
      object cmbSetControlItemIndex: TComboBox
        Left = 176
        Top = 185
        Width = 113
        Height = 21
        ItemHeight = 13
        TabOrder = 12
        Text = '0'
        Items.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9'
          '10')
      end
      object btnGetControlItemCount: TButton
        Left = 8
        Top = 160
        Width = 75
        Height = 22
        Caption = 'Get Item Count'
        TabOrder = 13
        OnClick = btnGetControlItemCountClick
      end
      object btnGetDbGridDataSet: TButton
        Left = 96
        Top = 213
        Width = 193
        Height = 25
        Caption = 'Get DbGrid.DataSet'
        TabOrder = 14
        OnClick = btnGetDbGridDataSetClick
      end
      object edtDataSetObj: TEdit
        Left = 96
        Top = 245
        Width = 81
        Height = 21
        TabOrder = 15
        Text = 'edtDataSetObj'
      end
      object btnDataSetPos: TButton
        Left = 8
        Top = 277
        Width = 89
        Height = 22
        Caption = 'DataSet.Post'
        TabOrder = 16
        OnClick = btnDataSetPosClick
      end
      object btnGetDataSetClass: TButton
        Left = 96
        Top = 277
        Width = 105
        Height = 22
        Caption = 'GetDataSetClass'
        TabOrder = 17
        OnClick = btnGetDataSetClassClick
      end
      object btnDataSetAppend: TButton
        Left = 8
        Top = 298
        Width = 89
        Height = 22
        Caption = 'DataSet.Append'
        TabOrder = 18
        OnClick = btnDataSetAppendClick
      end
      object btnDatSetGetActive: TButton
        Left = 96
        Top = 298
        Width = 105
        Height = 22
        Caption = 'DatSet.GetActive'
        TabOrder = 19
        OnClick = btnDatSetGetActiveClick
      end
      object btnDataSetGetFields: TButton
        Left = 96
        Top = 319
        Width = 105
        Height = 25
        Caption = 'GetDataSetFields'
        TabOrder = 20
        OnClick = btnDataSetGetFieldsClick
      end
      object edtFieldName: TEdit
        Left = 96
        Top = 348
        Width = 81
        Height = 21
        TabOrder = 21
        Text = 'edtFieldName'
      end
      object btnGetFieldValue: TButton
        Left = 184
        Top = 346
        Width = 75
        Height = 22
        Caption = 'GetFieldValue'
        TabOrder = 22
        OnClick = btnGetFieldValueClick
      end
      object edtFieldValue: TEdit
        Left = 96
        Top = 372
        Width = 81
        Height = 21
        TabOrder = 23
        Text = 'edtFieldValue'
      end
      object btnSetFieldValue: TButton
        Left = 184
        Top = 371
        Width = 75
        Height = 22
        Caption = 'SetFieldValue'
        TabOrder = 24
        OnClick = btnSetFieldValueClick
      end
      object cmbRootObj: TComboBox
        Left = 8
        Top = 4
        Width = 281
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 25
        Items.Strings = (
          'SpecInvoiceForm'
          'FaceForm'
          'MainForm'
          'InvoiceForm'
          'ConfirmInvNoForm'
          'TmpInvQueryForm'
          'InvQryDialogForm'
          'TmpMultiCommInvFrm'
          'TmpSpecInvoiceForm'
          'InvListForm'
          'TmpInvDiscountForm'
          'MultiCommInvFrm')
      end
      object btnDataSet_First: TButton
        Left = 208
        Top = 277
        Width = 75
        Height = 21
        Caption = 'First'
        TabOrder = 26
        OnClick = btnDataSet_FirstClick
      end
      object btnDataSet_Next: TButton
        Left = 208
        Top = 297
        Width = 75
        Height = 21
        Caption = 'Next'
        TabOrder = 27
        OnClick = btnDataSet_NextClick
      end
      object Button1: TButton
        Left = 8
        Top = 213
        Width = 81
        Height = 25
        Caption = 'DBCmb.DataSet'
        TabOrder = 28
        OnClick = Button1Click
      end
      object Button3: TButton
        Left = 8
        Top = 184
        Width = 81
        Height = 22
        Caption = 'Get Item Index'
        TabOrder = 29
        OnClick = Button3Click
      end
      object btnSetEditText: TButton
        Left = 184
        Top = 394
        Width = 75
        Height = 22
        Caption = 'SetEditText'
        TabOrder = 30
        OnClick = btnSetEditTextClick
      end
    end
    object TabSheet3: TTabSheet
      Caption = '控制'
      ImageIndex = 2
      object MemoCtrl: TMemo
        Left = 0
        Top = 0
        Width = 672
        Height = 414
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = '宋体'
        Font.Style = []
        Lines.Strings = (
          'MemoCtrl')
        ParentFont = False
        TabOrder = 0
      end
    end
    object TabSheet4: TTabSheet
      Caption = '设置'
      ImageIndex = 3
      object chkAutoInvoiceNumTip: TCheckBox
        Left = 8
        Top = 8
        Width = 193
        Height = 17
        Caption = '自动确认[发票号码确认] 窗口'
        TabOrder = 0
      end
      object chkAutoClose_TLoginForm: TCheckBox
        Left = 8
        Top = 32
        Width = 177
        Height = 17
        Caption = '自动确认[操作员登录]窗口'
        TabOrder = 1
      end
      object Button2: TButton
        Left = 216
        Top = 120
        Width = 105
        Height = 89
        Caption = '税'
        TabOrder = 2
        OnClick = Button2Click
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'Hide'
      ImageIndex = 4
      object PanelHide: TPanel
        Left = 0
        Top = 0
        Width = 672
        Height = 414
        Align = alClient
        Caption = 'PanelHide'
        TabOrder = 0
      end
    end
  end
  object TimerWork: TTimer
    Interval = 200
    OnTimer = TimerWorkTimer
    Left = 480
    Top = 64
  end
end
