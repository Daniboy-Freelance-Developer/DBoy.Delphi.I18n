unit DBoy.I18n.FMX.DMData;

interface

uses
  System.SysUtils, System.Classes, DBoy.I18n.FMX.DMTranslator,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TDMData = class(TDMTranslator)
    tabEntity: TFDMemTable;
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

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDMData.DataModuleCreate(Sender: TObject);
begin
  inherited;
  // Não conecta dados em ambiente de Tests de DFM e extração de Tradução
  // en: Does not connect data in DFM testing and translation extraction environment
  // porque os TFields estão adicionados DFM para Extração do DisplayLabel
  // en: because TFields are added to DFM for DisplayLabel extraction
  if DBoyI18nGlobalTests then
    Exit;

  tabEntity.CreateDataSet;
end;

end.
