unit DBoy.I18n.Extractor.FMX.Tests;

interface

uses
  DUnitX.TestFramework, System.SysUtils, System.IOUtils,
  Dboy.I18n.Engine, Dboy.I18n.Extractor, DBoy.I18n.Extractor.Tests;

type
  [TestFixture]
  TI18nGeneratorTests = class(TI18nTests)
  public
    [Test]
    procedure GenerateBaseLanguageTemplate; override;
  end;

implementation

uses
  DBoy.I18n.FMX.ViewMain, DBoy.I18n.FMX.FraEntity, DBoy.I18n.FMX.DMData;

procedure TI18nGeneratorTests.GenerateBaseLanguageTemplate;
begin
  // Carregando o idioma padrão
  // en: Loading default language
  TDBoyI18nEngine.RegisterTranslatableProperty('DisplayLabel');
  TDBoyI18nEngine.LoadFromFile('Languages\pt_BR.json');

  // 1. Registra as janelas e frames que deseja inspecionar
  // en: 1. Registers the windows and frames to inspect
  TI18nExtractor.RegisterClasses([
    TFrmViewMain,
    TFraEntity,
    TDMData
  ]);

  inherited;
end;

initialization
  TDUnitX.RegisterTestFixture(TI18nGeneratorTests);

end.
