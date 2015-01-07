object JvSearchFileMainForm: TJvSearchFileMainForm
  Left = 372
  Top = 182
  AutoScroll = False
  Caption = 'SearchFiles'
  ClientHeight = 503
  ClientWidth = 620
  Color = clBtnFace
  Constraints.MinHeight = 343
  Constraints.MinWidth = 370
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    620
    503)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 4
    Top = 6
    Width = 611
    Height = 139
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    DesignSize = (
      611
      139)
    object Label1: TLabel
      Left = 10
      Top = 16
      Width = 48
      Height = 13
      Caption = '&Directory:'
    end
    object Label2: TLabel
      Left = 8
      Top = 44
      Width = 47
      Height = 13
      Caption = '&File mask:'
      FocusControl = edFileMask
    end
    object chkRecursive: TCheckBox
      Left = 72
      Top = 64
      Width = 97
      Height = 17
      Caption = '&Recursive'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = OptionsChange
    end
    object edFileMask: TEdit
      Left = 62
      Top = 40
      Width = 539
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = '*.*'
      OnChange = OptionsChange
    end
    object cbContainText: TComboBox
      Left = 24
      Top = 108
      Width = 577
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 4
      OnChange = OptionsChange
    end
    object rbInclude: TRadioButton
      Left = 6
      Top = 87
      Width = 79
      Height = 17
      Caption = '&With text:'
      Checked = True
      TabOrder = 2
      TabStop = True
      OnClick = OptionsChange
    end
    object rbExclude: TRadioButton
      Left = 132
      Top = 87
      Width = 113
      Height = 17
      Caption = 'With&out text:'
      TabOrder = 3
      OnClick = OptionsChange
    end
    object edtJvDirectoryBox1: TEdit
      Left = 64
      Top = 16
      Width = 121
      Height = 21
      TabOrder = 5
      Text = 'c:\'
    end
  end
  object btnSearch: TButton
    Left = 264
    Top = 160
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '&Search'
    Default = True
    TabOrder = 3
    OnClick = btnSearchClick
  end
  object GroupBox2: TGroupBox
    Left = 4
    Top = 190
    Width = 611
    Height = 290
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 5
    object reFoundFiles: TListBox
      Left = 2
      Top = 15
      Width = 607
      Height = 273
      Align = alClient
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object btnCancel: TButton
    Left = 350
    Top = 160
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = '&Cancel'
    Enabled = False
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 484
    Width = 620
    Height = 19
    Panels = <
      item
        Text = 'Ready'
        Width = 50
      end>
  end
  object chkClearList: TCheckBox
    Left = 24
    Top = 152
    Width = 134
    Height = 17
    Caption = 'C&lear list before search'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object chkNoDupes: TCheckBox
    Left = 24
    Top = 171
    Width = 134
    Height = 17
    Caption = 'Skip d&uplicates'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object btnExit: TButton
    Left = 534
    Top = 160
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = 'Exit'
    TabOrder = 7
    OnClick = btnExitClick
  end
  object btnLocateFile: TButton
    Left = 438
    Top = 160
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = 'Locate File'
    TabOrder = 8
    OnClick = btnLocateFileClick
  end
end
