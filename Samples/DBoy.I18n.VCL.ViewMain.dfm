inherited FrmViewMain: TFrmViewMain
  Caption = 'FrmViewMain'
  ClientHeight = 500
  ClientWidth = 600
  Menu = MainMenu
  StyleElements = [seFont, seClient, seBorder]
  OnCreate = FormCreate
  ExplicitWidth = 616
  ExplicitHeight = 559
  TextHeight = 15
  inherited lblLocale: TLabel
    Top = 485
    Width = 600
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 485
  end
  object GroupBoxMain: TGroupBox
    Left = 0
    Top = 0
    Width = 600
    Height = 485
    Align = alClient
    Caption = 'GroupBoxMain'
    TabOrder = 0
    object ListBoxEntity: TListBox
      Left = 2
      Top = 368
      Width = 596
      Height = 115
      Align = alBottom
      ItemHeight = 15
      TabOrder = 0
    end
    inline FraEntityMain: TFraEntity
      Left = 2
      Top = 17
      Width = 596
      Height = 40
      Align = alTop
      TabOrder = 1
      ExplicitLeft = 2
      ExplicitTop = 17
      ExplicitWidth = 596
      inherited lblEntity: TLabel
        Height = 34
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited edtEntity: TEdit
        Width = 399
        StyleElements = [seFont, seClient, seBorder]
        ExplicitLeft = 52
        ExplicitWidth = 399
      end
      inherited btnPost: TButton
        Left = 457
        OnClick = FraEntityMainbtnPostClick
        ExplicitLeft = 457
      end
      inherited btnDelete: TButton
        Left = 528
        ExplicitLeft = 528
      end
    end
    object DBGrid1: TDBGrid
      AlignWithMargins = True
      Left = 5
      Top = 60
      Width = 590
      Height = 305
      Align = alClient
      DataSource = dsEntity
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object ActionList: TActionList
    Images = ImageList
    Left = 240
    Top = 120
    object actNewEntity: TAction
      Caption = 'actNewEntity'
      OnExecute = actNewEntityExecute
    end
  end
  object MainMenu: TMainMenu
    Images = ImageList
    Left = 320
    Top = 120
    object mItemApp: TMenuItem
      Caption = 'mItemApp'
      object mItemactNewEntity: TMenuItem
        Action = actNewEntity
      end
    end
    object mItemLocale: TMenuItem
      Caption = 'mItemLocale'
    end
    object mItemClose: TMenuItem
      Caption = 'mItemClose'
      OnClick = mItemCloseClick
    end
  end
  object ImageList: TImageList
    ColorDepth = cd32Bit
    Left = 160
    Top = 120
  end
  object dsEntity: TDataSource
    Left = 240
    Top = 184
  end
end
