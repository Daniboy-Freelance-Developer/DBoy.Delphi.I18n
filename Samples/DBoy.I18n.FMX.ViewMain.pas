unit DBoy.I18n.FMX.ViewMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, DBoy.I18n.FMX.ViewTranslator,
  FMX.Menus, System.ImageList, FMX.ImgList, System.Actions, FMX.ActnList,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox,
  DBoy.I18n.FMX.FraEntity, DBoy.I18n.FMX.FraTranslator, System.Rtti,
  FMX.Grid.Style, Data.Bind.Components, Data.Bind.DBScope, FMX.ScrollBox,
  FMX.Grid, Data.Bind.Grid;

type
  TFrmViewMain = class(TFrmViewFMXTranslator)
    ActionList: TActionList;
    MainMenu: TMainMenu;
    ImageList: TImageList;
    mItemApp: TMenuItem;
    mItemClose: TMenuItem;
    mItemLocale: TMenuItem;
    GroupBoxMain: TGroupBox;
    ListBoxEntity: TListBox;
    FraEntityMain: TFraEntity;
    actNewEntity: TAction;
    mItemactNewEntity: TMenuItem;
    GridEntity: TGrid;
    procedure mItemCloseClick(Sender: TObject);
    procedure FraEntityMainbtnPostClick(Sender: TObject);
    procedure actNewEntityExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FBindSourceDB: TBindSourceDB;
    FLinkGrid: TLinkGridToDataSource;
    procedure SetupLiveBindings;
  public
    { Public declarations }
  end;

var
  FrmViewMain: TFrmViewMain;

implementation

uses DBoy.I18n.ResourceStrings, DBoy.I18n.Engine, DBoy.I18n.LanguageMenu,
  DBoy.I18n.FMX.AppDialogs, DBoy.I18n.ImageListLoader, System.IOUtils,
  DBoy.I18n.FMX.DMData,
  // Units essenciais de Registro e Bindings do FMX
  // en: Essential units for FMX Registration and Bindings
  Fmx.Bind.Editors,
  Fmx.Bind.DBLinks,
  Fmx.Bind.Grid,
  Data.Bind.EngExt,
  Fmx.Bind.Consts, DBoy.I18n.GlobalTests;

{$R *.fmx}

procedure TFrmViewMain.actNewEntityExecute(Sender: TObject);
var
  LFraNew: TFraEntity;
begin
  inherited;
  LFraNew := TFraEntity.Create(Self);
  LFraNew.Align := TAlignLayout.Top;
  LFraNew.Position.Y := 9999;
  LFraNew.Parent := GroupBoxMain;
  LFraNew.Margins.Rect := TRectF.Create(3, 3, 3, 3);
  LFraNew.Name := LFraNew.Name + ComponentCount.ToString;
  LFraNew.btnPost.OnClick := FraEntityMainbtnPostClick;
end;

procedure TFrmViewMain.FormCreate(Sender: TObject);
var
  IconsFolder: string;
begin
  inherited;

  // Não vincula dados em ambiente de Tests de DFM e extração de Tradução
  // en: Does not bind data in DFM testing and translation extraction environment
  // Nem controles apenas visuais, não usados em Tests
  // en: Neither purely visual controls, not used in tests
  if DBoyI18nGlobalTests then
    Exit;

  // Popula o ImageList dinamicamente com as imagens da pasta
  // en: Populates the ImageList dynamically with the images from the folder
  IconsFolder := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Assets');
  TImageListLoader.LoadFromFolder(ImageList, IconsFolder, True);
  // Popula o menu de idiomas passando o TMenuItem pai (ex: mnuIdiomas)
  // en: Populates the language menu by passing the parent TMenuItem (e.g. mnuIdiomas)
  TDBoyI18nLanguageMenuBuilder.BuildLanguageMenu(mItemLocale);

  SetupLiveBindings;
end;

procedure TFrmViewMain.FraEntityMainbtnPostClick(Sender: TObject);
var
  LFra: TFraEntity;
begin
  inherited;

  LFra := (TFmxObject(Sender).Owner as TFraEntity);

  if LFra.edtEntity.Text.IsEmpty then
    Exit;

  var LId: integer := DMData.tabEntity.RecordCount +1;
  DMData.tabEntity.AppendRecord([LId, LFra.edtEntity.Text]);

  ListBoxEntity.Items.Add(LFra.edtEntity.Text);
  ListBoxEntity.Items.Add(SMsgSaveSuccess);
end;

procedure TFrmViewMain.mItemCloseClick(Sender: TObject);
begin
  inherited;

  {
  O TDialogServiceSync.MessageDialog não possui, de forma geral,
  um mecanismo próprio para você traduzir os textos dos botões.
  Os botões padrão (OK, Cancel, Yes, No, etc.) são definidos pela implementação do IFMXDialogService da plataforma.
  MessageDlg(SMsgConfirmExit, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0);
  }

  if TAppDialog.MessageDlg(SMsgConfirmExit, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo) = mrYes then
  begin
    Close;
  end;
end;

procedure TFrmViewMain.SetupLiveBindings;
begin
  // 1. Cria a ponte do LiveBindings com o FDMemTable
  // en: 1. Creates the LiveBindings bridge with FDMemTable
  FBindSourceDB := TBindSourceDB.Create(Self);
  FBindSourceDB.DataSet := DMData.tabEntity;

  // 2. Cria o vínculo bidirecional entre a Grid e a Fonte de Dados
  // en: 2. Creates the bidirectional link between the Grid and the Data Source
  FLinkGrid := TLinkGridToDataSource.Create(Self);
  FLinkGrid.DataSource := FBindSourceDB;
  FLinkGrid.GridControl := GridEntity;

  // AutoBufferCount mantém o scroll sincronizado com os registros da tabela
  // en: AutoBufferCount keeps scroll synchronized with table records
  FLinkGrid.AutoBufferCount := True;

  // 3. Ativa e gera as colunas automaticamente baseadas nos Fields do MemTable
  // en: 3. Activates and generates columns automatically based on the MemTable Fields
  FLinkGrid.Active := True;
end;

end.
