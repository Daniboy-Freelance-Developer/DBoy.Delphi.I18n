unit DBoy.I18n.FMX.ViewTranslator;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Messaging, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TFrmViewFMXTranslator = class(TForm)
    lblLocale: TLabel;
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

{$R *.fmx}

{ TFrmViewVCLTranslator }

procedure TFrmViewFMXTranslator.AfterConstruction;
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

procedure TFrmViewFMXTranslator.RetranslateUI;
begin
  TDBoyI18nEngine.Translate(Self);
  lblLocale.Text := TDBoyI18nEngine.CurrentLocale;
end;

constructor TFrmViewFMXTranslator.Create(AOwner: TComponent);
begin
  inherited;
  // Registra no barramento do Delphi
  // en: Registers on the Delphi bus
  FMsgSubId := TMessageManager.DefaultManager.SubscribeToMessage(
    TDBoyI18nLanguageChangeMessage, OnLanguageChanged
  );
end;

destructor TFrmViewFMXTranslator.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TDBoyI18nLanguageChangeMessage, FMsgSubId);
  inherited;
end;

procedure TFrmViewFMXTranslator.OnLanguageChanged(const Sender: TObject;
  const M: TMessage);
begin
  if (M is TDBoyI18nLanguageChangeMessage) then
  begin
    lblLocale.Text := (M as TDBoyI18nLanguageChangeMessage).Value;
    RetranslateUI;
  end;
end;

end.
