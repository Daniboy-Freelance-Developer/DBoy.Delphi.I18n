unit DBoy.I18n.LanguageMenu;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Types,
  System.JSON, DBoy.I18n.Engine
  {$IFDEF VCL}
  , Vcl.Menus, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.Controls
  {$ELSE}
  , FMX.Menus, FMX.Forms, FMX.Dialogs, FMX.ImgList
  {$ENDIF}
  ;

type
  {$IFDEF VCL}
  TDBoyLanguageMenuItem = class(TMenuItem)
  public
    FilePath: string;
  end;
  {$ENDIF}

  TDBoyI18nLanguageMenuBuilder = class
  private
    class function GetMainMenu(const AMenuItem: TMenuItem): TMainMenu;
    class function GetImageList(const AMenuItem: TMenuItem): TImageList;
    class procedure OnLanguageItemClick(Sender: TObject);
    class function GetLanguageDisplayName(const AFilePath: string; out ALocale, AIcon: string): string;
  public
    // Popula um TMenuItem pai com os idiomas encontrados na pasta
    // en: Populates a parent TMenuItem with the languages found in the folder
    class procedure BuildLanguageMenu(AParentMenuItem: TMenuItem; const ALanguagesFolder: string = '');
  end;

implementation

uses
  {$IFDEF VCL}
  Winapi.Windows,
  {$ELSE}
  FMX.Types,
  {$ENDIF}
  DBoy.I18n.ImageListLoader;

{ TDBoyI18nLanguageMenuBuilder }

class function TDBoyI18nLanguageMenuBuilder.GetImageList(
  const AMenuItem: TMenuItem): TImageList;
var
  LMainMenu: TMainMenu;
begin
  LMainMenu := GetMainMenu(AMenuItem);
  if Assigned(LMainMenu) then
    Result := LMainMenu.Images as TImageList
  else
    Result := nil;
end;

class function TDBoyI18nLanguageMenuBuilder.GetLanguageDisplayName(const AFilePath: string; out ALocale, AIcon: string): string;
var
  JsonContent: string;
  RootVal: TJSONValue;
  RootObj: TJSONObject;
begin
  // Fallback padrão: usa o nome do próprio arquivo
  // en: Default fallback: uses the file name itself
  ALocale := TPath.GetFileNameWithoutExtension(AFilePath);
  Result := ALocale;

  try
    JsonContent := TFile.ReadAllText(AFilePath, TEncoding.UTF8);
    RootVal := TJSONObject.ParseJSONValue(JsonContent);
    if Assigned(RootVal) and (RootVal is TJSONObject) then
    try
      RootObj := TJSONObject(RootVal);

      if RootObj.Values['locale'] <> nil then
        ALocale := RootObj.Values['locale'].Value;

      // Pega o nome amigável para exibição no Menu
      // en: Gets the friendly name for display in the Menu
      if RootObj.Values['languageName'] <> nil then
        Result := RootObj.Values['languageName'].Value
      else
        Result := ALocale;

      // Pega o nome icon para Menu
      // en: Gets the icon name for the Menu
      if RootObj.Values['iconName'] <> nil then
        AIcon := RootObj.Values['iconName'].Value
      else
        AIcon := ALocale;
    finally
      RootVal.Free;
    end;
  except
    // Caso o JSON esteja malformado, mantém o nome do arquivo
    // en: If JSON is malformed, keeps the file name
  end;
end;

class function TDBoyI18nLanguageMenuBuilder.GetMainMenu(
  const AMenuItem: TMenuItem): TMainMenu;
begin
  Result := nil;
  if AMenuItem = nil then Exit;

  {$IFDEF VCL}
  if AMenuItem.GetParentMenu is TMainMenu then
    Result := TMainMenu(AMenuItem.GetParentMenu);
  {$ELSE}
  var LParent: TFmxObject;
  LParent := AMenuItem.Parent;

  // Sobe na hierarquia enquanto o pai for outro item de menu
  // en: Goes up the hierarchy as long as the parent is another menu item
  while (LParent <> nil) and not (LParent is TMainMenu) do
  begin
    if LParent is TMenuItem then
      LParent := TMenuItem(LParent).Parent
    else
      Break; // Para caso encontre outro tipo de container (Ex: TPopupMenu)
      // en: In case it finds another type of container (e.g. TPopupMenu)
  end;

  // Se o loop parou em um TMainMenu, encontramos o pai!
  // en: If the loop stopped at a TMainMenu, we found the parent!
  if (LParent <> nil) and (LParent is TMainMenu) then
    Result := TMainMenu(LParent);
  {$ENDIF}
end;

class procedure TDBoyI18nLanguageMenuBuilder.OnLanguageItemClick(Sender: TObject);
var
  FilePath: string;
begin
  {$IFDEF VCL}
  if not (Sender is TDBoyLanguageMenuItem) then
    Exit;
  FilePath := TDBoyLanguageMenuItem(Sender).FilePath;
  {$ELSE}
  if not (Sender is TMenuItem) then
    Exit;
  FilePath := TMenuItem(Sender).TagString; // Caminho completo do arquivo JSON
  // en: Full path of the JSON file
  {$ENDIF}

  if TFile.Exists(FilePath) then
  begin
    if TDBoyI18nEngine.LoadFromFile(FilePath) then
    begin
      {$IFDEF VCL}
      TMenuItem(Sender).Checked := True;
      {$ELSE}
      TMenuItem(Sender).IsChecked := True;
      {$ENDIF}
      TDBoyI18nEngine.NotifyLanguageChanged;
    end
    else
      ShowMessage('Erro ao carregar o arquivo de idioma: ' + FilePath);
  end;
end;

class procedure TDBoyI18nLanguageMenuBuilder.BuildLanguageMenu(AParentMenuItem: TMenuItem; const ALanguagesFolder: string);
var
  TargetFolder, FilePath, DisplayName, Locale, Icon: string;
  Files: TStringDynArray;
  {$IFDEF VCL}
  NewItem: TDBoyLanguageMenuItem;
  {$ELSE}
  NewItem: TMenuItem;
  {$ENDIF}
  LImageList: TImageList;
begin
  if not Assigned(AParentMenuItem) then
    Exit;

  // Limpa itens anteriores para permitir atualização dinâmica
  // en: Clears previous items to allow dynamic updating
  AParentMenuItem.Clear;

  // Define o diretório (padrão: [AppPath]/Languages)
  // en: Sets the directory (default: [AppPath]/Languages)
  if ALanguagesFolder.IsEmpty then
    TargetFolder := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Languages')
  else
    TargetFolder := ALanguagesFolder;

  if not TDirectory.Exists(TargetFolder) then
    Exit;

  LImageList := GetImageList(AParentMenuItem);

  // Busca todos os arquivos .json na pasta
  // en: Searches for all .json files in the folder
  Files := TDirectory.GetFiles(TargetFolder, '*.json');

  for FilePath in Files do
  begin
    DisplayName := GetLanguageDisplayName(FilePath, Locale, Icon);

    {$IFDEF VCL}
    NewItem := TDBoyLanguageMenuItem.Create(AParentMenuItem);
    NewItem.Caption := DisplayName;
    NewItem.FilePath := FilePath;
    NewItem.RadioItem := True;
    NewItem.GroupIndex := 118;
    NewItem.OnClick := OnLanguageItemClick;
    {$ELSE}
    // Cria o TMenuItem no padrão FMX
    // en: Creates the TMenuItem in FMX pattern
    NewItem := TMenuItem.Create(AParentMenuItem);
    NewItem.Text := DisplayName;
    NewItem.TagString := FilePath; // Armazena o caminho completo do arquivo
    // en: Stores the full path of the file
    NewItem.AutoCheck := True;
    NewItem.RadioItem := True;
    NewItem.GroupIndex := 118;     // Comportamento estilo RadioButton
    // en: RadioButton-style behavior
    NewItem.OnClick := OnLanguageItemClick;
    {$ENDIF}

    if Assigned(LImageList) then
    begin
      NewItem.ImageIndex := LImageList.IndexByName(Icon);
    end;

    // Marca como checado se for o idioma atualmente ativo
    // en: Marks as checked if it is the currently active language
    if SameText(Locale, TDBoyI18nEngine.CurrentLocale) or
       SameText(TPath.GetFileNameWithoutExtension(FilePath), TDBoyI18nEngine.CurrentLocale) then
    begin
      {$IFDEF VCL}
      NewItem.Checked := True;
      {$ELSE}
      NewItem.IsChecked := True;
      {$ENDIF}
    end;

    {$IFDEF VCL}
    AParentMenuItem.Add(NewItem);
    {$ELSE}
    AParentMenuItem.AddObject(NewItem);
    {$ENDIF}
  end;
end;

end.
