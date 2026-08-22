program DBoy.I18n.FMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  DBoy.I18n.FMX.ViewMain in 'DBoy.I18n.FMX.ViewMain.pas' {FrmViewMain},
  DBoy.I18n.FMX.ViewTranslator in 'DBoy.I18n.FMX.ViewTranslator.pas' {FrmViewFMXTranslator},
  DBoy.I18n.Engine in '..\Source\DBoy.I18n.Engine.pas',
  DBoy.I18n.Messages in '..\Source\DBoy.I18n.Messages.pas',
  DBoy.I18n.LanguageMenu in '..\Source\DBoy.I18n.LanguageMenu.pas',
  DBoy.I18n.ResourceStrings in 'DBoy.I18n.ResourceStrings.pas',
  DBoy.I18n.FMX.FraTranslator in 'DBoy.I18n.FMX.FraTranslator.pas' {FraTranslator: TFrame},
  DBoy.I18n.FMX.FraEntity in 'DBoy.I18n.FMX.FraEntity.pas' {FraEntity: TFrame},
  DBoy.I18n.FMX.NativeConsts in 'DBoy.I18n.FMX.NativeConsts.pas',
  DBoy.I18n.FMX.AppDialogs in 'DBoy.I18n.FMX.AppDialogs.pas',
  DBoy.I18n.ImageListLoader in '..\Source\DBoy.I18n.ImageListLoader.pas',
  DBoy.I18n.FMX.DMTranslator in 'DBoy.I18n.FMX.DMTranslator.pas' {DMTranslator: TDataModule},
  DBoy.I18n.FMX.DMData in 'DBoy.I18n.FMX.DMData.pas' {DMData: TDataModule},
  DBoy.I18n.GlobalTests in '..\Source\DBoy.I18n.GlobalTests.pas';

{$R *.res}

begin
  Application.Initialize;
  // Adicionando tratamento de TField na tradução
  // en: Adding TField handling to the translation
  TDBoyI18nEngine.RegisterTranslatableProperty('DisplayLabel');
  // Carregando o idioma padrão
  // en: Loading default language
  TDBoyI18nEngine.LoadFromFile('Languages\pt_BR.json');
  // Iniciando módulo de dados
  // en: Starting data module
  Application.CreateForm(TDMData, DMData);
  Application.CreateForm(TFrmViewMain, FrmViewMain);
  Application.Run;
end.
