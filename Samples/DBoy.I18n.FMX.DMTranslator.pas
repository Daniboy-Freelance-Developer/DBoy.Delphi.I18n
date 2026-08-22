unit DBoy.I18n.FMX.DMTranslator;

interface

uses
  System.SysUtils, System.Classes, System.Messaging;

type
  TDMTranslator = class(TDataModule)
  private
    FMsgSubId: Integer;
    procedure OnLanguageChanged(const Sender: TObject; const M: TMessage);
  protected
    procedure RetranslateUI; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
  end;

implementation

uses
  DBoy.I18n.Messages, DBoy.I18n.Engine;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TDMTranslator }

procedure TDMTranslator.AfterConstruction;
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

constructor TDMTranslator.Create(AOwner: TComponent);
begin
  inherited;
  // Registra no barramento do Delphi
  // en: Registers on the Delphi bus
  FMsgSubId := TMessageManager.DefaultManager.SubscribeToMessage(
    TDBoyI18nLanguageChangeMessage, OnLanguageChanged
  );
end;

destructor TDMTranslator.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TDBoyI18nLanguageChangeMessage, FMsgSubId);
  inherited;
end;

procedure TDMTranslator.OnLanguageChanged(const Sender: TObject;
  const M: TMessage);
begin
  if (M is TDBoyI18nLanguageChangeMessage) then
  begin
    RetranslateUI;
  end;
end;

procedure TDMTranslator.RetranslateUI;
begin
  TDBoyI18nEngine.Translate(Self);
end;

end.
