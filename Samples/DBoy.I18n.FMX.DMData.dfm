inherited DMData: TDMData
  OnCreate = DataModuleCreate
  object tabEntity: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 56
    Top = 32
    object tabEntityID: TIntegerField
      FieldName = 'ID'
    end
    object tabEntityEntity_Name: TStringField
      FieldName = 'Entity_Name'
      Size = 50
    end
  end
end
