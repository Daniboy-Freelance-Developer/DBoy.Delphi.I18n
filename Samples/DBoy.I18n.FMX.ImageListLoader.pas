unit DBoy.I18n.FMX.ImageListLoader;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Types,
  FMX.ImgList, FMX.Graphics, FMX.MultiResBitmap, System.UITypes;

type
  TImageListLoader = class
  public
    class procedure LoadFromFolder(
      AImageList: TImageList;
      const AFolderPath: string;
      const AClearExisting: Boolean = True
    );
  end;

  TImageListHelper = class helper for TImageList
  public
    // Retorna o índice no Destination pelo nome do arquivo/source, ou -1 se não encontrar
    // en: Returns the index in Destination by file/source name, or -1 if not found
    function IndexByName(const AImageName: string): TImageIndex;
  end;

implementation

{ TImageListLoader }

class procedure TImageListLoader.LoadFromFolder(
  AImageList: TImageList;
  const AFolderPath: string;
  const AClearExisting: Boolean
);
var
  Files: TStringDynArray;
  FilePath, ItemName: string;
  SourceItem: TSourceItem;
  DestItem: TCustomDestinationItem;
  Layer: TLayer;
  BitmapItem: TCustomBitmapItem;
begin
  if not Assigned(AImageList) or not TDirectory.Exists(AFolderPath) then
    Exit;

  AImageList.BeginUpdate; //
  try
    if AClearExisting then
    begin
      AImageList.Source.Clear;
      AImageList.Destination.Clear;
    end;

    // Localiza arquivos de imagens comuns
    // en: Locates common image files
    Files := TDirectory.GetFiles(
      AFolderPath,
      '*.*',
      TSearchOption.soTopDirectoryOnly,
      function(const Path: string; const SearchRec: TSearchRec): Boolean
      var
        Ext: string;
      begin
        Ext := LowerCase(ExtractFileExt(SearchRec.Name));
        Result := (Ext = '.png') or (Ext = '.jpg') or (Ext = '.jpeg') or
                  (Ext = '.ico') or (Ext = '.bmp') or (Ext = '.svg');
      end
    );

    for FilePath in Files do
    begin
      ItemName := TPath.GetFileNameWithoutExtension(FilePath);

      // 1. Cria a entrada na coleção Source usando TSourceItem
      // en: 1. Creates the entry in the Source collection using TSourceItem
      SourceItem := AImageList.Source.Add as TSourceItem; //[cite: 2]
      SourceItem.Name := ItemName; //[cite: 2]

      // Adiciona o Bitmap no MultiResBitmap (escala 1.0)
      // en: Adds the Bitmap to the MultiResBitmap (scale 1.0)
      BitmapItem := SourceItem.MultiResBitmap.ItemByScale(1.0, True, True);
      if BitmapItem = nil then
        BitmapItem := SourceItem.MultiResBitmap.Add;

      BitmapItem.Scale := 1.0; //[cite: 2]
      BitmapItem.Bitmap.LoadFromFile(FilePath);

      // 2. Cria o item correspondente no Destination
      // en: 2. Creates the corresponding item in the Destination
      DestItem := AImageList.Destination.Add; //[cite: 2]
      Layer := DestItem.Layers.Add; //[cite: 2]
      Layer.Name := ItemName; //[cite: 2]
      Layer.SourceRect.Rect := TRectF.Create(0, 0, BitmapItem.Bitmap.Width, BitmapItem.Bitmap.Height); //[cite: 2]
    end;
  finally
    AImageList.EndUpdate; //[cite: 2]
  end;
end;

{ TImageListHelper }

function TImageListHelper.IndexByName(const AImageName: string): TImageIndex;
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

end.
