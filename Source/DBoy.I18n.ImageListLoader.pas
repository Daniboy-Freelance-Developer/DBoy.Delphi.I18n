unit DBoy.I18n.ImageListLoader;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Types, System.UITypes,
  System.Generics.Collections
  {$IFDEF VCL}
  , Vcl.ImgList, Vcl.Graphics, Vcl.Controls
  {$ELSE}
  , FMX.ImgList, FMX.Graphics, FMX.MultiResBitmap
  {$ENDIF}
  ;



type
  TImageListLoader = class
  private
    {$IFDEF VCL}
    class var FNamesMap: TDictionary<TImageList, TDictionary<string, Integer>>;
    {$ENDIF}
  public
    {$IFDEF VCL}
    class constructor Create;
    class destructor Destroy;
    class function GetIndexByName(AImageList: TImageList; const AImageName: string): Integer;
    {$ENDIF}

    class procedure LoadFromFolder(
      {$IFDEF VCL}AImageList: Vcl.Controls.TImageList;{$ELSE}AImageList: FMX.ImgList.TImageList;{$ENDIF}
      const AFolderPath: string;
      const AClearExisting: Boolean = True
    );
  end;

  TImageListHelper = class helper for TImageList
  public
    // Retorna o índice no Destination pelo nome do arquivo/source, ou -1 se não encontrar
    // en: Returns the index in Destination by file/source name, or -1 if not found
    function IndexByName(const AImageName: string): Integer;
  end;

implementation

{ TImageListLoader }

{$IFDEF VCL}
class constructor TImageListLoader.Create;
begin
  FNamesMap := TDictionary<TImageList, TDictionary<string, Integer>>.Create;
end;

class destructor TImageListLoader.Destroy;
var
  Pair: TPair<TImageList, TDictionary<string, Integer>>;
begin
  for Pair in FNamesMap do
    Pair.Value.Free;
  FNamesMap.Free;
end;

class function TImageListLoader.GetIndexByName(AImageList: TImageList; const AImageName: string): Integer;
var
  Dict: TDictionary<string, Integer>;
begin
  Result := -1;
  if FNamesMap.TryGetValue(AImageList, Dict) then
  begin
    if not Dict.TryGetValue(AImageName.ToLower, Result) then
      Result := -1;
  end;
end;
{$ENDIF}

class procedure TImageListLoader.LoadFromFolder(
  {$IFDEF VCL}AImageList: Vcl.Controls.TImageList;{$ELSE}AImageList: FMX.ImgList.TImageList;{$ENDIF}
  const AFolderPath: string;
  const AClearExisting: Boolean
);
var
  Files: TStringDynArray;
  FilePath, ItemName, Ext: string;
  {$IFDEF VCL}
  LImage: TWICImage;
  LBitmap: TBitmap;
  LIcon: TIcon;
  LIndex: Integer;
  Dict: TDictionary<string, Integer>;
  {$ELSE}
  SourceItem: TSourceItem;
  DestItem: TCustomDestinationItem;
  Layer: TLayer;
  BitmapItem: TCustomBitmapItem;
  {$ENDIF}
begin
  if not Assigned(AImageList) or not TDirectory.Exists(AFolderPath) then
    Exit;

  {$IFDEF VCL}
  if AClearExisting then
  begin
    AImageList.Clear;
    if FNamesMap.TryGetValue(AImageList, Dict) then
      Dict.Clear;
  end;

  if not FNamesMap.TryGetValue(AImageList, Dict) then
  begin
    Dict := TDictionary<string, Integer>.Create;
    FNamesMap.Add(AImageList, Dict);
  end;
  {$ELSE}
  AImageList.BeginUpdate;
  try
    if AClearExisting then
    begin
      AImageList.Source.Clear;
      AImageList.Destination.Clear;
    end;
  {$ENDIF}

    // Localiza arquivos de imagens comuns
    // en: Locates common image files
    Files := TDirectory.GetFiles(
      AFolderPath,
      '*.*',
      TSearchOption.soTopDirectoryOnly,
      function(const Path: string; const SearchRec: TSearchRec): Boolean
      var
        LExt: string;
      begin
        LExt := LowerCase(ExtractFileExt(SearchRec.Name));
        Result := (LExt = '.png') or (LExt = '.jpg') or (LExt = '.jpeg') or
                  (LExt = '.ico') or (LExt = '.bmp') or (LExt = '.svg');
      end
    );

    for FilePath in Files do
    begin
      ItemName := TPath.GetFileNameWithoutExtension(FilePath);
      Ext := LowerCase(ExtractFileExt(FilePath));

      {$IFDEF VCL}
      if Ext = '.ico' then
      begin
        LIcon := TIcon.Create;
        try
          LIcon.LoadFromFile(FilePath);
          LIndex := AImageList.AddIcon(LIcon);
        finally
          LIcon.Free;
        end;
      end
      else
      begin
        LImage := TWICImage.Create;
        try
          LImage.LoadFromFile(FilePath);
          LBitmap := TBitmap.Create;
          try
            LBitmap.Assign(LImage);
            LIndex := AImageList.Add(LBitmap, nil);
          finally
            LBitmap.Free;
          end;
        finally
          LImage.Free;
        end;
      end;

      if LIndex <> -1 then
        Dict.AddOrSetValue(ItemName.ToLower, LIndex);
      {$ELSE}
      // 1. Cria a entrada na coleção Source usando TSourceItem
      // en: 1. Creates the entry in the Source collection using TSourceItem
      SourceItem := AImageList.Source.Add as TSourceItem;
      SourceItem.Name := ItemName;

      // Adiciona o Bitmap no MultiResBitmap (escala 1.0)
      // en: Adds the Bitmap to the MultiResBitmap (scale 1.0)
      BitmapItem := SourceItem.MultiResBitmap.ItemByScale(1.0, True, True);
      if BitmapItem = nil then
        BitmapItem := SourceItem.MultiResBitmap.Add;

      BitmapItem.Scale := 1.0;
      BitmapItem.Bitmap.LoadFromFile(FilePath);

      // 2. Cria o item correspondente no Destination
      // en: 2. Creates the corresponding item in the Destination
      DestItem := AImageList.Destination.Add;
      Layer := DestItem.Layers.Add;
      Layer.Name := ItemName;
      Layer.SourceRect.Rect := TRectF.Create(0, 0, BitmapItem.Bitmap.Width, BitmapItem.Bitmap.Height);
      {$ENDIF}
    end;
  {$IFNDEF VCL}
  finally
    AImageList.EndUpdate;
  end;
  {$ENDIF}
end;

{ TImageListHelper }

function TImageListHelper.IndexByName(const AImageName: string): Integer;
{$IFDEF VCL}
begin
  Result := TImageListLoader.GetIndexByName(Self, AImageName);
end;
{$ELSE}
var
  I, J: Integer;
  TargetName: string;
begin
  Result := -1;
  if (Self = nil) or AImageName.Trim.IsEmpty then
    Exit;

  TargetName := AImageName.Trim;

  // Percorre todos os itens de Destination
  // en: Iterates through all Destination items
  for I := 0 to Self.Destination.Count - 1 do
  begin
    // Percorre as camadas de cada Destination procurando a correspondência
    // en: Iterates through the layers of each Destination looking for matches
    for J := 0 to Self.Destination[I].Layers.Count - 1 do
    begin
      if SameText(Self.Destination[I].Layers[J].Name, TargetName) then
      begin
        Exit(I); // Retorna o ImageIndex
        // en: Returns the ImageIndex
      end;
    end;
  end;
end;
{$ENDIF}

end.
