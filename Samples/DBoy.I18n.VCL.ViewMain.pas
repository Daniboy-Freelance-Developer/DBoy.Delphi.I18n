unit DBoy.I18n.VCL.ViewMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Menus, Vcl.ImgList, System.Actions, Vcl.ActnList,
  DBoy.I18n.VCL.ViewTranslator, DBoy.I18n.VCL.FraEntity, System.ImageList,
  DBoy.I18n.VCL.FraTranslator, Data.DB, Vcl.Grids, Vcl.DBGrids;

type
  TFrmViewMain = class(TFrmViewTranslator)
    ActionList: TActionList;
    MainMenu: TMainMenu;
    ImageList: TImageList;
    mItemApp: TMenuItem;
    mItemClose: TMenuItem;
    mItemLocale: TMenuItem;
    mItemactNewEntity: TMenuItem;
    GroupBoxMain: TGroupBox;
    ListBoxEntity: TListBox;
    actNewEntity: TAction;
    FraEntityMain: TFraEntity;
    DBGrid1: TDBGrid;
    dsEntity: TDataSource;
    procedure mItemCloseClick(Sender: TObject);
    procedure FraEntityMainbtnPostClick(Sender: TObject);
    procedure actNewEntityExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure SetupLiveBindings;
  public
    { Public declarations }
  end;

var
  FrmViewMain: TFrmViewMain;

implementation

uses
  DBoy.I18n.ResourceStrings, DBoy.I18n.Engine, DBoy.I18n.LanguageMenu,
  DBoy.I18n.VCL.AppDialogs, DBoy.I18n.ImageListLoader, System.IOUtils,
  DBoy.I18n.VCL.DMData, DBoy.I18n.GlobalTests;

{$R *.dfm}

procedure TFrmViewMain.actNewEntityExecute(Sender: TObject);
var
  LFraNew: TFraEntity;
begin
  inherited;
  LFraNew := TFraEntity.Create(Self);
  LFraNew.Parent := GroupBoxMain;
  LFraNew.Align := alTop;
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

  SetupLiveBindings;

  // Popula o ImageList dinamicamente com as imagens da pasta
  // en: Populates the ImageList dynamically with the images from the folder
  IconsFolder := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Assets');
  TImageListLoader.LoadFromFolder(ImageList, IconsFolder, True);
  // Popula o menu de idiomas passando o TMenuItem pai (ex: mnuIdiomas)
  // en: Populates the language menu by passing the parent TMenuItem (e.g. mnuIdiomas)
  TDBoyI18nLanguageMenuBuilder.BuildLanguageMenu(mItemLocale);
end;

procedure TFrmViewMain.FraEntityMainbtnPostClick(Sender: TObject);
var
  LFra: TFraEntity;
begin
  inherited;
  // O Sender é o botão, o Owner do botão é o Frame
  // en: The Sender is the button, the Owner of the button is the Frame
  LFra := (TComponent(Sender).Owner as TFraEntity);

  if LFra.edtEntity.Text = '' then
    Exit;

  var LId: integer := DMData.tabEntity.RecordCount +1;
  DMData.tabEntity.AppendRecord([LId, LFra.edtEntity.Text]);

  ListBoxEntity.Items.Add(LFra.edtEntity.Text);
  ListBoxEntity.Items.Add(SMsgSaveSuccess);
end;

procedure TFrmViewMain.mItemCloseClick(Sender: TObject);
begin
  inherited;
  if TAppDialog.MessageDlg(SMsgConfirmExit, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo) = mrYes then
  begin
    Close;
  end;
end;

procedure TFrmViewMain.SetupLiveBindings;
begin
  dsEntity.DataSet := DMData.tabEntity;
end;

end.
