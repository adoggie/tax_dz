object frmSyncMsg: TfrmSyncMsg
  Left = 504
  Top = 253
  Width = 531
  Height = 368
  Caption = 'frmSyncMsg'
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
  object btn_InjectKPSystem: TButton
    Left = 8
    Top = 8
    Width = 105
    Height = 25
    Caption = 'InjectKPSystem'
    TabOrder = 0
    OnClick = btn_InjectKPSystemClick
  end
  object btnIsmShow: TButton
    Left = 8
    Top = 40
    Width = 75
    Height = 25
    Caption = 'IsmShow'
    TabOrder = 1
    OnClick = btnIsmShowClick
  end
  object btnIsmHide: TButton
    Left = 8
    Top = 64
    Width = 75
    Height = 25
    Caption = 'IsmHide'
    TabOrder = 2
    OnClick = btnIsmHideClick
  end
  object btnIsmFree: TButton
    Left = 8
    Top = 88
    Width = 75
    Height = 25
    Caption = 'IsmFree'
    TabOrder = 3
  end
  object PanelHide: TPanel
    Left = 0
    Top = 184
    Width = 143
    Height = 129
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'PanelHide'
    TabOrder = 4
  end
  object chkLock: TCheckBox
    Left = 8
    Top = 136
    Width = 81
    Height = 17
    Caption = 'chkLock'
    TabOrder = 5
    OnClick = chkLockClick
  end
  object Memo1: TMemo
    Left = 160
    Top = 0
    Width = 340
    Height = 330
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Memo1')
    TabOrder = 6
  end
  object TimerLock: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerLockTimer
    Left = 96
    Top = 40
  end
end
