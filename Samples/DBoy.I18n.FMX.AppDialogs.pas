unit DBoy.I18n.FMX.AppDialogs;

interface

uses
  System.SysUtils, System.UITypes, System.Classes, FMX.Dialogs, FMX.DialogService.Sync;

type
  TAppDialog = class
  public
    class function MessageDlg(const AMessage: string; const DlgType: TMsgDlgType;
      const Buttons: TMsgDlgButtons; const DefaultButton: TMsgDlgBtn): TModalResult;
  end;

implementation

uses
  FMX.Consts;

class function TAppDialog.MessageDlg(const AMessage: string; const DlgType: TMsgDlgType;
  const Buttons: TMsgDlgButtons; const DefaultButton: TMsgDlgBtn): TModalResult;
var
  CustomCaptions: array[TMsgDlgBtn] of string;
begin
  // Carrega os textos já atualizados pelas resourcestrings hookadas
  // en: Loads the texts already updated by the hooked resource strings.
  CustomCaptions[TMsgDlgBtn.mbYes]      := SMsgDlgYes;
  CustomCaptions[TMsgDlgBtn.mbNo]       := SMsgDlgNo;
  CustomCaptions[TMsgDlgBtn.mbOK]       := SMsgDlgOK;
  CustomCaptions[TMsgDlgBtn.mbCancel]   := SMsgDlgCancel;
  CustomCaptions[TMsgDlgBtn.mbAbort]    := SMsgDlgAbort;
  CustomCaptions[TMsgDlgBtn.mbRetry]    := SMsgDlgRetry;
  CustomCaptions[TMsgDlgBtn.mbIgnore]   := SMsgDlgIgnore;
  CustomCaptions[TMsgDlgBtn.mbAll]      := SMsgDlgAll;
  CustomCaptions[TMsgDlgBtn.mbNoToAll]  := SMsgDlgNoToAll;
  CustomCaptions[TMsgDlgBtn.mbYesToAll] := SMsgDlgYesToAll;
  CustomCaptions[TMsgDlgBtn.mbHelp]     := SMsgDlgHelp;
  CustomCaptions[TMsgDlgBtn.mbClose]    := SMsgDlgClose;

  // Passa o array CustomCaptions para o DialogService, porém FMX não tem suporte
  // en: Pass the CustomCaptions array to the DialogService, but FMX is not supported.
  Result := TDialogServiceSync.MessageDialog(
    AMessage,
    DlgType,
    Buttons,
    DefaultButton,
    0{,
    CustomCaptions}
  );
end;

end.
