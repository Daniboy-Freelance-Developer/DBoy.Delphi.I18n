inherited DMData: TDMData
  OnCreate = DataModuleCreate
  Height = 325
  Width = 354
  object tabEntity: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 72
    Top = 72
    object tabEntityID: TIntegerField
      FieldName = 'ID'
    end
    object tabEntityEntity_Name: TStringField
      FieldName = 'Entity_Name'
      Size = 50
    end
  end
end
