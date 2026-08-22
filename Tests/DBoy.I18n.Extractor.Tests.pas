unit DBoy.I18n.Extractor.Tests;

interface

uses
  DUnitX.TestFramework, System.SysUtils, System.IOUtils;

type
  [TestFixture]
  TI18nTests = class
  protected
    function GetFileBackupName: String;
  public
    [Setup]
    procedure Setup;
    [Teardown]
    procedure Teardown;
    /// <summary>
    ///   Metodo para Teste de extração das propriedades dos Componentes para tradução.
    /// en: Method for testing extraction of component properties for translation.
    ///  Importante: registrar as classes antes do inherited;
    /// en: Important: register classes before inherited;
    /// </summary>
    
    procedure GenerateBaseLanguageTemplate; virtual;
  end;

implementation

uses
  DBoy.I18n.GlobalTests, DBoy.I18n.Extractor;

{ TI18nTests }

procedure TI18nTests.GenerateBaseLanguageTemplate;
var
  OutputDir, OutputFile: string;
begin
  OutputDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Languages');
  TDirectory.CreateDirectory(OutputDir);

  // 2. Verifica se já tem o arquivo de saída e Faz backup
  // en: 2. Checks if the output file already exists and makes a backup
  // pode ficar com erros se ocorrecer erros na criação das janelas diversas
  // en: may have errors if errors occur during the creation of various windows
  OutputFile := TPath.Combine(OutputDir, 'template_extracted.json');
  if TFile.Exists(OutputFile) then
  begin
    TFile.Copy(OutputFile, ChangeFileExt(OutputFile, GetFileBackupName + '.bkp'));
    TFile.Delete(OutputFile);
  end;

  // 3. Exporta o JSON base completo
  // en: 3. Exports the complete base JSON
  TI18nExtractor.ExportToFile(OutputFile, 'pt_BR', 'Português (Brasil)');

  // 4. Valida a criação do arquivo no Teste
  // en: 4. Validates the file creation in the Test
  Assert.IsTrue(TFile.Exists(OutputFile), 'O arquivo de template JSON deve ter sido gerado com sucesso.');
  Assert.IsTrue(TFile.ReadAllText(OutputFile).Length > 0, 'O arquivo JSON não pode estar vazio.');
end;

function TI18nTests.GetFileBackupName: String;
begin
  Result := FormatDateTime('yyyy_dd_mm_hh_nn_ss_zzzz', Now);
end;

procedure TI18nTests.Setup;
begin
  StartDBoyI18nGlobalTests;
end;

procedure TI18nTests.Teardown;
begin
  StopDBoyI18nGlobalTests;
end;

end.
