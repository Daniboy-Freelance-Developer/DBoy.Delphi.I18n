unit DBoy.I18n.VCL.ViewTranslator;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Messaging;

type
  TFrmViewTranslator = class(TForm)
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

{$R *.dfm}

{ TFrmViewVCLTranslator }

procedure TFrmViewTranslator.AfterConstruction;
begin
  inherited;
  RetranslateUI;
end;

constructor TFrmViewTranslator.Create(AOwner: TComponent);
begin
  inherited;
  FMsgSubId := TMessageManager.DefaultManager.SubscribeToMessage(
    TDBoyI18nLanguageChangeMessage, OnLanguageChanged
  );
end;

destructor TFrmViewTranslator.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TDBoyI18nLanguageChangeMessage, FMsgSubId);
  inherited;
end;

procedure TFrmViewTranslator.OnLanguageChanged(const Sender: TObject;
  const M: TMessage);
begin
  if (M is TDBoyI18nLanguageChangeMessage) then
  begin
    lblLocale.Caption := (M as TDBoyI18nLanguageChangeMessage).Value;
    RetranslateUI;
  end;
end;

procedure TFrmViewTranslator.RetranslateUI;
begin
  TDBoyI18nEngine.Translate(Self);
  lblLocale.Caption := TDBoyI18nEngine.CurrentLocale;
end;

end.
