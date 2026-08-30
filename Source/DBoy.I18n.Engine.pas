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
    class var FOriginalResStringIdentifiers: TDictionary<PResStringRec, NativeUInt>;
    class var FHookedStrings: TDictionary<PResStringRec, string>;
    class var FDictionary: TDictionary<string, string>;
    class var FCurrentLocale: string;
    class var FTranslatableProperties: TList<string>;

    // Modifica o ponteiro da resourcestring em memória (32 e 64-bit) de forma segura
    // en: Modifies the resourcestring pointer in memory (32 and 64-bit) safely
    class procedure HookResourceString(OldStr: PResStringRec; const NewStr: string);
    class procedure UnhookAllResourceStrings;
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

    // Limpeza e redefinição para o estado padrão
    // en: Clearing and resetting to default state
    class procedure Clear;
    class procedure Reset;

    class procedure NotifyLanguageChanged;

    // Tradução de componentes visuais (VCL / FMX)
    // en: Translation of visual components (VCL / FMX)
    class procedure Translate(AInstance: TComponent);

    class property CurrentLocale: string read FCurrentLocale;

    class function ResStringRegistry: TDictionary<string, PResStringRec>;
    class function DictionaryCount: Integer;
  end;

  TLanguageChangedMessage = class(TMessage<string>);

implementation

uses
  DBoy.I18n.Messages;

{ TDBoyI18nEngine }

class constructor TDBoyI18nEngine.Create;
begin
  FResStringRegistry := TDictionary<string, PResStringRec>.Create;
  FOriginalResStringIdentifiers := TDictionary<PResStringRec, NativeUInt>.Create;
  FHookedStrings := TDictionary<PResStringRec, string>.Create;
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
  UnhookAllResourceStrings;
  FResStringRegistry.Free;
  FOriginalResStringIdentifiers.Free;
  FHookedStrings.Free;
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
  if AResRec <> nil then
  begin
    FResStringRegistry.AddOrSetValue(AKey.ToLower, AResRec);
    if not FOriginalResStringIdentifiers.ContainsKey(AResRec) then
      FOriginalResStringIdentifiers.Add(AResRec, AResRec.Identifier);
  end;
end;

class function TDBoyI18nEngine.ResStringRegistry: TDictionary<string, PResStringRec>;
begin
  Result := FResStringRegistry;
end;

class function TDBoyI18nEngine.DictionaryCount: Integer;
begin
  if Assigned(FDictionary) then
    Result := FDictionary.Count
  else
    Result := 0;
end;

class procedure TDBoyI18nEngine.UnhookAllResourceStrings;
{$IFDEF MSWINDOWS}
var
  OldProtect: DWORD;
  P: Pointer;
  Pair: TPair<PResStringRec, NativeUInt>;
  ResRec: PResStringRec;
  OrigId: NativeUInt;
begin
  if FOriginalResStringIdentifiers = nil then
    Exit;

  for Pair in FOriginalResStringIdentifiers do
  begin
    ResRec := Pair.Key;
    OrigId := Pair.Value;
    if (ResRec <> nil) and (ResRec.Module <> nil) then
    begin
      P := @ResRec.Identifier;
      if VirtualProtect(P, SizeOf(Pointer), PAGE_EXECUTE_READWRITE, @OldProtect) then
      try
        PPointer(P)^ := Pointer(OrigId);
      finally
        VirtualProtect(P, SizeOf(Pointer), OldProtect, @OldProtect);
      end;
    end;
  end;

  if FHookedStrings <> nil then
    FHookedStrings.Clear;
end;
{$ELSE}
begin
  // Hooking resource strings is only supported on Windows
end;
{$ENDIF}

class procedure TDBoyI18nEngine.HookResourceString(OldStr: PResStringRec; const NewStr: string);
{$IFDEF MSWINDOWS}
var
  OldProtect: DWORD;
  P: Pointer;
  LStoredStr: string;
begin
  // Validação segura para 32-bit e 64-bit
  // en: Safe validation for 32-bit and 64-bit
  if (OldStr = nil) or (OldStr.Module = nil) then
    Exit;

  // Preserva o identificador original nativo antes de aplicar o hook
  // en: Preserves original native identifier before applying hook
  if not FOriginalResStringIdentifiers.ContainsKey(OldStr) then
    FOriginalResStringIdentifiers.Add(OldStr, OldStr.Identifier);

  // Mantém a string permanentemente alocada na memória com refcount ativo
  // en: Keeps the string permanently allocated in memory with active refcount
  FHookedStrings.AddOrSetValue(OldStr, NewStr);
  LStoredStr := FHookedStrings[OldStr];

  P := @OldStr.Identifier; // Endereço onde o ID ou ponteiro da string reside
  // en: Address where the string ID or pointer resides

  if VirtualProtect(P, SizeOf(Pointer), PAGE_EXECUTE_READWRITE, @OldProtect) then
  try
    // Sobrescreve o identificador/ponteiro com o endereço do PChar do novo texto
    // en: Overwrites the identifier/pointer with the PChar address of the new text
    PPointer(P)^ := PChar(LStoredStr);
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

class procedure TDBoyI18nEngine.Clear;
begin
  UnhookAllResourceStrings;
  if Assigned(FDictionary) then
    FDictionary.Clear;
  FCurrentLocale := '';
end;

class procedure TDBoyI18nEngine.Reset;
begin
  Clear;
  NotifyLanguageChanged;
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

    // Restaura hooks anteriores e limpa o dicionário antes de carregar novo idioma
    // en: Restores previous hooks and clears dictionary before loading new language
    UnhookAllResourceStrings;
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
  if (not Assigned(AObj)) or (FDictionary = nil) or (FDictionary.Count = 0) then
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
             (not CurVal.Trim.IsEmpty and (GetTranslation('general.' + CurVal, NewVal) or GetTranslation(CurVal, NewVal))) then
          begin
            if not NewVal.IsEmpty then
              Prop.SetValue(AObj, TValue.From<string>(NewVal));
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
      var LName: string := ChildComp.Name;
      if not LName.IsEmpty then
        TranslateObject(ChildComp, APrefix + '.' + LName);
    end;
  end;
end;

class procedure TDBoyI18nEngine.Translate(AInstance: TComponent);
begin
  // Bypass Total: Se o dicionário estiver vazio ou não carregado, aborta imediatamente
  // en: Total Bypass: If dictionary is empty or not loaded, aborts immediately
  if (not Assigned(AInstance)) or (FDictionary = nil) or (FDictionary.Count = 0) then
    Exit;

  TranslateObject(AInstance, AInstance.ClassName);
end;

end.