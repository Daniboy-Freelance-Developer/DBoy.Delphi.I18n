unit DBoy.I18n.FMX.NativeConsts;

interface

uses
  FMX.Consts, DBoy.I18n.Engine;

implementation

initialization
  // Títulos dos Diálogos FMX
  // en: FMX Dialog Titles
  TDBoyI18nEngine.RegisterResString('SMsgDlgWarning',      @SMsgDlgWarning);
  TDBoyI18nEngine.RegisterResString('SMsgDlgError',        @SMsgDlgError);
  TDBoyI18nEngine.RegisterResString('SMsgDlgInformation',  @SMsgDlgInformation);
  TDBoyI18nEngine.RegisterResString('SMsgDlgConfirm',      @SMsgDlgConfirm);

  // Botões dos Diálogos FMX
  // en: FMX Dialog Buttons
  TDBoyI18nEngine.RegisterResString('SMsgDlgYes',          @SMsgDlgYes);
  TDBoyI18nEngine.RegisterResString('SMsgDlgNo',           @SMsgDlgNo);
  TDBoyI18nEngine.RegisterResString('SMsgDlgOK',           @SMsgDlgOK);
  TDBoyI18nEngine.RegisterResString('SMsgDlgCancel',       @SMsgDlgCancel);
  TDBoyI18nEngine.RegisterResString('SMsgDlgHelp',         @SMsgDlgHelp);
  TDBoyI18nEngine.RegisterResString('SMsgDlgAbort',        @SMsgDlgAbort);
  TDBoyI18nEngine.RegisterResString('SMsgDlgRetry',        @SMsgDlgRetry);
  TDBoyI18nEngine.RegisterResString('SMsgDlgIgnore',       @SMsgDlgIgnore);
  TDBoyI18nEngine.RegisterResString('SMsgDlgAll',          @SMsgDlgAll);
  TDBoyI18nEngine.RegisterResString('SMsgDlgNoToAll',      @SMsgDlgNoToAll);
  TDBoyI18nEngine.RegisterResString('SMsgDlgYesToAll',     @SMsgDlgYesToAll);
  TDBoyI18nEngine.RegisterResString('SMsgDlgClose',        @SMsgDlgClose);

end.
