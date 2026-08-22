unit DBoy.I18n.FMX.FraEntity;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Edit, FMX.Controls.Presentation, DBoy.I18n.FMX.ViewTranslator,
  DBoy.I18n.FMX.FraTranslator;

type
  TFraEntity = class(TFraTranslator)
    lblEntity: TLabel;
    edtEntity: TEdit;
    btnDelete: TButton;
    LayoutMain: TLayout;
    btnPost: TButton;
    procedure btnDeleteClick(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure RetranslateUI; override;
  public
    { Public declarations }
  end;

implementation

uses DBoy.I18n.ResourceStrings;

{$R *.fmx}

procedure TFraEntity.btnDeleteClick(Sender: TObject);
begin
  raise Exception.Create(SMsgErrorDelete);
end;

procedure TFraEntity.RetranslateUI;
begin
  inherited;
  btnPost.Text := SBtnPost;
  btnDelete.Text := SBtnDelete;
end;

end.
