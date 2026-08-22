unit DBoy.I18n.VCL.AppDialogs;

interface

uses
  System.SysUtils, System.UITypes, System.Classes, Vcl.Dialogs;

type
  TAppDialog = class
  public
    class function MessageDlg(const AMessage: string; const DlgType: TMsgDlgType;
      const Buttons: TMsgDlgButtons; const DefaultButton: TMsgDlgBtn): TModalResult;
  end;

implementation

class function TAppDialog.MessageDlg(const AMessage: string; const DlgType: TMsgDlgType;
  const Buttons: TMsgDlgButtons; const DefaultButton: TMsgDlgBtn): TModalResult;
begin
  Result := Vcl.Dialogs.MessageDlg(AMessage, DlgType, Buttons, 0, DefaultButton);
end;

end.
