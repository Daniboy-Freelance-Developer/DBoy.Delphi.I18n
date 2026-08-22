unit DBoy.I18n.VCL.DMData;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient, DBoy.I18n.VCL.DMTranslator;

type
  TDMData = class(TDMTranslator)
    tabEntity: TClientDataSet;
    tabEntityID: TIntegerField;
    tabEntityEntity_Name: TStringField;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DMData: TDMData;

implementation

uses
  DBoy.I18n.GlobalTests;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDMData.DataModuleCreate(Sender: TObject);
begin
  // Não conecta dados em ambiente de Tests de DFM e extração de Tradução
  // en: Does not connect data in DFM testing and translation extraction environment
  // porque os TFields estão adicionados DFM para Extração do DisplayLabel
  // en: because TFields are added to DFM for DisplayLabel extraction
  if DBoyI18nGlobalTests then
    Exit;

  tabEntity.CreateDataSet;
  tabEntity.LogChanges := False;
end;

end.
