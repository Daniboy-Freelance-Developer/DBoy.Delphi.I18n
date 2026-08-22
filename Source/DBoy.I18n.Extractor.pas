unit DBoy.I18n.Extractor;

interface

uses
  System.SysUtils, System.Classes, System.Rtti, System.TypInfo,
  System.Generics.Collections, System.JSON, System.IOUtils,
  DBoy.I18n.Engine;

type
  TComponentClass = class of TComponent;

  TI18nExtractor = class
  private
    class var FFormClasses: TList<TComponentClass>;
    class procedure ExtractFromObject(AObj: TObject; AJsonObj: TJSONObject; const APrefix: string = '');
  public
    class constructor Create;
    class destructor Destroy;

    // Registra as classes de tela a serem inspecionadas
    // en: Registers the screen classes to be inspected
    class procedure RegisterClass(AClass: TComponentClass);
    class procedure RegisterClasses(const AClasses: array of TComponentClass);

    // Gera a árvore JSON completa
    // en: Generates the complete JSON tree
    class function GenerateJson(const ALocale: string = 'pt_BR'; const ALanguageName: string = 'Português (Brasil)'): TJSONObject;

    // Salva o JSON base diretamente em disco
    // en: Saves the base JSON directly to disk
    class procedure ExportToFile(const AFilePath: string; const ALocale: string = 'pt_BR'; const ALanguageName: string = 'Português (Brasil)');
  end;

implementation

{ TI18nExtractor }

class constructor TI18nExtractor.Create;
begin
  FFormClasses := TList<TComponentClass>.Create;
end;

class destructor TI18nExtractor.Destroy;
begin
  FFormClasses.Free;
end;

class procedure TI18nExtractor.RegisterClass(AClass: TComponentClass);
begin
  if not FFormClasses.Contains(AClass) then
    FFormClasses.Add(AClass);
end;

class procedure TI18nExtractor.RegisterClasses(const AClasses: array of TComponentClass);
var
  Cls: TComponentClass;
begin
  for Cls in AClasses do
    RegisterClass(Cls);
end;

class procedure TI18nExtractor.ExtractFromObject(AObj: TObject; AJsonObj: TJSONObject; const APrefix: string);
var
  Ctx: TRttiContext;
  RttiType: TRttiType;
  Prop: TRttiProperty;
  CurVal, PropKey: string;
  I: Integer;
  ChildComp: TComponent;
begin
  if (AObj = nil) or (AJsonObj = nil) then
    Exit;

  Ctx := TRttiContext.Create;
  try
    RttiType := Ctx.GetType(AObj.ClassType);
    if not Assigned(RttiType) then
      Exit;

    for Prop in RttiType.GetProperties do
    begin
      if (Prop.Visibility in [mvPublic, mvPublished]) and
         (Prop.PropertyType.TypeKind in [tkUString, tkString, tkWString]) and
         Prop.IsWritable then
      begin
        if TDBoyI18nEngine.IsTranslatableProperty(Prop.Name) then
        begin
          CurVal := Prop.GetValue(AObj).AsString.Trim;

          // Extrai apenas textos não vazios e ignora nomes de componentes autogerados
          // en: Extracts only non-empty texts and ignores auto-generated component names
          if not CurVal.IsEmpty and not SameText(CurVal, AObj.ClassName) then
          begin
            if APrefix.IsEmpty then
              PropKey := Prop.Name
            else
              PropKey := APrefix + '.' + Prop.Name;

            // Adiciona no nó do JSON se ainda não existir
            // en: Adds to the JSON node if it does not exist yet
            if AJsonObj.Values[PropKey] = nil then
              AJsonObj.AddPair(PropKey, CurVal);
          end;
        end;
      end;
    end;
  finally
    Ctx.Free;
  end;

  // Varre componentes filhos (Buttons, Edits, Panels, Labels, etc.)
  // en: Scans child components (Buttons, Edits, Panels, Labels, etc.)
  if AObj is TComponent then
  begin
    for I := 0 to TComponent(AObj).ComponentCount - 1 do
    begin
      ChildComp := TComponent(AObj).Components[I];
      var LName: string := ChildComp.Name;
      if not LName.IsEmpty then
        ExtractFromObject(ChildComp, AJsonObj, ChildComp.Name);
    end;
  end;
end;

class function TI18nExtractor.GenerateJson(const ALocale, ALanguageName: string): TJSONObject;
var
  RootObj, TransObj, GeneralObj, FormObj: TJSONObject;
  Cls: TComponentClass;
  Instance: TComponent;
  ResKey: string;
  ResRec: PResStringRec;
  LRaiseSilent: boolean;
begin
  RootObj := TJSONObject.Create;
  RootObj.AddPair('locale', ALocale);
  RootObj.AddPair('languageName', ALanguageName);

  TransObj := TJSONObject.Create;
  RootObj.AddPair('translations', TransObj);

  // 1. Exporta todas as resourcestrings cadastradas no Engine sob "General"
  // en: 1. Exports all registered resourcestrings in the Engine under "General"
  GeneralObj := TJSONObject.Create;
  for ResKey in TDBoyI18nEngine.ResStringRegistry.Keys do
  begin
    ResRec := TDBoyI18nEngine.ResStringRegistry[ResKey];
    GeneralObj.AddPair(ResKey, LoadResString(ResRec));
  end;
  TransObj.AddPair('General', GeneralObj);

  // 2. Instancia cada formulário/frame em memória para ler a árvore visual
  // en: 2. Instantiates each form/frame in memory to read the visual tree
  for Cls in FFormClasses do
  begin
    FormObj := TJSONObject.Create;
    LRaiseSilent := True;
    try
      try
        // Cria a instância sem Owner (não visível)
        // en: Creates the instance without Owner (not visible)
        Instance := Cls.Create(nil);
        try
          ExtractFromObject(Instance, FormObj, '');
        finally
          Instance.Free;
        end;

        if FormObj.Count > 0 then
          TransObj.AddPair(Cls.ClassName, FormObj)
        else
          FormObj.Free;

        LRaiseSilent := False;
      except
        on E: Exception do
        begin
          System.Writeln('Error creating instance of ' + Cls.ClassName + ': ' + E.ClassName + ' - ' + E.Message);
          FormObj.Free;
          LRaiseSilent := False;
        end;
      end;
    finally
      if LRaiseSilent then
      begin
        System.Writeln('Error creating instance of ' + Cls.ClassName + ': Error occurred without going through the try-except block; class not processed.');
        FormObj.Free;
      end;
    end;
  end;

  Result := RootObj;
end;

class procedure TI18nExtractor.ExportToFile(const AFilePath, ALocale, ALanguageName: string);
var
  JsonObj: TJSONObject;
  FormattedJson: string;
begin
  JsonObj := GenerateJson(ALocale, ALanguageName);
  try
    FormattedJson := JsonObj.Format(2); // Indentação de 2 espaços
    // en: 2-space indentation
    TFile.WriteAllText(AFilePath, FormattedJson, TEncoding.UTF8);
  finally
    JsonObj.Free;
  end;
end;

end.
