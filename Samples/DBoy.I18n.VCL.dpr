program DBoy.I18n.VCL;

{$DEFINE VCL}

uses
  Vcl.Forms,
  DBoy.I18n.VCL.ViewMain in 'DBoy.I18n.VCL.ViewMain.pas' {FrmViewMain},
  DBoy.I18n.VCL.ViewTranslator in 'DBoy.I18n.VCL.ViewTranslator.pas' {FrmViewTranslator},
  DBoy.I18n.Engine in '..\Source\DBoy.I18n.Engine.pas',
  DBoy.I18n.Messages in '..\Source\DBoy.I18n.Messages.pas',
  DBoy.I18n.LanguageMenu in '..\Source\DBoy.I18n.LanguageMenu.pas',
  DBoy.I18n.ResourceStrings in 'DBoy.I18n.ResourceStrings.pas',
  DBoy.I18n.VCL.FraTranslator in 'DBoy.I18n.VCL.FraTranslator.pas' {FraTranslator: TFrame},
  DBoy.I18n.VCL.NativeConsts in 'DBoy.I18n.VCL.NativeConsts.pas',
  DBoy.I18n.VCL.AppDialogs in 'DBoy.I18n.VCL.AppDialogs.pas',
  DBoy.I18n.ImageListLoader in '..\Source\DBoy.I18n.ImageListLoader.pas',
  DBoy.I18n.VCL.FraEntity in 'DBoy.I18n.VCL.FraEntity.pas' {FraEntity: TFrame},
  DBoy.I18n.VCL.DMTranslator in 'DBoy.I18n.VCL.DMTranslator.pas' {DMTranslator: TDataModule},
  DBoy.I18n.VCL.DMData in 'DBoy.I18n.VCL.DMData.pas' {DMData: TDataModule},
  DBoy.I18n.GlobalTests in '..\Source\DBoy.I18n.GlobalTests.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TDBoyI18nEngine.RegisterTranslatableProperty('DisplayLabel');
  TDBoyI18nEngine.LoadFromFile('Languages\pt_BR.json');
  Application.CreateForm(TDMData, DMData);
  Application.CreateForm(TFrmViewMain, FrmViewMain);
  application.Run;
end.
