inherited FraEntity: TFraEntity
  Width = 640
  Height = 40
  ExplicitWidth = 640
  ExplicitHeight = 40
  object lblEntity: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 43
    Height = 34
    Align = alLeft
    Caption = 'lblEntity'
    Layout = tlCenter
    ExplicitHeight = 15
  end
  object edtEntity: TEdit
    AlignWithMargins = True
    Left = 52
    Top = 3
    Width = 443
    Height = 34
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 55
    ExplicitWidth = 440
    ExplicitHeight = 23
  end
  object btnPost: TButton
    AlignWithMargins = True
    Left = 501
    Top = 3
    Width = 65
    Height = 34
    Align = alRight
    Caption = 'btnPost'
    TabOrder = 1
  end
  object btnDelete: TButton
    AlignWithMargins = True
    Left = 572
    Top = 3
    Width = 65
    Height = 34
    Align = alRight
    Caption = 'btnDelete'
    TabOrder = 2
    OnClick = btnDeleteClick
  end
end
