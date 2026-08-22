unit DBoy.I18n.Messages;

interface

uses
  Winapi.Messages, Winapi.Windows, System.Messaging;

type

  /// <summary>
  ///  Mensagem usada para anunciar uma mudança de idioma/localidade no projeto com RTL sistema de mensagens.
  ///  en: Message used to broadcast a locale/language change in the project with the RTL messaging system.
  /// </summary>
  TDBoyI18nLanguageChangeMessage = class(tmessage<string>)
  end;

  /// <summary>
  ///  Execute a transmissão de uma alteração de idioma/localidade no projeto usando o sistema de mensagens RTL.
  ///  en: Execute broadcast a locale/language change in the project with the RTL messaging system.
  /// </summary>
  procedure BroadcastLanguageChange(const ALocale: string);

implementation

uses
  System.Classes;

procedure BroadcastLanguageChange(const ALocale: string);
var
  LLocale: string;
begin
  LLocale := ALocale;

  tthread.queue(nil,
    procedure
    begin
      TMessageManager.DefaultManager.SendMessage(nil,
        TDBoyI18nLanguageChangeMessage.Create(LLocale));
    end);
end;

end.
