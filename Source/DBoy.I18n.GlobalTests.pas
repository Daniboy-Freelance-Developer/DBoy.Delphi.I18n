unit DBoy.I18n.GlobalTests;

interface
  /// <summary>
  ///   Controle para Criação visual dos TFrom e TDataModule sem conxeção com dados
  ///  e outros recursos que são forem exclusivamente visual para Extração do Componentes
  ///  para tradução e geração do JSON.
  /// en: Control for visual creation of TForm and TDataModule without data connection
  /// en: and other features that are exclusively visual for component extraction    
  /// en: for translation and JSON generation.
  /// </summary>
  function DBoyI18nGlobalTests: boolean;

  procedure StartDBoyI18nGlobalTests;
  procedure StopDBoyI18nGlobalTests;

implementation

var
  GDBoyI18nGlobalTests: boolean = False;

function DBoyI18nGlobalTests: boolean;
begin
  Result := GDBoyI18nGlobalTests;
end;

procedure StartDBoyI18nGlobalTests;
begin
  GDBoyI18nGlobalTests := True;
end;

procedure StopDBoyI18nGlobalTests;
begin
  GDBoyI18nGlobalTests := False;
end;

end.
