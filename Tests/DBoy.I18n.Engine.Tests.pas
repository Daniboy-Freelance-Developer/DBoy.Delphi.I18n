unit DBoy.I18n.Engine.Tests;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  DBoy.I18n.Engine;

resourcestring
  StrTestAccent = 'Atenção e Configurações';
  StrTestExecution = 'Execução de Padrões';

type
  // Componente filho
  TTestChildControl = class(TComponent)
  private
    FCaption: string;
    FText: string;
    FHint: string;
  published
    property Caption: string read FCaption write FCaption;
    property Text: string read FText write FText;
    property Hint: string read FHint write FHint;
  end;

  // Formulário/Container de teste
  TTestVisualForm = class(TComponent)
  private
    FCaption: string;
    FText: string;
    FHint: string;
    FHelpText: string;
  published
    property Caption: string read FCaption write FCaption;
    property Text: string read FText write FText;
    property Hint: string read FHint write FHint;
    property HelpText: string read FHelpText write FHelpText;
  end;

  [TestFixture]
  TDBoyI18nEngineTests = class
  public
    [Setup]
    procedure Setup;
    [Teardown]
    procedure Teardown;

    [Test]
    procedure TestEmptyDictionaryTotalBypassPreservesAccents;

    [Test]
    procedure TestPartialTranslationPreservesUntranslatedItems;

    [Test]
    procedure TestChildComponentTranslation;

    [Test]
    procedure TestResourceStringHookAndUnhookReset;

    [Test]
    procedure TestUtf8JsonFileLoadingWithAccents;
  end;

implementation

{ TDBoyI18nEngineTests }

procedure TDBoyI18nEngineTests.Setup;
begin
  TDBoyI18nEngine.Clear;
end;

procedure TDBoyI18nEngineTests.Teardown;
begin
  TDBoyI18nEngine.Clear;
end;

procedure TDBoyI18nEngineTests.TestEmptyDictionaryTotalBypassPreservesAccents;
var
  Form: TTestVisualForm;
  Child: TTestChildControl;
begin
  Form := TTestVisualForm.Create(nil);
  try
    Form.Name := 'FrmConfig';
    Form.Caption := 'Configurações Avançadas';
    Form.Text := 'Execução de Padrões';
    Form.Hint := 'Atenção: Não desligue';
    Form.HelpText := 'Opções de Instalação';

    Child := TTestChildControl.Create(Form);
    Child.Name := 'btnSalvar';
    Child.Caption := 'Gravação Concluída';
    Child.Text := 'Atenção';
    Child.Hint := 'Dica de Execução';

    // Garante que o motor está vazio (sem JSON)
    Assert.AreEqual(0, TDBoyI18nEngine.DictionaryCount, 'Dicionário deve estar vazio');

    // Executa Translate
    TDBoyI18nEngine.Translate(Form);

    // Valida que absolutamente nada foi corrompido ou alterado
    Assert.AreEqual('Configurações Avançadas', Form.Caption, 'Caption deve permanecer 100% íntegra');
    Assert.AreEqual('Execução de Padrões', Form.Text, 'Text deve permanecer 100% íntegro');
    Assert.AreEqual('Atenção: Não desligue', Form.Hint, 'Hint deve permanecer 100% íntegro');
    Assert.AreEqual('Opções de Instalação', Form.HelpText, 'HelpText deve permanecer 100% íntegro');

    Assert.AreEqual('Gravação Concluída', Child.Caption, 'Child Caption deve permanecer íntegra');
    Assert.AreEqual('Atenção', Child.Text, 'Child Text deve permanecer íntegro');
    Assert.AreEqual('Dica de Execução', Child.Hint, 'Child Hint deve permanecer íntegro');
  finally
    Form.Free;
  end;
end;

procedure TDBoyI18nEngineTests.TestPartialTranslationPreservesUntranslatedItems;
var
  Form: TTestVisualForm;
  JsonPartial: string;
begin
  Form := TTestVisualForm.Create(nil);
  try
    Form.Name := 'FrmMain';
    Form.Caption := 'Gravar';
    Form.Text := 'Configurações de Execução';
    Form.Hint := 'Atenção ao salvar';

    // JSON com tradução APENAS para Caption, sem chaves para Text ou Hint
    JsonPartial := 
      '{' +
      '  "locale": "en_US",' +
      '  "translations": {' +
      '    "TTestVisualForm": {' +
      '      "Caption": "Save"' +
      '    }' +
      '  }' +
      '}';

    Assert.IsTrue(TDBoyI18nEngine.LoadFromString(JsonPartial), 'Deve carregar JSON parcial com sucesso');

    TDBoyI18nEngine.Translate(Form);

    // Caption deve ser traduzida
    Assert.AreEqual('Save', Form.Caption, 'Caption mapeada deve ser traduzida para "Save"');

    // Text e Hint NÃO devem ser alterados nem corrompidos
    Assert.AreEqual('Configurações de Execução', Form.Text, 'Text não traduzido deve manter o texto original com acentos');
    Assert.AreEqual('Atenção ao salvar', Form.Hint, 'Hint não traduzido deve manter o texto original');
  finally
    Form.Free;
  end;
end;

procedure TDBoyI18nEngineTests.TestChildComponentTranslation;
var
  Form: TTestVisualForm;
  Child: TTestChildControl;
  JsonTree: string;
begin
  Form := TTestVisualForm.Create(nil);
  try
    Form.Name := 'FrmMain';
    Form.Caption := 'Título Original';

    Child := TTestChildControl.Create(Form);
    Child.Name := 'btnSave';
    Child.Caption := 'Salvar';
    Child.Hint := 'Dica Original';

    JsonTree := 
      '{' +
      '  "locale": "en_US",' +
      '  "translations": {' +
      '    "TTestVisualForm": {' +
      '      "Caption": "Main Window",' +
      '      "btnSave.Caption": "Save Button"' +
      '    }' +
      '  }' +
      '}';

    Assert.IsTrue(TDBoyI18nEngine.LoadFromString(JsonTree), 'Carregar JSON hierárquico');

    TDBoyI18nEngine.Translate(Form);

    Assert.AreEqual('Main Window', Form.Caption, 'Título do form traduzido');
    Assert.AreEqual('Save Button', Child.Caption, 'Botão filho traduzido');
    Assert.AreEqual('Dica Original', Child.Hint, 'Hint não mapeado preservado');
  finally
    Form.Free;
  end;
end;

procedure TDBoyI18nEngineTests.TestResourceStringHookAndUnhookReset;
var
  JsonRes: string;
begin
  // Registra as resourcestrings
  TDBoyI18nEngine.RegisterResString('StrTestAccent', @StrTestAccent);
  TDBoyI18nEngine.RegisterResString('StrTestExecution', @StrTestExecution);

  // Valor original padrão
  Assert.AreEqual('Atenção e Configurações', LoadResString(@StrTestAccent), 'Valor nativo inicial de StrTestAccent');
  Assert.AreEqual('Execução de Padrões', LoadResString(@StrTestExecution), 'Valor nativo inicial de StrTestExecution');

  // Aplica tradução via JSON
  JsonRes := 
    '{' +
    '  "locale": "en_US",' +
    '  "translations": {' +
    '    "General": {' +
    '      "StrTestAccent": "Attention & Settings"' +
    '    }' +
    '  }' +
    '}';

  Assert.IsTrue(TDBoyI18nEngine.LoadFromString(JsonRes), 'LoadFromString de ResourceStrings');

  // StrTestAccent deve estar traduzida
  Assert.AreEqual('Attention & Settings', LoadResString(@StrTestAccent), 'StrTestAccent deve ter valor hookado');
  // StrTestExecution (não inclusa no JSON) deve continuar com o valor original
  Assert.AreEqual('Execução de Padrões', LoadResString(@StrTestExecution), 'StrTestExecution deve manter o valor original');

  // Reseta o motor (Clear/Reset)
  TDBoyI18nEngine.Reset;

  // StrTestAccent deve ser deshookada e voltar ao valor original nativo
  Assert.AreEqual('Atenção e Configurações', LoadResString(@StrTestAccent), 'StrTestAccent deve voltar ao valor nativo original após Reset');
  Assert.AreEqual('Execução de Padrões', LoadResString(@StrTestExecution), 'StrTestExecution deve permanecer intacta');
end;

procedure TDBoyI18nEngineTests.TestUtf8JsonFileLoadingWithAccents;
var
  TempFile: string;
  JsonContent: string;
  Form: TTestVisualForm;
begin
  TempFile := TPath.Combine(TPath.GetTempPath, 'test_i18n_utf8.json');
  JsonContent := 
    '{' + sLineBreak +
    '  "locale": "pt_BR",' + sLineBreak +
    '  "languageName": "Português (Brasil)",' + sLineBreak +
    '  "translations": {' + sLineBreak +
    '    "TTestVisualForm": {' + sLineBreak +
    '      "Caption": "Operação Concluída com Sucesso",' + sLineBreak +
    '      "Hint": "Atenção: Verifique as Informações de Instalação"' + sLineBreak +
    '    }' + sLineBreak +
    '  }' + sLineBreak +
    '}';

  TFile.WriteAllText(TempFile, JsonContent, TEncoding.UTF8);
  try
    Assert.IsTrue(TDBoyI18nEngine.LoadFromFile(TempFile), 'LoadFromFile UTF-8 deve retornar True');

    Form := TTestVisualForm.Create(nil);
    try
      Form.Name := 'FrmTest';
      Form.Caption := 'Original';
      Form.Hint := 'Original Hint';

      TDBoyI18nEngine.Translate(Form);

      Assert.AreEqual('Operação Concluída com Sucesso', Form.Caption, 'Caption deve conter acentos UTF-8 perfeitamente');
      Assert.AreEqual('Atenção: Verifique as Informações de Instalação', Form.Hint, 'Hint deve conter acentos UTF-8 perfeitamente');
    finally
      Form.Free;
    end;
  finally
    if TFile.Exists(TempFile) then
      TFile.Delete(TempFile);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDBoyI18nEngineTests);

end.