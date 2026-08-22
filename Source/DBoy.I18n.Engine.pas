unit DBoy.I18n.Engine;

interface

uses
  System.SysUtils, System.Classes, System.Rtti, System.TypInfo,
  System.Generics.Collections, System.JSON, System.IOUtils,
  System.Messaging
  {$IFDEF MSWINDOWS}
  , Winapi.Windows
  {$ENDIF}
  ;

type
  TDBoyI18nEngine = class
  private
    class var FResStringRegistry: TDictionary<string, PResStringRec>;
    class var FDictionary: TDictionary<string, string>;
    class var FCurrentLocale: string;
    class var FTranslatableProperties: TList<string>;

    // Modifica o ponteiro da resourcestring em memória (32 e 64-bit)
    // en: Modifies the resourcestring pointer in memory (32 and 64-bit)
    class procedure HookResourceString(OldStr: PResStringRec; const NewStr: string);
    class procedure ParseJsonObject(AJsonObj: TJSONObject; const APrefix: string = '');
    class function GetTranslation(const AKey: string; out ATranslated: string): Boolean;
    class procedure TranslateObject(AObj: TObject; const APrefix: string = '');
  public

    class constructor Create;
    class destructor Destroy;

    // Gerenciamento de propriedades traduzíveis
    // en: Management of translatable properties
    class procedure RegisterTranslatableProperty(const APropName: string);
    class function IsTranslatableProperty(const APropName: string): Boolean;

    // Registro das resourcestring
    // en: Registration of resourcestrings
    class procedure RegisterResString(const AKey: string; AResRec: PResStringRec);

    // Carregador e aplicador
    // en: Loader and applier
    class function LoadFromFile(const AFilePath: string): Boolean;
    class function LoadFromString(const AJsonContent: string): Boolean;

    class procedure NotifyLanguageChanged;

    // Tradução de componentes visuais (VCL / FMX)
    // en: Translation of visual components (VCL / FMX)
    class procedure Translate(AInstance: TComponent);

    class property CurrentLocale: string read FCurrentLocale;

    class function ResStringRegistry: TDictionary<string, PResStringRec>;
  end;

  TLanguageChangedMessage = class(TMessage<string>);

implementation

uses
  DBoy.I18n.Messages;

{ TDBoyI18nEngine }

class constructor TDBoyI18nEngine.Create;
begin
  FResStringRegistry := TDictionary<string, PResStringRec>.Create;
  FDictionary := TDictionary<string, string>.Create;
  FTranslatableProperties := TList<string>.Create;
  FCurrentLocale := '';

  // Propriedades padrão
  // en: Default properties
  FTranslatableProperties.Add('Caption');
  FTranslatableProperties.Add('Text');
  FTranslatableProperties.Add('Hint');
  FTranslatableProperties.Add('HelpText');
end;

class destructor TDBoyI18nEngine.Destroy;
begin
  FResStringRegistry.Free;
  FDictionary.Free;
  FTranslatableProperties.Free;
end;

class procedure TDBoyI18nEngine.RegisterTranslatableProperty(const APropName: string);
begin
  if not IsTranslatableProperty(APropName) then
    FTranslatableProperties.Add(APropName);
end;

class function TDBoyI18nEngine.IsTranslatableProperty(const APropName: string): Boolean;
var
  Prop: string;
begin
  Result := False;
  for Prop in FTranslatableProperties do
  begin
    if SameText(Prop, APropName) then
      Exit(True);
  end;
end;

class procedure TDBoyI18nEngine.RegisterResString(const AKey: string; AResRec: PResStringRec);
begin
  FResStringRegistry.AddOrSetValue(AKey.ToLower, AResRec);
end;

class function TDBoyI18nEngine.ResStringRegistry: TDictionary<string, PResStringRec>;
begin
  Result := FResStringRegistry;
end;

class procedure TDBoyI18nEngine.HookResourceString(OldStr: PResStringRec; const NewStr: string);
{$IFDEF MSWINDOWS}
var
  OldProtect: DWORD;
  P: Pointer;
begin
  // Validação segura para 32-bit e 64-bit
  // en: Safe validation for 32-bit and 64-bit
  if (OldStr = nil) or (OldStr.Module = nil) then
    Exit;

  P := @OldStr.Identifier; // Endereço onde o ID ou ponteiro da string reside
  // en: Address where the string ID or pointer resides

  if VirtualProtect(P, SizeOf(Pointer), PAGE_EXECUTE_READWRITE, @OldProtect) then
  try
    // Sobrescreve o identificador/ponteiro com o endereço do PChar do novo texto
    // en: Overwrites the identifier/pointer with the PChar address of the new text
    // (A string NewStr deve permanecer alocada na memória)
    // en: (The NewStr string must remain allocated in memory)
    PPointer(P)^ := PChar(NewStr);
  finally
    VirtualProtect(P, SizeOf(Pointer), OldProtect, @OldProtect);
  end;
end;
{$ELSE}
begin
  // Hooking resource strings is only supported on Windows
end;
{$ENDIF}

class procedure TDBoyI18nEngine.ParseJsonObject(AJsonObj: TJSONObject; const APrefix: string);
var
  Pair: TJSONPair;
  Key, RawKey: string;
  ResRec: PResStringRec;
begin
  if not Assigned(AJsonObj) then
    Exit;

  for Pair in AJsonObj do
  begin
    RawKey := Pair.JsonString.Value;
    if APrefix.IsEmpty then
      Key := RawKey
    else
      Key := APrefix + '.' + RawKey;

    if Pair.JsonValue is TJSONObject then
      ParseJsonObject(TJSONObject(Pair.JsonValue), Key)
    else if Pair.JsonValue is TJSONString then
    begin
      // Guarda no dicionário comum para RTTI
      // en: Stores in the common dictionary for RTTI
      FDictionary.AddOrSetValue(Key.ToLower, Pair.JsonValue.Value);

      // Se pertencer à seção General, executa o Hook na resourcestring
      // en: If it belongs to the General section, hooks the resourcestring
      if SameText(APrefix, 'General') then
      begin
        if FResStringRegistry.TryGetValue(RawKey.ToLower, ResRec) then
          HookResourceString(ResRec, Pair.JsonValue.Value);
      end;
    end;
  end;
end;

class function TDBoyI18nEngine.LoadFromString(const AJsonContent: string): Boolean;
var
  RootVal: TJSONValue;
  RootObj, TransObj: TJSONObject;
begin
  Result := False;
  RootVal := TJSONObject.ParseJSONValue(AJsonContent);
  if not Assigned(RootVal) then
    Exit;

  try
    if not (RootVal is TJSONObject) then
      Exit;

    RootObj := TJSONObject(RootVal);
    if RootObj.Values['locale'] <> nil then
      FCurrentLocale := RootObj.Values['locale'].Value;

    FDictionary.Clear;

    if RootObj.Values['translations'] is TJSONObject then
      TransObj := TJSONObject(RootObj.Values['translations'])
    else
      TransObj := RootObj;

    ParseJsonObject(TransObj, '');
    Result := True;

    // Dispara notificação no barramento global
    // en: Triggers notification on the global bus
    TMessageManager.DefaultManager.SendMessage(nil, TLanguageChangedMessage.Create(FCurrentLocale));
  finally
    RootVal.Free;
  end;
end;

class procedure TDBoyI18nEngine.NotifyLanguageChanged;
begin
  BroadcastLanguageChange(CurrentLocale);
end;

class function TDBoyI18nEngine.LoadFromFile(const AFilePath: string): Boolean;
var
  Content: string;
begin
  Result := False;
  if not TFile.Exists(AFilePath) then
    Exit;

  Content := TFile.ReadAllText(AFilePath, TEncoding.UTF8);
  Result := LoadFromString(Content);
end;

class function TDBoyI18nEngine.GetTranslation(const AKey: string; out ATranslated: string): Boolean;
begin
  Result := FDictionary.TryGetValue(AKey.ToLower, ATranslated);
end;

class procedure TDBoyI18nEngine.TranslateObject(AObj: TObject; const APrefix: string);
var
  Ctx: TRttiContext;
  RttiType: TRttiType;
  Prop: TRttiProperty;
  CurVal, NewVal, TranslationKey: string;
  I: Integer;
  ChildComp: TComponent;
begin
  if not Assigned(AObj) then
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
        if IsTranslatableProperty(Prop.Name) then
        begin
          CurVal := Prop.GetValue(AObj).AsString;
          TranslationKey := APrefix + '.' + Prop.Name;

          if GetTranslation(TranslationKey, NewVal) or
             GetTranslation('general.' + CurVal, NewVal) or
             GetTranslation(CurVal, NewVal) then
          begin
            Prop.SetValue(AObj, NewVal);
          end;
        end;
      end;
    end;
  finally
    Ctx.Free;
  end;

  if AObj is TComponent then
  begin
    for I := 0 to TComponent(AObj).ComponentCount - 1 do
    begin
      ChildComp := TComponent(AObj).Components[I];
      TranslateObject(ChildComp, APrefix + '.' + ChildComp.Name);
    end;
  end;
end;

class procedure TDBoyI18nEngine.Translate(AInstance: TComponent);
begin
  if not Assigned(AInstance) then
    Exit;

  TranslateObject(AInstance, AInstance.ClassName);
end;

end.
