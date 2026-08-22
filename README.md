# DBoy.Delphi.I18n - Suporte a Internacionalização para Delphi (VCL e FMX)

O **DBoy.Delphi.I18n** é uma biblioteca moderna e unificada para internacionalização de aplicações Delphi. Ele suporta tanto o framework **VCL** (VCL Forms) quanto o **FMX** (FireMonkey), permitindo traduzir em tempo de execução formulários (**TForm**), frames (**TFrame**), módulos de dados (**TDataModule**), componentes visuais (via RTTI) e constantes de string (`resourcestring`) do próprio Delphi e de diálogos do sistema.

No Windows, a biblioteca realiza um patch de memória dinâmico (`VirtualProtect`) para substituir as `resourcestring` nativas da aplicação, fazendo com que diálogos padrão de sistema (`MessageDlg`, avisos, etc.) e strings globais passem a exibir a tradução carregada instantaneamente, sem necessidade de recompilar.

<table border="0" style="border-collapse: collapse; width: 100%;">
  <tr>
    <td style="padding: 8px;"><a href="https://github.com/Daniboy-Freelance-Developer/DBoy.Delphi.I18n/blob/main/Imagens/sample_fmx_br.png">
<img src="https://github.com/Daniboy-Freelance-Developer/DBoy.Delphi.I18n/blob/main/Imagens/sample_fmx_br.jpg" width="365" alt="Exemplo FMX Idioma pt_BR"></a>
</td>
    <td style="padding: 8px;"><a href="https://github.com/Daniboy-Freelance-Developer/DBoy.Delphi.I18n/blob/main/Imagens/sample_vcl_en.png">
<img src="https://github.com/Daniboy-Freelance-Developer/DBoy.Delphi.I18n/blob/main/Imagens/sample_vcl_en.jpg" width="365" alt="Exemplo VCL Idioma en_US"></a></td>
    <td style="padding: 8px;"><a href="https://github.com/Daniboy-Freelance-Developer/DBoy.Delphi.I18n/blob/main/Imagens/sample_fmx_zh.png">
<img src="https://github.com/Daniboy-Freelance-Developer/DBoy.Delphi.I18n/blob/main/Imagens/sample_fmx_zh.jpg" width="365" alt="Exemplo FMX Idioma zh_CN (Symbol UTF8)"></a></td>
  </tr>
</table>

---

## 🚀 Funcionalidades Principais

*   **Dual-Framework**: Compatibilidade 100% nativa com **VCL** e **FMX** (usando diretivas de compilação inteligentes).
*   **Hooking de Resource Strings**: Substituição segura de strings nativas e de terceiros em tempo de execução (somente Windows).
*   **Tradução Baseada em JSON**: Estrutura simples de arquivos JSON para definição dos idiomas.
*   **Tradução Automatizada por RTTI**: Varre dinamicamente a árvore de componentes visuais e não-visuais (Formulários, Frames e **DataModules**) traduzindo propriedades comuns (`Caption`, `Text`, `Hint`, `HelpText`) e permitindo registrar propriedades personalizadas sob demanda (como o `DisplayLabel` do `TField`).
*   **Extrator Automático**: Inspeciona as classes registradas do seu projeto e exporta um arquivo JSON de template limpo com todos os textos estáticos identificados.
*   **Menu Dinâmico de Idiomas**: Construtor automático de menus com suporte a ícones/bandeiras dinâmicas carregadas de arquivos locais.

---

## 📁 Estrutura de Arquivos JSON de Idioma

Os arquivos de idioma (por exemplo, `pt_BR.json`, `en_US.json`) contêm metadados sobre o idioma e as chaves estruturadas. Há uma seção reservada `General` para as `resourcestring` globais da aplicação e blocos específicos para cada classe de formulário/frame.

```json
{
  "locale": "en_US",
  "languageName": "English (United States)",
  "iconName": "flag_en_US",
  "translations": {
    "General": {
      "SMsgConfirmExit": "Do you really want to exit?",
      "SMsgSaveSuccess": "Record saved successfully!",
      "SMsgErrorDelete": "You do not have permission to delete this record.",
      "SBtnDelete": "Delete",
      "SBtnPost": "Save",
      "SMsgDlgWarning": "Warning",
      "SMsgDlgError": "Error",
      "SMsgDlgConfirm": "Confirm",
      "SMsgDlgYes": "&Yes",
      "SMsgDlgNo": "&No",
      "SMsgDlgOK": "OK",
      "SMsgDlgCancel": "Cancel"
    },
    "TFrmViewVCLMain": {
      "Caption": "Internationalization Support Demo",
      "GroupBoxMain.Caption": "Records List",
      "actNewEntity.Caption": "Add New Entity",
      "mItemApp.Caption": "&Application",
      "mItemClose.Caption": "Exit",
      "mItemLocale.Caption": "&Language"
    },
    "TFraEntity": {
      "lblEntity.Caption": "Entity name"
    }
  }
}
```

---

## 🛠️ Como Utilizar no Seu Projeto

### 1. Definir e Registrar Resource Strings
Crie uma unit centralizada para declarar as `resourcestring` de sua aplicação e registre-as no motor de tradução na seção de `initialization`:

```delphi
unit DBoy.I18n.ResourceStrings;

interface

resourcestring
  SMsgConfirmExit = 'Deseja realmente encerrar a aplicação?';
  SMsgSaveSuccess = 'Registro gravado com sucesso!';
  SMsgErrorDelete = 'Você não tem permissão de exclusão';
  SBtnDelete      = 'Excluir';
  SBtnPost        = 'Gravar';

implementation

uses
  DBoy.I18n.Engine;

initialization
  TDBoyI18nEngine.RegisterResString('SMsgConfirmExit', @SMsgConfirmExit);
  TDBoyI18nEngine.RegisterResString('SMsgSaveSuccess', @SMsgSaveSuccess);
  TDBoyI18nEngine.RegisterResString('SMsgErrorDelete', @SMsgErrorDelete);
  TDBoyI18nEngine.RegisterResString('SBtnDelete', @SBtnDelete);
  TDBoyI18nEngine.RegisterResString('SBtnPost', @SBtnPost);

end.
```

### 2. Implementar nos Formulários/Frames

#### Base de Tradução em VCL
Crie um formulário base ou herde diretamente no seu formulário o suporte para escutar o barramento global de notificações de alteração de idioma.

```delphi
unit MyProject.VCL.ViewTranslator;

interface

uses
  Vcl.Forms, System.Classes, System.Messaging, DBoy.I18n.Messages, DBoy.I18n.Engine;

type
  TFrmViewVCLTranslator = class(TForm)
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

constructor TFrmViewVCLTranslator.Create(AOwner: TComponent);
begin
  inherited;
  // Inscreve a janela no barramento do Delphi RTL para ouvir eventos de idioma
  FMsgSubId := TMessageManager.DefaultManager.SubscribeToMessage(
    TDBoyI18nLanguageChangeMessage, OnLanguageChanged
  );
end;

destructor TFrmViewVCLTranslator.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TDBoyI18nLanguageChangeMessage, FMsgSubId);
  inherited;
end;

procedure TFrmViewVCLTranslator.AfterConstruction;
begin
  inherited;
  RetranslateUI;
end;

procedure TFrmViewVCLTranslator.OnLanguageChanged(const Sender: TObject; const M: TMessage);
begin
  if (M is TDBoyI18nLanguageChangeMessage) then
    RetranslateUI;
end;

procedure TFrmViewVCLTranslator.RetranslateUI;
begin
  // Executa RTTI para traduzir labels, botões, painéis, menus, etc.
  TDBoyI18nEngine.Translate(Self);
end;

end.
```

#### Aplicação Inicial no Arquivo Principal (`.dpr`)
Carregue o arquivo de idioma no ponto de entrada do seu programa:

```delphi
program MyVCLApp;

uses
  Vcl.Forms,
  DBoy.I18n.Engine,
  MyProject.VCL.ViewMain in 'MyProject.VCL.ViewMain.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  
  // Carrega idioma padrão (Ex: pt_BR.json)
  TDBoyI18nEngine.LoadFromFile('Languages\pt_BR.json');
  
  Application.CreateForm(TFrmViewMain, FrmViewMain);
  Application.Run;
end.
```

---

## ⚡ Helpers e Utilitários

### 1. Inicializar o Menu de Idiomas Dinamicamente
Você pode apontar a biblioteca para uma pasta cheia de JSONs de tradução e ela irá criar as opções de menu (com rádio de marcação e suporte a ícones) automaticamente:

```delphi
procedure TFrmViewMain.FormCreate(Sender: TObject);
begin
  // Popula o menu de idiomas passando o TMenuItem pai (ex: mnuIdiomas)
  TDBoyI18nLanguageMenuBuilder.BuildLanguageMenu(mItemLocale);
end;
```

### 2. Carregar Ícones Dinamicamente
A unit `DBoy.I18n.ImageListLoader` permite povoar um `TImageList` dinamicamente varrendo arquivos de imagens locais (ex: bandeiras nos formatos PNG, ICO, BMP, JPG, SVG):

```delphi
procedure TFrmViewMain.FormCreate(Sender: TObject);
var
  IconsFolder: string;
begin
  IconsFolder := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Assets');
  TImageListLoader.LoadFromFolder(ImageList, IconsFolder, True);
end;
```

### 3. Registro de Propriedades Personalizadas (Ex: DisplayLabel de TField)
Por padrão, o motor de tradução por RTTI inspeciona as propriedades `Caption`, `Text`, `Hint` e `HelpText`. Caso seu projeto necessite traduzir outras propriedades (como o título de colunas `DisplayLabel` em campos de datasets `TField`), você pode registrá-las dinamicamente antes de executar a tradução dos componentes:

```delphi
procedure TFrmViewMain.FormCreate(Sender: TObject);
begin
  inherited;
  // Registra 'DisplayLabel' como uma propriedade traduzível por RTTI
  TDBoyI18nEngine.RegisterTranslatableProperty('DisplayLabel');
  
  // Agora, qualquer TField dentro de seus formulários ou DataModules terá
  // seu DisplayLabel traduzido se a chave correspondente constar no JSON!
end;
```

---

## 🧪 Geração de Templates Automáticos (Testes Unitários/Extractor)

A biblioteca inclui o `TI18nExtractor` para poupar tempo de desenvolvimento. Registre os seus Forms, Frames e DataModule e exporte um JSON completo com todos os componentes traduzíveis:

```delphi
procedure GenerateBaseLanguageTemplate;
var
  OutputFile: string;
begin
  // 1. Registra os forms/frames a serem inspecionados
  TI18nExtractor.RegisterClasses([
    TFrmViewMain,
    TFraEntity,
    TDMData
  ]);

  OutputFile := 'Languages\template_extracted.json';

  // 2. Exporta o JSON base completo contendo todos os textos localizáveis
  TI18nExtractor.ExportToFile(OutputFile, 'pt_BR', 'Português (Brasil)');
end;
```

---

## ⚙️ Configuração no Projeto (`.dproj`)

Para garantir que a biblioteca use as declarações de VCL ou FMX corretas, o arquivo `.dproj` de seu projeto VCL deve conter o símbolo `VCL` em suas diretivas de compilação:

```xml
<DCC_Define>VCL;$(DCC_Define)</DCC_Define>
```

Se compilando um projeto FMX, a biblioteca assume FMX como padrão ou pode ser declarada opcionalmente sem o símbolo `VCL`.
