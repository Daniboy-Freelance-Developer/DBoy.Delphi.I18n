unit DBoy.I18n.ResourceStrings;

interface

resourcestring
  SMsgConfirmExit = 'SMsgConfirmExit';
  SMsgSaveSuccess = 'SMsgSaveSuccess';
  SMsgErrorDelete = 'SMsgErrorDelete';

  SBtnDelete = 'SBtnDelete';
  SBtnPost = 'SBtnPost';

implementation

uses
  DBoy.I18n.Engine;

initialization
  // Mapeia o identificador do JSON para o ponteiro da resourcestring
  // en: Maps the JSON identifier to the resourcestring pointer
  TDBoyI18nEngine.RegisterResString('SMsgConfirmExit', @SMsgConfirmExit);
  TDBoyI18nEngine.RegisterResString('SMsgSaveSuccess', @SMsgSaveSuccess);
  TDBoyI18nEngine.RegisterResString('SMsgErrorDelete', @SMsgErrorDelete);

  TDBoyI18nEngine.RegisterResString('SBtnDelete', @SBtnDelete);
  TDBoyI18nEngine.RegisterResString('SBtnPost', @SBtnPost);

end.
