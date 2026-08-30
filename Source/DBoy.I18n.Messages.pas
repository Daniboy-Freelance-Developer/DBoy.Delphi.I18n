unit DBoy.I18n.Messages;

interface

uses
  Winapi.Messages, Winapi.Windows, System.Messaging;

type

  /// <summary>
  ///  Mensagem usada para anunciar uma mudança de idioma/localidade no projeto com RTL sistema de mensagens.
  ///  en: Message used to broadcast a locale/language change in the project with the RTL messaging system.
  /// </summary>
  TDBoyI18nLanguageChangeMessage = class(TMessage<string>)
  end;

  /// <summary>
  ///  Execute a transmissão de uma alteração de idioma/localidade no projeto usando o sistema de mensagens RTL.
  ///  en: Execute broadcast a locale/language change in the project with the RTL messaging system.
  /// </summary>
  procedure BroadcastLanguageChange(const ALocale: string);

implementation

uses
  System.Classes, System.SysUtils;

procedure BroadcastLanguageChange(const ALocale: string);
var
  LLocale: string;
  LProc: TThreadProcedure;
begin
  LLocale := ALocale;
  LProc :=
    procedure
    begin
      TMessageManager.DefaultManager.SendMessage(nil,
        TDBoyI18nLanguageChangeMessage.Create(LLocale));
    end;
  TThread.Queue(nil, LProc);
end;

end.