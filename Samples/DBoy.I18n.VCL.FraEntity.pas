unit DBoy.I18n.VCL.FraEntity;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  DBoy.I18n.VCL.FraTranslator;

type
  TFraEntity = class(TFraTranslator)
    lblEntity: TLabel;
    edtEntity: TEdit;
    btnPost: TButton;
    btnDelete: TButton;
    procedure btnDeleteClick(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure RetranslateUI; override;
  public
    { Public declarations }
  end;

implementation

uses
  DBoy.I18n.ResourceStrings;


{$R *.dfm}

procedure TFraEntity.btnDeleteClick(Sender: TObject);
begin
  raise Exception.Create(SMsgErrorDelete);
end;

procedure TFraEntity.RetranslateUI;
begin
  inherited;
  btnPost.Caption := SBtnPost;
  btnDelete.Caption := SBtnDelete;
end;

end.
