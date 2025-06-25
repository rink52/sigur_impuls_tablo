object DemoForm: TDemoForm
  Left = 196
  Top = 141
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1058#1077#1089#1090#1080#1088#1086#1074#1072#1085#1080#1077
  ClientHeight = 497
  ClientWidth = 717
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 20
    Top = 48
    Width = 34
    Height = 13
    Caption = #1040#1076#1088#1077#1089':'
  end
  object SpinEdit1: TSpinEdit
    Left = 68
    Top = 12
    Width = 73
    Height = 22
    MaxValue = 256
    MinValue = 1
    TabOrder = 0
    Value = 1
    OnChange = SpinEdit1Change
  end
  object SpinEdit2: TSpinEdit
    Left = 68
    Top = 44
    Width = 73
    Height = 22
    MaxValue = 65535
    MinValue = 0
    TabOrder = 1
    Value = 9999
  end
  object Memo1: TMemo
    Left = 8
    Top = 372
    Width = 689
    Height = 113
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object RadioButton1: TRadioButton
    Left = 8
    Top = 14
    Width = 53
    Height = 17
    Caption = 'COM:'
    Checked = True
    TabOrder = 3
    TabStop = True
    OnClick = RadioButton1Click
  end
  object RadioButton2: TRadioButton
    Left = 196
    Top = 14
    Width = 53
    Height = 17
    Caption = 'TCP:'
    TabOrder = 4
  end
  object Edit1: TEdit
    Left = 256
    Top = 12
    Width = 121
    Height = 21
    TabOrder = 5
    Text = '192.168.0.11:5000'
  end
  object Button2: TButton
    Left = 468
    Top = 12
    Width = 85
    Height = 17
    Caption = #1059#1089#1090'. '#1074#1088#1077#1084#1103
    TabOrder = 6
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 468
    Top = 48
    Width = 85
    Height = 17
    Caption = #1057#1095#1080#1090'. '#1074#1088#1077#1084#1103
    TabOrder = 7
    OnClick = Button3Click
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 76
    Width = 113
    Height = 45
    Caption = ' '#1071#1088#1082#1086#1089#1090#1100' '
    TabOrder = 8
    object SpinEdit3: TSpinEdit
      Left = 8
      Top = 16
      Width = 53
      Height = 22
      MaxValue = 10
      MinValue = 1
      TabOrder = 0
      Value = 5
    end
    object Button4: TButton
      Left = 68
      Top = 20
      Width = 37
      Height = 17
      Caption = '->'
      TabOrder = 1
      OnClick = Button4Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 132
    Width = 541
    Height = 121
    Caption = ' '#1058#1077#1082#1089#1090' '
    TabOrder = 9
    object Label1: TLabel
      Left = 12
      Top = 100
      Width = 48
      Height = 13
      Caption = #1044#1080#1089#1087#1083#1077#1081':'
    end
    object Label3: TLabel
      Left = 12
      Top = 20
      Width = 37
      Height = 13
      Caption = #1064#1088#1080#1092#1090':'
    end
    object Label4: TLabel
      Left = 252
      Top = 44
      Width = 78
      Height = 13
      Caption = #1042#1099#1088#1072#1074#1085#1080#1074#1072#1085#1080#1077':'
    end
    object Label5: TLabel
      Left = 424
      Top = 40
      Width = 51
      Height = 13
      Caption = #1057#1082#1086#1088#1086#1089#1090#1100':'
    end
    object Label6: TLabel
      Left = 132
      Top = 20
      Width = 33
      Height = 13
      Caption = #1058#1077#1082#1089#1090':'
    end
    object Label7: TLabel
      Left = 132
      Top = 44
      Width = 28
      Height = 13
      Caption = #1062#1074#1077#1090':'
    end
    object Label8: TLabel
      Left = 132
      Top = 76
      Width = 52
      Height = 13
      Caption = #1055#1086#1074#1090#1086#1088#1086#1074':'
    end
    object Label9: TLabel
      Left = 252
      Top = 76
      Width = 52
      Height = 13
      Caption = #1048#1085#1090#1077#1088#1074#1072#1083':'
    end
    object Label10: TLabel
      Left = 12
      Top = 48
      Width = 43
      Height = 13
      Caption = #1069#1092#1092#1077#1082#1090':'
    end
    object SpinEdit4: TSpinEdit
      Left = 68
      Top = 96
      Width = 49
      Height = 22
      MaxValue = 63
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object CheckBox1: TCheckBox
      Left = 444
      Top = 16
      Width = 81
      Height = 17
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object SpinEdit5: TSpinEdit
      Left = 68
      Top = 16
      Width = 49
      Height = 22
      MaxValue = 7
      MinValue = 0
      TabOrder = 2
      Value = 5
    end
    object ComboBox1: TComboBox
      Left = 336
      Top = 40
      Width = 73
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 3
      Text = #1042#1087#1088#1072#1074#1086
      Items.Strings = (
        #1042#1083#1077#1074#1086
        #1042#1087#1088#1072#1074#1086
        #1055#1086' '#1094#1077#1085#1090#1088#1091)
    end
    object SpinEdit6: TSpinEdit
      Left = 484
      Top = 36
      Width = 49
      Height = 22
      MaxValue = 5
      MinValue = 0
      TabOrder = 4
      Value = 3
    end
    object Edit2: TEdit
      Left = 176
      Top = 16
      Width = 253
      Height = 21
      TabOrder = 5
      Text = 
        '{[pause:2]}{[col:1]}{[Font:1]}12{[blink:5,25]}34{[Font:4]}56{[co' +
        'l:3]}{[blink:15,10]}78'
    end
    object Button5: TButton
      Left = 464
      Top = 98
      Width = 65
      Height = 17
      Caption = #1042#1099#1074#1077#1089#1090#1080
      TabOrder = 6
      OnClick = Button5Click
    end
    object SpinEdit8: TSpinEdit
      Left = 176
      Top = 40
      Width = 49
      Height = 22
      MaxValue = 7
      MinValue = 0
      TabOrder = 7
      Value = 1
    end
    object SpinEdit10: TSpinEdit
      Left = 192
      Top = 72
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 8
      Value = 5
    end
    object SpinEdit11: TSpinEdit
      Left = 312
      Top = 71
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 9
      Value = 25
    end
    object CheckBox4: TCheckBox
      Left = 368
      Top = 74
      Width = 161
      Height = 17
      Caption = #1055#1072#1091#1079#1072' '#1074#1086' '#1074#1088#1077#1084#1103' '#1101#1092#1092#1077#1082#1090#1072
      TabOrder = 10
    end
    object SpinEdit9: TSpinEdit
      Left = 68
      Top = 44
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 11
      Value = 0
    end
    object Button8: TButton
      Left = 416
      Top = 96
      Width = 37
      Height = 17
      Caption = 'eff'
      TabOrder = 12
      Visible = False
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 360
      Top = 96
      Width = 45
      Height = 17
      Caption = 'Clear'
      TabOrder = 13
      OnClick = Button9Click
    end
    object RadioButton4: TRadioButton
      Left = 132
      Top = 100
      Width = 81
      Height = 17
      Caption = #1055#1086' '#1091#1084#1086#1083#1095'.'
      Checked = True
      TabOrder = 14
      TabStop = True
    end
    object RadioButton5: TRadioButton
      Left = 220
      Top = 100
      Width = 57
      Height = 17
      Caption = #1057#1077#1075#1084'.'
      TabOrder = 15
    end
    object RadioButton6: TRadioButton
      Left = 288
      Top = 100
      Width = 69
      Height = 17
      Caption = #1058#1077#1082#1089#1090'.'
      TabOrder = 16
    end
    object Button16: TButton
      Left = 12
      Top = 72
      Width = 53
      Height = 17
      Caption = 'Skip'
      TabOrder = 17
      Visible = False
      OnClick = Button16Click
    end
    object CheckBox9: TCheckBox
      Left = 436
      Top = 60
      Width = 97
      Height = 17
      Caption = #1072#1076#1072#1087#1090#1080#1074#1085#1072#1103
      Checked = True
      State = cbChecked
      TabOrder = 18
    end
  end
  object GroupBox3: TGroupBox
    Left = 160
    Top = 76
    Width = 185
    Height = 45
    Caption = ' '#1058#1077#1089#1090' '
    TabOrder = 10
    object SpinEdit7: TSpinEdit
      Left = 8
      Top = 16
      Width = 53
      Height = 22
      MaxValue = 6
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object Button6: TButton
      Left = 140
      Top = 16
      Width = 37
      Height = 17
      Caption = '->'
      TabOrder = 1
      OnClick = Button6Click
    end
    object CheckBox2: TCheckBox
      Left = 68
      Top = 16
      Width = 61
      Height = 17
      Caption = #1062#1080#1082#1083
      TabOrder = 2
    end
  end
  object GroupBox4: TGroupBox
    Left = 372
    Top = 76
    Width = 177
    Height = 45
    Caption = ' '#1057#1074#1103#1079#1100' '
    TabOrder = 11
    object Button1: TButton
      Left = 100
      Top = 18
      Width = 65
      Height = 17
      Caption = #1058#1077#1089#1090
      TabOrder = 0
      OnClick = Button1Click
    end
    object CheckBox3: TCheckBox
      Left = 12
      Top = 18
      Width = 65
      Height = 17
      Caption = #1062#1080#1082#1083
      TabOrder = 1
      OnClick = CheckBox3Click
    end
  end
  object GroupBox5: TGroupBox
    Left = 8
    Top = 256
    Width = 541
    Height = 101
    Caption = ' '#1055#1086#1089#1090#1086#1103#1085#1085#1099#1077' '#1101#1092#1092#1077#1082#1090#1099' '
    TabOrder = 12
    object Label11: TLabel
      Left = 72
      Top = 24
      Width = 52
      Height = 13
      Caption = #1055#1086#1074#1090#1086#1088#1086#1074':'
    end
    object Label12: TLabel
      Left = 192
      Top = 24
      Width = 52
      Height = 13
      Caption = #1048#1085#1090#1077#1088#1074#1072#1083':'
    end
    object Label13: TLabel
      Left = 72
      Top = 52
      Width = 52
      Height = 13
      Caption = #1055#1086#1074#1090#1086#1088#1086#1074':'
    end
    object Label14: TLabel
      Left = 192
      Top = 52
      Width = 52
      Height = 13
      Caption = #1048#1085#1090#1077#1088#1074#1072#1083':'
    end
    object Label15: TLabel
      Left = 72
      Top = 80
      Width = 52
      Height = 13
      Caption = #1055#1086#1074#1090#1086#1088#1086#1074':'
    end
    object Label16: TLabel
      Left = 192
      Top = 80
      Width = 52
      Height = 13
      Caption = #1048#1085#1090#1077#1088#1074#1072#1083':'
    end
    object Label17: TLabel
      Left = 304
      Top = 24
      Width = 36
      Height = 13
      Caption = #1042#1088#1077#1084#1103':'
    end
    object Label18: TLabel
      Left = 304
      Top = 52
      Width = 36
      Height = 13
      Caption = #1042#1088#1077#1084#1103':'
    end
    object Label19: TLabel
      Left = 304
      Top = 80
      Width = 36
      Height = 13
      Caption = #1042#1088#1077#1084#1103':'
    end
    object SpinEdit12: TSpinEdit
      Left = 132
      Top = 20
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 0
      Value = 5
    end
    object SpinEdit13: TSpinEdit
      Left = 252
      Top = 19
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 1
      Value = 25
    end
    object CheckBox6: TCheckBox
      Left = 400
      Top = 22
      Width = 65
      Height = 17
      Caption = #1055#1072#1091#1079#1072
      TabOrder = 2
    end
    object SpinEdit14: TSpinEdit
      Left = 12
      Top = 20
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 3
      Value = 0
    end
    object SpinEdit15: TSpinEdit
      Left = 12
      Top = 48
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 4
      Value = 0
    end
    object SpinEdit16: TSpinEdit
      Left = 132
      Top = 48
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 5
      Value = 5
    end
    object SpinEdit17: TSpinEdit
      Left = 252
      Top = 47
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 6
      Value = 5
    end
    object SpinEdit18: TSpinEdit
      Left = 12
      Top = 76
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 7
      Value = 5
    end
    object SpinEdit19: TSpinEdit
      Left = 132
      Top = 76
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 8
      Value = 5
    end
    object SpinEdit20: TSpinEdit
      Left = 252
      Top = 75
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 9
      Value = 5
    end
    object Button7: TButton
      Left = 468
      Top = 20
      Width = 65
      Height = 17
      Caption = #1042#1099#1074#1077#1089#1090#1080
      TabOrder = 10
      OnClick = Button7Click
    end
    object CheckBox5: TCheckBox
      Left = 400
      Top = 50
      Width = 65
      Height = 17
      Caption = #1055#1072#1091#1079#1072
      TabOrder = 11
    end
    object CheckBox7: TCheckBox
      Left = 400
      Top = 78
      Width = 65
      Height = 17
      Caption = #1055#1072#1091#1079#1072
      TabOrder = 12
    end
    object SpinEdit21: TSpinEdit
      Left = 344
      Top = 19
      Width = 49
      Height = 22
      MaxValue = 65
      MinValue = 0
      TabOrder = 13
      Value = 8
    end
    object SpinEdit22: TSpinEdit
      Left = 344
      Top = 47
      Width = 49
      Height = 22
      MaxValue = 65
      MinValue = 0
      TabOrder = 14
      Value = 8
    end
    object SpinEdit23: TSpinEdit
      Left = 344
      Top = 75
      Width = 49
      Height = 22
      MaxValue = 65
      MinValue = 0
      TabOrder = 15
      Value = 8
    end
  end
  object Button10: TButton
    Left = 384
    Top = 4
    Width = 75
    Height = 25
    Caption = 'Button10'
    TabOrder = 13
    Visible = False
    OnClick = Button10Click
  end
  object RadioButton3: TRadioButton
    Left = 196
    Top = 42
    Width = 53
    Height = 17
    Caption = 'UDP:'
    TabOrder = 14
  end
  object Edit3: TEdit
    Left = 256
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 15
    Text = '192.168.0.11:5000'
  end
  object GroupBox6: TGroupBox
    Left = 556
    Top = 132
    Width = 145
    Height = 77
    Caption = ' '#1048#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103' '
    TabOrder = 16
    object Label20: TLabel
      Left = 64
      Top = 24
      Width = 9
      Height = 13
      Caption = '->'
    end
    object SpinEdit24: TSpinEdit
      Left = 8
      Top = 20
      Width = 49
      Height = 22
      MaxValue = 31
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object SpinEdit25: TSpinEdit
      Left = 84
      Top = 20
      Width = 49
      Height = 22
      MaxValue = 31
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object Button11: TButton
      Left = 72
      Top = 52
      Width = 63
      Height = 17
      Caption = #1042#1099#1074#1077#1089#1090#1080
      TabOrder = 2
      OnClick = Button11Click
    end
    object CheckBox10: TCheckBox
      Left = 8
      Top = 52
      Width = 49
      Height = 17
      Caption = #1057#1086#1093#1088'.'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
  end
  object GroupBox7: TGroupBox
    Left = 556
    Top = 216
    Width = 145
    Height = 117
    Caption = ' '#1058#1077#1082#1089#1090#1086#1074#1099#1077' '#1087#1086#1083#1103' '
    TabOrder = 17
    object SpinEdit26: TSpinEdit
      Left = 8
      Top = 24
      Width = 49
      Height = 22
      MaxValue = 31
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object Edit4: TEdit
      Left = 68
      Top = 24
      Width = 69
      Height = 21
      TabOrder = 1
      Text = '12345'
    end
    object Button12: TButton
      Left = 76
      Top = 52
      Width = 61
      Height = 17
      Caption = #1042#1099#1074#1077#1089#1090#1080
      TabOrder = 2
      OnClick = Button12Click
    end
    object Button13: TButton
      Left = 8
      Top = 52
      Width = 53
      Height = 17
      Caption = #1057#1095#1080#1090#1072#1090#1100
      TabOrder = 3
      OnClick = Button13Click
    end
    object Button14: TButton
      Left = 8
      Top = 80
      Width = 75
      Height = 25
      Caption = 'Button14'
      TabOrder = 4
      Visible = False
      OnClick = Button14Click
    end
    object Button15: TButton
      Left = 96
      Top = 80
      Width = 37
      Height = 25
      Caption = '0'
      TabOrder = 5
      Visible = False
      OnClick = Button15Click
    end
  end
  object GroupBox8: TGroupBox
    Left = 564
    Top = 12
    Width = 145
    Height = 109
    Caption = ' '#1053#1086#1074#1099#1081' '#1072#1076#1088#1077#1089' '
    TabOrder = 18
    object Label21: TLabel
      Left = 12
      Top = 24
      Width = 34
      Height = 13
      Caption = #1040#1076#1088#1077#1089':'
    end
    object Label22: TLabel
      Left = 12
      Top = 52
      Width = 12
      Height = 13
      Caption = 'Id:'
    end
    object SpinEdit27: TSpinEdit
      Left = 60
      Top = 20
      Width = 73
      Height = 22
      MaxValue = 65534
      MinValue = 1
      TabOrder = 0
      Value = 9999
    end
    object SpinEdit28: TSpinEdit
      Left = 60
      Top = 48
      Width = 73
      Height = 22
      MaxValue = 65535
      MinValue = -1
      TabOrder = 1
      Value = 9999
    end
    object Button17: TButton
      Left = 44
      Top = 80
      Width = 89
      Height = 17
      Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100
      TabOrder = 2
      OnClick = Button17Click
    end
  end
  object CheckBox8: TCheckBox
    Left = 388
    Top = 44
    Width = 73
    Height = 17
    Caption = 'Resend'
    TabOrder = 19
    OnClick = CheckBox8Click
  end
end
