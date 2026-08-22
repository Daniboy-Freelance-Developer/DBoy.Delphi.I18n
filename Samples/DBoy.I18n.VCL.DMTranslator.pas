unit DBoy.I18n.VCL.DMTranslator;

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

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDMTranslator }

procedure TDMTranslator.AfterConstruction;
begin
  inherited;
  RetranslateUI;
end;

constructor TDMTranslator.Create(AOwner: TComponent);
begin
  inherited;
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
