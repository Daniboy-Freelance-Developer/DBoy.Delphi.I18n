unit DBoy.I18n.VCL.FraTranslator;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Messaging;

type
  TFraTranslator = class(TFrame)
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

{$R *.dfm}

{ TFraTranslator }

procedure TFraTranslator.AfterConstruction;
begin
  inherited;
  RetranslateUI;
end;

constructor TFraTranslator.Create(AOwner: TComponent);
begin
  inherited;
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
