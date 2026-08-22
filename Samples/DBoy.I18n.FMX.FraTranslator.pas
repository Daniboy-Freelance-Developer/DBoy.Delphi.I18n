unit DBoy.I18n.FMX.FraTranslator;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Messaging;

type
  TFraTranslator = class(TFrame)
  private
    FMsgSubId: Integer;
    procedure OnLanguageChanged(const Sender: TObject; const M: TMessage);
  protected
    procedure RetranslateUI; virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
  end;

implementation

uses
  DBoy.I18n.Messages, DBoy.I18n.Engine;

{$R *.fmx}

{ TFraTranslator }

procedure TFraTranslator.AfterConstruction;
begin
  inherited;
  // Não é necessário Traduzir nos Tests para Extração da tradução do Json usando DBoyI18nGlobalTests
  // en: No need to translate in tests for JSON translation extraction using DBoyI18nGlobalTests
  // porém se carregar o Locate/Idioma antes de iniciar os Tests de extração realizando tradução o json
  // en: however, if the Locate/Language is loaded before starting the extraction tests and performing translation, the JSON
  // não identifica o que está traduzido e o que falta ser traduzido.
  // en: does not identify what is translated and what still needs to be translated.
  RetranslateUI;
end;

constructor TFraTranslator.Create(AOwner: TComponent);
begin
  inherited;
  // Registra no barramento do Delphi
  // en: Registers on the Delphi bus
  FMsgSubId := TMessageManager.DefaultManager.SubscribeToMessage(
    TDBoyI18nLanguageChangeMessage, OnLanguageChanged
  );
end;

destructor TFraTranslator.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TDBoyI18nLanguageChangeMessage, FMsgSubId);
  inherited;
end;

procedure TFraTranslator.OnLanguageChanged(const Sender: TObject;
  const M: TMessage);
begin
  if (M is TDBoyI18nLanguageChangeMessage) then
  begin
    RetranslateUI;
  end;
end;

procedure TFraTranslator.RetranslateUI;
begin
  TDBoyI18nEngine.Translate(Self);
end;

end.
