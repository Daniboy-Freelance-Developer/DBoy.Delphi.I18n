program DBoy.I18n.FMX.Tests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  DBoy.I18n.Engine in '..\Source\DBoy.I18n.Engine.pas',
  DBoy.I18n.Extractor in '..\Source\DBoy.I18n.Extractor.pas',
  DBoy.I18n.ImageListLoader in '..\Source\DBoy.I18n.ImageListLoader.pas',
  DBoy.I18n.LanguageMenu in '..\Source\DBoy.I18n.LanguageMenu.pas',
  DBoy.I18n.GlobalTests in '..\Source\DBoy.I18n.GlobalTests.pas',
  DBoy.I18n.Messages in '..\Source\DBoy.I18n.Messages.pas',
  DBoy.I18n.FMX.AppDialogs in '..\Samples\DBoy.I18n.FMX.AppDialogs.pas',
  DBoy.I18n.FMX.FraEntity in '..\Samples\DBoy.I18n.FMX.FraEntity.pas' {FraEntity: TFrame},
  DBoy.I18n.FMX.FraTranslator in '..\Samples\DBoy.I18n.FMX.FraTranslator.pas' {FraTranslator: TFrame},
  DBoy.I18n.FMX.ImageListLoader in '..\Samples\DBoy.I18n.FMX.ImageListLoader.pas',
  DBoy.I18n.FMX.NativeConsts in '..\Samples\DBoy.I18n.FMX.NativeConsts.pas',
  DBoy.I18n.FMX.ViewMain in '..\Samples\DBoy.I18n.FMX.ViewMain.pas' {FrmViewMain},
  DBoy.I18n.FMX.ViewTranslator in '..\Samples\DBoy.I18n.FMX.ViewTranslator.pas' {FrmViewFMXTranslator},
  DBoy.I18n.ResourceStrings in '..\Samples\DBoy.I18n.ResourceStrings.pas',
  DBoy.I18n.FMX.DMData in '..\Samples\DBoy.I18n.FMX.DMData.pas' {DMData: TDataModule},
  DBoy.I18n.FMX.DMTranslator in '..\Samples\DBoy.I18n.FMX.DMTranslator.pas' {DMTranslator: TDataModule},
  DBoy.I18n.Extractor.Tests in 'DBoy.I18n.Extractor.Tests.pas',
  DBoy.I18n.Extractor.FMX.Tests in 'DBoy.I18n.Extractor.FMX.Tests.pas';

{ keep comment here to protect the following conditional from being removed by the IDE when adding a unit }
{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  TDBoyI18nEngine.RegisterTranslatableProperty('DisplayLabel');
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
