unit DBoy.I18n.Extractor.VCL.Tests;

interface

uses
  DUnitX.TestFramework, System.SysUtils, System.IOUtils, System.Classes,
  DBoy.I18n.Engine, DBoy.I18n.Extractor, DBoy.I18n.Extractor.Tests;

type
  TTestCustomComponent = class(TComponent)
  private
    FDisplayLabel: string;
  published
    property DisplayLabel: string read FDisplayLabel write FDisplayLabel;
  end;

  [TestFixture]
  TI18nGeneratorVCLTests = class(TI18nTests)
  public
    [Test]
    procedure GenerateBaseLanguageTemplate; override;
    [Test]
    procedure TestCustomTranslatableProperty;
  end;

implementation

uses
  DBoy.I18n.VCL.ViewMain, DBoy.I18n.VCL.FraEntity, DBoy.I18n.VCL.DMData,
  DBoy.I18n.GlobalTests;

procedure TI18nGeneratorVCLTests.GenerateBaseLanguageTemplate;
begin
  TDBoyI18nEngine.RegisterTranslatableProperty('DisplayLabel');

  // 1. Registra as janelas e frames que deseja inspecionar
  // en: 1. Registers the windows and frames to inspect
  TI18nExtractor.RegisterClasses([
    TFrmViewMain,
    TFraEntity,
    TDMData
  ]);

  inherited;
end;

procedure TI18nGeneratorVCLTests.TestCustomTranslatableProperty;
var
  LComp: TTestCustomComponent;
begin
  // Registra e valida se foi registrado corretamente
  // en: Registers and validates if registered correctly
  TDBoyI18nEngine.RegisterTranslatableProperty('DisplayLabel');
  Assert.IsTrue(TDBoyI18nEngine.IsTranslatableProperty('DisplayLabel'), 'DisplayLabel deve estar registrado como traduzível.');

  LComp := TTestCustomComponent.Create(nil);
  try
    LComp.DisplayLabel := 'OriginalLabel';

    // Carrega um JSON de tradução contendo a nova propriedade
    // en: Loads a translation JSON containing the new property
    TDBoyI18nEngine.LoadFromString(
      '{"locale":"en_US","translations":{"TTestCustomComponent":{"DisplayLabel":"TranslatedLabel"}}}'
    );

    // Executa a tradução por RTTI
    // en: Performs translation by RTTI
    TDBoyI18nEngine.Translate(LComp);

    // Verifica se a tradução foi aplicada com sucesso
    // en: Checks if the translation was successfully applied
    Assert.AreEqual('TranslatedLabel', LComp.DisplayLabel, 'A propriedade DisplayLabel deve ter sido traduzida.');
  finally
    LComp.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TI18nGeneratorVCLTests);

end.
